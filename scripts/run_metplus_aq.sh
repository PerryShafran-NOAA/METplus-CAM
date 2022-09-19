#PBS -N metplus_aq
#PBS -j oe
#PBS -o /lfs/h2/emc/ptmp/perry.shafran/output/metplus_aq.out
#PBS -e /lfs/h2/emc/ptmp/perry.shafran/output/metplus_aq.out
#PBS -q "dev"
#PBS -A VERF-DEV
#PBS -S /bin/bash
#PBS -l select=1:ncpus=1:mem=3000MB
#PBS -l walltime=02:00:00
#PBS -l debug=true

set -x

export cycle=t00z
export MET_PLUS_TMP=/lfs/h2/emc/ptmp/perry.shafran/metplus_aq

module purge
export HPC_OPT=/apps/ops/para/libs
module use /apps/ops/para/libs/modulefiles/compiler/intel/19.1.3.304/
module load intel
module load gsl
module load python/3.8.6
module load netcdf/4.7.4
module load met/10.0.1
module load metplus/4.0.0

module load prod_util/2.0.13
module load prod_envir/2.0.6

#export MET_BASE=/apps/ops/para/libs/intel/19.1.3.304/met/10.1.1/share/met
#export MET_ROOT=/apps/ops/para/libs/intel/19.1.3.304/met/10.1.1

rm -f -r $MET_PLUS_TMP
mkdir -p $MET_PLUS_TMP
cd $MET_PLUS_TMP

sh setpdy.sh
. $MET_PLUS_TMP/PDY

export DATE=$PDYm3
export DATEP1=$PDYm2
export DATE=20220814
export DATEP1=20220815
export MET_PLUS_CONF=/lfs/h2/emc/vpppg/save/perry.shafran/METplus-4.0.0/parm/use_cases/perry
export MET_PLUS_OUT=/lfs/h2/emc/vpppg/noscrub/perry.shafran/metplus_aq
export MET_PLUS_STD=/lfs/h2/emc/ptmp/perry.shafran/metplus_aq

cat << EOF > shared.conf_aq
[config]
VALID_BEG = ${DATE}01
VALID_END = ${DATEP1}00

OBS_WINDOW_BEGIN = -86400
OBS_WINDOW_END = 86400

VALID_INCREMENT = 1H
INIT_SEQ = 6, 12
LEAD_SEQ_MAX = 72
EOF

model=aq
model1=`echo $model | tr a-z A-Z`
echo $model1


cat << EOF > ${model}.conf
[dir]
#FCST_POINT_STAT_INPUT_DIR = /lfs/h1/ops/prod/com/aqm/v6.1
FCST_POINT_STAT_INPUT_DIR = /lfs/h2/emc/physics/noscrub/ho-chun.huang/verification/aqm/v70c3
OBS_POINT_STAT_INPUT_DIR = {OUTPUT_BASE}/aqm/conus_sfc
#PB2NC_INPUT_DIR = /lfs/h1/ops/prod/com/obsproc/v1.0
PB2NC_INPUT_DIR = /lfs/h2/emc/vpppg/noscrub/perry.shafran/com/hourly/v0.0
[config]
PB2NC_OBS_BUFR_VAR_LIST= COPO
METPLUS_CONF = {OUTPUT_BASE}/conf/${model}/metplus_final_pb2nc_pointstat.conf
POINT_STAT_CONFIG_FILE ={METPLUS_PARM_BASE}/met_config/PointStatConfig_AIRNOW
#LEAD_SEQ = begin_end_incr(1,72,1)
MODEL = ${model1}
FCST_VAR1_NAME = OZCON
FCST_VAR1_LEVELS = L1
FCST_VAR1_OPTIONS = set_attr_name = "OZCON1";
OBS_VAR1_NAME= COPO
OBS_VAR1_LEVELS= A1
OBS_VAR1_OPTIONS =  convert(x) = x * 10^9;
FCST_VAR2_NAME = OZCON
FCST_VAR2_LEVELS = A8
FCST_VAR2_OPTIONS = set_attr_name = "OZCON8";
OBS_VAR2_NAME= COPO
OBS_VAR2_LEVELS= A8
OBS_VAR2_OPTIONS =  convert(x) = x * 10^9;
[filename_templates]
FCST_POINT_STAT_INPUT_TEMPLATE = cs.{init?fmt=%Y%m%d}/aqm.t{init?fmt=%2H}z.awpozcon.f{lead?fmt=%2H}.793.grib2
#OBS_POINT_STAT_INPUT_TEMPLATE = prepbufr.aqm.{valid?fmt=%Y%m%d%H}.nc
OBS_POINT_STAT_INPUT_TEMPLATE = prepbufr.aqm.${DATE}.nc
POINT_STAT_OUTPUT_TEMPLATE = ${model}
PB2NC_INPUT_TEMPLATE = hourly.{da_init?fmt=%Y%m%d}/aqm.t12z.prepbufr.tm00
#PB2NC_OUTPUT_TEMPLATE  = prepbufr.aqm.{valid?fmt=%Y%m%d%H}.nc
PB2NC_OUTPUT_TEMPLATE = prepbufr.aqm.${DATE}.nc
EOF

