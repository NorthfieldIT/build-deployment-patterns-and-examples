# Building Scalable Build and Deployment Pipelines.
Build and Deployment Pipelines are not a sexy subject within our industry. It's often an afterthought relegated to the last minute and cobbled together. It's also extremely hard to find resources from people who've been in the trenches and seen what has worked and what hasn't. This article is an attempt at sharing the knowledge I have from building Build and Deployment Pipelines that have deployed applications that served billions of requests daily.

You may not agree with everything that is documented here and that's ok! If you are going to deviate, deviate with purpose!

# Common Patterns

## Build and Deployment Pipeline Driven Development
Strive for being able to stand up a build pipeline on Day 0 of a codebase. This can greatly influence the application in a positive fashion. It's now trivial to push code out to key stakeholders etc. to get feedback. It also makes the entire development lifecycle much more transparent as anyone can go and review the latest working version. It will also force conversation around application architecture and infrastructure as teams will want to keep their high velocity deploys. Anything impeding that velocity will naturally force a conversation to occur.

## Build and Deployment == Process Automation
Build and deployments are a replacement, enabler or compliment to your current process. Try to think "we are automating our process" and not "I need to have a job that does XYZ".

## Approach With Empathy
We should approach our solutions with empathy towards our peers. Truly believe that every employee that comes into work wants to do their best. Understanding this will aid us in picking correct solutions.

### Example pattern implementation
One of the core elements when designing build and deployment pipelines is ensuring that the application builds! We want our build systems to give feedback and indicate whether or not changes have caused the code base to be unbuildable. What should we do if we find that the build is showing "red" more often than not? The naive solution would be to implement a leaderboard of "Build Breakers" and shame our peers into quality control. Or we can approach the problem with empathy and understand people want to do their best. We just need to give that feedback earlier!

An option would be to run builds against submitted code reviews. This would give feedback earlier on and lead people towards better quality without affecting others. You could extend that easily and do long running code reviews that give feedback on each iteration. We can push that even further and provide incremental builds and feedback loops locally with file watchers that build and test as the code changes.

## Make The Right Path (for your organization), The Easy Path
have you ever heard "If it was easy, it would just be called the way"? In this case, we can make that happen. Many Organizations have the right intentions but bury the “Right Way” under layers of documentation or red tape. Why not make it easy to do the right thing? You can even double down on this concept by providing a high amount of value upfront so that choosing the "Right Way" just makes sense.

Note that the "Right Way" may look different to each organization. You may have technical debt, technology restrictions or even compliance requirements that may change what the “Right Way” looks to you.

### Example pattern implementation
We are primarily a Gradle Spring Boot Java shop. We attempt to provide as much value upfront so that our teams continue to pick Gradle Spring Boot as their choice. We provide a menu of currently supported tech stacks for teams to select from, which Gradle Spring Boot is part of. They can “instantly” get infrastructure resources and full “go to production” pipelines if they choose Gradle Spring Boot from the menu. We also provide a Java libraries and Gradle plugins that will automatically hook into our Consul cluster (app configs) to make configuration ultra simple. Lastly, we provide a starter repo that has everything already laid out so that you can start slinging code without having to put up any initial repo scaffolding. At this point, not picking “The Right Way” seems like insanity.

Lastly we also provided a repo of vagrant files to additional resources like Redis and MySQL that pushes teams to pick items that we already support.


## Convention Over Configuration (with the option to configure)
Figure out some conventions and attempt to extend those conventions across as many areas of your build and deployment pipeline. Following Convention over Configuration typically will lead you to solutions that are simpler overall. Not only that, but it will help with scaling up when rolling out more and more pipelines. It will be hard to keep up and scale if you are forced to configure and plumb every single application that comes up. That being said, do leave yourself the option to configure things when needed.

The Convention can also become a "source of truth" to reason about your systems at a high level. Single Pane of Glass source of truth can be costly to develop. The other option is getting an off the shelf solution that typically requires configuration and tweaking to get it working perfectly for your organization. Worse yet, you may write piles of documentation to document your environments which become lies at the point that they are written.


Convention over Configuration can also help with teams picking the “Right Way”. Your convention may allow you to make many assumptions about the application and automatically plumb things like alerting, monitoring and logs! Another value add on day one.

