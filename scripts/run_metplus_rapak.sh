#PBS -N metplus_rapak
#PBS -j oe
#PBS -o /lfs/h2/emc/ptmp/perry.shafran/output/metplus_rapak.out
#PBS -e /lfs/h2/emc/ptmp/perry.shafran/output/metplus_rapak.out
#PBS -q "dev"
#PBS -A VERF-DEV
#PBS -S /bin/bash
#PBS -l select=1:ncpus=1:mem=8500MB
#PBS -l walltime=08:00:00
#PBS -l debug=true


set -x

export cycle=t00z
export MET_PLUS_TMP=/lfs/h2/emc/ptmp/perry.shafran/metplus_rapak

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
export MET_PLUS_STD=/lfs/h2/emc/ptmp/perry.shafran/metplus_rapak

mkdir -p $MET_PLUS_STD

export model=rapak
model1=`echo $model | tr a-z A-Z`
echo $model1

cat << EOF > shared_${model}.conf
[config]
VALID_BEG = ${DATE}00
VALID_END = ${DATE}23
EOF

cat << EOF > ${model}.conf
[dir]
FCST_POINT_STAT_INPUT_DIR = /lfs/h1/ops/prod/com/rap/v5.1
OBS_POINT_STAT_INPUT_DIR = {OUTPUT_BASE}/cam/alaska_cam
[config]
METPLUS_CONF = {OUTPUT_BASE}/conf/${model}/metplus_final_pb2nc_pointstat.conf
POINT_STAT_CONFIG_FILE ={METPLUS_PARM_BASE}/met_config/PointStatConfig_cam_ak
LEAD_SEQ = begin_end_incr(0,51,1)
MODEL = ${model1}
POINT_STAT_GRID = G216
BOTH_VAR7_NAME = MSLMA
BOTH_VAR8_OPTIONS = censor_thresh = gt16090; censor_val = 16090; desc = "GSL";
[filename_templates]
FCST_POINT_STAT_INPUT_TEMPLATE = rap.{init?fmt=%Y%m%d}/rap.t{init?fmt=%2H}z.awp242f{lead?fmt=%2H}.grib2
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

###mv ${MET_PLUS_OUT}/logs/master_metplus.log.${DATEP1} ${MET_PLUS_TMP}

/gpfs/dell2/emc/verification/save/Perry.Shafran/aws/mv_load_to_aws.sh perry.shafran ${MET_PLUS_TMP}/stat/ ${MET_PLUS_TMP}/load_met_rapak.xml

cp /gpfs/dell2/ptmp/Perry.Shafran/output/metplus_rapak.out $MET_PLUS_STD/metplus_rapak_$DATE.out

exit
