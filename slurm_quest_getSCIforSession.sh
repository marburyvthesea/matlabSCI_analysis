#!/bin/bash
#SBATCH -A p30771
#SBATCH -p normal
#SBATCH -t 12:00:00
#SBATCH -o ./logfiles/slurm.%x-%j.out # STDOUT
#SBATCH --job-name="slurm_matlab_cnmfe_batch_run"
#SBATCH --mem-per-cpu=5200M
#SBATCH -N 1
#SBATCH -n 16

module purge all

cd ~

#path to file (h5 or tiff should work)

INPUT_dirPath=$1
echo $INPUT_dirPath

#parameters for CNMF_E

INPUT_session=7
INPUT_save_path=21
INPUT_micronsPerPixel=21
INPUT_parallel_enable=true


#add project directory to PATH
export PATH=$PATH/projects/p30771/

#load modules to use
module load python/anaconda3.6 

#load modules to use
module load matlab/r2018a

#cd to script directory
cd /projects/p30771/MATLAB/CNMF_E_jjm/quest_MATLAB_cnmfe
#run  



matlab -nosplash -nodesktop -r "exit;"



