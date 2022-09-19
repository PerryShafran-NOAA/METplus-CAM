#PBS -N metplus_hrrr_aod
#PBS -j oe
#PBS -o /lfs/h2/emc/ptmp/Perry.Shafran/output/metplus_hrrr_aod.out
#PBS -e /lfs/h2/emc/ptmp/Perry.Shafran/output/metplus_hrrr_aod.out
#PBS -q "dev"
#PBS -A VERF-DEV
#PBS -S /bin/bash
#PBS -l select=1:ncpus=1:mem=3000MB
#PBS -l walltime=1:00:00
#PBS -l debug=true

set -x

export cycle=t00z
export MET_PLUS_TMP=/lfs/h2/emc/ptmp/Perry.Shafran/metplus_hrrr_aod

rm -f -r $MET_PLUS_TMP
mkdir -p $MET_PLUS_TMP
cd $MET_PLUS_TMP

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

sh setpdy.sh
. $MET_PLUS_TMP/PDY

export DATE=$PDYm3
export DATEP1=$PDY
export DATEM1=$PDYm4
export MET_PLUS_CONF=/lfs/h2/emc/vpppg/noscrub/Perry.Shafran/METplus-4.0.0/parm/use_cases/perry
export MET_PLUS_OUT=/lfs/h2/emc/vpppg/noscrub/Perry.Shafran/metplus_hrrraod
export MET_PLUS_STD=/lfs/h2/emc/ptmp/Perry.Shafran/metplus_hrrr_aod_${DATE}

mkdir -p $MET_PLUS_STD

export model=hrrr
model1=`echo $model | tr a-z A-Z`
echo $model1

mkdir -p /lfs/h2/emc/vpppg/noscrub/Perry.Shafran/VIIRS_AOD/${DATE}
mkdir -p /lfs/h2/emc/vpppg/noscrub/Perry.Shafran/VIIRS_AOD_HRRR_REGRID/${DATE}
cd /lfs/h2/emc/vpppg/noscrub/Perry.Shafran/VIIRS_AOD/${DATE}

ftp -n <<EOF
open ftp.star.nesdis.noaa.gov
user anonymous perry.shafran@noaa.gov

cd /pub/smcd/VIIRS_Aerosol/Hongqing/VIIRS_L3_AQM/$DATE
mget VIIRS-L3-AOD_AQM_${DATE}*.nc
cd /pub/smcd/VIIRS_Aerosol/Hongqing/VIIRS_L3_AQM/$DATEM1
mget VIIRS-L3-AOD_AQM_${DATE}*.nc

close
EOF

cd $MET_PLUS_TMP

cat << EOF > regrid.conf
[config]
VALID_BEG = ${DATE}00
VALID_END = ${DATE}23
VALID_INCREMENT = 1H
EOF


run_metplus.py -c  ${MET_PLUS_CONF}/regrid_viirs_hrrr.conf ${MET_PLUS_TMP}/regrid.conf

#cp regrid.conf grid_stat.conf

cat << EOF > grid_stat.conf
[config]
VALID_BEG = ${DATE}17
VALID_END = ${DATE}23
VALID_INCREMENT = 1H
EOF

#for level in low medium high
#do

#level1=`echo $level | tr a-z A-Z`

#cat << EOF > level.conf
#[config]
#MODEL = CMAQ${level1}
#GRID_STAT_OUTPUT_PREFIX = CMAQ_AOD_VS_OBS_AOD_${level1}
#[filename_templates]
#OBS_GRID_STAT_INPUT_TEMPLATE = aqm.{da_init?fmt=%Y%m%d}/OBS_AOD_aqm_g16_{da_init?fmt=%Y%m%d}_{da_init?fmt=%2H}_${level}.nc
#EOF

run_metplus.py -c ${MET_PLUS_CONF}/grid_stat_hrrr_smoke_aod.conf ${MET_PLUS_TMP}/grid_stat.conf 

exit

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

run_metplus.py -c ${MET_PLUS_CONF}/StatAnalysis_gatherByDay_hysplit.conf ${MET_PLUS_TMP}/statanalysis.conf

###mv ${MET_PLUS_OUT}/logs/master_metplus.log.${DATEP1} ${MET_PLUS_TMP}

#cp ${MET_PLUS_CONF}/load_met.xml load_met_${model}.xml

exit

