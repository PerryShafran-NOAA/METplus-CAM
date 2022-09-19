#PBS -N metplus_rtma
#PBS -j oe
#PBS -o /lfs/h2/emc/ptmp/perry.shafran/output/metplus_rtma.out
#PBS -e /lfs/h2/emc/ptmp/perry.shafran/output/metplus_rtma.out
#PBS -q "dev"
#PBS -A VERF-DEV
#PBS -S /bin/bash
#PBS -l select=1:ncpus=1:mem=6000MB
#PBS -l walltime=02:00:00
#PBS -l debug=true


set -x

export cycle=t00z
export MET_PLUS_TMP=/lfs/h2/emc/ptmp/perry.shafran/metplus_rtma

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

rm -f -r $MET_PLUS_TMP
mkdir -p $MET_PLUS_TMP
cd $MET_PLUS_TMP

sh setpdy.sh
. $MET_PLUS_TMP/PDY

export DATE=$PDYm1
export DATEP1=$PDY
export MET_PLUS_CONF=/lfs/h2/emc/vpppg/save/perry.shafran/METplus-4.0.0/parm/use_cases/perry
export MET_PLUS_OUT=/lfs/h2/emc/vpppg/noscrub/perry.shafran/metplus_rtma
export MET_PLUS_STD=/lfs/h2/emc/ptmp/perry.shafran/metplus_rtma_${DATE}

mkdir -p $MET_PLUS_STD

export model=rtma
model1=`echo $model | tr a-z A-Z`
echo $model1

cat << EOF > shared_${model}.conf
[config]
VALID_BEG = ${DATE}00
VALID_END = ${DATE}23
EOF

cat << EOF > ${model}.conf
[dir]
FCST_POINT_STAT_INPUT_DIR = /lfs/h1/ops/prod/com/rtma/v2.9
OBS_POINT_STAT_INPUT_DIR = {OUTPUT_BASE}/cam/conus_cam
[config]
POINT_STAT_CONFIG_FILE = {PARM_BASE}/met_config/PointStatConfig_wrapped
METPLUS_CONF = {OUTPUT_BASE}/conf/${model}/metplus_final_pb2nc_pointstat.conf
##LEAD_SEQ = 00
BOTH_VAR8_OPTIONS = GRIB_lvl_typ = 1; censor_thresh = gt16090; censor_val = 16090; desc = "EMC";
OBS_VAR10_NAME = HGT
FCST_VAR10_NAME = CEIL
FCST_VAR10_LEVELS = L0
FCST_VAR10_OPTIONS = GRIB_lvl_typ = 215; desc = "CEILING"
FCST_VAR10_THRESH = <152, <305, <914, <1520, <3040, >=914
FCST_VAR16_NAME = VIS
FCST_VAR16_LEVELS = L0
FCST_VAR16_THRESH =  <805, <1609, <4828, <8045 ,>=8045, <16090
FCST_VAR16_OPTIONS = GRIB_lvl_typ = 3; desc = "GSL"; censor_thresh = gt16090; censor_val = 16090;
OBS_VAR16_NAME = VIS
OBS_VAR16_LEVELS = L0
OBS_VAR16_THRESH =  <805, <1609, <4828, <8045 ,>=8045, <16090
OBS_VAR16_OPTIONS = censor_thresh = gt16090; censor_val = 16090; desc = "GSL";
FCST_VAR17_NAME = WIND
FCST_VAR17_LEVELS = Z10
OBS_VAR17_NAME = WIND
OBS_VAR17_LEVELS = Z10
POINT_STAT_OUTPUT_FLAG_SL1L2 = STAT
POINT_STAT_OUTPUT_FLAG_CTC = STAT
MODEL = ${model1}
[filename_templates]
FCST_POINT_STAT_INPUT_TEMPLATE = rtma2p5.{init?fmt=%Y%m%d}/rtma2p5.t{init?fmt=%2H}z.2dvaranl_ndfd.grb2
POINT_STAT_OUTPUT_TEMPLATE = ${model}
EOF

#model1=`echo $model | tr a-z A-Z`
#echo $model1

run_metplus.py -c  ${MET_PLUS_CONF}/pb2nc_cam.conf -c ${MET_PLUS_CONF}/point_stat_cam.conf -c ${MET_PLUS_TMP}/${model}.conf -c ${MET_PLUS_CONF}/shared.conf -c ${MET_PLUS_TMP}/shared_${model}.conf -c ${MET_PLUS_CONF}/system_rtma.conf 

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

###mv ${MET_PLUS_OUT}/logs/master_metplus.log.${DATEP1} ${MET_PLUS_TMP}

#cp ${MET_PLUS_CONF}/load_met.xml load_met_${model}.xml

exit

cat << EOF > load_met_${model}.xml
<load_spec>
  <connection>
    <host>metviewer-dev-cluster.cluster-czbts4gd2wm2.us-east-1.rds.amazonaws.com:3306</host>
    <database>mv_meso_grid2obs_2021_metplus</database>
    <user>rds_user</user>
    <password>rds_pwd</password>
    <management_system>aurora</management_system>
  </connection>

  <met_version>V6.1</met_version>

  <verbose>true</verbose>
  <insert_size>1</insert_size>
  <mode_header_db_check>true</mode_header_db_check>
  <stat_header_db_check>true</stat_header_db_check>
  <drop_indexes>false</drop_indexes>
  <apply_indexes>true</apply_indexes>
  <load_stat>true</load_stat>
  <load_mode>true</load_mode>
  <load_mpr>true</load_mpr>
  <load_orank>true</load_orank>
  <force_dup_file>true</force_dup_file>
  <group>EMC Regional CAM</group>
  <description>Regional Meso METplus data</description>
 <folder_tmpl>/base_dir/{model}</folder_tmpl>
  <load_val>
    <field name="model">
      <val>${model}</val>
    </field>
  </load_val>


  <load_xml>true</load_xml>
</load_spec>
EOF

/gpfs/dell2/emc/verification/save/Perry.Shafran/aws/mv_load_to_aws.sh perry.shafran ${MET_PLUS_TMP}/stat/ ${MET_PLUS_TMP}/load_met_nam.xml

cp /gpfs/dell2/ptmp/Perry.Shafran/output/metplus_nam.out $MET_PLUS_STD/metplus_nam_$DATE.out

exit
