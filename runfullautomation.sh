#!/usr/bin/env bash
export PATH=/usr/lib/jvm/java-7-openjdk-amd64/jre/bin:$PATH

automationinfo="logsautomationinfo.txt"
automation_count=1

serverport=8080
sqlport=65432

build_file_name="SupportCenterPlus_Mac.zip"

#Getting present location
AUTOMATION_PATH=$(pwd)
echo "AUTOMATION_PATH is $AUTOMATION_PATH"  >> $automationinfo

machinename=$(uname)
echo "machinename is $machinename"  >> $automationinfo

buildext_folder="exe_"$(date +%H-%M)

report_folder="report"

diffreport_folder="diffreport"

logs_folder="logs"

#module_names="request;project"
module_names="request"

cookies_file="cookies.txt"

url_response_file="url_response.txt"

build_urlpath="http://build.csez.zohocorpin.com/me/supportcenterplus/SUPPORTCENTERPLUS_MSP_11_BRANCH/"
latest_build="?C=M;O=A"
branch_name=$(echo $build_urlpath| cut -d'/' -f 6,7,8,9,10) && branch_name=${branch_name%?} && branch_name=${branch_name//\//_}
build_date=$(date +%b_%d_%Y) 

bash cleanautomationfolder.sh >> $automationinfo

# method to invoke the string set to variable 'url'
function invoke_url_login()
{
    echo $url
  wget --save-cookies $cookies_file \
     --keep-session-cookies \
     --delete-after \
     --post-data "j_username=administrator&j_password=administrator" \
     $url
}

function invoke_url()
{
  echo "$url" >> $url_response_file
  wget --load-cookies $cookies_file -O - >> $url_response_file \
    $url
}


# method to encode the querystring with query and cachekey ('query={"rawquery"="$actualquery","cachekey":"$cachekey"}') set to variable 'query' by opening in the browser
function execute_query () {
  echo  "$servlet_url?rawquery=$query"
  query=${query//\{/%7B} && query=${query//\}/%7D} && query=${query//\[/%5B} && query=${query//\]/%5D} && query=${query//\ /%20} && query=${query//\"/%22} && query=${query//\'/%27}
  url="$servlet_url?rawquery=$query"
  invoke_url
}

# method to execute the test_cases_list set to variable 'test_cases' using automation_v2.0.3.jar by opening in the browser
function execute_testcases() {
  count=$automation_count
  url="$servlet_url?config_path=$CONFIG_JSON_PATH&excel_testing=$test_cases&isnewconfig=yes"
  invoke_url

  sleep 5

  java -cp "AutoMateR_Standalone.jar:api_tools_lib/*:." com.zoho.automater.testcaserun.runner.Runner config.json
  mv Report.html  Report$count.html
  mv run_log.log run_log_${count}.log
  mv automation_db.log automation_db_${count}.log
  mv automation_db.properties automation_db_${count}.properties
  echo "Executed $test_cases and renaming to report$count.html , run_log_${count}.log, automation_db_${count}.log,automation_db_${count}.properties"
  automation_count=$(expr $count + 1)
}

function execute_new_testcases()
{ 
  url="$servlet_url?config_path=$CONFIG_JSON_PATH&excel_testing=$test_cases&isnewconfig=yes"
  invoke_url
  java -cp "AutoMateR_Standalone.jar:api_tools_lib/*:." com.zoho.automater.testcaserun.runner.Runner config.json
  mv Report.html  Report$custom_cases.html
  mv run_log.log run_log_${custom_cases}.log
  mv automation_db.log automation_db_${custom_cases}.log
  mv automation_db.properties automation_db_${custom_cases}.properties
  echo "Executed $test_cases and renaming to report$custom_cases.html , run_log_${custom_cases}.log, automation_db_${custom_cases}.log,automation_db_${custom_cases}.properties"
  custom_cases=""
}

# method to create complete folder path under Reports module
function reports_folder_creations() {
#adding new folder(Branch_name) under Reports
  echo "adding new folder /Reports/$branch_name"
  mkdir ../Reports/$branch_name

  #adding new folder(Branch_name/build_date) under Reports
  echo "adding new folder /Reports/$branch_name/$build_date"
  mkdir ../Reports/$branch_name/$build_date

  #adding new folder(Branch_name/build_date/ppm) under Reports
  echo "adding new folder /Reports/$branch_name/$build_date/$buildext_folder"
  mkdir ../Reports/$branch_name/$build_date/$buildext_folder

  #adding new folder(Branch_name/build_date/ppm/report) under Reports
  echo "adding new folder /Reports/$branch_name/$build_date/$buildext_folder/$report_folder"
  mkdir ../Reports/$branch_name/$build_date/$buildext_folder/$report_folder

  #adding new folder(Branch_name/build_date/ppm/logs) under Reports
  echo "adding new folder /Reports/$branch_name/$build_date/$buildext_folder/$logs_folder"
  mkdir ../Reports/$branch_name/$build_date/$buildext_folder/$logs_folder

  #moving logs folder under Reports folder
  echo "moving run logs folder under Reports folder"
  mv run_log_*.log ../Reports/$branch_name/$build_date/$buildext_folder/$logs_folder/

  #moving db to logs folder under Reports folder
  echo "moving db logs folder under Reports folder"
  mv automation_db_*.log ../Reports/$branch_name/$build_date/$buildext_folder/$logs_folder/

  #moving properties to logs folder under Reports folder
  echo "moving db properties to logs folder under Reports folder"
  mv automation_db_*.properties ../Reports/$branch_name/$build_date/$buildext_folder/$logs_folder/
  automation_db.script

  #moving scripts to logs folder under Reports folder
  echo "moving db scripts to logs folder under Reports folder"
  mv automation_db.script ../Reports/$branch_name/$build_date/$buildext_folder/$logs_folder/

  #moving config.json to logs folder under Reports folder
  echo "moving config.json to logs folder under Reports folder"
  mv config.json ../Reports/$branch_name/$build_date/$buildext_folder/$logs_folder/

  #moving ppm file to ppm folder under Reports folder
  echo "moving $ppmname to ppm folder under Reports folder"
  mv $ppmname ../Reports/$branch_name/$build_date/$buildext_folder/

  #moving AdventNet folder  to ppm folder under Reports folder
  echo "removing AdventNet folder  to ppm folder under Reports folder"
  rm -r --interactive=never AdventNet 

  #moving AdventNet.zip folder  to ppm folder under Reports folder
  echo "removing AdventNet folder  to ppm folder under Reports folder"
  rm AdventNet.zip 

  #moving report*.html to report folder under Reports folder
  echo "moving Report*.html to report folder under Reports folder"
  mv Report[0-9]*.html ../Reports/$branch_name/$build_date/$buildext_folder/$report_folder

  echo "Moving ReportNew*.html"
  mv ReportNew*.html ../Reports/$branch_name/$build_date/$buildext_folder/$report_folder

  #moving cookies.txt to logs folder under Reports folder
  echo "moving $cookies_file to logs folder under Reports folder"
  mv $AUTOMATION_PATH/$cookies_file ../Reports/$branch_name/$build_date/$buildext_folder/$logs_folder/

  #moving url_response.txt to logs folder under Reports folder
  echo "moving $url_response_file to logs folder under Reports folder"
  mv $AUTOMATION_PATH/$url_response_file ../Reports/$branch_name/$build_date/$buildext_folder/$logs_folder/

  #moving Snapshots folder  to ppm folder under Reports folder
  echo "moving Snapshot folder folder  to ppm folder under Reports folder"
  mv Snapshots ../Reports/$branch_name/$build_date/$buildext_folder/
}


# method to invoke the diff tool , and moving diff files to Reports folder from DiffTool folder
function invoke_diffTool() {
  #removing old_testcases and new_testcases folder under DiffTool folder
  echo "removing old_testcases and new_testcases folder under DiffTool folder"
  rm -rf old_testcases
  rm -rf new_testcases

  #adding old_testcases and new_testcases folder under DiffTool folder
  echo "adding old_testcases and new_testcases folder under DiffTool folder"
  mkdir old_testcases
  mkdir new_testcases

  old_testcasespath="$AUTOMATION_PATH/Report/Report*.html"
  new_testcasespath="$AUTOMATION_PATH/../Reports/$branch_name/$build_date/$buildext_folder/report/Report*.html"
  report_url_path="http://sdp-u16-3500:4000/$branch_name/$build_date/$buildext_folder"

  #copying reports from the old_testcasespath and new_testcasespath to old_testcases and new_testcases respectively
  echo "copying reports from the $old_testcasespath and $new_testcasespath to old_testcases and new_testcases respectively"
  echo "the report url path is : $report_url_path"

  cp -r $old_testcasespath old_testcases
  cp -r $new_testcasespath new_testcases

  echo "executing DiffTool.sh script"
  sh DiffTool.sh $report_url_path

  sleep 25

  #moving the diffreport folder under Reports folder
  echo "moving the diffreport folder under Reports folder"
  mv $diffreport_folder ../Reports/$branch_name/$build_date/$buildext_folder

  #moving logsautomationinfo.txt to logs folder under Reports folder
  echo "moving $automationinfo to logs folder under Reports folder"
  mv $AUTOMATION_PATH/$automationinfo ../Reports/$branch_name/$build_date/$buildext_folder/$logs_folder/
}

function non_esm_cases() {
  for module in $(echo $module_names | tr ";" "\n");
  do
    case $module in
      "request")
        request_non_esm_testcases
      ;;
      "project")
        #project case method
      ;;
      *)
      request_non_esm_testcases
      ;;
    esac
  done
}

