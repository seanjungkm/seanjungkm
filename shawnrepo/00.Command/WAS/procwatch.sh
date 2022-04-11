#!/bin/bash

HOST_NAME=`echo \`hostname\` | awk '{print toupper($0)}'`
now=`date +%Y-%m-%d_%H:%M:%S`

MODE=`echo $1 | awk '{print toupper($0)}'`
TYPE=`echo $2 | awk '{print toupper($0)}'`

#Environment Variable Setting for Crontab
#coem
JAVA_HOME=/home/pgpro/.jdk-8u265-ojdkbuild-linux-x64
PATH=$PATH:$JAVA_HOME/bin
CLASSPATH=$JAVA_HOME/jre/lib:$JAVA_HOME/lib/tools.jar
export JAVA_HOME PATH CLASSPATH

#TYPE Check
if [ -z "$TYPE" ]
then
    TYPE="ALL"
fi

#Choice Configuration File.
if [[ $HOST_NAME =~ "REPLANITWAS1" ]]
then
    PROCESSLIST=/home/pgpro/script/processlist_replanitwas1.conf
elif [[ $HOST_NAME =~ "REPLANITWAS2" ]]
then
    PROCESSLIST=/home/pgpro/script/processlist_replanitwas2.conf
else
    echo -e "서버정보에 맞는 설정 파일이 존재하지 않습니다.\n스크립트 실행을 종료합니다."
    exit 1
fi

#Check TYPE by PROCESSLIST
if [ $TYPE != "ALL" ]
then
    PROC_CNT=`cat $PROCESSLIST | awk '{print $2}' | grep -x $TYPE | wc -l`
    if [ $PROC_CNT != 1 ]
    then
        echo -e "설정파일($PROCESSLIST)에 해당 프로세스정보($TYPE)가 존재하지 않습니다.\n스크립트 실행을 종료합니다."
        exit 1
    fi

    FIRST=`grep $TYPE $PROCESSLIST | cut -c 1`
    if [ $FIRST == "#" ]
    then 
        echo -e "해당 프로세스정보($TYPE)는 비활성화되어 있습니다.\n스크립트 실행을 종료합니다."
        exit 1
    fi
fi

#STATUS Mode
function app_status()
{
    echo -e "\t _______________________________________________________________________________________________"
    echo -e "\t|   프로세스\t|    Port\t|    PID\t|  시작시간\t|  사용시간\t|    상 태\t|"
    echo -e "\t|_______________|_______________|_______________|_______________|_______________|_______________|"
    
    if [ $TYPE == "ALL" ] 
    then 
        while read BINTYPE BINARY BINPATH
        do
            processlist_check $BINTYPE
            each_status $BINARY
        done < $1
    else
        each_status $TYPE
    fi
}

function each_status()
{
    INFO_NAME=$1
    INFO_PID=`ps -ef | grep  \`whoami\` | grep $INFO_NAME |  grep -v grep | grep -v tail | grep -v vi | grep -v watch | awk '{print $2}'`
    INFO_STIME=`ps -ef | grep  \`whoami\` | grep $INFO_NAME |  grep -v grep | grep -v tail | grep -v vi | grep -v watch | awk '{print $5}'`
    INFO_TIME=`ps -ef | grep  \`whoami\` | grep $INFO_NAME |  grep -v grep | grep -v tail | grep -v vi | grep -v watch | awk '{print $7}'`
    INFO_STATUS=`ps -ef | grep  \`whoami\` | grep $INFO_NAME |  grep -v grep | grep -v tail | grep -v vi | grep -v watch | wc -l`

    if [ -z "$INFO_PID" ]
    then 
        INFO_PORT=""
    else
        #INFO_PORT=`netstat -tnlp 2> /dev/null | grep $INFO_PID | awk '{print $4}' | grep 0.0.0.0 | awk -F':' '{print $2}'`
        INFO_PORT=`netstat -tnlp 2> /dev/null | grep $INFO_PID | awk '{print $4}' | grep ::: | awk -F':' '{print $4}'`
    fi

    INFO_NAME_LEN=`echo ${#INFO_NAME}`
    if [ $INFO_NAME_LEN -lt 7 ]
    then
        INFO_NAME=$INFO_NAME\\t\\t
    else 
        INFO_NAME=$INFO_NAME\\t
    fi

    INFO_TIME_LEN=`echo ${#INFO_TIME}`
    if [ $INFO_TIME_LEN -lt 7 ]
    then
        INFO_TIME=$INFO_TIME\\t\\t
    else
        INFO_TIME=$INFO_TIME\\t
    fi

    echo -e "\t|$INFO_NAME|$INFO_PORT\t\t|$INFO_PID\t\t|$INFO_STIME\t\t|$INFO_TIME|\c"
    
    if [ $INFO_STATUS -eq 1 ]
    then 
        echo -e "정상\t\t|"
    else 
        echo -e "확인필요\t|"
    fi

    echo -e "\t|_______________|_______________|_______________|_______________|_______________|_______________|"
}

