#PBS -N metplus_pcp_nam
#PBS -j oe
#PBS -o /lfs/h2/emc/ptmp/perry.shafran/output/metplus_pcp_nam.out
#PBS -e /lfs/h2/emc/ptmp/perry.shafran/output/metplus_pcp_nam.out
#PBS -q "dev"
#PBS -A VERF-DEV
#PBS -S /bin/bash
#PBS -l select=1:ncpus=1:mem=3000MB
#PBS -l walltime=02:00:00
#PBS -l debug=true


set -x

export cycle=t00z
export MET_PLUS_TMP=/lfs/h2/emc/ptmp/perry.shafran/metplus_pcp_nam

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

export DATE=$PDYm2
export DATEP1=$PDY

export MET_PLUS_CONF=/lfs/h2/emc/vpppg/save/perry.shafran/METplus-4.0.0/parm/use_cases/precip
export MET_PLUS_OUT=/lfs/h2/emc/vpppg/noscrub/perry.shafran/metplus_pcp
export MET_PLUS_STD=/lfs/h2/emc/ptmp/perry.shafran/metplus_pcp_nam

mkdir -p $MET_PLUS_STD

export model=nam
model1=`echo $model | tr a-z A-Z`
echo $model1

export model_dir=/lfs/h1/ops/prod/com/nam/v4.2
export EXPTDIR=/lfs/h2/emc/vpppg/noscrub/perry.shafran/metplus_pcp
export OBS_DIR=/lfs/h2/emc/ptmp/perry.shafran/ccpa
export acc=1hr
export fhr_list="begin_end_incr(0,84,1)"
export CDATE=${DATE}00

export METPLUS_PATH=${MET_PLUS}
export MET_INSTALL_DIR=/apps/ops/para/libs/intel/19.1.3.304/met/10.1.1
export METPLUS_CONF=/lfs/h2/emc/vpppg/save/perry.shafran/METplus-4.0.0/parm
export MET_CONFIG=/lfs/h2/emc/vpppg/save/perry.shafran/METplus-4.0.0/parm/met_config

mkdir -p /lfs/h2/emc/ptmp/perry.shafran/ccpa/ccpa.$PDYm2
mkdir -p /lfs/h2/emc/ptmp/perry.shafran/ccpa/ccpa.$PDYm3
mkdir -p /lfs/h2/emc/ptmp/perry.shafran/ccpa/ccpa.$PDYm4
mkdir -p /lfs/h2/emc/ptmp/perry.shafran/ccpa/ccpa.$PDYm5

cp /lfs/h1/ops/prod/com/ccpa/v4.2/ccpa.$PDYm4/00/ccpa.*.03h.hrap.conus.gb2 /lfs/h2/emc/ptmp/perry.shafran/ccpa/ccpa.$PDYm4
cp /lfs/h1/ops/prod/com/ccpa/v4.2/ccpa.$PDYm4/06/ccpa.*.03h.hrap.conus.gb2 /lfs/h2/emc/ptmp/perry.shafran/ccpa/ccpa.$PDYm4
cp /lfs/h1/ops/prod/com/ccpa/v4.2/ccpa.$PDYm4/12/ccpa.*.03h.hrap.conus.gb2 /lfs/h2/emc/ptmp/perry.shafran/ccpa/ccpa.$PDYm4
cp /lfs/h1/ops/prod/com/ccpa/v4.2/ccpa.$PDYm4/18/ccpa.*.03h.hrap.conus.gb2 /lfs/h2/emc/ptmp/perry.shafran/ccpa/ccpa.$PDYm4
cp /lfs/h1/ops/prod/com/ccpa/v4.2/ccpa.$PDYm5/00/ccpa.t00z.03h.hrap.conus.gb2 /lfs/h2/emc/ptmp/perry.shafran/ccpa/ccpa.$PDYm4

cp /lfs/h1/ops/prod/com/ccpa/v4.2/ccpa.$PDYm3/00/ccpa.*.03h.hrap.conus.gb2 /lfs/h2/emc/ptmp/perry.shafran/ccpa/ccpa.$PDYm3
cp /lfs/h1/ops/prod/com/ccpa/v4.2/ccpa.$PDYm3/06/ccpa.*.03h.hrap.conus.gb2 /lfs/h2/emc/ptmp/perry.shafran/ccpa/ccpa.$PDYm3
cp /lfs/h1/ops/prod/com/ccpa/v4.2/ccpa.$PDYm3/12/ccpa.*.03h.hrap.conus.gb2 /lfs/h2/emc/ptmp/perry.shafran/ccpa/ccpa.$PDYm3
cp /lfs/h1/ops/prod/com/ccpa/v4.2/ccpa.$PDYm3/18/ccpa.*.03h.hrap.conus.gb2 /lfs/h2/emc/ptmp/perry.shafran/ccpa/ccpa.$PDYm3
cp /lfs/h1/ops/prod/com/ccpa/v4.2/ccpa.$PDYm4/00/ccpa.t00z.03h.hrap.conus.gb2 /lfs/h2/emc/ptmp/perry.shafran/ccpa/ccpa.$PDYm3

