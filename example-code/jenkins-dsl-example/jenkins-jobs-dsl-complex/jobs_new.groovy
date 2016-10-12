import static groovy.json.JsonOutput.*

Globals.DSL_FACTORY = this
Globals.JOBDSL_OUT = out


REPLACE_ME


ViewBuilder.build()


// why is this here? Well because http://jenkins-ci.361315.n4.nabble.com/High-Memory-Usage-with-Job-DSL-td4756057.html
Globals.DSL_FACTORY = null
Globals.JOBDSL_OUT = null
Globals.APP_NAME = null
Globals.GITHUB_REPO = null
ViewBuilder.viewMap = null
System.gc()
