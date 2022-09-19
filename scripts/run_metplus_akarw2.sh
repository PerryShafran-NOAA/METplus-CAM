#PBS -N metplus_akarw2
#PBS -j oe
#PBS -o /lfs/h2/emc/ptmp/perry.shafran/output/metplus_akarw2.out
#PBS -e /lfs/h2/emc/ptmp/perry.shafran/output/metplus_akarw2.out
#PBS -q "dev"
#PBS -A VERF-DEV
#PBS -S /bin/bash
#PBS -l select=1:ncpus=1:mem=1GB
#PBS -l walltime=04:00:00
#PBS -l debug=true

set -x

export cycle=t00z
export MET_PLUS_TMP=/lfs/h2/emc/ptmp/perry.shafran/metplus_akarw2

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

export MET_BASE=/apps/ops/para/libs/intel/19.1.3.304/met/10.1.1/share/met
export MET_ROOT=/apps/ops/para/libs/intel/19.1.3.304/met/10.1.1

rm -f -r $MET_PLUS_TMP
mkdir -p $MET_PLUS_TMP
cd $MET_PLUS_TMP

sh setpdy.sh
. $MET_PLUS_TMP/PDY

export DATE=$PDYm1
export DATEP1=$PDY
export MET_PLUS_CONF=/lfs/h2/emc/vpppg/save/perry.shafran/METplus-4.0.0/parm/use_cases/perry
export MET_PLUS_OUT=/lfs/h2/emc/vpppg/noscrub/perry.shafran/metplus_cam
export MET_PLUS_STD=/lfs/h2/emc/ptmp/perry.shafran/metplus_akarw2

mkdir -p $MET_PLUS_STD

export model=akarw2
model1=`echo $model | tr a-z A-Z`
echo $model1

cat << EOF > shared_${model}.conf
[config]
VALID_BEG = ${DATE}00
VALID_END = ${DATE}23
EOF

cat << EOF > ${model}.conf
[dir]
FCST_POINT_STAT_INPUT_DIR = /lfs/h1/ops/prod/com/hiresw/v8.1
OBS_POINT_STAT_INPUT_DIR = {OUTPUT_BASE}/cam/alaska_cam
[config]
METPLUS_CONF = {OUTPUT_BASE}/conf/${model}/metplus_final_pb2nc_pointstat.conf
POINT_STAT_CONFIG_FILE ={METPLUS_PARM_BASE}/met_config/PointStatConfig_cam_ak
LEAD_SEQ = begin_end_incr(0,48,1)
MODEL = ${model1}
POINT_STAT_GRID = G216
[filename_templates]
FCST_POINT_STAT_INPUT_TEMPLATE = hiresw.{init?fmt=%Y%m%d}/hiresw.t{init?fmt=%2H}z.arw_5km.f{lead?fmt=%2H}.akmem2.grib2
POINT_STAT_OUTPUT_TEMPLATE = ${model}
EOF

run_metplus.py -c ${MET_PLUS_CONF}/pb2nc_cam_ak.conf -c ${MET_PLUS_CONF}/point_stat_cam.conf -c ${MET_PLUS_TMP}/${model}.conf -c ${MET_PLUS_CONF}/shared.conf -c ${MET_PLUS_TMP}/shared_${model}.conf -c ${MET_PLUS_CONF}/system_cam.conf

mkdir -p ${MET_PLUS_TMP}/stat/${model}
cp ${MET_PLUS_OUT}/cam/stat/${model}/*${DATE}* ${MET_PLUS_TMP}/stat/${model}
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
