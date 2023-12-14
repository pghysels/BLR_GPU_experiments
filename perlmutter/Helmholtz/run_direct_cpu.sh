#!/bin/bash
#SBATCH -A m2957_g
#SBATCH -C gpu
#SBATCH -G 0
#SBATCH -N 8
#SBATCH -q debug
#SBATCH -t 0:30:00

export MPICH_GPU_SUPPORT_ENABLED=0

export OMP_NUM_THREADS=1
export OMP_PLACES=threads
export OMP_PROC_BIND=spread   # for bandwidth
# export OMP_PROC_BIND=close  # for cache locality

out=out_direct_cpu
mkdir $out

export SUPERLU_ACC_OFFLOAD=0

nmpi=512

for n in 50 100 150 200; do
    # for solver in strumpack superlu_dist pastix; do
    for solver in strumpack superlu_dist; do
	srun -n $nmpi -c 2 --cpu_bind=cores -G 0 \
	     ../../driver/build/Helmholtz -n $n \
	     -ksp_type preonly -pc_type lu -pc_factor_mat_solver_type ${solver} \
	     -mat_strumpack_verbose -mat_strumpack_gpu 0 \
	     -mat_superlu_dist_printstat \
	     -mat_pastix_verbose 1 \
	     -ksp_monitor -log_view -use_gpu_aware_mpi 0 \
	     > ${out}/n_${n}_${solver}.log
    done
done