cp /lfs/h1/ops/prod/com/ccpa/v4.2/ccpa.$PDYm2/00/ccpa.*.03h.hrap.conus.gb2 /lfs/h2/emc/ptmp/perry.shafran/ccpa/ccpa.$PDYm2
cp /lfs/h1/ops/prod/com/ccpa/v4.2/ccpa.$PDYm2/06/ccpa.*.03h.hrap.conus.gb2 /lfs/h2/emc/ptmp/perry.shafran/ccpa/ccpa.$PDYm2
cp /lfs/h1/ops/prod/com/ccpa/v4.2/ccpa.$PDYm2/12/ccpa.*.03h.hrap.conus.gb2 /lfs/h2/emc/ptmp/perry.shafran/ccpa/ccpa.$PDYm2
cp /lfs/h1/ops/prod/com/ccpa/v4.2/ccpa.$PDYm2/18/ccpa.*.03h.hrap.conus.gb2 /lfs/h2/emc/ptmp/perry.shafran/ccpa/ccpa.$PDYm2
cp /lfs/h1/ops/prod/com/ccpa/v4.2/ccpa.$PDYm3/00/ccpa.t00z.03h.hrap.conus.gb2 /lfs/h2/emc/ptmp/perry.shafran/ccpa/ccpa.$PDYm2


cat << EOF > ${model}.conf
[config]
METPLUS_CONF = {OUTPUT_BASE}/conf/${model}/metplus_final_gridstat.conf
MODEL = ${model1}
LEAD_SEQ = begin_end_incr(0,84,3)
VALID_INCREMENT = 3H
[filename_templates]
FCST_GRID_STAT_INPUT_TEMPLATE = nam.{init?fmt=%Y%m%d}/nam.t{init?fmt=%2H}z.awphys{lead?fmt=%2H}.tm00.grib2
GRID_STAT_OUTPUT_TEMPLATE = grid_stat/${model}
EOF

cat << EOF > ${model}_pcpcombine.conf
[config]
METPLUS_CONF = {OUTPUT_BASE}/conf/${model}/metplus_final_pcpcombine_{ENV[acc]}_gridstat.conf
MODEL = ${model1}
OBS_PCP_COMBINE_INPUT_ACCUMS = 03
FCST_PCP_COMBINE_INPUT_ACCUMS = 03
LEAD_SEQ = begin_end_incr(0,84,3)
VALID_INCREMENT = 3H
[filename_templates]
OBS_PCP_COMBINE_INPUT_TEMPLATE = ccpa.{valid?fmt=%Y%m%d}/ccpa.t{valid?fmt=%H}z.03h.hrap.conus.gb2
FCST_PCP_COMBINE_INPUT_TEMPLATE = nam.{init?fmt=%Y%m%d}/nam.t{init?fmt=%2H}z.awphys{lead?fmt=%2H}.tm00.grib2
FCST_PCP_COMBINE_OUTPUT_TEMPLATE = ${DATE}/nam.t{init?fmt=%H}z.conus.f{lead?fmt=%HH}.a{level?fmt=%HH}h
GRID_STAT_OUTPUT_TEMPLATE = grid_stat/${model}
EOF


#${MET_PLUS}/ush/master_metplus.py -c ${MET_PLUS_CONF}/common.conf -c ${MET_PLUS_CONF}/APCP_01h.conf -c ${model}.conf

export acc=3hr
run_metplus.py -c ${MET_PLUS_CONF}/common.conf -c ${MET_PLUS_CONF}/APCP_03h_3hccpa.conf -c ${model}.conf

export acc=6hr
run_metplus.py -c ${MET_PLUS_CONF}/common.conf -c ${MET_PLUS_CONF}/APCP_06h.conf -c ${model}_pcpcombine.conf

export acc=24hr
run_metplus.py -c ${MET_PLUS_CONF}/common.conf -c ${MET_PLUS_CONF}/APCP_24h.conf -c ${model}_pcpcombine.conf


#${MET_PLUS}/ush/master_metplus.py -c ${MET_PLUS}/parm/use_cases/grid_to_obs/grid_to_obs.conf -c ${MET_PLUS}/parm/use_cases/grid_to_obs/examples/conus_surface.conf -c ${MET_PLUS_CONF}/pb2nc_cam.conf -c ${MET_PLUS_CONF}/point_stat_cam.conf -c ${MET_PLUS_TMP}/${model}.conf -c ${MET_PLUS_CONF}/shared.conf -c ${MET_PLUS_TMP}/shared_${model}.conf -c ${MET_PLUS_CONF}/system_cam.conf 

mkdir -p ${MET_PLUS_TMP}/stat/${model}
cp ${MET_PLUS_OUT}/grid_stat/${model}/*${DATE}* ${MET_PLUS_TMP}/stat/${model}
mv ${MET_PLUS_OUT}/logs/master_metplus.log.${DATEP1} ${MET_PLUS_TMP}/master_metplus.log.${DATEP1}_${model}

#cat << EOF > statanalysis.conf
#[config]
#VALID_BEG = $DATE
#VALID_END = $DATE
#MODEL = $model
#MODEL1 = $model1
#EOF

#${MET_PLUS}/ush/master_metplus.py -c ${MET_PLUS_CONF}/system_cam.conf ${MET_PLUS_CONF}/StatAnalysis_gatherByHour.conf ${MET_PLUS_TMP}/statanalysis.conf

###mv ${MET_PLUS_OUT}/logs/master_metplus.log.${DATEP1} ${MET_PLUS_TMP}

#cp ${MET_PLUS_CONF}/load_met.xml load_met_${model}.xml

cat << EOF > load_met_${model}.xml
<load_spec>
  <connection>
    <host>metviewer-dev-cluster.cluster-czbts4gd2wm2.us-east-1.rds.amazonaws.com:3306</host>
    <database>mv_meso_pcp_2021_metplus</database>
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
  <group>EMC Precip Cloud</group>
  <description>Load of Meso Precip data</description>
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

cp /gpfs/dell2/ptmp/Perry.Shafran/output/metplus_nam_pcp.out $MET_PLUS_STD/metplus_nam_$DATE.out

exit