### Example pattern implementation
By convention we expect an application name in a configuration file in every application repo. We use that application name in our logging, in our application monitoring, to name our infrastructure and even our deploy pipelines. This means you can take this app name from any context and use it in other contexts to reason about a system. As an example you could be logged into a random box and take the box name (dc1APP_NAME_HERE01.yourdomain.com) and pull the application name from it, and then use it to search logs or application monitoring tools. You can then use that application name to search code repositories (we use Github Enterprise) to the find the specific code repo that owns the code that is running on that box. You can then figure out the specific deploy pipeline that will deploy the code repo that your looking at as it uses that app name as well.

Defining an application name within a repo will also allow us to have a completely safe rolling restart deployment right into production. We take the app name and are able to figure out the load balancer pool that fronts the application. We will then pull out each node from that pool, safely shut the application down, deploy the app, start the application (the init script is based off the app name), bring it up healthy and put it back into the pool. Our init scripts are using the OS's services to start and stop the application gracefully. The OS init script is also extremely light as we package our apps as fat jars with Spring Boot.


## Build Once, Deploy Many
Build app and deploy it to any and all environments. The application should not be concerned or direct knowledge of the environment it runs in. The only indication of environment should be purely by the configurations provided to the application from the environment itself.

At a base level this is about quality control. Just like a factory, the item should move from location to location being poked and prodded to validate its quality. Can we really trust the feedback the validation gives If we need to rebuild the application artifact to run validation steps?

### Example implementation
You can achieve this by using an artifact repository to store the build artifacts and it's supporting items so that it can be used at every step. We keep this simple by zipping up the core workspace from the build and using that zip in subsequent steps. We have additional optimizations where we zip only whats required. Those artifacts are then unzipped and validated with whatever makes sense.

Convention Over Configuration supports this pattern as well. Since all our apps follow a similar tech stack and repo setup, we can make certain assumptions about our artifact. We know where the resulting fat jar is located and its supporting files. We can drop the rest of the files on the floor after the initial build and validation steps.

We also use Consul to store all of our application configs. This means that the application doesn’t need to ship with its configurations. It can grab those configurations from Consul at runtime.


## Common Build Validation
Your build and validation methods should give you quick validation (within reason) and give you a high enough degree of confidence to say "yes this can go to prod!". Anything over a 10 minute validation loop becomes a burden and the value of that feedback starts to drop. Not only that but it affects your MTTR (Mean Time To Recovery). You want to be able to have a high level of confidence in a short enough amount of time to fix production issues as they arise.

This quick feedback loop means you can run it more often and closer to the developer. That build validation can be run at their local machine as an extremely tight feedback loop. Teams will strive to keep that tight feedback loop once it’s been established. They will then invest more and more into tests that are not only quick, but test more and more of the stack while providing less false positives.

Striving for common validation loop at any point in the development lifecycle also leads you to higher software quality. It becomes more and more painful if your feedback loop at the pre-code review stage says one thing and as it gets closer to production it says another thing. Finding bugs earlier in the process means less time wasted trying to fix and validate at a later stage.

## Low Config Build Systems
Have your build systems run like dumb workers. It should not have much knowledge on what it's building. It should clone a repo and essentially "run build" and then "run deploy". The code should contain all it needs to do it's build validation and then do its own deploy. This will then allow you to essentially copy/paste your build and deployment pipelines as new apps come up. You can also roll out build system wide updates without worrying about breaking random jobs. The only things that should make your jobs unique is the names of the jobs and the source repository that it gets the code from, anything after that is a build and deployment smell.

This pattern also gives you some nice side benefits. You can change and upgrade an app’s actual build steps without requiring migration steps or stopping workflow. Each commit will know how to build and deploy itself and therefore you can incrementally update the build and deployment process. New commits in a PR will require a mysql DB? No problem! Add the build steps with the code change and no one is affected.

### Pattern implementation
Build in-house build and deployment scripts or use community built scripts. I personally believe that everyone's environment is unique enough that it will require some unique steps and configuration. In some cases it's best to try and use what the community has built and layer on top of that base. As an example, Capistrano has many built in best case scenario configs that you should probably follow. If you want to build your own internal scripts, you can start with something as simple as some shell scripts.

