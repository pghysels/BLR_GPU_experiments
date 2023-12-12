#!/bin/bash

# rm -rf code
mkdir code
cd code

export MAGMA_DIR=`pwd`/magma-2.7.2/install
export SLATE_DIR=`pwd`/slate/install
export METIS_DIR=`pwd`/ParMETIS_install
export PARMETIS_DIR=`pwd`/ParMETIS_install
export STRUMPACK_DIR=`pwd`/STRUMPACK/install
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
git clone https://github.com/KarypisLab/ParMETIS
git clone https://github.com/KarypisLab/GKlib.git
git clone https://github.com/KarypisLab/METIS.git


cd kblas-gpu-dev
cp ../../make.inc .
git checkout wajih_syncwarp
make -j
cd ../


mkdir ParMETIS_install
cd GKlib
make config cc=cc prefix=${PARMETIS_DIR}
make -j
make install
cd ../METIS
make config cc=cc prefix=${PARMETIS_DIR}
make -j
make install
cd ../ParMETIS
make config cc=cc prefix=${PARMETIS_DIR}
make -j
make install
cd ../


cd slate
rm -rf build
rm -rf install
mkdir build
mkdir install
cd build
cmake .. \
      -Dblas=libsci \
      -DCMAKE_CXX_COMPILER=CC \
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
      -DTPL_METIS_LIBRARIES="${METIS_DIR}/lib/libmetis.a;${PARMETIS_DIR}/lib/libGKlib.a" \
      -DTPL_ParMETIS_INCLUDE_DIR="${PARMETIS_DIR}/include" \
      -DTPL_ParMETIS_LIBRARIES="${METIS_DIR}/lib/libparmetis.a;${PARMETIS_DIR}/lib/libGKlib.a"
make -j
make install -j
make examples -j
cd ../../


cd petsc
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
    --with-metis-lib=[${METIS_DIR}/lib/libmetis.a,${PARMETIS_DIR}/lib/libGKlib.a] \
    --with-parmetis-include=${METIS_DIR}/include \
    --with-parmetis-lib=[${METIS_DIR}/lib/libparmetis.a,${PARMETIS_DIR}/lib/libGKlib.a] \
    --download-ptscotch \
    --download-superlu_dist=yes \
    --download-superlu=yes \
    --download-mumps=yes \
    --download-pastix=no \
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
