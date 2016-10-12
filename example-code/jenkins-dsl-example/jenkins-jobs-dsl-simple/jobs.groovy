
BuildFramework.setupConfirmApp(this, 'delivery-presentation', 'northfield-scripts', 'example-code/Nortfield.Scripts')
BuildFramework.setupDeployableApp(this, 'delivery-presentation', 'random-jenkins', 'example-code/random-jenkins-chef-recipe')


class BuildFramework {
    static buildJob(dslFactory, repo, app_name, workingDir) {
        dslFactory.freeStyleJob("${app_name}_1_Build_and_Test") {
            scm {
                git {
                    remote {
                        url("https://github.com/NorthfieldIT/${repo}.git")
                        branch('master')
                    }
                }
            }
            wrappers {
                preBuildCleanup {}
                ansiColorBuildWrapper {
                    colorMapName('xterm')
                    defaultFg(1)
                    defaultBg(2)
                }
            }
            triggers {
                scm('H/2 * * * *')
            }
            steps {
                shell("""
cd ${workingDir}
bundle install
rake northfield_build
""")
            }
        }
    }

    static buildAndDeployJob(dslFactory, repo, app_name, workingDir) {
        dslFactory.freeStyleJob("${app_name}_1_Build_Test_And_Deploy") {
            scm {
                git {
                    remote {
                        url("https://github.com/NorthfieldIT/${repo}.git")
                        branch('master')
                    }
                }
            }
            wrappers {
                preBuildCleanup {}
                ansiColorBuildWrapper {
                    colorMapName('xterm')
                    defaultFg(1)
                    defaultBg(2)
                }
            }
            triggers {
                scm('H/2 * * * *')
            }
            steps {
                shell("""
cd ${workingDir}
bundle install
rake northfield_build
rake northfield_deploy
""")
            }
        }
    }

    static pullRequestJob(dslFactory, repo, app_name, workingDir) {
        dslFactory.job("${app_name}_0_Build_and_Test_PR") {
            scm {
                git {
                    remote {
                        github("NorthfieldIT/${repo}")
                        url("https://github.com/NorthfieldIT/${repo}.git")
                        refspec('+refs/pull/*:refs/remotes/origin/pr/*')
                    }
                    branch('${sha1}')
                }
            }

            triggers {
                githubPullRequest {
                    orgWhitelist('NorthfieldIT')
                    cron('* * * * *')
                    onlyTriggerPhrase(false)
                    useGitHubHooks(false)
                    permitAll()
                    autoCloseFailedPullRequests(false)
                    displayBuildErrorsOnDownstreamBuilds(false)
                    whiteListTargetBranches(['master'])
                    allowMembersOfWhitelistedOrgsAsAdmin()
                }
            }
            steps {
                shell("""
cd ${workingDir}
bundle install
rake northfield_build
""")
            }
            publishers {
                mergeGithubPullRequest {
                    onlyAdminsMerge()
                    disallowOwnCode(false)
                    failOnNonMerge()
                    deleteOnMerge(false)
                }
            }
        }
    }


    static setupDeployableApp(dslFactory, repo, app_name, workingDir) {
        buildAndDeployJob(dslFactory, repo, app_name, workingDir)
        pullRequestJob(dslFactory, repo, app_name, workingDir)
    }

    static setupConfirmApp(dslFactory, repo, app_name, workingDir) {
        buildJob(dslFactory, repo, app_name, workingDir)
        pullRequestJob(dslFactory, repo, app_name, workingDir)
    }
}