run_metplus.py -c ${MET_PLUS_CONF}/pb2nc_aq.conf -c ${MET_PLUS_CONF}/point_stat_aq.conf -c ${MET_PLUS_TMP}/${model}.conf -c ${MET_PLUS_CONF}/shared.conf -c ${MET_PLUS_TMP}/shared.conf_aq -c ${MET_PLUS_CONF}/system_aq.conf

cat << EOF > statanalysis.conf
[dir]
STAT_ANALYSIS_OUTPUT_DIR = {OUTPUT_BASE}/stat/aqm
MODEL1_STAT_ANALYSIS_LOOKIN_DIR = {OUTPUT_BASE}/aqm/stat/${model}/*{VALID_BEG}*
[config]
VALID_BEG = ${DATE}
VALID_END = ${DATE}
MODEL = $model
MODEL1 = $model1
EOF

run_metplus.py -c ${MET_PLUS_CONF}/system_aq.conf -c ${MET_PLUS_CONF}/StatAnalysis_gatherByDay.conf -c ${MET_PLUS_TMP}/statanalysis.conf


#${MET_PLUS}/ush/master_metplus.py -c ${MET_PLUS}/parm/use_cases/grid_to_obs/grid_to_obs.conf -c ${MET_PLUS}/parm/use_cases/grid_to_obs/examples/conus_surface.conf -c ${MET_PLUS_CONF}/pb2nc_aq.conf -c ${MET_PLUS_CONF}/point_stat_aq.conf -c ${MET_PLUS_TMP}/${model}.conf -c ${MET_PLUS_CONF}/shared.conf -c ${MET_PLUS_TMP}/shared.conf_aq -c ${MET_PLUS_CONF}/system_aq.conf -c ${MET_PLUS_CONF}/StatAnalysis_gatherByHour_aq.conf -c ${MET_PLUS_TMP}/statanalysis.conf

model=pm
model1=`echo $model | tr a-z A-Z`
echo $model1

cat << EOF > ${model}.conf
[dir]
#FCST_POINT_STAT_INPUT_DIR = /lfs/h1/ops/prod/com/aqm/v6.1
FCST_POINT_STAT_INPUT_DIR = /lfs/h2/emc/physics/noscrub/ho-chun.huang/verification/aqm/v70c3
OBS_POINT_STAT_INPUT_DIR = {OUTPUT_BASE}/aqm/conus_sfc
#PB2NC_INPUT_DIR = /lfs/h1/ops/prod/com/obsproc/v1.0
PB2NC_INPUT_DIR = /lfs/h2/emc/vpppg/noscrub/perry.shafran/com/hourly/v0.0
[config]
PB2NC_OBS_BUFR_VAR_LIST= COPOPM
METPLUS_CONF = {OUTPUT_BASE}/conf/${model}/metplus_final_pb2nc_pointstat.conf
POINT_STAT_CONFIG_FILE ={METPLUS_PARM_BASE}/met_config/PointStatConfig_ANOWPM
###LEAD_SEQ = begin_end_incr(0,72,1)
FCST_VAR1_NAME = PMTF
FCST_VAR1_LEVELS = L1
OBS_VAR1_NAME= COPOPM
OBS_VAR1_LEVELS= A1
OBS_VAR1_OPTIONS =  convert(x) = x * 10^9;
MODEL = ${model1}
[filename_templates]
FCST_POINT_STAT_INPUT_TEMPLATE = cs.{init?fmt=%Y%m%d}/aqm.t{init?fmt=%2H}z.pm25.f{lead?fmt=%2H}.793.grib2
#OBS_POINT_STAT_INPUT_TEMPLATE = prepbufr.pm.{valid?fmt=%Y%m%d%H}.nc
OBS_POINT_STAT_INPUT_TEMPLATE = prepbufr.pm.${DATE}.nc
POINT_STAT_OUTPUT_TEMPLATE = ${model}
PB2NC_INPUT_TEMPLATE = hourly.{da_init?fmt=%Y%m%d?shift=86400}/aqm.t12z.anowpm.pb.tm024
#PB2NC_OUTPUT_TEMPLATE  = prepbufr.pm.{valid?fmt=%Y%m%d%H}.nc
PB2NC_OUTPUT_TEMPLATE = prepbufr.pm.${DATE}.nc
EOF

run_metplus.py -c  ${MET_PLUS_CONF}/pb2nc_aq.conf -c ${MET_PLUS_CONF}/point_stat_aq.conf -c ${MET_PLUS_TMP}/${model}.conf -c ${MET_PLUS_CONF}/shared.conf -c ${MET_PLUS_TMP}/shared.conf_aq -c ${MET_PLUS_CONF}/system_aq.conf

cat << EOF > statanalysis.conf
[dir]
STAT_ANALYSIS_OUTPUT_DIR = {OUTPUT_BASE}/stat/pm
MODEL1_STAT_ANALYSIS_LOOKIN_DIR = {OUTPUT_BASE}/aqm/stat/{MODEL}/*{VALID_BEG}*
[config]
VALID_BEG = $DATE
VALID_END = $DATE
MODEL = $model
MODEL1 = $model1
EOF

run_metplus.py -c ${MET_PLUS_CONF}/system_aq.conf ${MET_PLUS_CONF}/StatAnalysis_gatherByDay.conf ${MET_PLUS_TMP}/statanalysis.conf


mv ${MET_PLUS_OUT}/logs/master_metplus.log.${DATEP1} ${MET_PLUS_TMP}

exit
