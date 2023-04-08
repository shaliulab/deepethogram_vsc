#! /bin/bash

#SBATCH --job-name=deg_train
#SBATCH --nodes=1
#SBATCH -c 36
#SBATCH --time=08:00:00
#SBATCH --mem=250GB
#SBATCH -A lp_big_wice_gpu
#SBATCH -p dedicated_big_gpu
#SBATCH --cluster wice
#SBATCH --mail-user=antonio.ortega@kuleuven.be
#SBATCH --mail-type=ALL


module purge
source /data/leuven/333/vsc33399/jupyter/bin/activate deepethogram

N_JOBS=35
FLYHOSTEL_ID=$1
NUMBER_OF_ANIMALS=$2
DATETIME=$3
PREFIX=FlyHostel${FLYHOSTEL_ID}_${NUMBER_OF_ANIMALS}X_${DATETIME}

HASH=$SLURM_JOB_ID

mkdir -p ${DEEPETHOGRAM_PROJECT_PATH}/logs

echo "DeepEthogram is in training mode"
DIRECTORY_LIST="all"
echo "Directory list: ${DIRECTORY_LIST}"
  
#echo "Training flow generator"
#python -m deepethogram.flow_generator.train \
#    project.path=$DEEPETHOGRAM_PROJECT_PATH \
#    flow_generator.weights=pretrained \
#    train.num_epochs=10 \
#    compute.num_workers=${N_JOBS} > $DEEPETHOGRAM_PROJECT_PATH/logs/flow_generator_train_${PREFIX}_${HASH}.txt 2>&1
#
#
#echo "Training feature extractor"
#python -m deepethogram.feature_extractor.train \
#    project.path=$DEEPETHOGRAM_PROJECT_PATH \
#    flow_generator.weights=latest \
#    feature_extractor.weights=pretrained \
#    train.num_epochs=10 \
#    compute.num_workers=${N_JOBS} > $DEEPETHOGRAM_PROJECT_PATH/logs/feature_extractor_train_${PREFIX}_${HASH}.txt 2>&1
#
#
#echo "Inference using feature extractor"
#python -m deepethogram.feature_extractor.inference \
#    project.path=$DEEPETHOGRAM_PROJECT_PATH \
#    feature_extractor.weights=latest \
#    flow_generator.weights=latest \
#    inference.overwrite=True \
#    inference.ignore_error=False \
#    train.num_epochs=10 \
#    train.status=True \
#    inference.directory_list=${DIRECTORY_LIST} \
#    compute.num_workers=${N_JOBS} > $DEEPETHOGRAM_PROJECT_PATH/logs/feature_extractor_inference_${PREFIX}_${HASH}.txt 2>&1
#
#
#echo "Training sequence model"
#python -m deepethogram.sequence.train \
#    project.path=$DEEPETHOGRAM_PROJECT_PATH \
#    train.num_epochs=10 \
#    compute.num_workers=${N_JOBS} > $DEEPETHOGRAM_PROJECT_PATH/logs/sequence_train_${PREFIX}_${HASH}.txt 2>&1

echo "Inference using sequence model"
python -m deepethogram.sequence.inference \
    project.path=${DEEPETHOGRAM_PROJECT_PATH} \
    inference.overwrite=True \
    sequence.weights=latest \
    inference.ignore_error=False \
    inference.directory_list=${DIRECTORY_LIST} \
    train.status=True \
    compute.num_workers=${N_JOBS} > $DEEPETHOGRAM_PROJECT_PATH/logs/sequence_inference_${PREFIX}_${HASH}.txt 2>&1
