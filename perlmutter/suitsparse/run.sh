#!/bin/bash
#SBATCH -A m3953_g
#SBATCH -C gpu
#SBATCH -N 1
#SBATCH -G 1
#SBATCH -q debug
#SBATCH -t 0:30:00

export MPICH_GPU_SUPPORT_ENABLED=0

export OMP_NUM_THREADS=8
export OMP_PLACES=threads
export OMP_PROC_BIND=spread   # for bandwidth
# export OMP_PROC_BIND=close  # for cache locality

out=out
mkdir $out

# Transport \
#              Serena \
#              Geo_1438 \
#              Hook_1498 \
#              ML_Geer \
for f in  Flan_1565 \
             Bump_2911 \
             Cube_Coup_dt0 \
             Cube_Coup_dt6 \
             Long_Coup_dt0 \
             Long_Coup_dt6 \
             StocF-1465; do
    # for comp in none; do
    for comp in blr; do
        srun -n 1 -c 32 --cpu_bind=cores -G 1 --gpu-bind=single:1 \
	     ../code/STRUMPACK/build/examples/sparse/testMMdouble \
	     /pscratch/sd/p/pghysels/BLR_GPU_experiments/suitesparse/${f}.mtx.bin \
	     --sp_maxit 100 \
	     --blr_rel_tol 1e-2 \
	     --blr_leaf_size 512 \
	     --sp_enable_METIS_NodeNDP \
	     --sp_compression $comp \
	     --sp_enable_gpu \
	     --help \
	     > ${out}/${f}_${comp}_GPU.log
	    
        srun -n 1 -c 32 --cpu_bind=cores -G 0 --gpu-bind=single:1 \
	     ../code/STRUMPACK/build/examples/sparse/testMMdouble \
	     /pscratch/sd/p/pghysels/BLR_GPU_experiments/suitesparse/${f}.mtx.bin \
	     --blr_rel_tol 1e-2 \
	     --blr_leaf_size 256 \
	     --sp_enable_METIS_NodeNDP \
	     --sp_compression $comp \
	     --sp_disable_gpu \
	     --help \
	     > ${out}/${f}_${comp}_CPU.log
    done
done
