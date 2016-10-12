class ChefJobs extends BaseBuildFramework {
    void build() {
        this.addDeployToStg = false
        this.addDeployToPrd = true

        if (addBuildAndTest) buildAndTest(Globals.DSL_FACTORY)
        if (addDeployToPrd) deployToPrd(Globals.DSL_FACTORY)
    }

    GString getDeployToPRDJobName() { return "${this.appName}_3_Upload_to_ChefServer"; }
}
