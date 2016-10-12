from fabric.api import *
import sys
import json
import requests



def generate_job_dsl():
    job_map = get_job_map()
    all_job_dsl_data = ""
    for key, value in job_map.iteritems():
        all_job_dsl_data+=str("Globals.APP_NAME = '%s'\n" % key)
        all_job_dsl_data+=str("Globals.GITHUB_REPO = '%s'\n" % value['repo'])
        all_job_dsl_data+=str(value['job_dsl_contents'])
        all_job_dsl_data+=str('\n')


    f = open('jobs_new.groovy','r')
    filedata = f.read()
    f.close()

    newdata = filedata.replace("REPLACE_ME",all_job_dsl_data)

    f = open('jobs_updated.groovy','w')
    f.write(newdata)
    f.close()

def get_github_url(url):
    result = requests.get(url, headers={'Authorization': 'token AUTH_TOKEN_HERE'})
    if result.status_code != requests.codes.ok:
        print("The URL did not return 200. The content is %s" % (result.text))
        sys.exit(129)
    return result.text

def get_job_dsl(repo_location):
    job_url = "https://GITHUB_ENTERPRISE_URL/api/v3/repos/{0}/contents/buildscripts/jenkins/jobs.groovy"

    job_json = json.loads(get_github_url(job_url.format(repo_location)))
    return get_github_url(job_json['download_url'])

def get_app_name(repo_location):
    yaml_url = "https://GITHUB_ENTERPRISE_URL/api/v3/repos/{0}/contents/buildscripts/configs/config.yml"
    yaml_download_result = get_github_url(yaml_url.format(repo_location))
    yaml_file_result = get_github_url(json.loads(yaml_download_result)['download_url'])

    found_app_name = ''
    for yaml_line in yaml_file_result.splitlines():
        if 'app_name:' in yaml_line:
            found_app_name = yaml_line.replace('app_name: ', "").replace(" ", "")

    if found_app_name == '':
        print("No found app_name")
        sys.exit(129)

    print("************************************************************")
    print("*")
    print("* Found the following app: %s" % found_app_name)
    print("*")
    print("************************************************************")
    return found_app_name


def get_job_map():
    job_map = {}
    search_url = "https://GITHUB_ENTERPRISE_URL/api/v3/search/code?q=build%20language:Groovy%20path:/buildscripts/jenkins&page={0}"

    search_results = json.loads(get_github_url(search_url.format(1)))
    total_entries = search_results['total_count']
    page = 0
    while len(job_map.keys()) < total_entries:
        page = page + 1

        search_results = json.loads(get_github_url(search_url.format(page)))

        for item in search_results['items']:
            repo_location = item['repository']['full_name']
            print("************************************************************")
            print("*")
            print("* Found the following repo: %s" % repo_location)
            print("*")
            print("************************************************************")

            found_app_name = get_app_name(repo_location)

            job_dsl = get_job_dsl(repo_location)

            if found_app_name in job_map:
                print("The app_name %s already exists" % (found_app_name))
                sys.exit(129)

            job_map[found_app_name] = {}
            job_map[found_app_name]['repo'] = repo_location
            job_map[found_app_name]['job_dsl_contents'] = job_dsl

    return job_map









