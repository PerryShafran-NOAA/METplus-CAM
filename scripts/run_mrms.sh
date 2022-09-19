#!/bin/ksh --login

set -x

export cycle=t00z
export utilscript=/gpfs/dell1/nco/ops/nwprod/prod_util.v1.1.2/ush

mkdir -p /gpfs/dell2/ptmp/Perry.Shafran/run_mrms_metplus
cd /gpfs/dell2/ptmp/Perry.Shafran/run_mrms_metplus

sh $utilscript/setpdy.sh
. /gpfs/dell2/ptmp/Perry.Shafran/run_mrms_metplus/PDY

export DATE=$PDYm1

STARTDATE=${DATE}00
ENDDATE=${DATE}00
DATE=$STARTDATE

while [ $DATE -le $ENDDATE ]; do

echo $DATE > curdate
DAY=`cut -c 1-8 curdate`
YEAR=`cut -c 1-4 curdate`
MONTH=`cut -c 1-6 curdate`
HOUR=`cut -c 9-10 curdate`

bsub < run_metplus_mrms.sh

DATE=`/gpfs/dell1/nco/ops/nwprod/prod_util.v1.1.2/exec/ips/ndate +1 $DATE`

done

exit

