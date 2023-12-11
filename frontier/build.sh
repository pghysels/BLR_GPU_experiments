#!/bin/bash

mkdir code
cd code

export MAGMA_DIR=`pwd`/magma-2.7.2/install
export SLATE_DIR=`pwd`/slate/install
# export METIS_DIR=`pwd`/metis-5.1.0/install
export METIS_DIR=`pwd`/ParMETIS_install
export PARMETIS_DIR=`pwd`/ParMETIS_install
export STRUMPACK_DIR=`pwd`/STRUMPACK/install
export PETSC_DIR=`pwd`/petsc


# wget https://icl.utk.edu/projectsfiles/magma/downloads/magma-2.7.2.tar.gz
# tar -xzf magma-2.7.2.tar.gz

# git clone --recursive https://github.com/icl-utk-edu/slate.git
# git clone git@github.com:pghysels/STRUMPACK.git
# git clone -b release https://gitlab.com/petsc/petsc.git petsc

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


# cd slate
# rm -rf build
# rm -rf install
# mkdir build
# mkdir install
# cd build
# cmake .. \
#       -DCMAKE_BUILD_TYPE=Release \
#       -DCMAKE_INSTALL_PREFIX=../install \
#       -Dblas=libsci \
#       -DCMAKE_CXX_COMPILER=hipcc \
#       -DCMAKE_C_COMPILER=cc \
#       -DCMAKE_Fortran_COMPILER=ftn \
#       -DBLAS_LIBRARIES="/opt/cray/pe/libsci/22.12.1.1/GNU/9.1/x86_64/lib/libsci_gnu_mp.so" \
#       -Dgpu_backend=hip \
#       -Dgpu_aware_mpi=0 \
#       -Duse_openmp=yes \
#       -Dbuild_tests=no \
#       -DSCALAPACK_LIBRARIES=" "
# make -j16
# make install
# cd ../../


# cd magma-2.7.2
# rm -rf build
# rm -rf install
# mkdir build
# mkdir install
# cd build
# cmake ../ \
#       -DCMAKE_INSTALL_PREFIX=../install \
#       -DCMAKE_EXE_LINKER_FLAGS="-Wl,--allow-shlib-undefined" \
#       -DCMAKE_BUILD_TYPE=Release \
#       -DCMAKE_CXX_COMPILER=hipcc \
#       -DCMAKE_C_COMPILER=cc \
#       -DCMAKE_Fortran_COMPILER=ftn \
#       -DMAGMA_ENABLE_HIP=ON \
#       -DGPU_TARGET='gfx90a' \
#       -DUSE_FORTRAN=OFF
# make -j16
# make install
# cd ../../


# cd STRUMPACK
# rm -rf build
# rm -rf install
# mkdir build
# mkdir install
# cd build
# cmake .. \
#       -DCMAKE_BUILD_TYPE=Release \
#       -DCMAKE_INSTALL_PREFIX=../install \
#       -DCMAKE_CXX_COMPILER=hipcc \
#       -DCMAKE_C_COMPILER=cc \
#       -DCMAKE_Fortran_COMPILER=ftn \
#       -DSTRUMPACK_USE_CUDA=OFF \
#       -DSTRUMPACK_USE_HIP=ON \
#       -DCMAKE_HIP_ARCHITECTURES=gfx90a \
#       -DSTRUMPACK_COUNT_FLOPS=ON \
#       -DTPL_ENABLE_BPACK=OFF \
#       -DTPL_ENABLE_ZFP=OFF \
#       -DTPL_ENABLE_SLATE=ON \
#       -DTPL_ENABLE_MAGMA=ON \
#       -DTPL_METIS_INCLUDE_DIR="${METIS_DIR}/include" \
#       -DTPL_METIS_LIBRARIES="${METIS_DIR}/lib/libmetis.a;${PARMETIS_DIR}/lib/libGKlib.a" \
#       -DTPL_ParMETIS_INCLUDE_DIR="${PARMETIS_DIR}/include" \
#       -DTPL_ParMETIS_LIBRARIES="${METIS_DIR}/lib/libparmetis.a;${PARMETIS_DIR}/lib/libGKlib.a"
# make -j
# make install -j
# make examples -j
# cd ../../


cd petsc
./configure \
    --with-mpi-compilers=0 \
    --with-mpi-dir=/opt/cray/pe/mpich/8.1.23/ofi/gnu/9.1/ \
    --CC=cc \
    --CXX=hipcc \
    --FC=ftn \
    --FOPTFLAGS="-O3 -march=native" \
    --CXXOPTFLAGS="-O3 -march=native" \
    --COPTFLAGS="-O3 -march=native" \
    --HIPOPTFLAGS="-O3" \
    --with-shared-libraries=0 \
    --with-hip=1 \
    --with-hip-arch=gfx90a \
    --with-debugging=0 \
    --with-openmp=1 \
    --with-metis=1 \
    --with-parmetis=1 \
    --with-metis-include=${METIS_DIR}/include \
    --with-metis-lib=[${METIS_DIR}/lib/libmetis.a,${PARMETIS_DIR}/lib/libGKlib.a] \
    --with-parmetis-include=${METIS_DIR}/include \
    --with-parmetis-lib=[${METIS_DIR}/lib/libparmetis.a,${PARMETIS_DIR}/lib/libGKlib.a] \
    --download-ptscotch \
    --download-superlu_dist=no \
    --download-superlu_dist-cmake-arguments="-UMPI_CXX_COMPILER" \
    --download-superlu=no \
    --download-mumps=yes \
    --download-pastix=no \
    --download-suitesparse=yes \
    --with-scalapack=1 \
    --with-strumpack=1 \
    --with-strumpack-include=[${STRUMPACK_DIR}/include] \
    --with-strumpack-lib=[${STRUMPACK_DIR}/lib64/libstrumpack.a]
make -j
