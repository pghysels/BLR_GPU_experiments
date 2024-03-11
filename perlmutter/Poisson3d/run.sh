#!/bin/bash
#SBATCH -A m2957_g
#SBATCH -C gpu
#SBATCH -N 32
#SBATCH -G 128
#SBATCH -q premium
#SBATCH -t 1:00:00

export MPICH_GPU_SUPPORT_ENABLED=0

export OMP_NUM_THREADS=16
export OMP_PLACES=threads
export OMP_PROC_BIND=spread   # for bandwidth
# export OMP_PROC_BIND=close  # for cache locality

out=outP3
mkdir $out

nmpi=128
# nmpi=32

# for k in 100 125 150 175 200 225 250 275 300; do
for k in 275 300 325 350 375 400; do
    # srun -n $nmpi -c 32 --cpu_bind=cores -G $nmpi --gpu-bind=single:1 \
    # 	 ../code/STRUMPACK/build/examples/sparse/testPoisson3dMPIDist $k \
    # 	 --sp_compression none \
    # 	 --sp_enable_gpu \
    # 	 --help \
    # 	 > ${out}/mpi${nmpi}_P3${k}_NONE_GPU_PPT1.log

    # srun -n $nmpi -c 32 --cpu_bind=cores -G $nmpi --gpu-bind=single:1 \
    # 	 ../code/STRUMPACK/build/examples/sparse/testPoisson3dMPIDist $k \
    # 	 --sp_compression_min_sep_size 2000 \
    # 	 --blr_rel_tol 1e-2 \
    # 	 --blr_leaf_size 512 \
    # 	 --sp_compression BLR \
    # 	 --sp_enable_gpu \
    # 	 --help \
    # 	 > ${out}/mpi${nmpi}_P3${k}_BLR_GPU.log


    srun -n $nmpi -c 32 --cpu_bind=cores -G $nmpi --gpu-bind=single:1 \
	 ../code_cpu/STRUMPACK/build/examples/sparse/testPoisson3dMPIDist $k \
	 --sp_compression none \
	 --sp_disable_gpu \
	 --help \
	 > ${out}/mpi${nmpi}_P3${k}_NONE_CPU.log

    # srun -n $nmpi -c 32 --cpu_bind=cores -G $nmpi --gpu-bind=single:1 \
    # 	 ../code_cpu/STRUMPACK/build/examples/sparse/testPoisson3dMPIDist $k \
    # 	 --sp_compression_min_sep_size 2000 \
    # 	 --blr_rel_tol 1e-2 \
    # 	 --blr_leaf_size 256 \
    # 	 --sp_compression BLR \
    # 	 --sp_disable_gpu \
    # 	 --help \
    # 	 > ${out}/mpi${nmpi}_P3${k}_BLR_CPU.log
done
