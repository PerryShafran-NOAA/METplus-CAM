#!/bin/ksh

set -x

module unload python/2.7.14
module load python/3.6.3

export cycle=t00z
export utilscript=/nwprod/util/ush
export utilexec=/nwprod/util/exec
export EXECutil=/nwprod/util/exec
export MET_PLUS_TMP=/stmpp1/Perry.Shafran/metplus_hrrrx

rm -f -r $MET_PLUS_TMP
mkdir -p $MET_PLUS_TMP
cd $MET_PLUS_TMP

sh $utilscript/setup.sh
sh $utilscript/setpdy.sh
. $MET_PLUS_TMP/PDY

export DATE=$PDYm1
export DATEP1=$PDY
export MET_PLUS=/meso/save/Perry.Shafran/METplus-3.0-beta1
export MET_PLUS_CONF=/meso/save/Perry.Shafran/METplus-3.0-beta1/parm/use_cases/perry
export MET_PLUS_OUT=/meso/noscrub/Perry.Shafran/metplus_hrrr
export MET_PLUS_STD=/ptmpp1/Perry.Shafran/metplus_hrrrx

mkdir -p $MET_PLUS_STD

cat << EOF > shared.conf
[config]

# Time method by which to perform validation, either by init time or by valid
# time. Indicate by either BY_VALID or BY_INIT
#TIME_METHOD = BY_VALID
LOOP_BY = VALID

# For processing by init time or valid time, indicate the start and end hours
# in HH format                                                             
VALID_TIME_FMT = %Y%m%d%H

VALID_BEG = ${DATE}00
VALID_END = ${DATE}23

# Indicate the begin and end date, and interval (in hours)                                                        
#BEG_TIME = 20190502
#END_TIME = 20190502
#INTERVAL_TIME = 1
VALID_INCREMENT = 3600

# start and end dates are created by combining the date with
# start and end hours (format can be hh, hhmm, or hhmmss.                                                         
#START_DATE = {BEG_TIME}{START_HOUR}
#END_DATE = {END_TIME}{END_HOUR}

# The obs window dictionary
OBS_WINDOW_BEGIN = -1080
OBS_WINDOW_END = 1080
EOF

for model in hrrrx
do

${MET_PLUS}/ush/master_metplus.py -c ${MET_PLUS}/parm/use_cases/grid_to_obs/grid_to_obs.conf -c ${MET_PLUS}/parm/use_cases/grid_to_obs/examples/conus_surface.conf -c ${MET_PLUS_CONF}/pb2nc_raphrrr.conf -c ${MET_PLUS_CONF}/point_stat_${model}.conf -c ${MET_PLUS_TMP}/shared.conf -c ${MET_PLUS_CONF}/system_hrrr.conf

mkdir -p ${MET_PLUS_TMP}/stat/${model}
cp ${MET_PLUS_OUT}/cam/stat/${model}/*${DATE}* ${MET_PLUS_TMP}/stat/${model}
mv ${MET_PLUS_OUT}/logs/master_metplus.log.${DATEP1} ${MET_PLUS_TMP}/master_metplus.log.${DATEP1}_${model}

done

###mv ${MET_PLUS_OUT}/logs/master_metplus.log.${DATEP1} ${MET_PLUS_TMP}

/meso/save/Perry.Shafran/aws/mv_load_to_aws.sh perry.shafran ${MET_PLUS_TMP}/stat/ /meso/save/Perry.Shafran/aws/load_met_raphrrrx.xml

cp /ptmpp2/Perry.Shafran/output/metplus_hrrrx.out $MET_PLUS_STD/metplus_hrrrx_$DATE.out

exit
