#!/bin/sh

#####################################
#                                   #
#   내부망 프로세스 체크 쉘 입니다.   #
#                                   #
#####################################

OPT=$1
# default OPTION is -d
if [ -z $OPT ]
then
   OPT=-d
fi

while :; do
  case $OPT in
    -s|-S|--short)
      OPT=S
      break
    ;;
    -d|-D|--detail)
      OPT=D
      break
    ;;
    -h|-H|--help) echo "usage : check [OPTION]"
                  echo "OPTION :"
                  echo "   -s|--short            Short Message like process_nm, succ_cnt, real_cnt, Active-Standby_gubun, status"
                  echo "   -d:--detail[default]  Detail Message, more short message like start_script, stop_script, log_location, usage_process"
                  exit 0
    ;;
    *)
      echo "check: unrecognized option '$1'"
      echo "Try 'check --help' for more information."
      exit 1
      break
  esac
done

# 호스트명
hostname=`uname -n`
# 오늘날짜 yyyymmdd
today=`date +%Y%m%d`
today2=`date +%Y-%m-%d`
now=`date +%Y년%m월%d일_%H:%M:%S`
HOST_NAME=`hostname`

#uppercase
HOST_NAME=`echo $HOST_NAME | awk '{print toupper($0)}'`

as="Active-Standby"
aa="Active-Active"

echo -e "\n\n"
if [ "$HOST_NAME" = "REPLANITWAS1" ]
then
  bin_location="/home/pgpro/server"
  log_location="/home/pgpro/server"

  # 프로세스 개수
  arr_prc_cnt=(
               1 1 1
               1 1 1 
               1 1 1 
               1 
               )
elif [ "$HOST_NAME" = "REPLANITWAS2" ]
then
  bin_location="/home/pgpro/server"
  log_location="/home/pgpro/server"

  # 프로세스 개수
  arr_prc_cnt=(
               1 0 1
               0 0 0
               1 1 1 
               1 
              )
elif [ "$HOST_NAME" = "VAN-DEV" ]
then
  bin_location="/home/pgpro/server"
  log_location="/home/pgpro/server"

  # 프로세스 개수
  arr_prc_cnt=(
               1 1 1
               1 1 1
               1 1 1 
               1 
              )
else
  echo "서버를 확인할 수 없어 종료합니다"
  exit 1
fi

###################################### CONFIG START ######################################
# 프로세스 명
arr_prc_nm=(
            "T-PGAS-CC" "T-PRNP   " "T-BJQP   "
            "T-BJSP   " "T-EMIF   " "T-CCNC   " 
            "T-PGADM  " "T-PGMCT  " "T-PGPAY  " 
            "T-PGRSL  " 
           )
# 프로세스 체크 방법
arr_prc_ck=(
            "T-PGAS-CC.jar" "T-PRNP.jar" "T-BJQP.jar"
            "T-BJSP.jar" "T-EMIF-" "T-CCNC.jar" 
            "T-PGADM" "T-PGMCT" "T-PGPAY" 
            "T-PGRSL"
           )
# 프로세스 Active-Standby 구분
arr_prc_as=(
            $aa $as $aa
            $aa $aa $as 
            $aa $aa $aa 
            $aa
           )
# 프로세스 리슨 포트
arr_prc_port=(
              "40510" "" ""
              "" "" "" 
              "40100" "40200" "40300" 
              "40400" 
             )
# 프로세스 기동 스크립트
arr_prc_start=(
               "$bin_location/T-PGAS-CC/bin/start.sh" "$bin_location/T-PRNP/bin/start.sh" "$bin_location/T-BJQP/bin/start.sh"
               "$bin_location/T-BJSP/bin/start.sh" "$bin_location/T-EMIF/bin/start.sh" "$bin_location/T-CCNC/bin/start.sh" 
               "/home/pgpro/web/T-PGADM/apache-tomcat-9.0.39/bin/startup.sh" "/home/pgpro/web/T-PGMCT/apache-tomcat-9.0.39/bin/startup.sh" "/home/pgpro/web/T-PGPAY/apache-tomcat-9.0.39/bin/startup.sh" 
               "/home/pgpro/web/T-PGRSL/apache-tomcat-9.0.39/bin/startup.sh" 
              )
