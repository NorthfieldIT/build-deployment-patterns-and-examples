class BaseBuildFramework {
    String appName = Globals.APP_NAME
    String githubRepo = Globals.GITHUB_REPO
    String authToken = Globals.APP_NAME
    String view_tab = Globals.CORE_VIEW


    Boolean addBuildAndTest = true
    Boolean addDeployToStg = true
    Boolean addDeployToPrd = true



    void build() {
    }


    void buildAndTest(dslFactory) {
        dslFactory.freeStyleJob("${this.getBuildAndTestJobName()}") {
            properties {
                githubProjectUrl("https://ENTERPRISE_GITHUB_URL/${this.githubRepo}/")
            }
            logRotator(-1, 30, -1, 5)
            concurrentBuild()
            scm {
                git {
                    remote {
                        url("git@ENTERPRISE_GITHUB_URL:${this.githubRepo}.git")
                        credentials('CREDENTIALS_ID')
                        branch('master')
                    }
                }
            }
            triggers {
                githubPush()
            }
            wrappers {
                buildUserVars()
                preBuildCleanup {}
                ansiColorBuildWrapper {
                    colorMapName('xterm')
                    defaultFg(1)
                    defaultBg(2)
                }
                deliveryPipelineVersion('${GIT_REVISION, length=7}', true)
                sshAgent('SSH_CREDENTIALS_ID')
            }

            steps {
                shell('rake northfield_build')
            }

            publishers {
                archiveArtifacts('archive.tar.gz')
                archiveJunit('build/test-results/**/*.xml')
                wsCleanup()
            }
        }
    }

    void deployToStg(dslFactory) {
        dslFactory.freeStyleJob("${this.getDeployToSTGJobName()}") {
            logRotator(-1, 15, -1, -1)
            concurrentBuild()

            wrappers {
                preBuildCleanup {}
                buildUserVars()
                ansiColorBuildWrapper {
                    colorMapName('xterm')
                    defaultFg(1)
                    defaultBg(2)
                }
                buildName('${ENV,var="PIPELINE_VERSION"}')
                sshAgent('SSH_CREDENTIAL_ID')
            }

            triggers {
                upstream("${this.getBuildAndTestJobName()}", 'SUCCESS')
            }

            steps {
                copyArtifacts("${this.getBuildAndTestJobName()}") {
                    buildSelector {
                        latestSuccessful(true)
                    }
                }
                shell('gzip -dc archive.tar.gz | tar xf -')
                shell('rm archive.tar.gz')
                shell('rake northfield_deploy')
            }

            publishers {
                wsCleanup()
            }
        }
    }

    void deployToPrd(dslFactory) {
        dslFactory.freeStyleJob("${this.getDeployToPRDJobName()}") {
            logRotator(-1, -1, -1, 5)
            concurrentBuild()

            wrappers {
                preBuildCleanup {}
                buildUserVars()
                ansiColorBuildWrapper {
                    colorMapName('xterm')
                    defaultFg(1)
                    defaultBg(2)
                }
                buildName('${ENV,var="PIPELINE_VERSION"}')
                sshAgent('SSH_CREDENTIAL_ID')
            }

            steps {
                copyArtifacts("${this.getBuildAndTestJobName()}") {
                    buildSelector {
                        latestSuccessful(true)
                    }
                }
                shell('gzip -dc archive.tar.gz | tar xf -')
                shell('rm archive.tar.gz')
                shell('rake northfield_deploy')
            }

            publishers {
                archiveArtifacts('archive.tar.gz')
                wsCleanup()
            }
        }
    }



    GString getBuildAndTestJobName() { return "${this.appName}_1_Build_and_Test"; }

    GString getBuildTestAndDeployToMavenJobName() { return "${this.appName}_1_Build_Test_and_Deploy_To_Maven"; }

    GString getDeployToSTGJobName() { return "${this.appName}_3_Deploy_to_STG"; }

    GString getDeployToPRDJobName() { return "${this.appName}_3_Deploy_to_PRD"; }
}
