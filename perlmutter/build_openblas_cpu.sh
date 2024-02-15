#!/bin/bash

module load cmake
module unload cray-libsci

# rm -rf code_cpu
mkdir code_cpu
cd code_cpu
export METIS_DIR=`pwd`/../code/ParMETIS_install
export PARMETIS_DIR=`pwd`/../code/ParMETIS_install
export STRUMPACK_DIR=`pwd`/STRUMPACK/install
export OpenBLAS_DIR=`pwd`/OpenBLAS/install
export SCALAPACK_DIR=`pwd`/scalapack/install


git clone git@github.com:OpenMathLib/OpenBLAS.git
git clone git@github.com:Reference-ScaLAPACK/scalapack.git


git clone git@github.com:pghysels/STRUMPACK.git


# cd OpenBLAS
# mkdir build
# mkdir install
# cd build
# cmake ../ \
#       -DCMAKE_BUILD_TYPE=Release \
#       -DCMAKE_INSTALL_PREFIX=../install \
#       -DUSE_OPENMP=1
# make -j16
# make install
# cd ../../

cd scalapack
mkdir build
mkdir install
cd build
cmake ../ \
      -DCMAKE_BUILD_TYPE=Release \
      -DCMAKE_INSTALL_PREFIX=../install \
      -DCMAKE_CXX_FLAGS='-fopenmp' \
      -DCMAKE_EXE_LINKER_FLAGS='-fopenmp' \
      -DBLAS_LIBRARIES=${OpenBLAS_DIR}/lib64/libopenblas.a \
      -DLAPACK_LIBRARIES=${OpenBLAS_DIR}/lib64/libopenblas.a
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
      -DSTRUMPACK_USE_CUDA=OFF \
      -DTPL_BLAS_LIBRARIES=${OpenBLAS_DIR}/lib64/libopenblas.a \
      -DTPL_LAPACK_LIBRARIES=${OpenBLAS_DIR}/lib64/libopenblas.a \
      -DTPL_SCALAPACK_LIBRARIES=${SCALAPACK_DIR}/lib/libscalapack.a \
      -DTPL_METIS_INCLUDE_DIR="${METIS_DIR}/include" \
      -DTPL_METIS_LIBRARIES="${METIS_DIR}/lib/libmetis.a" \
      -DTPL_ParMETIS_INCLUDE_DIR="${PARMETIS_DIR}/include" \
      -DTPL_ParMETIS_LIBRARIES="${METIS_DIR}/lib/libparmetis.a"
make -j
make install -j
make examples -j
cd ../../

