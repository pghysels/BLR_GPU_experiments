#!/bin/bash
#SBATCH -A m2957_g
#SBATCH -C gpu
#SBATCH -G 16
#SBATCH -N 4
#SBATCH -q debug
#SBATCH -t 0:05:00

export MPICH_GPU_SUPPORT_ENABLED=0

export OMP_NUM_THREADS=16
export OMP_PLACES=threads
export OMP_PROC_BIND=spread   # for bandwidth
# export OMP_PROC_BIND=close  # for cache locality

out=out
mkdir $out

for n in 50 75 100 125 150 175 200; do
    for GPU in 0; do
	for comp in NONE BLR; do
	    # applications may perform better with --gpu-bind=none instead of --gpu-bind=single:1
	    srun -n 16 -c 32 --cpu_bind=cores -G 16 --gpu-bind=single:1 \
		 ../../driver/build/Helmholtz -n $n \
		 -pc_type lu \
		 -pc_factor_mat_solver_type strumpack \
    		 -mat_strumpack_compression $comp \
		 -mat_strumpack_verbose \
		 -mat_strumpack_gpu $GPU \
		 -ksp_monitor \
		 -log_view \
		 -use_gpu_aware_mpi 0 \
		 > ${out}/n_${n}_STRUMPACK_GPU${GPU}_${comp}.log
	done
    done
done