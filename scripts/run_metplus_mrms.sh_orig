#!/bin/ksh --login
#
#BSUB -J verif_nam_mrms
#BSUB -o /gpfs/dell2/ptmp/Perry.Shafran/output/fv3sar.out%J
#BSUB -e /gpfs/dell2/ptmp/Perry.Shafran/output/fv3sar.err%J
#BSUB -W 02:00
#BSUB -n 64
#BSUB -R span[ptile=16]
#BSUB -P VERF-T2O
#BSUB -q "dev_shared"
#BSUB -R "affinity[core]"
#BSUB -R "rusage[mem=1500]"

set -x

export cycle=t00z
export utilscript=/gpfs/dell1/nco/ops/nwprod/prod_util.v1.1.2/ush

mkdir -p /gpfs/dell2/ptmp/Perry.Shafran/run_mrms_metplus
cd /gpfs/dell2/ptmp/Perry.Shafran/run_mrms_metplus

sh $utilscript/setpdy.sh
. /gpfs/dell2/ptmp/Perry.Shafran/run_mrms_metplus/PDY

export DATE=$PDYm1
export VDATE=${DATE}00

echo "/gpfs/dell2/emc/verification/save/Perry.Shafran/METplus-3.0/scripts/run_metplus_refc.sh" >> poescript
echo "/gpfs/dell2/emc/verification/save/Perry.Shafran/METplus-3.0/scripts/run_metplus_refd1.sh" >> poescript
echo "/gpfs/dell2/emc/verification/save/Perry.Shafran/METplus-3.0/scripts/run_metplus_retop.sh" >> poescript

chmod 775 poescript
export MP_PGMMODEL=mpmd
export MP_CMDFILE=poescript

echo beforelsf
mpirun -l cfp poescript
echo afterlsf

export VDATE=${DATE}
export VHOUR=00
echo $VDATE $VHOUR

export MET_PLUS=/gpfs/dell2/emc/verification/save/Perry.Shafran/METplus-3.0
export MET_PLUS_OUT=/gpfs/dell2/emc/verification/noscrub/Perry.Shafran/metplus_mrms
export MET_PLUS_CONF=/gpfs/dell2/emc/verification/save/Perry.Shafran/METplus-3.0/parm/use_cases/perry
export MET_PLUS_TMP=/gpfs/dell2/ptmp/Perry.Shafran/metplus_nam_retop
export model=nam

${MET_PLUS}/ush/master_metplus.py -c ${MET_PLUS_CONF}/system_mrms.conf ${MET_PLUS_CONF}/StatAnalysis_fcstCAM_obsMRMS_gatherByHour.conf ${MET_PLUS_TMP}/${model}.conf


exit
