#!/bin/ksh

set -x

export cycle=t00z
export utilscript=/nwprod/util/ush
export utilexec=/nwprod/util/exec
export EXECutil=/nwprod/util/exec
export MET_PLUS_TMP=/stmpp1/Perry.Shafran/metplus

rm -f -r $MET_PLUS_TMP
mkdir -p $MET_PLUS_TMP
cd $MET_PLUS_TMP

sh $utilscript/setup.sh
sh $utilscript/setpdy.sh
. $MET_PLUS_TMP/PDY

export DATE=$PDYm1
export DATEP1=$PDY
export MET_PLUS=/meso/save/Perry.Shafran/METplus-2.1
export MET_PLUS_CONF=/meso/save/Perry.Shafran/METplus-2.1/parm/use_cases/perry
export MET_PLUS_OUT=/meso/noscrub/Perry.Shafran/metplus

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

for model in nam conusnest fv3sar fv3sarx
do

${MET_PLUS}/ush/master_metplus.py -c ${MET_PLUS}/parm/use_cases/grid_to_obs/grid_to_obs.conf -c ${MET_PLUS}/parm/use_cases/grid_to_obs/examples/conus_surface.conf -c ${MET_PLUS_CONF}/pb2nc.conf -c ${MET_PLUS_CONF}/point_stat_${model}.conf -c ${MET_PLUS_TMP}/shared.conf -c ${MET_PLUS_CONF}/perry.system.conf.tide

done
mv ${MET_PLUS_OUT}/logs/master_metplus.log.${DATEP1} ${MET_PLUS_TMP}

exit
