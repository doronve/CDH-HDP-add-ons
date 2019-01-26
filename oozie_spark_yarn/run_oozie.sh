#!/bin/bash

tmpdir=`mktemp -d /tmp/oozie_spark_yarn_XXXX`
BASEDIR=`dirname $0`
export CM_HOST=$1
[[ -z "$CM_HOST" ]] && export CM_HOST=`hostname -f`
export JOB_TRACKER=$2
[[ -z "$JOB_TRACKER" ]] && export JOB_TRACKER=${CM_HOST}:8032
export NAME_NODE=$3
[[ -z "$NAME_NODE" ]] && export NAME_NODE=hdfs://${CM_HOST}:8020
cp -R $BASEDIR/* $tmpdir
cd $tmpdir

hdfs dfs -mkdir -p $tmpdir
hdfs dfs -chmod 777 $tmpdir

rm -f ${tmpdir}/job.properties ${tmpdir}/oozie.output ${tmpdir}/workflow.xml ${tmpdir}/myhive.py ${tmpdir}/run-spark-submit.sh
cp ${tmpdir}/job.properties.template     ${tmpdir}/job.properties
cp ${tmpdir}/workflow.xml.template       ${tmpdir}/workflow.xml
cp ${tmpdir}/myhive.py.template           ${tmpdir}/myhive.py
cp ${tmpdir}/run-spark-submit.sh.template ${tmpdir}/run-spark-submit.sh

sed -i 's!JOB_TRACKER!'$JOB_TRACKER'!g' ${tmpdir}/job.properties
sed -i 's!USER!'$USER'!g'               ${tmpdir}/job.properties
sed -i 's!NAME_NODE!'$NAME_NODE'!g'     ${tmpdir}/job.properties
sed -i 's!TMPDIR!'$tmpdir'!g'           ${tmpdir}/job.properties
sed -i 's!TMPDIR!'$tmpdir'!g'           ${tmpdir}/workflow.xml
sed -i 's!TMPDIR!'$tmpdir'!g'           ${tmpdir}/myhive.py
sed -i 's!TMPDIR!'$tmpdir'!g'           ${tmpdir}/run-spark-submit.sh

clush -a -c $tmpdir/
clush -a chmod 777 $tmpdir
hdfs dfs -put -f $tmpdir/* $tmpdir/.
oozie job -run -config $tmpdir/job.properties 2>&1 | tee $tmpdir/oozie.output
jobid=`awk '{print $NF}' $tmpdir/oozie.output`
echo oozie job -info $jobid
oozie job -info $jobid
echo oozie job -info $jobid -verbose
