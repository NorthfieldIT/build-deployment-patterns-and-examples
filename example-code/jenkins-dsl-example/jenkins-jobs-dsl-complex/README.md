# jenkins-jobs-dsl-complex
This is a stripped down version of our actual Jenkins DSL code ... but it's pretty close. The inspiration for this code base is the following article http://marcesher.com/2016/06/13/jenkins-as-code-creating-reusable-builders/ . The API documentation for your jenkins install is at https://YOUR_JENKINS_URL/plugin/job-dsl/api-viewer/index.html .

# How does this work?
Our core Jenkins DSL job will call into our fabfile.py script. This will query our Github Enterprise API looking for a "jobs.groovy" file in a specific directory. This File will be used to indicate the jobs it should be setup and small configuration changes. It will also collect the `app_name` from the config.yml file and the repo location. It will take all this content and inject it into the `jobs_new.groovy` file and replace the "REPLACE_ME" portion with all the job configuration information.

The contents of the repo `jobs.groovy` will be extremely small. As an example a java app would have

```groovy
new AppJobs(
        addDeployToStg: false
).build()
```

This would tell the DSL to setup all the jobs for a typical Java application but leave out the Deploy to STG job. For Chef repos we would have something like the following.

```groovy
new ChefJobs().build()
```

Which basically it's telling it to create the typical jobs for jenkins. The output of the final groovy DSL would look something like the following:


```groovy
import static groovy.json.JsonOutput.*

Globals.DSL_FACTORY = this
Globals.JOBDSL_OUT = out


Globals.APP_NAME = 'some_java_app'
Globals.GITHUB_REPO = 'github_org/app_repo'
new AppJobs(
        addDeployToStg: false
).build()


Globals.APP_NAME = 'some_chef_recipe'
Globals.GITHUB_REPO = 'github_org/chef_repo'
new ChefJobs().build()


ViewBuilder.build()

```


Jenkins would then consume this file to produce all the require jobs. This means we can standup a repo and throw in a few definition files for buildscript and jenkins jobs and we can bring up an entire build and deployment pipeline. We also have each collection of jobs register themselves to a "ViewBuilder". This will collect all the relevant list of jobs to automatically build deployment pipeline views with the following plugin. https://wiki.jenkins-ci.org/display/JENKINS/Delivery+Pipeline+Plugin

# Why are you doing XYZ that way?
So there are some ugly bits. The "GLOBALS" that get set on each round for each repo was a hack way to pass in various config values to the underlying DSL. We wanted the ability to define additional job configuration in the repo `jobs.groovy` file so we couldn't not make any assumptions on the content. Totally hacky but gave us access to the data for each repo.

You maybe asking why "fabric" as the initial script ... no particular reason. It could have been written in ruby....
