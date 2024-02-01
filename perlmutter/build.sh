#!/bin/bash
module load cmake
rm -rf code
mkdir code
cd code
NVSHMEM_HOME=/global/cfs/cdirs/m3894/lib/PrgEnv-gnu/nvshmem_src_2.8.0-3/build/
export MAGMA_DIR=`pwd`/magma-2.7.2/install
export SLATE_DIR=`pwd`/slate/install
export METIS_DIR=`pwd`/ParMETIS_install
export PARMETIS_DIR=`pwd`/ParMETIS_install
export STRUMPACK_DIR=`pwd`/STRUMPACK/install
export SUPERLU_DIST_DIR=`pwd`/superlu_dist/build
export PETSC_DIR=`pwd`/petsc
export PETSC_ARCH=arch-linux-c-opt
export KBLAS_DIR=`pwd`/kblas-gpu-dev
export CUDAToolkit_ROOT=${CUDATOOLKIT_HOME}


wget https://icl.utk.edu/projectsfiles/magma/downloads/magma-2.7.2.tar.gz
tar -xzf magma-2.7.2.tar.gz

git clone --recursive https://github.com/icl-utk-edu/slate.git
git clone git@github.com:ecrc/kblas-gpu-dev.git
git clone git@github.com:pghysels/STRUMPACK.git
git clone -b release https://gitlab.com/petsc/petsc.git petsc
git clone https://github.com/xiaoyeli/superlu_dist.git


# git clone https://github.com/KarypisLab/ParMETIS
# git clone https://github.com/KarypisLab/GKlib.git
# git clone https://github.com/KarypisLab/METIS.git

# mkdir ParMETIS_install
# cd GKlib
# make config cc=cc prefix=${PARMETIS_DIR}
# make -j
# make install
# cd ../METIS
# make config cc=cc prefix=${PARMETIS_DIR}
# make -j
# make install
# cd ../ParMETIS
# make config cc=cc prefix=${PARMETIS_DIR}
# make -j
# make install
# cd ../


mkdir -p ParMETIS_install
wget https://launchpad.net/ubuntu/+archive/primary/+sourcefiles/parmetis/4.0.3-4/parmetis_4.0.3.orig.tar.gz
tar -xf parmetis_4.0.3.orig.tar.gz
cd parmetis-4.0.3/
cp ../../../patches/CMakeLists.txt .
mkdir -p install
# make config shared=1 cc=cc cxx=CC prefix=${PARMETIS_DIR}
make config cc=cc cxx=CC prefix=${PARMETIS_DIR}
make install > make_parmetis_install.log 2>&1
cd ../
cp $PWD/parmetis-4.0.3/build/Linux-x86_64/libmetis/libmetis.a $PARMETIS_DIR/lib/.
cp $PWD/parmetis-4.0.3/metis/include/metis.h $PARMETIS_DIR/include/.





cd slate
rm -rf build
rm -rf install
mkdir build
mkdir install
cd build
cmake .. \
      -Dblas=libsci \
      -DCMAKE_CXX_COMPILER=CC \
      -DCMAKE_CXX_FLAGS=-DSLATE_HAVE_MT_BCAST \
      -DCMAKE_C_COMPILER=cc \
      -DCMAKE_Fortran_COMPILER=ftn \
      -Dgpu_backend=cuda \
      -Dbuild_tests=OFF \
      -DBUILD_SHARED_LIBS=ON \
      -DCMAKE_BUILD_TYPE=Release \
      -DCMAKE_INSTALL_PREFIX=../install \
      -DSCALAPACK_LIBRARIES=" " \
      -DCMAKE_CUDA_ARCHITECTURES="80"
make -j16
make install
cd ../../


cd magma-2.7.2
rm -rf build
rm -rf install
mkdir build
mkdir install
cd build
cmake ../ \
      -DCMAKE_INSTALL_PREFIX=../install \
      -DCMAKE_CXX_COMPILER=CC \
      -DCMAKE_C_COMPILER=cc \
      -DCMAKE_Fortran_COMPILER=ftn \
      -DCMAKE_BUILD_TYPE=Release \
      -DGPU_TARGET='sm_80' \
      -DCUDAToolkit_ROOT=$CUDATOOLKIT_HOME
make -j16
make install
cd ../../


cd kblas-gpu-dev
cp ../../make.inc .
git checkout wajih_syncwarp
cp ../../kblas_operators.h include
make -j
cd ../


cd STRUMPACK
rm -rf build
rm -rf install
mkdir build
mkdir install
cd build
cmake .. \
      -DCMAKE_BUILD_TYPE=Release \
      -DCMAKE_INSTALL_PREFIX=../install \
      -DSTRUMPACK_USE_MPI=ON \
      -DSTRUMPACK_USE_OPENMP=ON \
      -DCMAKE_CXX_COMPILER=CC \
      -DCMAKE_C_COMPILER=cc \
      -DCMAKE_Fortran_COMPILER=ftn \
      -DSTRUMPACK_COUNT_FLOPS=ON \
      -DSTRUMPACK_USE_CUDA=ON \
      -DCMAKE_CUDA_COMPILER=${CUDA_HOME}/bin/nvcc \
      -DCMAKE_CUDA_ARCHITECTURES="80" \
      -DTPL_ENABLE_MAGMA=ON \
      -DTPL_ENABLE_SLATE=ON \
      -DTPL_ENABLE_SCOTCH=OFF \
      -DTPL_ENABLE_PTSCOTCH=OFF \
      -DTPL_ENABLE_KBLAS=ON \
      -DTPL_KBLAS_INCLUDE_DIR="${KBLAS_DIR}/include" \
      -DTPL_KBLAS_LIBRARIES="${KBLAS_DIR}/lib/libkblas-gpu.a" \
      -DTPL_METIS_INCLUDE_DIR="${METIS_DIR}/include" \
      -DTPL_METIS_LIBRARIES="${METIS_DIR}/lib/libmetis.a" \
      -DTPL_ParMETIS_INCLUDE_DIR="${PARMETIS_DIR}/include" \
      -DTPL_ParMETIS_LIBRARIES="${METIS_DIR}/lib/libparmetis.a"
