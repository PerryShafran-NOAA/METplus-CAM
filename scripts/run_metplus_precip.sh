#!/bin/bash

#BSUB -J metplus_nam
#BSUB -o /gpfs/dell2/ptmp/Perry.Shafran/output/metplus_nam.o%J
#BSUB -e /gpfs/dell2/ptmp/Perry.Shafran/output/metplus_nam.o%J
#BSUB -q "dev"
#BSUB -P VERF-T2O
#BSUB -R "rusage[mem=3000]"
#BSUB -n 1
#BSUB -W 04:00

set -x

export cycle=t00z
export utilscript=/gpfs/dell1/nco/ops/nwprod/prod_util.v1.1.2/ush
export utilexec=/gpfs/dell1/nco/ops/nwprod/prod_util.v1.1.2/exec
export EXECutil=/gpfs/dell1/nco/ops/nwprod/prod_util.v1.1.2/exec
export MET_PLUS_TMP=/gpfs/dell2/ptmp/Perry.Shafran/metplus_precip

rm -f -r $MET_PLUS_TMP
mkdir -p $MET_PLUS_TMP
cd $MET_PLUS_TMP

sh $utilscript/setup.sh
sh $utilscript/setpdy.sh
. $MET_PLUS_TMP/PDY

export DATE=$PDYm3
export DATEP1=$PDY

export MET_PLUS=/gpfs/dell2/emc/verification/save/Perry.Shafran/METplus-3.1
export MET_PLUS_CONF=/gpfs/dell2/emc/verification/save/Perry.Shafran/METplus-3.1/parm/use_cases/precip
export MET_PLUS_OUT=/gpfs/dell2/emc/verification/noscrub/Perry.Shafran/metplus_pcp
export MET_PLUS_STD=/gpfs/dell2/ptmp/Perry.Shafran/metplus_precip

mkdir -p $MET_PLUS_STD

export model=fv3lam
model1=`echo $model | tr a-z A-Z`
echo $model1

export model_dir=/gpfs/dell4/ptmp/emc.campara/fv3lam
export EXPTDIR=/gpfs/dell2/emc/verification/noscrub/Perry.Shafran/metplus_pcp
export OBS_DIR=/gpfs/dell2/ptmp/Perry.Shafran/ccpa
export acc=1hr
export fhr_list="begin_end_incr(1,60,1)"
export CDATE=${DATE}00

export METPLUS_PATH=${MET_PLUS}
export MET_INSTALL_DIR=/gpfs/dell2/emc/verification/noscrub/emc.metplus/met/9.1
export METPLUS_CONF=/gpfs/dell2/emc/verification/save/Perry.Shafran/METplus-3.1/parm
export MET_CONFIG=/gpfs/dell2/emc/verification/save/Perry.Shafran/METplus-3.1/parm/met_config

mkdir -p /gpfs/dell2/ptmp/Perry.Shafran/ccpa/ccpa.$PDYm2

cp /gpfs/dell1/nco/ops/com/ccpa/prod/ccpa.$PDYm3/00/ccpa.*.01h.hrap.conus.gb2 /gpfs/dell2/ptmp/Perry.Shafran/ccpa/ccpa.$PDYm3
cp /gpfs/dell1/nco/ops/com/ccpa/prod/ccpa.$PDYm3/06/ccpa.*.01h.hrap.conus.gb2 /gpfs/dell2/ptmp/Perry.Shafran/ccpa/ccpa.$PDYm3
cp /gpfs/dell1/nco/ops/com/ccpa/prod/ccpa.$PDYm3/12/ccpa.*.01h.hrap.conus.gb2 /gpfs/dell2/ptmp/Perry.Shafran/ccpa/ccpa.$PDYm3
cp /gpfs/dell1/nco/ops/com/ccpa/prod/ccpa.$PDYm3/18/ccpa.*.01h.hrap.conus.gb2 /gpfs/dell2/ptmp/Perry.Shafran/ccpa/ccpa.$PDYm3
cp /gpfs/dell1/nco/ops/com/ccpa/prod/ccpa.$PDYm4/00/ccpa.t00z.01h.hrap.conus.gb2 /gpfs/dell2/ptmp/Perry.Shafran/ccpa/ccpa.$PDYm3

