#!/bin/bash

mkdir code
cd code

export MAGMA_DIR=`pwd`/magma
export SLATE_DIR=`pwd`/slate/install
export METIS_DIR=${METIS_ROOT}
export PARMETIS_DIR=${PARMETIS_ROOT}
export STRUMPACK_DIR=`pwd`/STRUMPACK/install
export PETSC_DIR=`pwd`/petsc

# git clone https://pieter_ghysels@bitbucket.org/icl/magma.git
# git clone --recursive https://github.com/icl-utk-edu/slate.git
# git clone git@github.com:ecrc/kblas-gpu-dev.git
# git clone git@github.com:pghysels/STRUMPACK.git
# git clone -b release https://gitlab.com/petsc/petsc.git petsc


# cd slate
# rm -rf build
# rm -rf install
# mkdir build
# mkdir install
# cd build
# cmake .. \
#       -DCMAKE_BUILD_TYPE=Release \
#       -DCMAKE_INSTALL_PREFIX=../install \
#       -DCMAKE_CXX_COMPILER=icpx \
#       -Dgpu_backend=sycl \
#       -Dblas=mkl \
#       -Dbuild_tests=OFF
# make -j16
# make install
# cd ../../


cd magma
git checkout dpcpp-port
cp ../../make.inc .
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
      -DOpenMP_CXX_FLAGS="-fiopenmp" \
      -DOpenMP_CXX_LIB_NAMES="" \
      -DCMAKE_INSTALL_PREFIX=../install \
      -DCMAKE_CXX_COMPILER=icpx \
      -DCMAKE_CXX_FLAGS="-fsycl" \
      -DCMAKE_C_COMPILER=icx \
      -DCMAKE_Fortran_COMPILER=ifx \
      -DSTRUMPACK_USE_MPI=ON \
      -DSTRUMPACK_USE_SLATE=ON \
      -DSTRUMPACK_USE_CUDA=OFF \
      -DSTRUMPACK_USE_SYCL=ON \
      -DBLA_VENDOR=Intel10_64lp \
      -DTPL_SCALAPACK_LIBRARIES="-lmkl_scalapack_lp64 -lmkl_blacs_intelmpi_lp64" \
      -DSTRUMPACK_COUNT_FLOPS=ON \
      -DTPL_ENABLE_MAGMA=ON \
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
    --CC=icx \
    --CXX=icpx \
    --FTN=ifx \
    --FOPTFLAGS="-O3 -march=native" \
    --CXXOPTFLAGS="-O3 -march=native" \
    --COPTFLAGS="-O3 -march=native" \
    --with-shared-libraries=0 \
    --with-cuda=0 \
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
