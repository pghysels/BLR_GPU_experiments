#!/bin/bash
#SBATCH -A m2957_g
#SBATCH -C gpu
#SBATCH -N 64
#SBATCH -G 256
#SBATCH -q regular
#SBATCH -t 1:00:00
export MPICH_GPU_SUPPORT_ENABLED=1

############################################### SuperLU_DIST runtime settings
export SUPERLU_ACC_OFFLOAD=1 # whether to do GPU factorization
export GPU3DVERSION=0 # cpp or c version of the GPU numerical factorization
export SUPERLU_ACC_SOLVE=1 # whether to do GPU solve


# parameters affecting factorization and solve 
export SUPERLU_MAXSUP=256 # max supernode size
export SUPERLU_RELAX=64  # upper bound for relaxed supernode size
d=2   # # of 2D processes, d should be a power of 2, it's recommended d<=min(16,nmpi) 
r=4   # 2D process row
c=2   # 2D process column, 1 is best for GPU solve performance. 

# parameters affecting factorization only 
export SUPERLU_MAX_BUFFER_SIZE=10000000 ## 500000000 # buffer size in words on GPU
export SUPERLU_NUM_LOOKAHEADS=4   ##4, must be at least 2, see 'lookahead winSize'
export SUPERLU_NUM_GPU_STREAMS=1
export SUPERLU_N_GEMM=6000 # FLOPS threshold divide workload between CPU and GPU


# the following are default settings? don't change them for now
nmpipergpu=1
export SUPERLU_MPI_PROCESS_PER_GPU=$nmpipergpu # 2: this can better saturate GPU
export ANC25D=0
export NEW3DSOLVE=1    
export NEW3DSOLVETREECOMM=1
# export SUPERLU_BIND_MPI_GPU=1 # assign GPU based on the MPI rank, assuming one MPI per GPU  ### this conflicts with petsc's setting, so commented out for now


##NVSHMEM settings:
NVSHMEM_HOME=/global/cfs/cdirs/m3894/lib/PrgEnv-gnu/nvshmem_src_2.8.0-3/build/
export NVSHMEM_USE_GDRCOPY=1
export NVSHMEM_MPI_SUPPORT=1
export MPI_HOME=${MPICH_DIR}
export NVSHMEM_LIBFABRIC_SUPPORT=1
export LIBFABRIC_HOME=/opt/cray/libfabric/1.15.2.0
export LD_LIBRARY_PATH=$NVSHMEM_HOME/lib:$LD_LIBRARY_PATH
export NVSHMEM_DISABLE_CUDA_VMM=1
export FI_CXI_OPTIMIZED_MRS=false
export NVSHMEM_BOOTSTRAP_TWO_STAGE=1
export NVSHMEM_BOOTSTRAP=MPI
export NVSHMEM_REMOTE_TRANSPORT=libfabric

########################################################





NTH=1
export OMP_NUM_THREADS=$NTH
TH_PER_RANK=`expr $NTH \* 2`
export OMP_PLACES=threads
export OMP_PROC_BIND=spread   # for bandwidth
# export OMP_PROC_BIND=close  # for cache locality

out=out_direct_gpu
mkdir -p $out


nmpi=16

for n in 50; do
    # for solver in superlu_dist; do
    for solver in strumpack superlu_dist pastix; do
        srun -n $nmpi -c $TH_PER_RANK --cpu_bind=cores -G $nmpi --gpu-bind=single:1 \
             ../../driver/build/Helmholtz -n $n \
             -ksp_type preonly -pc_type lu -pc_factor_mat_solver_type ${solver} \
             -mat_strumpack_verbose -mat_strumpack_gpu 1 \
             -mat_superlu_dist_printstat \
             -ksp_monitor -use_gpu_aware_mpi 0 -mat_superlu_dist_3d -mat_superlu_dist_d $d -mat_superlu_dist_r $r -mat_superlu_dist_c $c\
             > ${out}/N64_n_${n}_${solver}_2x.log
        # -log_view
    done
done