make -j
make install -j
make examples -j
cd ../../


cd superlu_dist
git checkout gpu3d-benchmark
mkdir build
cd build
cmake .. \
  -DCMAKE_C_FLAGS="-O2 -DGPU_SOLVE -std=c11 -DPRNTlevel=0 -DPROFlevel=0 -DDEBUGlevel=0 -DAdd_" \
  -DCMAKE_CXX_FLAGS="-O2" \
  -DCMAKE_Fortran_FLAGS="-O2" \
  -DCMAKE_CXX_COMPILER=CC \
  -DCMAKE_C_COMPILER=cc \
  -DCMAKE_Fortran_COMPILER=ftn \
  -DXSDK_ENABLE_Fortran=ON \
  -DTPL_ENABLE_INTERNAL_BLASLIB=OFF \
  -DTPL_ENABLE_LAPACKLIB=ON \
  -DBUILD_SHARED_LIBS=ON \
  -DTPL_ENABLE_CUDALIB=ON \
  -DCMAKE_CUDA_FLAGS="-I${NVSHMEM_HOME}/include -I${MPICH_DIR}/include -ccbin=/opt/cray/pe/craype/2.7.30/bin/CC" \
  -DCMAKE_CUDA_ARCHITECTURES=80 \
  -DCMAKE_INSTALL_PREFIX=. \
  -DCMAKE_INSTALL_LIBDIR=./lib \
  -DCMAKE_BUILD_TYPE=Release \
  -DTPL_BLAS_LIBRARIES=/opt/cray/pe/libsci/23.12.5/GNU/12.3/x86_64/lib/libsci_gnu_123_mp.a \
  -DTPL_LAPACK_LIBRARIES=/opt/cray/pe/libsci/23.12.5/GNU/12.3/x86_64/lib/libsci_gnu_123_mp.a \
  -DTPL_PARMETIS_INCLUDE_DIRS="${PARMETIS_DIR}/include;${METIS_DIR}/include" \
  -DTPL_PARMETIS_LIBRARIES="${PARMETIS_DIR}/lib/libparmetis.a;${METIS_DIR}/lib/libmetis.a" \
  -DTPL_ENABLE_COMBBLASLIB=OFF \
  -DTPL_ENABLE_NVSHMEM=ON \
  -DTPL_NVSHMEM_LIBRARIES="-L${CUDA_HOME}/lib64/stubs/ -lnvidia-ml -L/usr/lib64 -lgdrapi -lstdc++ -L/opt/cray/libfabric/1.15.2.0/lib64 -lfabric -L${NVSHMEM_HOME}/lib -lnvshmem" \
  -DCMAKE_VERBOSE_MAKEFILE:BOOL=ON \
  -DMPIEXEC_NUMPROC_FLAG=-n \
  -DMPIEXEC_EXECUTABLE=/usr/bin/srun \
  -DMPIEXEC_MAX_NUMPROCS=16

make pddrive -j16
make pddrive3d -j16
make install
cd ../../

cd petsc
cp ../../../patches/superlu_dist.c ./src/mat/impls/aij/mpi/superlu_dist/.
./configure \
    --FOPTFLAGS="-O3 -march=native" \
    --CXXOPTFLAGS="-O3 -march=native" \
    --COPTFLAGS="-O3 -march=native" \
    --CUDAOPTFLAGS="-O3" \
    --with-scalar-type=complex \
    --with-shared-libraries=1 \
    --with-cuda=1 \
    --with-cuda-arch=80 \
    --with-debugging=0 \
    --with-openmp=1 \
    --with-metis=1 \
    --with-parmetis=1 \
    --with-metis-include=${METIS_DIR}/include \
    --with-metis-lib=[${METIS_DIR}/lib/libmetis.a] \
    --with-parmetis-include=${METIS_DIR}/include \
    --with-parmetis-lib=[${METIS_DIR}/lib/libparmetis.a] \
    --download-ptscotch \
    --with-superlu_dist-include=${SUPERLU_DIST_DIR}/include \
    --with-superlu_dist-lib=[${SUPERLU_DIST_DIR}/lib/libsuperlu_dist.a] \
    --download-superlu=yes \
    --download-mumps=yes \
    --download-hwloc \
    --download-pastix=yes \
    --download-suitesparse=yes \
    --with-scalapack=1 \
    --with-strumpack=1 \
    --with-strumpack-include=[${STRUMPACK_DIR}/include,${KBLAS_DIR}/include] \
    --with-strumpack-lib=[${STRUMPACK_DIR}/lib64/libstrumpack.a,${KBLAS_DIR}/lib/libkblas-gpu.a]
make -j
cd ../

cd ../../

cd driver
rm -rf build
mkdir build
cd build
cmake ../ \
      -DCMAKE_CXX_COMPILER=CC \
      -DCMAKE_C_COMPILER=cc \
      -DCMAKE_Fortran_COMPILER=ftn \
      -DCMAKE_BUILD_TYPE=Release
make
cd ../../