function esm_cases() {
  for module in $(echo $module_names | tr ";" "\n");
  do
    case $module in
      "request")
        request_esm_testcases
      ;;
      "project")
        #project case method
      ;;
      *)
      request_esm_testcases
      ;;
  esac
  done
}

function request_non_esm_testcases() {
	#generating users for further automation
	test_cases="ESM_user.xlsx"
	execute_testcases

	sleep 5

	#generating authtoken for the users specified
	url="$servlet_url?generateAllConfig=true&config_path=$CONFIG_JSON_PATH&users=guest,tech1_vip,user1,user2,hg,hs,new_requester_own,new_requester_dept,new_requester_site,new_requester_all,hd"
	invoke_url

	sleep 5

	#for ON_BEHALF_OF_USERFIELD setting 'false' paramvalue
	query=\{\"rawquery\":\[\{\"query\":\"update\ globalconfig\ set\ paramvalue=\'false\'\ where\ parameter\ like\ \'ON_BEHALF_OF_USERFIELD\'\ and\ category\ like\ \'RequesterFeatures\'\;\"\,\"cachekey\":\"GLOBALCONFIG\"\}\]\}
	execute_query

	sleep 5

	#executing NonESM_obo_false testcases
	test_cases="NonESM_obo_false.xlsx"
	execute_testcases

	sleep 5

	#for ON_BEHALF_OF_USERFIELD setting 'true' paramvalue
	query=\{\"rawquery\":\[\{\"query\":\"update\ globalconfig\ set\ paramvalue=\'true\'\ where\ parameter\ like\ \'ON_BEHALF_OF_USERFIELD\'\ and\ category\ like\ \'RequesterFeatures\'\;\"\,\"cachekey\":\"GLOBALCONFIG\"\}\]\}
	execute_query

	sleep 5

	#executing NonESM_obo_user_dept testcases
	test_cases="NonESM_obo_user_dept.xlsx"
	execute_testcases

	sleep 5

	#for SHOW_OBOUSERS setting 'All' paramvalue
	query=\{\"rawquery\":\[\{\"query\":\"update\ globalconfig\ set\ paramvalue=\'All\'\ where\ parameter\ like\ \'SHOW_OBOUSERS\'\ and\ category\ like\ \'RequesterFeatures\'\;\"\,\"cachekey\":\"GLOBALCONFIG\"\}\]\}
	execute_query

	sleep 5

	#executing NonESM_obo_user_all testcases
	test_cases="NonESM_obo_user_all.xlsx"
	execute_testcases

	sleep 5

	#executing users , admin api testcases
	test_cases="nonESM_deletedUsers.xlsx,get_all_requester_exe.xlsx,nonESM_admin_APIs_exe.xlsx"
	execute_testcases

	sleep 5
}

function portal_creation_testcases() {
  #creating and generating portals , associating users and change as technician
	test_cases="ESM_USER_EXE.xlsx,ESM_prerequiste_exe.xlsx"
	execute_testcases
	sleep 5
}

function user_custom_cases(){

test_cases="$(python -c 'from downloadFromWorkDrive import custom_sheets_string;custom_sheets_string()')"
echo "Custom test cases are $test_cases" >> $AUTOMATION_PATH/$automationinfo
if [[ -z "$test_cases" ]]
  then
   echo "New Cases are Empty"
  else
   custom_cases="New"
   execute_new_testcases
fi
   
}

function request_esm_testcases() {
	#generating authtoken for the users specified
	url="$servlet_url?generateAllConfig=true&config_path=$CONFIG_JSON_PATH&users=user4,user3,user_hd,restricted_withfull,requester_dept"
	invoke_url

	sleep 5

	#executing admin api for ESM
	test_cases="get_portal.xlsx,ESM_status.xlsx,ESM_impact.xlsx,ESM_level.xlsx,ESM_mode.xlsx,ESM_priority.xlsx,ESM_urgency.xlsx,ESM_requesttype.xlsx,ESM_requestclosurecode.xlsx,ESM_csi.xlsx,ESM_resolution_template.xlsx,get_all_api_test_cases_portal_specific.xlsx,ESM_RequestScenarios.xlsx"
	execute_testcases

	sleep 5

	#for ON_BEHALF_OF_USERFIELD setting 'false' paramvalue
	query=\{\"rawquery\":\[\{\"query\":\"update\ globalconfig\ set\ paramvalue=\'false\'\ where\ parameter\ like\ \'ON_BEHALF_OF_USERFIELD\'\ and\ category\ like\ \'RequesterFeatures\'\;\"\,\"cachekey\":\"GLOBALCONFIG\"\}\]\}
	execute_query

	sleep 5

	#executing ESM_obo_false testcases
	test_cases="get_portal.xlsx,ESM_obo_false.xlsx"
	execute_testcases

	sleep 5

	#for ON_BEHALF_OF_USERFIELD setting 'true' paramvalue
	query=\{\"rawquery\":\[\{\"query\":\"update\ globalconfig\ set\ paramvalue=\'true\'\ where\ parameter\ like\ \'ON_BEHALF_OF_USERFIELD\'\ and\ category\ like\ \'RequesterFeatures\'\;\"\,\"cachekey\":\"GLOBALCONFIG\"\}\]\}
	execute_query

	sleep 5

	#for SHOW_OBOUSERS setting 'Department' paramvalue
	query=\{\"rawquery\":\[\{\"query\":\"update\ globalconfig\ set\ paramvalue=\'Department\'\ where\ parameter\ like\ \'SHOW_OBOUSERS\'\ and\ category\ like\ \'RequesterFeatures\'\;\"\,\"cachekey\":\"GLOBALCONFIG\"\}\]\}
	execute_query

	sleep 5

	#executing ESM_obo_user_dept testcases
	test_cases="get_portal.xlsx,ESM_obo_user_dept.xlsx"
	execute_testcases

	sleep 5

	#for SHOW_OBOUSERS setting 'All' paramvalue
	query=\{\"rawquery\":\[\{\"query\":\"update\ globalconfig\ set\ paramvalue=\'All\'\ where\ parameter\ like\ \'SHOW_OBOUSERS\'\ and\ category\ like\ \'RequesterFeatures\'\;\"\,\"cachekey\":\"GLOBALCONFIG\"\}\]\}
	execute_query

	sleep 5

	#executing ESM_obo_user_all testcases
	test_cases="get_portal.xlsx,ESM_obo_user_all.xlsx"
	execute_testcases
}

function start_build()
{

cd $RUN_BUILD_SCRIPT_PATH || exit
  #Starting the sdp server
echo "This script is about to call run.sh script." >> $AUTOMATION_PATH/$automationinfo

nohup sh run.sh  >> $AUTOMATION_PATH/$automationinfo &

while true
do
sleep 100
if grep -q 'Server started' $AUTOMATION_PATH/$automationinfo
then
echo "server started , going to trigger the automation" >> $AUTOMATION_PATH/$automationinfo
  break
else
echo "still server is starting" >> $AUTOMATION_PATH/$automationinfo
fi
done
echo "Here goes the automation" >> $AUTOMATION_PATH/$automationinfo

cd "$AUTOMATION_PATH" || exit

echo "Going to $AUTOMATION_PATH folder" >> $automationinfo

CONFIG_JSON_PATH="$AUTOMATION_PATH/config.json"
echo "CONFIG_JSON_PATH is $CONFIG_JSON_PATH" >> $automationinfo

licensePath="$AUTOMATION_PATH/esm_license.xml"
echo "licensePath is $licensePath" >> $automationinfo

domain_name="http://localhost:$serverport"
echo "domain_name is $domain_name" >> $automationinfo

servlet_url="$domain_name/servlet/DebugServlet"
echo "servlet_url is $servlet_url" >> $automationinfo

#logging to the server using default_user(administrator) credential
url="$domain_name/j_security_check"
invoke_url_login >> $automationinfo

sleep 10

#resetting the attachmentpath to the build running
url="$servlet_url?resetAttachmentPath=true"
invoke_url >> $automationinfo

sleep 10

#applying license file(esm_license.xml) to the build running
url="$servlet_url?licenseFile=$licensePath"
invoke_url >> $automationinfo

sleep 10

#creates the config.json file with authtoken of default_user
url="$servlet_url?generateAdminConfig=true&config_path=$CONFIG_JSON_PATH"
invoke_url >> $automationinfo

}

function stop_build()
{
cd $RUN_BUILD_SCRIPT_PATH || exit

echo "Going to $RUN_BUILD_SCRIPT_PATH folder" >> $AUTOMATION_PATH/$automationinfo

echo "This script is about to call shutdown.sh script." >> $AUTOMATION_PATH/$automationinfo
 
sh shutdown.sh >> $AUTOMATION_PATH/$automationinfo &

sleep 20

cd $AUTOMATION_PATH || exit
}

function take_snapshot(){


#taking database backups for Iteration

cd "$RUN_BUILD_SCRIPT_PATH" || exit

echo "This script is about to take screen shot" >> $AUTOMATION_PATH/$automationinfo

sh backUpData.sh >> $AUTOMATION_PATH/$automationinfo 

sleep 5

cd "$buildPath/backup" || exit

BackUpDir=$(ls -td -- */ | head -n 1 | cut -d'/' -f1)

echo "Backup Dir is $BackUpDir" >> $AUTOMATION_PATH/$automationinfo

mkdir -p $AUTOMATION_PATH/Snapshots/backup_${suite} && cp -r $BackUpDir $AUTOMATION_PATH/Snapshots/backup_${suite} >> $AUTOMATION_PATH/$automationinfo

LogDir=$buildPath/logs/*

echo "Log Count is $count" >> $AUTOMATION_PATH/$automationinfo

mkdir -p $AUTOMATION_PATH/Snapshots/logs_${suite} && mv  $LogDir $AUTOMATION_PATH/Snapshots/logs_${suite} >> $AUTOMATION_PATH/$automationinfo

echo "Snapshot Taken" >> $AUTOMATION_PATH/$automationinfo

cd $AUTOMATION_PATH || exit

}

function zip_Report_Diff()
{
cd $AUTOMATION_PATH || exit

cd $AUTOMATION_PATH/../Reports/$branch_name/$build_date/$buildext_folder 

echo "Zipping the Report,DiffReport and Automation Logs" >> $AUTOMATION_PATH/$automationinfo

zip -r Reports_Diff.zip report/ diffreport/ logs/

cd $AUTOMATION_PATH || exit 

}

if [ "$machinename" == "Linux" ]
  then
    # #Shutdown EXE SETUP
    fuser -k $serverport/tcp
    fuser -k $sqlport/tcp
    build_file_name="SupportCenterPlus_Linux64.zip"
  else
    lsof -ti:$serverport | xargs kill
    lsof -ti:$sqlport | xargs kill
fi

echo "killing any resources using server port $serverport and sql port $sqlport"  >> $automationinfo
echo "build_file_name is $build_file_name"  >> $automationinfo

if [ -n "$1" ]
then
    wget -q --spider "$1"
    result=$?
    if [ $result != 0 ]
    then
      export module_names=$1
    else
      export build_url=$1
      if [ -n "$2" ]
      then
        export module_names=$2
      fi
    fi
fi

if [ -n "$build_url" ]
then
  echo "$build_url from paramter" >> $automationinfo
  exename=$(awk -F/ '{print $NF}' <<<  $build_url) # "AdventNet_ManageEngine_ServiceDesk_Mac.zip" #
 if [ -n "$exename" ]
 then
  build_url="${build_url//$exename/}"
  echo "Getting the EXE file Name  :  $exename" >> $automationinfo
 else
  wget $build_url >> $automationinfo  || exit
  echo "index.html file downloaded" >> $automationinfo
  if [ "$machinename" == "Linux" ]
    then
      exename="SupportCenterPlus_Linux64.zip"
    else
      exename=$(grep -o 'SupportCenterPlus_[^(zip)]*\.zip' index.html | head -1)  # "AdventNet_ManageEngine_ServiceDesk_Mac.zip" #
  fi
  echo "Getting the EXE file Name  from index.html:  $exename" >> $automationinfo
  rm index.html >> $automationinfo
 fi
 branch_name=$(echo $build_url| cut -d'/' -f 6,7,8,9,10) && branch_name=${branch_name%?} && branch_name=${branch_name//\//_}
 build_url="$build_url""/""$exename"
else
  #Download the index.html file
  latest_build_url_path="$build_urlpath""/""$latest_build"
  wget $latest_build_url_path >> $automationinfo  || exit
  mv "index.html$latest_build" index.html >> $automationinfo
  echo "index.html file downloaded" >> $automationinfo
  exename=$(grep -o 'SupportCenterPlus_[^(zip)]*\.zip' index.html | head -1)  # "AdventNet_ManageEngine_ServiceDesk_Mac.zip" #
  echo "Getting the EXE file Name  :  $exename" >> $automationinfo
  if [ -n "$exename" ]
  then
    #delete the index.html
    rm index.html >> $automationinfo
    echo "index.html file deleted" >> $automationinfo
    build_url="$build_urlpath""/""$exename"
  else
    mapfile -t date_array < <(awk -F '[<.*.\".*.\/\">]' '{for(i=1;i<=NF;i++) if($i ~ /_.*$/) print $i}' index.html)
    echo "date_array is ${date_array[*]}"   >> $automationinfo
    #delete the index.html
    rm index.html >> $automationinfo
    echo "index.html file deleted" >> $automationinfo
    datearraylength=${#date_array[@]}
    for index in $(seq 1 "$datearraylength")
    do
      build_date=${date_array[$datearraylength-$index]} #`date +%b_%d_%Y` # "May_31_2019_5" #
      echo "$build_date"  >> $automationinfo
      build_url="$build_urlpath$build_date/$build_file_name"
      echo "$build_url"  >> $automationinfo
      wget -q --spider "$build_url"  >> $automationinfo
      result=$?
      if [ $result != 0 ]
      then
        echo "invalid url $result"  >> $automationinfo
      else
        echo "valid url $result"  >> $automationinfo
        break
      fi
    done
  fi
fi

echo "build_urlpath is $build_urlpath"  >> $automationinfo
echo "branch_name is $branch_name"  >> $automationinfo
echo "build_date is $build_date"  >> $automationinfo
echo "build_url is $build_url"  >> $automationinfo

if [[ $build_url == *"$build_file_name"* ]]
then
  #Download the build.zip file
  echo "Downloading $build_url file"  >> $automationinfo
  wget $build_url  >> $automationinfo
else
  echo "$build_url is invalid to download the exe file" >> $automationinfo
  exit
fi

#unzipping the zip file
echo "unzipping the $build_file_name file into $AUTOMATION_PATH" >> $automationinfo
unzip $AUTOMATION_PATH/$build_file_name -d $AUTOMATION_PATH  >> $automationinfo

rm $AUTOMATION_PATH/$build_file_name >> $automationinfo

buildPath="$AUTOMATION_PATH"
echo "buildPath is $buildPath" >> $automationinfo


fixesfolder="$AUTOMATION_PATH/fixes/"
mkdir $fixesfolder
echo "fixesfolder is $fixesfolder" >> $automationinfo

RUN_BUILD_SCRIPT_PATH=$buildPath/bin/
echo "Going to $RUN_BUILD_SCRIPT_PATH folder" >> $AUTOMATION_PATH/$automationinfo

cd $RUN_BUILD_SCRIPT_PATH || exit

#application automation and additional jars if needed in 1autoreport*.fjar
cp $AUTOMATION_PATH/1.fjar $fixesfolder  >> $AUTOMATION_PATH/$automationinfo


#placing fjars in Jars folder to fixes folder if any.
echo "Going to apply Jars" >> $AUTOMATION_PATH/$automationinfo
if [ -d "$AUTOMATION_PATH/Jars/" ]; then
  echo "Placing jars to $buildPath /fixes folder..." >> $AUTOMATION_PATH/$automationinfo
  if [ ! -d "$buildPath/fixes" ]; then
    mkdir $buildPath/fixes
  fi
  for f in $AUTOMATION_PATH/Jars/*.fjar
  do
    cp -v $f $buildPath/fixes/ >> $AUTOMATION_PATH/$automationinfo
  done
fi
echo "Automation fjar is applied properly" >> $AUTOMATION_PATH/$automationinfo

start_build  >> $AUTOMATION_PATH/$automationinfo

sleep 5

non_esm_cases  >> $AUTOMATION_PATH/$automationinfo

sleep 5

user_custom_cases >> $AUTOMATION_PATH/$automationinfo

sleep 5

portal_creation_testcases >> $AUTOMATION_PATH/$automationinfo

sleep 5

esm_cases >> $AUTOMATION_PATH/$automationinfo

sleep 5

stop_build >>  $AUTOMATION_PATH/$automationinfo

suite="full_automation"
take_snapshot >> $automationinfo

cd $AUTOMATION_PATH || exit

echo "Going to $AUTOMATION_PATH" >> $AUTOMATION_PATH/$automationinfo

reports_folder_creations  >> $AUTOMATION_PATH/$automationinfo

cd $AUTOMATION_PATH/../DiffTool || exit

echo "Going to $AUTOMATION_PATH/../DiffTool folder" >> $AUTOMATION_PATH/$automationinfo

invoke_diffTool >> $AUTOMATION_PATH/$automationinfo

zip_Report_Diff >> $AUTOMATION_PATH/$automationinfo

echo "Removing all Excel Sheets" $AUTOMATION_PATH/$automationinfo

cd $AUTOMATION_PATH || exit

rm *.xlsx   >>  $AUTOMATION_PATH/$automationinfo