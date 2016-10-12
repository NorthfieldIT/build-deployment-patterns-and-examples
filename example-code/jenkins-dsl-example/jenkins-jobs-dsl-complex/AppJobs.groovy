class AppJobs extends BaseBuildFramework {
    void build() {
        if (addBuildAndTest) buildAndTest(Globals.DSL_FACTORY)
        if (addDeployToStg) deployToStg(Globals.DSL_FACTORY)
        if (addDeployToPrd) deployToPrd(Globals.DSL_FACTORY)

        if (addBuildAndTest) ViewBuilder.register(view_tab, appName, appName, getBuildAndTestJobName())
    }
}