# 프로세스 종료 스크립트
arr_prc_stop=(
              "$bin_location/T-PGAS-CC/bin/stop.sh" "$bin_location/T-PRNP/bin/stop.sh" "$bin_location/T-BJQP/bin/stop.sh"
              "$bin_location/T-BJSP/bin/stop.sh" "$bin_location/T-EMIF/bin/stop.sh" "$bin_location/T-CCNC/bin/stop.sh" 
              "/home/pgpro/web/T-PGADM/apache-tomcat-9.0.39/bin/shutdown.sh" "/home/pgpro/web/T-PGMCT/apache-tomcat-9.0.39/bin/shutdown.sh" "/home/pgpro/web/T-PGPAY/apache-tomcat-9.0.39/bin/shutdown.sh" 
              "/home/pgpro/web/T-PGRSL/apache-tomcat-9.0.39/bin/shutdown.sh" 
             )
# 프로세스 로그 위치
arr_prc_log=(
             "$log_location/T-PGAS-CC/log/T-PGAS.log" "$log_location/T-PRNP/log/T-PRNP.log" "$log_location/T-BJQP/log/T-BJQP.log"
             "$log_location/T-BJSP/log/T-BJSP.log" "$bin_location/T-EMIF/log/T-EMIF.log" "$log_location/T-CCNC/log/T-CCNC.log" 
             "/home/pgpro/web/T-PGADM/apache-tomcat-9.0.39/logs/T-PGADM.log" "/home/pgpro/web/T-PGMCT/apache-tomcat-9.0.39/logs/T-PGMCT.log" "/home/pgpro/web/T-PGPAY/apache-tomcat-9.0.39/logs/T-PGPAY.log" 
             "/home/pgpro/web/T-PGRSL/apache-tomcat-9.0.39/logs/T-PGRSL.log" 
            )
# 프로세스 용도 
arr_prc_desc=(
              "신용카드 결제 연동 서버" "가맹점 결제결과 API 전송 데몬" "배치업무처리 데몬"
              "배치스케쥴러 데몬" "메일 전송 데몬" "신용카드 망취소 처리 데몬"
              "관리자 사이트" "가맹점 사이트" "결제 사이트" 
              "영업점 사이트"
             )
###################################### CONFIG END ######################################

echo "                               !!!  현재 시스템은 $HOST_NAME 서버 입니다.  !!!"

# 프로세스 갯수 체크

echo -e "\n\n"
echo "                #########   PG 업무  pgpro 계정의 사용  프로세스 체크  - $now #########"
echo ""
#echo "          << $HOST_NAME 에서 사용하는 계정은 : pgpro 이며, Webtob기동은 계정별 접속하여 기동하시면 됩니다. >>"
echo ""

PADDING=""

if [ $OPT == 'S' ]
then
    PADDING="        "
    echo "$PADDING ____________________________________________________________________"
    echo "$PADDING|   프로세스명  |  정상개수 |  실제개수 |    A/S 구분   |    상 태   |"
    echo "$PADDING|_______________|___________|___________|_______________|____________|"
else
    PADDING=""
    echo "$PADDING _________________________________________________________________________________________________________________________________________________________________"
    echo "$PADDING|   프로세스명  |  정상개수 |  실제개수 |    A/S 구분   |    상 태   |                        스 크 립 트                                                         "
    echo "$PADDING|_______________|___________|___________|_______________|____________|____________________________________________________________________________________________"
fi

for (( i = 0 ; i < ${#arr_prc_nm[@]} ; i++ )) ; do
    prc_cnt=`ps -ef | grep "${arr_prc_ck[$i]}" | grep \`whoami\` | grep -v grep | grep -v vi | grep -v tail | wc -l`
    prc_succ_cnt=${arr_prc_cnt[$i]}
    prc_nm=${arr_prc_nm[$i]}

    echo -e "$PADDING|$prc_nm\t|     $prc_succ_cnt     |     $prc_cnt     |${arr_prc_as[$i]}\t|\c"
    if [ $prc_cnt -eq $prc_succ_cnt ]
    then
        echo -e "    정상    \c"
    else
        echo -e "CHECK 요망!!\c"
    fi
    
    if [ $OPT == 'S' ]
    then
        echo "|"
        echo "$PADDING|_______________|___________|___________|_______________|____________|"
    else
        echo "| 중지 : ${arr_prc_stop[$i]}"
        
        if [ ${#arr_prc_port[$i]} -ge 1 ]
        then
            prc_port="(${arr_prc_port[$i]} Port)\t"
        else
            prc_port="               "
        fi
        
        echo -e "$PADDING|$prc_port|           |           |               |            | 구동 : ${arr_prc_start[$i]}"
        echo "$PADDING|               |           |           |               |            | 로그 : ${arr_prc_log[$i]}"
        echo "$PADDING|               |           |           |               |            | 용도 : ${arr_prc_desc[$i]}"
        echo "$PADDING|_______________|___________|___________|_______________|____________|____________________________________________________________________________________________"
    fi
    
done

echo -e  "\n\n"

