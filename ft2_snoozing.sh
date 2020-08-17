#!/bin/bash


#############################################
#
# Shell Name : ft2_snoozing.sh
# 
# $1 : Data File_name
# $2 : ACK  File_name
# $3 : Interval 
# $4 : Total Wait Mins
# $5 : Limit
# $6 : Directory_name
#
# 사용법 : 파일전송을 체크해주는 스크립트 
# 
#############################################

DATA_FILE=$1
ACK_FILE=$2
INTERVAL=$3
TOT_WAIT=$4
TIME_LIMIT=$5
FILE_DIR=$6

echo $FILE_DIR

#### ENV
WORK_DATE=`date +%Y%m%d`
CHK_DIR=/data/1/gcgdlkkrk/tmp/f_watcher

#### Argument Check ####
if [ "$#" -eq 6 ]; then 
  echo "$1 $2 $3 $4 $5 $6"
else
  echo "Invalid Number of Arguments. Please Read Help!"
  echo "Usage : ft2_snoozing.sh <DATAFILE> <ACK> <Interval> <Tot WAIT Mins> <LIMIT> <FILE_DIR>"
  exit 1
fi

#### Function Area

function ProgressBar {
# Process data
  let _progress=(${1}*100/${2}*100)/100
  let _done=(${_progress}*4)/10
  let _left=40-$_done
# Build progressbar string lengths
  _fill=$(printf "%${_done}s")
  _empty=$(printf "%${_left}s")

# 1.2 Build progressbar strings and print the ProgressBar line
# 1.2.1 Output example:                           
# 1.2.1.1 Progress : [########################################] 100%
printf "\rProgress : [${_fill// /#}${_empty// /-}] ${_progress}%%"
}


function fn_actual_script {
_start=1
_end=100

for number in $(seq ${_start} ${_end})
do
  sleep 0.02
  ProgressBar ${number} ${_end}
done

printf '\n\n\n\n\n======= File Information ======= \n' | tee -a ${CHK_DIR}/${DATA_FILE}.${WORK_DATE}
echo  ${CHK_DIR}/${DATA_FILE}.${WORK_DATE}
touch ${CHK_DIR}/${DATA_FILE}.${WORK_DATE}

date | tee -a ${CHK_DIR}/${DATA_FILE}.${WORK_DATE} 
echo "Record Count"  | tee -a ${CHK_DIR}/${DATA_FILE}.${WORK_DATE} 
wc -l  ${FILE_DIR}/${DATA_FILE} | tee -a ${CHK_DIR}/${DATA_FILE}.${WORK_DATE}
echo "Check SUM"  | tee -a ${CHK_DIR}/${DATA_FILE}.${WORK_DATE} 
md5sum ${FILE_DIR}/${DATA_FILE} | tee -a ${CHK_DIR}/${DATA_FILE}.${WORK_DATE}
md5sum ${FILE_DIR}/${ACK_FILE}  | tee -a ${CHK_DIR}/${DATA_FILE}.${WORK_DATE}
echo "File Size/Info"  | tee -a ${CHK_DIR}/${DATA_FILE}.${WORK_DATE} 
ls -l  --time-style=long-iso ${FILE_DIR}/${DATA_FILE} ${FILE_DIR}/${ACK_FILE} | tee -a ${CHK_DIR}/${DATA_FILE}.${WORK_DATE}

printf '\nFinished!\n'
}


#### Check Previous ####
if [ -f ${CHK_DIR}/${DATA_FILE}.${WORK_DATE} ]; then
echo "FW Completed Skip"
exit 0
fi

#### Data file Check ####
while true
do
  if [ -f "${FILE_DIR}/${DATA_FILE}" ]; then
    echo "DATA File is presented. Proceeding. File_name : ${FILE_DIR}/${DATA_FILE}"
    break;
  else
    echo "DATA File is not presented wait ${INTERVAL} second(s) File_name : ${FILE_DIR}/${DATA_FILE}"
    sleep ${INTERVAL}
  fi
  
  ## Limit Time check
  if [ `date +%H%M` -gt ${TIME_LIMIT} ]; then
    echo "Time Limit Exceed. Stopping."
    exit 0
  fi
done

#### ACK file Check ####
while true
do
  if [ -f "${FILE_DIR}/${ACK_FILE}" ]; then
    echo "ACK File is presented. Proceeding. File_name : ${FILE_DIR}/${ACK_FILE}"
    echo "Job will be executed after 30s"
    fn_actual_script
    break;
  else
    echo "ACK File is not presented wait ${INTERVAL} second(s) File_name : ${FILE_DIR}/${ACK_FILE}"
    sleep ${INTERVAL}
  fi

  ## Limit Time check
  if [ `date +%H%M` -gt ${TIME_LIMIT} ]; then
    echo "Data File Presented, Only ACK File is not presented. Please check ACK File"
    exit 1
  fi

done


