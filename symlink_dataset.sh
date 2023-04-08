#! /bin/bash
#
#SBATCH --job-name=symlink
#SBATCH --nodes=1
#SBATCH -c 36
#SBATCH --time=05:00:00
#SBATCH --mem=250GB
#SBATCH -A lp_big_wice_cpu
#SBATCH -p dedicated_big_bigmem
#SBATCH --cluster wice
#SBATCH --mail-user=antonio.ortega@kuleuven.be
#SBATCH --mail-type=ALL


module purge
source /data/leuven/333/vsc33399/jupyter/bin/activate deepethogram

N_JOBS=35
FLYHOSTEL_ID=$1
NUMBER_OF_ANIMALS=$2
DATETIME=$3
VIDEOS_DIR=${FLYHOSTEL_VIDEOS}/FlyHostel${FLYHOSTEL_ID}/${NUMBER_OF_ANIMALS}X/${DATETIME}/flyhostel/single_animal/
START_CHUNK=${4:-50}
END_CHUNK=${5:-349}
STRIDE=${6:-80}

CHUNKS=$(seq $START_CHUNK $END_CHUNK)

python ~/opt/deepethogram/deepethogram/add.py --project-path ${DEEPETHOGRAM_PROJECT_PATH} --videos-dir ${VIDEOS_DIR}   --chunks ${CHUNKS[*]} --mode symlink --data-dir DATA --n-jobs $N_JOBS --stride ${STRIDE}
