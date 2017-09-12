::Readme::
Fill in the required information in the job.properties file

-----------------------------
sample of the job.properties
-----------------------------
jenkins_username=admin
jenkins_password=admin
jenkins_url=http://10.10.10.10:8080
jenkins_has_port=true
jenkins_job_name=new_job_cli
jenkins_job_git_url=git@git.company.com:path/repo.git
jenkins_add_job_to_view=false
jenkins_view=ViewName

Note: 
1. If your jenkins_url has no port, set jenkins_has_port value in job.properties to flase, else leave it to default true. 
2. Add job to a specific view set the value of 'jenkins_add_job_to_view' to 'true', and set the viewname to 'jenkins_view'.
   else, leave the value of 'jenkins_add_job_to_view' to 'false'.
 
Once all the information is filled in the job.properties file, run command
$./createjob.sh

