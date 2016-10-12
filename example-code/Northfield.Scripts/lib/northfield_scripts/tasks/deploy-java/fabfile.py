from fabric.api import *
from fabric.operations import run, put
import commands
import requests
import time
import sys
import json

# the common deploy user
env.user = "THE_DEPLOY_USER"
env.forward_agent = True
env.f5_pool_timeout = 15


def deploy_app(appname, environment, deployable, health_check_endpoint):
  result=run("uname -a")

  if result.succeeded:
    print "[PASSED] Connecting to remote server "+env.host_string
  else:
    print "[FAILED] Could *not* ssh into server "+env.host_string+"! Please fix the auto-ssh issue. Exiting!";
    sys.exit(1)
  run("whoami")

  # stop the service. The init script is the app name
  run('service %s stop' % (appname))

  # delete old deploys. We symlink the current running version.
  _delete_old_deploys(appname)

  # move the file over
  put('%s/%s' % (deployable_location, deployable), '/opt/app/%s/%s' % (appname, deployable))
  # symlink the file
  run('ln -sf /opt/app/%s/%s /opt/app/%s/%s.jar' % (appname, deployable, appname, appname))
  time.sleep(2)
  # start the app
  run('service %s start' % (appname))

  # health check the application. All we are looking for is a 200 from the /health endpoint
  _health_check_box(health_check_endpoint)




#needs off switch for health check as certain apps wont use it
def _health_check_box(health_check_endpoint):
    print("""
************************************************************************
*
*     HEALTH CHECK """ + health_check_endpoint + """ endpoint
*
************************************************************************
    """)

    health_pass = False
    for a in range(0, 10):
        if health_pass != True:
            try:
                ping_url = "http://" + env.host_string + "" + health_check_endpoint
                result = requests.get(ping_url, verify=False)
                if result.status_code != requests.codes.ok:
                    print("Health check did not return 200. The content is %s" % (result.text))
                else:
                    print("Health check succeeded!")
                    health_pass = True
            except Exception as e:
                print("Error in health check! %s" % e)
            time.sleep(30)


    if health_pass != True:
        print("""The health check failed.

        ************************************************************************
        *
        *                HEALTH CHECK HAS FAILED
        *
        ************************************************************************

        """ + ping_url + """ has failed it's health check. Please check the logs


        If the above CURL errors show 404, it means there is no """ + health_check_endpoint + """ endpoint.

        ************************************************************************
        *
        *
        *
        ************************************************************************



        """)
        sys.exit(129)


def _delete_old_deploys(appname):
  with cd('/opt/app/%s' % appname):
    file_count=run("find . -maxdepth 1 -type f | xargs -x --no-run-if-empty ls -t | sed -e '1,5d' | wc -l")
    file_count.replace("ls: write error: Broken pipe", "").strip()
    try:
        total_files = float(file_count)
        if total_files > 0:
            print "[INFO] Deleting the following files"
            run("find . -maxdepth 1 -type f | xargs -x --no-run-if-empty ls -t | sed -e '1,5d'")
            print "[INFO] Deleting now"

            run("find . -maxdepth 1 -type f | xargs -x --no-run-if-empty ls -t | sed -e '1,5d' | xargs --no-run-if-empty -L1 rm")
    except Exception as e:
        print("[ERROR] Error deleting files! %s" % e)
        print("[ERROR] File Count return was %s" % file_count)