cp /gpfs/dell1/nco/ops/com/ccpa/prod/ccpa.$PDYm2/00/ccpa.*.01h.hrap.conus.gb2 /gpfs/dell2/ptmp/Perry.Shafran/ccpa/ccpa.$PDYm2
cp /gpfs/dell1/nco/ops/com/ccpa/prod/ccpa.$PDYm2/06/ccpa.*.01h.hrap.conus.gb2 /gpfs/dell2/ptmp/Perry.Shafran/ccpa/ccpa.$PDYm2
cp /gpfs/dell1/nco/ops/com/ccpa/prod/ccpa.$PDYm2/12/ccpa.*.01h.hrap.conus.gb2 /gpfs/dell2/ptmp/Perry.Shafran/ccpa/ccpa.$PDYm2
cp /gpfs/dell1/nco/ops/com/ccpa/prod/ccpa.$PDYm2/18/ccpa.*.01h.hrap.conus.gb2 /gpfs/dell2/ptmp/Perry.Shafran/ccpa/ccpa.$PDYm2
cp /gpfs/dell1/nco/ops/com/ccpa/prod/ccpa.$PDYm3/00/ccpa.t00z.01h.hrap.conus.gb2 /gpfs/dell2/ptmp/Perry.Shafran/ccpa/ccpa.$PDYm2


${MET_PLUS}/ush/master_metplus.py -c ${MET_PLUS_CONF}/common.conf -c ${MET_PLUS_CONF}/APCP_01h.conf 

export acc=3hr
${MET_PLUS}/ush/master_metplus.py -c ${MET_PLUS_CONF}/common.conf -c ${MET_PLUS_CONF}/APCP_03h.conf

export acc=6hr
${MET_PLUS}/ush/master_metplus.py -c ${MET_PLUS_CONF}/common.conf -c ${MET_PLUS_CONF}/APCP_06h.conf

export acc=24hr
${MET_PLUS}/ush/master_metplus.py -c ${MET_PLUS_CONF}/common.conf -c ${MET_PLUS_CONF}/APCP_24h.conf

exit

#${MET_PLUS}/ush/master_metplus.py -c ${MET_PLUS}/parm/use_cases/grid_to_obs/grid_to_obs.conf -c ${MET_PLUS}/parm/use_cases/grid_to_obs/examples/conus_surface.conf -c ${MET_PLUS_CONF}/pb2nc_cam.conf -c ${MET_PLUS_CONF}/point_stat_cam.conf -c ${MET_PLUS_TMP}/${model}.conf -c ${MET_PLUS_CONF}/shared.conf -c ${MET_PLUS_TMP}/shared_${model}.conf -c ${MET_PLUS_CONF}/system_cam.conf 

#mkdir -p ${MET_PLUS_TMP}/stat/${model}
#cp ${MET_PLUS_OUT}/cam/stat/${model}/*${DATE}* ${MET_PLUS_TMP}/stat/${model}
#mv ${MET_PLUS_OUT}/logs/master_metplus.log.${DATEP1} ${MET_PLUS_TMP}/master_metplus.log.${DATEP1}_${model}

exit

cat << EOF > statanalysis.conf
[config]
VALID_BEG = $DATE
VALID_END = $DATE
MODEL = $model
MODEL1 = $model1
EOF

${MET_PLUS}/ush/master_metplus.py -c ${MET_PLUS_CONF}/system_cam.conf ${MET_PLUS_CONF}/StatAnalysis_gatherByHour.conf ${MET_PLUS_TMP}/statanalysis.conf

###mv ${MET_PLUS_OUT}/logs/master_metplus.log.${DATEP1} ${MET_PLUS_TMP}

#cp ${MET_PLUS_CONF}/load_met.xml load_met_${model}.xml

cat << EOF > load_met_${model}.xml
<load_spec>
  <connection>
    <host>metviewer-dev-cluster.cluster-czbts4gd2wm2.us-east-1.rds.amazonaws.com:3306</host>
    <database>mv_emc_g2o_met</database>
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
  <group>pshafran</group>
  <description>Test of loading real set of data</description>
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
