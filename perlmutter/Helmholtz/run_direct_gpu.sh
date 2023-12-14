#!/bin/bash
#SBATCH -A m2957_g
#SBATCH -C gpu
#SBATCH -N 8
#SBATCH -G 32
#SBATCH -q debug
#SBATCH -t 0:30:00

export MPICH_GPU_SUPPORT_ENABLED=0

export OMP_NUM_THREADS=16
export OMP_PLACES=threads
export OMP_PROC_BIND=spread   # for bandwidth
# export OMP_PROC_BIND=close  # for cache locality

out=out_direct_gpu
mkdir $out

export SUPERLU_ACC_OFFLOAD=1

nmpi=32

for n in 50 100 150 200; do
    for solver in strumpack superlu_dist; do
	srun -n $nmpi -c 32 --cpu_bind=cores -G $nmpi --gpu-bind=single:1 \
	     ../../driver/build/Helmholtz -n $n \
	     -ksp_type preonly -pc_type lu -pc_factor_mat_solver_type ${solver} \
	     -mat_strumpack_verbose -mat_strumpack_gpu 1 \
	     -mat_superlu_dist_printstat \
	     -ksp_monitor -log_view -use_gpu_aware_mpi 0 \
	     > ${out}/n_${n}_${solver}.log
    done
done
