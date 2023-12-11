module swap PrgEnv-cray PrgEnv-gnu
module load cmake
module load cray-mpich
module load craype-accel-amd-gfx90a
module load rocm/5.7.0
export MPICH_GPU_SUPPORT_ENABLED=1
