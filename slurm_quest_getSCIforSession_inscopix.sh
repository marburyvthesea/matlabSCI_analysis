#!/bin/bash
#SBATCH -A p30771
#SBATCH -p normal
#SBATCH -t 12:00:00
#SBATCH -o ./logfiles/slurm.%x-%j.out # STDOUT
#SBATCH --job-name="computeSCI"
#SBATCH --mem-per-cpu=5200M
#SBATCH -N 1
#SBATCH -n 16

module purge all

#path to data

INPUT_dirPath=$1
echo $INPUT_dirPath

#parameters for CNMF_E

INPUT_session=$2
INPUT_save_path='/scratch/jma819/CNMFE_filesForClusteringAnalysis/analysisOutput/'
INPUT_micronsPerPixel=2.5
INPUT_parallel_enable=true


#add project directory to PATH
export PATH=$PATH/scratch/jma819/

#load modules to use
#module load python/anaconda3.6 

#load modules to use
module load matlab/r2023b

#run  
matlab -nosplash -nodesktop -r "addpath(genpath('spatial_clustering'));dir_path='$INPUT_dirPath';session='$INPUT_session';save_path='$INPUT_save_path';micronsPerPixel=$INPUT_micronsPerPixel;disp(dir_path);disp(session);disp(save_path);run('mainScriptSciAnalysisPerSessionQuest.m');exit;"



