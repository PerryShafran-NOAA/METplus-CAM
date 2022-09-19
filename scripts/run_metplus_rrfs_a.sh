#PBS -N metplus_rrfs_a
#PBS -j oe
#PBS -o /lfs/h2/emc/ptmp/perry.shafran/output/metplus_rrfs_a.out
#PBS -e /lfs/h2/emc/ptmp/perry.shafran/output/metplus_rrfs_a.out
#PBS -q "dev"
#PBS -A VERF-DEV
#PBS -S /bin/bash
#PBS -l select=1:ncpus=1:mem=2GB
#PBS -l walltime=10:00:00
#PBS -l debug=true

set -x

export cycle=t00z
export MET_PLUS_TMP=/lfs/h2/emc/ptmp/perry.shafran/metplus_rrfs

module purge
export HPC_OPT=/apps/ops/para/libs
module use /apps/ops/para/libs/modulefiles/compiler/intel/19.1.3.304/
module load intel
module load gsl
module load python/3.8.6
module load netcdf/4.7.4
module load met/10.1.1
module load metplus/4.1.1

module load prod_util/2.0.13
module load prod_envir/2.0.6

rm -f -r $MET_PLUS_TMP
mkdir -p $MET_PLUS_TMP
cd $MET_PLUS_TMP


sh setpdy.sh
. $MET_PLUS_TMP/PDY

export DATE=$PDYm1
export DATEP1=$PDY
export MET_PLUS_CONF=/lfs/h2/emc/vpppg/save/perry.shafran/METplus-4.0.0/parm/use_cases/perry
export MET_PLUS_OUT=/lfs/h2/emc/vpppg/noscrub/perry.shafran/metplus_cam
export MET_PLUS_STD=/lfs/h2/emc/ptmp/perry.shafran/metplus_rrfs

mkdir -p $MET_PLUS_STD

export model=rrfs_a
model1=`echo $model | tr a-z A-Z`
echo $model1

cat << EOF > shared_${model}.conf
[config]
VALID_BEG = ${DATE}00
VALID_END = ${DATE}23
EOF

cat << EOF > ${model}.conf
[dir]
FCST_POINT_STAT_INPUT_DIR = /lfs/h2/emc/ptmp/Shun.Liu/rrfs_a/para
OBS_POINT_STAT_INPUT_DIR = {OUTPUT_BASE}/cam/conus_cam
[config]
LOG_MET_VERBOSITY = 7
METPLUS_CONF = {OUTPUT_BASE}/conf/${model}/metplus_final_pb2nc_pointstat.conf
#LEAD_SEQ = begin_end_incr(0,60,1)
INIT_SEQ = 00, 12
LEAD_SEQ_MAX = 36
MODEL = ${model1}
BOTH_VAR8_OPTIONS = GRIB_lvl_typ = 1; censor_thresh = gt16090; censor_val = 16090; desc = "EMC";
FCST_VAR16_NAME = VIS
FCST_VAR16_LEVELS = L0
FCST_VAR16_THRESH =  <805, <1609, <4828, <8045 ,>=8045, <16090
FCST_VAR16_OPTIONS = GRIB_lvl_typ = 3; desc = "GSL"; censor_thresh = gt16090; censor_val = 16090;
OBS_VAR16_NAME = VIS
OBS_VAR16_LEVELS = L0
OBS_VAR16_THRESH =  <805, <1609, <4828, <8045 ,>=8045, <16090
OBS_VAR16_OPTIONS = censor_thresh = gt16090; censor_val = 16090; desc = "GSL";
FCST_VAR17_NAME = CAPE
FCST_VAR17_LEVELS = P90-0
FCST_VAR17_OPTIONS = cnt_thresh = [ >0 ];
FCST_VAR17_THRESH = >500, >1000, >1500, >2000, >3000, >4000
OBS_VAR17_NAME = MLCAPE
OBS_VAR17_LEVELS = L0-100000
OBS_VAR17_OPTIONS = cnt_thresh = [ >0 ]; cnt_logic = UNION;
OBS_VAR17_THRESH = >500, >1000, >1500, >2000, >3000, >4000
[filename_templates]
FCST_POINT_STAT_INPUT_TEMPLATE = rrfs_a.{init?fmt=%Y%m%d}/{init?fmt=%2H}/rrfs.t{init?fmt=%2H}z.prslev.f{lead?fmt=%3H}.conus_3km.grib2
POINT_STAT_OUTPUT_TEMPLATE = ${model}
EOF

run_metplus.py -c  ${MET_PLUS_CONF}/pb2nc_cam.conf -c ${MET_PLUS_CONF}/point_stat_cam.conf -c ${MET_PLUS_TMP}/${model}.conf -c ${MET_PLUS_CONF}/shared.conf -c ${MET_PLUS_TMP}/shared_${model}.conf -c ${MET_PLUS_CONF}/system_cam.conf

mkdir -p ${MET_PLUS_STD}/stat/${model}
cp ${MET_PLUS_OUT}/cam/stat/${model}/*${DATE}* ${MET_PLUS_STD}/stat/${model}
mv ${MET_PLUS_OUT}/logs/master_metplus.log.${DATEP1} ${MET_PLUS_TMP}/master_metplus.log.${DATEP1}_${model}

cat << EOF > statanalysis.conf
[config]
VALID_BEG = $DATE
VALID_END = $DATE
MODEL = $model
MODEL1 = $model1
EOF

run_metplus.py -c ${MET_PLUS_CONF}/system_cam.conf ${MET_PLUS_CONF}/StatAnalysis_gatherByDay.conf ${MET_PLUS_TMP}/statanalysis.conf

exit

