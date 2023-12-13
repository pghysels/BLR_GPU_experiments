#!/bin/bash
#SBATCH -A m2957_g
#SBATCH -C gpu
#SBATCH -G 0
#SBATCH -N 4
#SBATCH -q debug
#SBATCH -t 0:30:00

export MPICH_GPU_SUPPORT_ENABLED=0

export OMP_NUM_THREADS=1
export OMP_PLACES=threads
export OMP_PROC_BIND=spread   # for bandwidth
# export OMP_PROC_BIND=close  # for cache locality

out=out
mkdir $out

for n in 50 75 100 125 150 175 200; do
    for comp in NONE BLR; do
	case $comp in
	    NONE) c=0;;
	    BLR)  c=1;;
	esac
	# applications may perform better with --gpu-bind=none instead of --gpu-bind=single:1
	srun -n 256 -c 2 --cpu_bind=cores -G 0 --gpu-bind=single:1 \
	     ../../driver/build/Helmholtz -n $n \
	     -pc_type lu \
	     -pc_factor_mat_solver_type mumps \
	     -mat_mumps_icntl_4 2 \
	     -mat_mumps_icntl_35 $c \
	     -ksp_monitor \
	     -log_view \
	     -use_gpu_aware_mpi 0 \
	     > ${out}/n_${n}_MUMPS_flat_${comp}.log
    done
done
