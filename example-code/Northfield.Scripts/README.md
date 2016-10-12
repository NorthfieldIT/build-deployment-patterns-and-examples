# Northfield.Scripts

This is an example repo of a shareable library of build and deployment scripts. This is a combination of our "Core" and "Chef" build script gems that we use internally.

# Notables
As mentioned above we have a "Core" gem of scripts that are used as a base for any build and deployable artifact. We then create additional script gems that extend the "Core" to add artifact specific scripts. Internally we have "Java", "Chef" and "Node" gems that get used by our Java, Chef and Node repos.

These gems will contain all logic needed to build, validate and deploy those artifacts. The actual artifact repos will contain zero additional scripts. They will only call the specific commands for it's artifact and a bit of configuration. You can see this in the /example-code/random-jenkins-chef-recipe directory in this repo. It contains a Gemfile to pull down the build scripts, a rakefile.rb file that defines the individual steps and a config file under /example-code/random-jenkins-chef-recipe/buildscripts/configs/config.yml which gives it some very basic configuration. This gem actually dog-foods itself to validate itself!

As noted, the rakefile.rb within the jenkins chef recipe directory is extremely minimal.

```ruby
$: << './'

require 'northfield_scripts/tasks'

task :northfield_build => [
  :northfield_build_init_seam,
  'berks:install',
  'rubocop',
  'foodcritic',
  'rspec',
  'check_version',
  :northfield_build_end_seam
]

task northfield_deploy: [
  :northfield_deploy_init_seam,
  'berks:install',
  'berks:upload',
  :northfield_deploy_end_seam
]

```

We use core alias steps that our build systems will call. For core builds and CI, the build system will call `rake northfield_build` and for deploys the build system will call `rake northfield_deploy`. This means we can control the specific steps for an application outside of the build system. We can also add and remove steps within a code review without affecting others.

Also note the `northfield_BLAH_seam` steps. These are shims added in that we control within the script repos. This allows us to inject and remove steps that should be applied to all build and deployables without the need to modify every single repo.

We also get repos to setup a very basic configuration. At a minimum an `app_name` needs to be defined.
```
# encoding: utf-8
app_name: random-jenkins

rubocop:
  max_offenses: 0

foodcritic:
  max_warnings: 3

```

This `app_name` is used to run all of our specific commands. In the context of the chef recipe, we use it to find out information about the chef recipe like whether or not that version has already been uploaded to the chef servers. Our Java and Node apps use this `app_name` more extensively. We will use the `app_name` to interact with the load-balancer. We can interact with the load ballancer without any other configuration as we name the pools based off the `app_name` and the environment due to convention. We also use that `app_name` for database migrations with no other configuration. We can reach into our config system to pull the database name, location and password that the app uses based off convention.

You will also note that we leverage many other tools. Our build scripts are essentially a light layer on top of whatever tool we need to use with some additional sugar. Sometimes the additional sugar is some basic configs for a given tool that we would like to see applied to all similar apps. As an example, our rubocop wrapper will run rubocop with specific switches to give us a common output. In some cases the additional sugar is to make people's lives easier. For our java apps, our common "build" step for java will look for a Gradle wrapper file. It will use the Gradle wrapper if it finds it or else will use the globally installed Gradle. It will also ensure that the Gradle wrapper file is executable.

