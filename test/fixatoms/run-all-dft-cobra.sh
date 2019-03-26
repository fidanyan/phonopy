#!/bin/bash -l
## run in /bin/bash NOTE the -l flag!
#
#######################################################
# example Slurm batch script for a plain MPI program
#######################################################
#
## do not join stdout and stderr
#SBATCH -o job.%j.out
#SBATCH -e job.%j.err

## name of the job
#SBATCH -J Phonons

## execute job from the current working directory
## this is default slurm behavior
#SBATCH -D ./

## do not send mail
#SBATCH --mail-type=NONE

## Total number of tasks must be a multiple of 32
## Each node has 40 cores
#SBATCH --nodes=12
#SBATCH --ntasks-per-node=40

#SBATCH --partition=express

## run time hh:mm:ss
# One job takes ~0.5 min
#SBATCH -t 0:30:00

if [ -e abort_scf ]
then
	rm abort_scf
fi
if [ -e abort_opt ]
then
	rm abort_opt
fi

# terminate on error
set -e

module purge
module load mkl intel impi
export OMP_NUM_THREADS=1

export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$MKL_HOME/lib/intel64
AIMS_EXE=''

## to save memory at high core counts, the "connectionless user datagram protocol" 
## can be enabled (might come at the expense of speed)
## see https://software.intel.com/en-us/articles/dapl-ud-support-in-intel-mpi-library
# export I_MPI_DAPL_UD=1

##gather MPI statistics to be analyzed with itac's mps tool
# export I_MPI_STATS=all

##gather MPI debug information (high verbosity)
# export I_MPI_DEBUG=5

date

j=0
for dir1 in constrained-new-phonopy constrained-supercell-new full-new-phonopy full-old-phonopy full-supercell-new full-supercell-old
do
    cd ${dir1}
        for i in `seq -w 66`
        do
            if [ -d phonopy-FHI-aims-displacement-0$i ]; then
                cd phonopy-FHI-aims-displacement-0$i
                    j=$((j+1))
#                    ln -s ../D_spin_01_kpt_000001.csc ./
                    srun --exclusive -N 1  -n 40  $AIMS_EXE > aims.out &
                cd ..
                if (( $j % 12 == 0 ))
                then 
                    echo "${dir1}/phonopy-FHI-aims-displacement-0${i}, waiting..."
                    wait
                fi
            elif [ $i -eq 19 ]; then break  # there are folders with 18 and 66 subfolders
            fi
        done
    cd ..
done

echo "Waiting for the last tasks!..."
wait
echo "Finally, it's done!"
date
