#!/bin/bash

# Test for presence of properties file
[[ ! -f "job.properties" ]] && echo "Properties file missing!" &&  exit

# Test for presence of template file
[[ ! -f "template.xml" ]] && echo "Template file missing!" &&  exit

# Check for wget command
if ! [ -x "$(command -v wget)" ]; then
  echo 'Error: wget is not installed.' >&2
  exit 1
fi

# Check for java command
if ! [ -x "$(command -v java)" ]; then
  echo 'Error: JRE is not installed.' >&2
  exit 1
fi

# Check for completeness of job.properties file
conf=$(grep -E '*=$' job.properties|wc -l)
if [ "$conf" -ne "0" ]; then
   echo "The job.properties file seem to be incomplete";
   exit;
else
	source job.properties
fi

# extract and test jenkins url port number -
# If your jenkins server is not exposed on a specific port like 8080 consider commenting next 6 lines
if [ $jenkins_has_port = true ]; then
	port=$(echo $jenkins_url| cut -d: -f3)
	case $port in
		([0-9][0-9][0-9][0-9]) : OK;;
		(*)  echo "Invalid port number in the jenkins_url specified in job.properties file!"; exit 
	    ;;
	esac
fi

#Test Jenkins URL
curl --output /dev/null --silent --head "$jenkins_url"
[[ $? -ne 0 ]] && echo "The jenkins url is not responding ... check job.properties file" && exit

# Fetch a copy of jenkins-cli.jar from the jenkins server
[[ -f jenkins-cli.jar ]] && rm jenkins-cli.jar
wget -q ${jenkins_url}/jnlpJars/jenkins-cli.jar || echo "Failed getting jenkins_cli.jar!" 

#changing git url in the template.xml
sed -i "s|<url>.*</url>|<url>${jenkins_job_git_url}</url>|g" template.xml

# Create job in jenkins from template.xml
echo "Creating job ${jenkins_job_name}"
java -jar jenkins-cli.jar -s ${jenkins_url} create-job ${jenkins_job_name} < template.xml --username ${jenkins_username} --password ${jenkins_password} 
[[ $? -eq 0 ]] && echo "The jenkins Job ${jenkins_job_name} created" || echo "The job ${jenkins_job_name} failed ... check jenkins log for details"

# Add job to a specific view
if [ $jenkins_add_job_to_view = true ]; then
java -jar jenkins-cli.jar -s ${jenkins_url} add-job-to-view ${jenkins_view} ${jenkins_job_name} --username ${jenkins_username} --password ${jenkins_password}
[[ $? -eq 0 ]] && echo "Job ${jenkins_job_name} added to view ${jenkins_view}" || echo "The job ${jenkins_job_name} could not be added to  ${jenkins_view}"
fi
