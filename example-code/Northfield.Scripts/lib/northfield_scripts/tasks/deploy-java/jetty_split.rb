# encoding: utf-8
require 'northfield_scripts/core'

namespace 'deploy' do
  namespace 'java' do
    desc 'Deploy a Fat Jar'
    task :jetty_split do
      TaskLogger.task_block 'Deploying A Fat Jar in Rolling Deploy Pattern' do
        app_name = NorthfieldScripts.settings['app_name']
        # This health point will be :8080/health by convention. We mostly use Spring Boot's built in health endpoint
        health_check_endpoint = NorthfieldScripts.settings['deploy']['health_check_endpoint']
        split_count = NorthfieldScripts.settings['deploy']['split_count']
        environment = 'prd'

        # We can guess where the fat jar will be located since we build spring boot apps. We can assume the following
        # pattern will find the jar './build/libs/*.jar'
        deployable = 'someFat.jar'

        # Get the list of servers. We use an F5 as a load balancer. We rely on this gem https://rubygems.org/gems/f5-icontrol to get data about the pool of nodes.
        # We can get the available nodes. We will then order the pool of nodes with the "red" nodes first (nodes that are currently un healthy)
        # This is ensures that we don't accidentally nuke our entire pool from multiple failed deploys.
        # I am making an example return of nodes.
        servers = %w(node1 node2 node3 node4)

        # We then split the collection of nodes. Typically we split the collection into 4 smaller groups and then deploy to each
        # quarter individually. We ensure the app comes up healthy before going to the next. #SafeToFail
        server_split = servers.each_slice((servers.length / split_count.to_f).ceil).to_a

        # We use fabric to move the jars onto the nodes, start it and health check it. http://www.fabfile.org/
        # Fabric does this well! It handles SSHing into multiple boxes in parallel very well.
        # We also avoid dealing with credentials by having jenkins start an SSH agent. The public SSH key is then put on the individual nodes for the
        # given common deployment user
        ops_path = File.dirname(File.expand_path(__FILE__))
        fab_path = File.join(ops_path, 'fabfile.py')


        # Loop over each 1/4 of nodes
        server_split.each do |servers_section|
          joined_servers = servers_section.join(',')

          # We use Nagios for health checks. Here we temporarily disable Nagios for the given nodes for 5 minutes and which point the checks
          # come back. This leads to less paging.
          # Nagios.disable_hosts_with_message app_name, environment, servers_section, nagios_silence_time_mins

          # we will call out to the load balancer and pull the nodes out of the F5. We will check the connection count and wait until
          # the connection count drops to 0 or we hit a time out

          # Here we are calling our fabric script with the current collection of nodes
          fabric_cmd = Command.new('fab')
          fabric_cmd.arg "deploy_app:appname=#{app_name},environment=#{environment},deployable=\'#{deployable}\'health_check_endpoint=\'#{health_check_endpoint}\'"
          fabric_cmd.arg '--no-pty'
          fabric_cmd.arg '-P'
          fabric_cmd.arg '--show=debug'
          fabric_cmd.arg "--fabfile=#{fab_path}"
          fabric_cmd.arg "-H #{joined_servers}"
          fabric_cmd.run

          # we will then put the nodes back into the load balancer

          # We then force the checks back on after the deploy completes.
          # Nagios.enable_hosts_with_message servers_section
        end
      end
    end
  end
end