#START Mode
function app_start()
{
    if [ $TYPE == "ALL" ]
    then

        LINE_NUM=0
        RUN_NUM=0
        
        while read BINTYPE BINARY BINPATH
        do

            processlist_check $BINTYPE
            LINE_NUM=`expr $LINE_NUM + 1`

            each_start $BINTYPE $BINARY $BINPATH

        done < $1
        callresult $LINE_NUM $RUN_NUM

    else
        BINTYPE=`grep $TYPE $PROCESSLIST | awk '{print $1}'`
        BINARY=`grep $TYPE $PROCESSLIST | awk '{print $2}'`
        BINPATH=`grep $TYPE $PROCESSLIST | awk '{print $3}'`
        each_start $BINTYPE $BINARY $BINPATH
    fi
}

function each_start()
{
    BINTYPE=$1
    BINARY=$2
    BINPATH=$3

    BINARY_LEN=`echo ${#BINARY}`
    if [ $BINARY_LEN -lt 9 ]
    then
        PAD=\\t\\t
    else
        PAD=\\t
    fi

    runcheck $BINARY

    if [ $? -eq 0 ]
    then
        echo -e "\t$BINARY$PAD: Ready - Process is not running."
        cd $BINPATH
        if [ $BINTYPE == "W" ]
        then
            ./startup.sh > /dev/null
        else
            ./start.sh > /dev/null
        fi

        sleep 2

        runcheck $BINARY

        if [ $? -eq 0 ]
        then
            printf "\t%s$PAD: %s\n" $BINARY Fail
        else
            RUN_NUM=`expr $RUN_NUM + 1`
            printf "\t%s$PAD: %s\n" $BINARY Success
        fi
    else
        RUN_NUM=`expr $RUN_NUM + 1`
        echo -e "\t$BINARY$PAD: Skip - Process is already running."
    fi
}

#STOP Mode
function app_stop()
{
    if [ $TYPE == "ALL" ]
    then

        LINE_NUM=0
        RUN_NUM=0

        while read BINTYPE BINARY BINPATH
        do

            processlist_check $BINTYPE
            LINE_NUM=`expr $LINE_NUM + 1`

            each_stop $BINTYPE $BINARY $BINPATH
            
        done < $1
        callresult $LINE_NUM $RUN_NUM

    else

        BINTYPE=`grep $TYPE $PROCESSLIST | awk '{print $1}'`
        BINARY=`grep $TYPE $PROCESSLIST | awk '{print $2}'`
        BINPATH=`grep $TYPE $PROCESSLIST | awk '{print $3}'`
        each_stop $BINTYPE $BINARY $BINPATH
    fi
}

function each_stop() 
{
    BINTYPE=$1
    BINARY=$2
    BINPATH=$3

    BINARY_LEN=`echo ${#BINARY}`
    if [ $BINARY_LEN -lt 9 ]
    then
        PAD=\\t\\t
    else
        PAD=\\t
    fi

    runcheck $BINARY

    if [ $? -eq 0 ]
    then
        RUN_NUM=`expr $RUN_NUM + 1`
        echo -e "\t$BINARY$PAD: Skip - Process is not already running."
    else
        echo -e "\t$BINARY$PAD: Ready - Process is running."
        cd $BINPATH
        if [ $BINTYPE == "W" ]
        then
            ./shutdown.sh > /dev/null
        else
            ./stop.sh > /dev/null
        fi

        sleep 2

        runcheck $BINARY

        if [ $? -eq 0 ]
        then
            RUN_NUM=`expr $RUN_NUM + 1`
            printf "\t%s$PAD: %s\n" $BINARY Success
        else
            printf "\t%s$PAD: %s\n" $BINARY Fail
        fi
    fi
}

#Process List Check
function processlist_check()
{
    FIRST=`echo $1 | cut -c 1`
    if [ $FIRST == "#" ]
    then 
        continue
    fi
}

#Process Run Check
function runcheck()
{
    return `ps -ef | grep  \`whoami\` | grep $1 |  grep -v grep | grep -v tail | grep -v vi | grep -v watch | wc -l`
}

#Basic Comment
function watch_head()
{
    echo -e "\n\n"
    echo "==================================================================================================="
    echo -e "\t\t\t\t현재 시스템은 $HOST_NAME 서버 입니다."
    echo "==================================================================================================="
    echo ""
    echo -e "\t\t\t\t\t\t\t\t실행 시간: $now"
    echo -e "\t\t\t\t\t\t\t\t실행 모드: $MODE"
    echo -e "\t\t\t\t\t\t\t\t실행 타겟: $TYPE"
    echo -e "\n"
}

function watch_tail()
{
    echo -e "\n\n"
}

#Process Call Result
function callresult()
{
    echo " "
    if [ $1 -eq $2 ]
    then 
        echo Execution Result ": All Success"
    else 
        echo Execution Result ": Fail ( You need to check processes )"
    fi
}

#case by MODE
case $MODE in
START)
    watch_head
    app_start $PROCESSLIST
    watch_tail
;;
STOP)
    watch_head
    app_stop $PROCESSLIST
    watch_tail
;;
STATUS)
    watch_head
    app_status $PROCESSLIST
    watch_tail
;;
*)
    echo "usage: process_watch [start|stop|status] [processname]"
    echo " > ex) process_watch start"
    echo "       process_watch start T-PGADM"
;;
esac

