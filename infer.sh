#! /bin/bash

#SBATCH --job-name=deg_infer
#SBATCH --nodes=1
#SBATCH -c 10
#SBATCH --time=06:00:00
#SBATCH --mem=100GB
#SBATCH -A lp_big_wice_gpu
#SBATCH -p dedicated_big_gpu
#SBATCH --cluster wice
#SBATCH --mail-user=antonio.ortega@kuleuven.be
#SBATCH --mail-type=ALL


module purge
source /data/leuven/333/vsc33399/jupyter/bin/activate deepethogram

N_JOBS=9
FLYHOSTEL_ID=$1
NUMBER_OF_ANIMALS=$2
DATETIME=$3
CHUNK_START=${4:-50}
CHUNK_END=${5:-349}
PREFIX=FlyHostel${FLYHOSTEL_ID}_${NUMBER_OF_ANIMALS}X_${DATETIME}
mkdir -p ${DEEPETHOGRAM_PROJECT_PATH}/logs

HASH=$(echo $RANDOM | md5sum | head -c 8)
HASH=$SLURM_JOB_ID
if [ -z "${FLYHOSTEL_ID}" ]
then
    DIRECTORY_LIST="all"
    echo ${DIRECTORY_LIST}
else
    DIRECTORY_LIST=`pwd`/${PREFIX}_${HASH}_directory_list.txt 
    echo "Directory list: ${DIRECTORY_LIST}"
    
    PATTERN=_$(printf %06d $CHUNK_START)_
    for CHUNK in $(seq $((CHUNK_START+1)) $CHUNK_END); do
        PATTERN="${PATTERN}|_$(printf %06d ${CHUNK})_"
    done
    # actual video list
    find $DEEPETHOGRAM_PROJECT_PATH/DATA/  -regex ".*${PREFIX}.*.mp4"  | sed -r 's/(.*)\/.*/\1/'  | grep -E ${PATTERN} |  sort -g  >> $DIRECTORY_LIST
    # labels (needed so deepethogram can estimate the mean duration of each behavior bout)
    find $DEEPETHOGRAM_PROJECT_PATH/DATA/  -regex ".*.csv"  | sed -r 's/(.*)\/.*/\1/'  |  sort -g  >> $DIRECTORY_LIST
fi

echo "DeepEthogram is inference-only mode"

echo "Inference using feature extractor"

python -m deepethogram.feature_extractor.inference \
    project.path=$DEEPETHOGRAM_PROJECT_PATH \
    feature_extractor.weights=latest \
    flow_generator.weights=latest \
    inference.overwrite=True \
    inference.ignore_error=False \
    inference.directory_list=${DIRECTORY_LIST} \
    train.status=False \
    inference.labels_only=True \
    compute.num_workers=${N_JOBS} > $DEEPETHOGRAM_PROJECT_PATH/logs/feature_extractor_inference_${PREFIX}_${HASH}.txt 2>&1
   

echo "Inference using sequence model"

python -m deepethogram.sequence.inference \
    project.path=${DEEPETHOGRAM_PROJECT_PATH} \
    inference.overwrite=True \
    sequence.weights=latest \
    inference.ignore_error=False \
    inference.directory_list=${DIRECTORY_LIST} \
    train.status=False \
    inference.labels_only=True \
    compute.num_workers=${N_JOBS} > $DEEPETHOGRAM_PROJECT_PATH/logs/sequence_inference_${PREFIX}_${HASH}.txt 2>&1
