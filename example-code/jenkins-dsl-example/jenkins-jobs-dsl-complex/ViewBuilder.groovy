class ViewBuilder {
    static HashMap<String,HashMap> viewMap = new LinkedHashMap<String,HashMap>()


    static register(tab, appName, pipelineName, jobName)
    {

        Globals.JOBDSL_OUT.println "[INFO] Attempting to register app ${appName} with pipeline ${pipelineName} on the ${tab} view."

        if(!viewMap.containsKey(tab)) {
            viewMap.put(tab,new LinkedHashMap<String,HashMap>())
        }
        if(!viewMap.get(tab).containsKey(appName)) {
            viewMap.get(tab).put(appName,new LinkedHashMap<String,HashMap>())
        }
        if(viewMap.get(tab).get(appName).containsKey(pipelineName)) {
            throw new Exception("The app ${appName} already has a pipeline ${pipelineName} on the ${tab} view.")
        }

        viewMap.get(tab).get(appName).put(pipelineName, jobName)
    }

    static build() {

        def viewMapKeys = viewMap.keySet().toArray()
        for (int viewMapKeyIndex = 0; viewMapKeyIndex < viewMapKeys.size(); viewMapKeyIndex++) {
            def tabName = viewMapKeys[viewMapKeyIndex]
            def apps = viewMap.get(tabName)
            Globals.DSL_FACTORY.nestedView("${tabName}") {
                views {
                    def appKeys = apps.keySet().toArray()
                    for (int appKeyIndex = 0; appKeyIndex < appKeys.size(); appKeyIndex++) {
                        def appName = appKeys[appKeyIndex]
                        def jobPipelines = apps.get(appName)
                        deliveryPipelineView("${appName}") {
                            allowPipelineStart(true)
                            allowRebuild(true)
                            // Sets the number of columns used for showing pipelines.
                            columns(1)
                            enableManualTriggers(true)
                            pipelineInstances(1)
                            pipelines {
                                def jobPipelineKeys = jobPipelines.keySet().toArray()
                                for (int jobPipelineKeyIndex = 0; jobPipelineKeyIndex < jobPipelineKeys.size(); jobPipelineKeyIndex++) {
                                    def pipelineName = jobPipelineKeys[jobPipelineKeyIndex]
                                    def job = jobPipelines.get(pipelineName)
                                    component("${pipelineName}", "${job}")
                                }
                            }
                            showAggregatedPipeline(true)
                            showAvatars(false)
                            showChangeLog(false)
                            showDescription(false)
                            showPromotions(false)
                            showTotalBuildTime(false)
                            updateInterval(2)
                        }
                    }
                }
            }
        }
    }
}
