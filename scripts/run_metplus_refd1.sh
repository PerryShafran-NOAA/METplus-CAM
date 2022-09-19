#!/bin/bash

set -x

sleep 10
. ~/dots/dot.for.metplus-3.0

export cycle=t00z
export utilscript=/gpfs/dell1/nco/ops/nwprod/prod_util.v1.1.2/ush
export MET_PLUS_TMP=/gpfs/dell2/ptmp/Perry.Shafran/metplus_hrrr_refd1

##rm -f -r $MET_PLUS_TMP
mkdir -p $MET_PLUS_TMP
cd $MET_PLUS_TMP

sh $utilscript/setup.sh
#sh /gpfs/dell2/emc/verification/save/Perry.Shafran/METplus-3.0/scripts/setpdy.sh
#. $MET_PLUS_TMP/PDY

#export DATE=$PDYm1
#export VDATE=${DATE}00
export DATEP1=$PDY
echo $DATE $VDATE
export MET_PLUS=/gpfs/dell2/emc/verification/save/Perry.Shafran/METplus-3.0.2
export MET_PLUS_CONF=/gpfs/dell2/emc/verification/save/Perry.Shafran/METplus-3.0.2/parm/use_cases/perry
export MET_PLUS_OUT=/gpfs/dell2/emc/verification/noscrub/Perry.Shafran/metplus_mrms
export MET_PLUS_STD=/gpfs/dell2/ptmp/Perry.Shafran/metplus_hrrr_refd1

mkdir -p $MET_PLUS_STD

export model=hrrr
model1=`echo $model | tr a-z A-Z`
echo $model1


export MASKS="/gpfs/dell2/emc/verification/noscrub/Logan.Dawson/CAM_verif/masks/G227/CONUS_G227.nc","/gpfs/dell2/emc/verification/noscrub/Logan.Dawson/CAM_verif/masks/G227/APL_G227.nc","/gpfs/dell2/emc/verification/noscrub/Logan.Dawson/CAM_verif/masks/G227/GMC_G227.nc","/gpfs/dell2/emc/verification/noscrub/Logan.Dawson/CAM_verif/masks/G227/GRB_G227.nc","/gpfs/dell2/emc/verification/noscrub/Logan.Dawson/CAM_verif/masks/G227/LMV_G227.nc","/gpfs/dell2/emc/verification/noscrub/Logan.Dawson/CAM_verif/masks/G227/MDW_G227.nc","/gpfs/dell2/emc/verification/noscrub/Logan.Dawson/CAM_verif/masks/G227/NEC_G227.nc","/gpfs/dell2/emc/verification/noscrub/Logan.Dawson/CAM_verif/masks/G227/NMT_G227.nc","/gpfs/dell2/emc/verification/noscrub/Logan.Dawson/CAM_verif/masks/G227/NPL_G227.nc","/gpfs/dell2/emc/verification/noscrub/Logan.Dawson/CAM_verif/masks/G227/NWC_G227.nc","/gpfs/dell2/emc/verification/noscrub/Logan.Dawson/CAM_verif/masks/G227/SEC_G227.nc","/gpfs/dell2/emc/verification/noscrub/Logan.Dawson/CAM_verif/masks/G227/SMT_G227.nc","/gpfs/dell2/emc/verification/noscrub/Logan.Dawson/CAM_verif/masks/G227/SPL_G227.nc","/gpfs/dell2/emc/verification/noscrub/Logan.Dawson/CAM_verif/masks/G227/SWC_G227.nc","/gpfs/dell2/emc/verification/noscrub/Logan.Dawson/CAM_verif/masks/G227/SWD_G227.nc"

${MET_PLUS}/ush/master_metplus.py -c ${MET_PLUS_CONF}/system_mrms.conf -c ${MET_PLUS_CONF}/GridStat_fcstCAM_obsMRMS_REFD1.conf -c ${MET_PLUS_CONF}/${model}.conf

exit