At a base level you should follow some sort of command pattern. Your build system should call into the repo and say "do build" and the scripts will know what to do. Essentially the “do build” command will be an alias to the underlying individual steps. This is also supported by Convention over Configuration as your build system can make certain assumptions that the build scripts will be present in that repo.

You may want to invest in a scripting language that has a good package manager if you are going to be rolling out many build and deploy pipelines. This will allow you to scale up and roll out changes to all of your pipelines. The code should point to your common commands and then pull down the actual implementation scripts from whatever package manager you have chosen. You can then version pin your build and deployment scripts. I typically only pin on major version and attempt to follow semantic versioning as close as possible. This allows me to push out new scripts that all pipelines will pick up. Even if something broken gets pushed in the scripts, I can quickly deploy a new version.

Also think about injecting start and end shims into those core alias steps. Something like a "build_init" and "build_end" alias step that will be managed by your core build and deployment scripts and are included in every repo's core "build" alias definition. This will allow you to roll inject common steps into all application build and deployment pipelines without updating ever single repo.

* [Here](https://github.com/NorthfieldIT/build-deployment-patterns-and-examples/tree/master/example-code/Northfield.Scripts) is an example of the scripts we've built to manage our build and deployments.


## Build System Templates
Having some sort of templating system for your pipelines will simplify your life as you start to scale up. You will be able to quickly roll out Build System wide changes with less fuss. This will be further supported by various other changes made to support Convention Over Configuration as you can make some assumptions around whether or not the change will be risky.

Teamcity has a fairly good stock templating system with inheritance that allows you to make a job an extension of a base template. You can create a few stock templates to represent the pipeline and then extend them for each new app. Jenkins has a plugin called "Job DSL" which is now part of the stock install of Jenkins 3. This will allow you to use Groovy to define jobs with code.

* [Here](https://github.com/NorthfieldIT/build-deployment-patterns-and-examples/tree/master/example-code/jenkins-dsl-example) is an example of our Jenkins DSL implementation.
* [Here](http://marcesher.com/2016/06/13/jenkins-as-code-creating-reusable-builders/) is an article that we used as inspiration for our implementation.

## Single Button Deploy
Deployments should be as easy as pressing the easy button ... in fact it should be a button that says "EASY"! It may take a bit of extra work but having a single button means the cost to deploy drops to rock bottom which encourages deploys to occur more often. It also makes the entire process much more approachable and distributes the work involved in deploying as it no longer requires to go through a single approval source.

Having deployments go through a central approval source is useless once you get past deploying more than 2 apps. That approval body will not have the context needed to actually approve the deployment. The deployment decision makers should be the key stakeholders who've seen that change through. Removing the friction in deployment puts that power in their hands.


## Externalize Application Configurations
Code based configurations require more work due to the fact of requiring a rebuild of the application for a configuration change. There are many situations where you will need to perform a configuration change during prime time and a rebuild is a pointless pain point. Your Build and Deployment Pipelines will quickly get coupled to the environments you support if those configs aren’t externalized as it will need some sort of custom process per environment. Make your artifact environment agnostic by pulling configs from the environment or from a tool like Consul that will manage those application configs.

## Applications Should Manage Their Dependencies
Applications should only assume the core dependencies are installed on the build systems and in their deployment locations. These are things like the base language any other generic dependencies. The application's repo should have enough in place to indicate and manage it's own dependencies. Most languages have things like package managers that allow you to define the required dependencies for that application to run. This will simplify the underlying build and deployment systems as you can make common resources to build and deploy all applications.

## Code-ify your Database Changes
Code-ify your database changes and roll them out on deploy! There are many frameworks that will aid you in versioning your schema changes. Most of them are glorified versioned schema files while other frameworks will contain additional sugar to make the changes a bit more safe.


# Opinionated Patterns
The following patterns are extremely opinionated. I've found that striving to achieve these patterns will aid you in the long run. You may choose to deviate from these patterns. If you do, deviate with purpose.

## Slow Validation Should Be Non Blocking
Strive to have all slow validation steps (anything over 10 minutes) to be non blocking validation steps. These validation steps shouldn't be within the main path to getting to production. This will ensure that your Mean Time To Recovery will continue to be low. Lengthy validation steps will also be an influencer in decision making as the cost of deployment will rise. Small changes that may be extremely beneficial to the end customer will be packaged up with other changes instead of shipping it right away.


## Minimal Amount of Environments
Strive for the least amount of environments possible. The best case scenario is a staging environment to use as a sanity check, a Production environment and that's it. More than two environments is a type of build and deployment smell that indicates that you’re supporting validation methods and process that won't scale well in the long run. Typically these are validation methods like end to end tests that require the entire stack to run. These validation methods are prone to error at the test level (testing framework, timings etc), the orchestration level (bring up all required apps, dbs etc) and other elements like queuing work loads. More time will be spent on debugging the entire validation environment then actually shipping value to your end customer

## K.I.S.S.
Your Build and Deployment Pipelines should be as simple as possible. At the core it should involve a code review validation step, a core build and then a deployment. Anything more complicated then that should be a smell indicating that you're trying to support something that wont scale in the long run.

## Applications Own Their Health Checks
Having your application own it’s own health-checks means it’s easier to scale up when multiple systems need access to that health check. Things like your load balancer, alerting system, deployment process and general debugging all need access to some sort of health indication. Having that app own it’s health check means that every system will automatically gain the updates you apply to that core health check. It’s also much easier to write the health check within the application that is serving it. Here is an excellent talk that delves deeper into the subject https://vimeo.com/173610242

## No Rollbacks
Your default stance on Application Deployments should be Roll Forward, no Rollbacks. Think of deployments like practice for game day; they should be routine and boring. Rollbacks are typically rarely ran which means they have inherent risk involved. How will you know if that rollback will work? How will you test rollback procedures? What will you do if it fails? You will be forced into a roll forward scenario if the rollback fails so you might as well cut out the middleman and use a process that you've practiced everyday.

## Deploy From Master
If it's in your master branch, it's ready for production. Forcing yourself to deploy whatever is in master will push you to make smaller changes with less risk. For larger changes you will implement things like feature flags within the application so that you can land changes without fear. This becomes extra beneficial as your unfinished code will run along production code serving customers ensuring that your changes do not have side effects. It will also mean that anyone can come to your repo and make a change in a crisis. There isn't any second guessing whether or not the master branch is ready for production.

## Lockdown Deployment Boxes
Lockdown access to any box where an application has been deployed. Trying to access a box to debug an issue could mean there is missing infrastructure or tooling to allow people to do their jobs. Things like a log system to easily collect and read logs or potentially an application performance monitoring tool. Having the boxes locked down will essentially put a speed bump in place to force people to have a conversation and solve those workflow issues.

## Don't Use Configuration Management For Deployment
Using Chef? Don't use it to deploy your application. Application deployments require coordination and knowledge about all the nodes. Chef and other configuration management software does not handle this well.

# Additional Links and Presentations
* http://githubengineering.com/move-fast/ : Article discussing how Github continuously deployed a core architecture migration.
* https://engineering.shopify.com/17489060-docker-at-shopify-how-we-built-containers-that-power-over-100-000-online-shops : Article discussing how Spotify use convention over configuration to build their containers.
* https://engineering.semantics3.com/2016/06/15/a-perl-toolchain-for-building-micro-services-at-scale/ : Article on Semantics3 Build and Deployment Pipelines for their micro services.
* https://www.youtube.com/watch?v=kb-m2fasdDY : Presentation from Uber -> What I Wish I Had Known Before Scaling Uber to 1000 Services
* http://www.slideshare.net/nicolefv/the-data-on-devops-making-the-case-for-awesome : Slides on the Value of DevOps
* https://blog.acolyer.org/2016/09/12/on-designing-and-deploying-internet-scale-services/
* https://zachholman.com/talk/how-github-no-longer-works/
* https://zachholman.com/talk/move-fast-break-nothing/
* http://nickcraver.com/blog/2016/05/03/stack-overflow-how-we-do-deployment-2016-edition/
* http://marcesher.com/2016/06/13/jenkins-as-code-creating-reusable-builders/
* https://github.com/chef/devops-kungfu
* http://businessofsoftware.org/2016/06/rock-solid-software-testing-without-hiring-an-army-trish-khoo-google-bos2015/
