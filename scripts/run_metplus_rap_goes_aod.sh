#PBS -N metplus_rap_aod
#PBS -j oe
#PBS -o /lfs/h2/emc/ptmp/perry.shafran/output/metplus_rap_goes_aod.out
#PBS -e /lfs/h2/emc/ptmp/perry.shafran/output/metplus_rap_goes_aod.out
#PBS -q "dev"
#PBS -A VERF-DEV
#PBS -S /bin/bash
#PBS -l select=1:ncpus=1:mem=3000MB
#PBS -l walltime=02:00:00
#PBS -l debug=true

set -x

export cycle=t00z
export MET_PLUS_TMP=/lfs/h2/emc/ptmp/perry.shafran/metplus_rap_aod

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

export DATE=$PDYm4
export DATEP1=$PDY
export DATEM1=$PDYm4
export MET_PLUS_CONF=/lfs/h2/emc/vpppg/save/perry.shafran/METplus-4.0.0/parm/use_cases/perry
export MET_PLUS_OUT=/lfs/h2/emc/vpppg/noscrub/perry.shafran/metplus_rapaod
export MET_PLUS_STD=/lfs/h2/emc/ptmp/perry.shafran/metplus_rap_aod_${DATE}

mkdir -p $MET_PLUS_STD

export model=rap
model1=`echo $model | tr a-z A-Z`
echo $model1

mkdir -p /lfs/h2/emc/vpppg/noscrub/perry.shafran/GOES16_AOD_RAP_REGRID/${DATE}
export OBSVDIR=/lfs/h2/emc/physics/noscrub/ho-chun.huang/GOES16_AOD/AOD/$DATE
export OBSVDIR_ADP=/lfs/h2/emc/physics/noscrub/ho-chun.huang/GOES16_AOD/ADP/$DATE
export REF_FILE=/lfs/h1/ops/prod/com/rap/v5.1/rap.$DATE/rap.t00z.awp130pgrbf00.grib2

cat << EOF > regrid.conf
[config]
VALID_BEG = ${DATE}00
VALID_END = ${DATE}23
VALID_INCREMENT = 1H
EOF

export jday=`date2jday.sh $DATE`

let ohr=0
let tend=23
while [ ${ohr} -le ${tend} ]; do
    oh=`printf %2.2d ${ohr}`
    ls ${OBSVDIR}/OR_ABI-L2-AODC-M*_G16_s${jday}${oh}*.nc > aa1
    ls ${OBSVDIR_ADP}/OR_ABI-L2-ADPC-M6_G16_${element_5}*.nc > aa2
    aod_file=`head -n1 aa1`
    element_1=$( echo ${aod_file} | awk -F"_" '{print $1}')
    element_2=$( echo ${aod_file} | awk -F"_" '{print $2}')
    element_3=$( echo ${aod_file} | awk -F"_" '{print $3}')
    element_4=$( echo ${aod_file} | awk -F"_" '{print $4}')
    element_5=$( echo ${aod_file} | awk -F"_" '{print $5}')
    ls ${OBSVDIR_ADP}/OR_ABI-L2-ADPC-M6_G16_${element_5}*.nc > aa2
    export infile=`head -n1 aa1`
    export adpfile=`head -n1 aa2`
    exit
cat << EOF > p2g.conf
[config]
VALID_BEG = ${DATE}${oh}
VALID_END = ${DATE}${oh}
EOF
   
    run_metplus.py -c  ${MET_PLUS_CONF}/point2grid_goes_aod_rap.conf ${MET_PLUS_TMP}/p2g.conf
    ((ohr++))
    echo $ohr

done

exit

cp regrid.conf grid_stat.conf

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

run_metplus.py -c ${MET_PLUS_CONF}/grid_stat_smoke_aod_rap.conf ${MET_PLUS_TMP}/grid_stat.conf 

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

