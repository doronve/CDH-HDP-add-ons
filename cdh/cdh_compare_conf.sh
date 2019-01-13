#!/bin/bash
#
# Name: cdh_compare_conf.sh
#
# Description: Compare between two cloudera clusters
#
# TODO:
#  - get admin password externaly
#  - get largest common api versions of both clusters
#  - compare certain areas
#

function Usage() {
  echo "Usage: $0 <cluser1> <cluster2>"
  echo "Note - cluster are expected to have admin/admin"
  exit 
}

c1=$1
c2=$2
[[ -z "$c1" ]] && Usage
[[ -z "$c2" ]] && Usage

curl -X GET -u admin:admin http://${c1}:7180/api/v10/cm/deployment > /tmp/deploymet.${c1}
curl -X GET -u admin:admin http://${c2}:7180/api/v10/cm/deployment > /tmp/deploymet.${c2}

sed -i 's/^ *//' /tmp/deploymet.${c1}
sed -i 's/^ *//' /tmp/deploymet.${c2}

echo ":%g/value/-j
:x" | ex /tmp/deploymet.${c1}

echo ":%g/value/-j
:x" | ex /tmp/deploymet.${c2}

grep value /tmp/deploymet.${c1} | sort > /tmp/deploymet.${c1}.val
grep value /tmp/deploymet.${c2} | sort > /tmp/deploymet.${c2}.val

sed -i '/role_jceks_password/d' /tmp/deploymet.${c1}.val /tmp/deploymet.${c2}.val
sed -i '/secret/d' /tmp/deploymet.${c1}.val /tmp/deploymet.${c2}.val
sed -i '/heap/d' /tmp/deploymet.${c1}.val /tmp/deploymet.${c2}.val
sed -i '/cmdb_password/d' /tmp/deploymet.${c1}.val /tmp/deploymet.${c2}.val
sed -i '/CLUSTER_STATS_START/d' /tmp/deploymet.${c1}.val /tmp/deploymet.${c2}.val
sed -i '/headlamp_database_password/d' /tmp/deploymet.${c1}.val /tmp/deploymet.${c2}.val

diff -w /tmp/deploymet.${c1}.val /tmp/deploymet.${c2}.val

rm -f /tmp/deploymet.${c1}* /tmp/deploymet.${c2}*
