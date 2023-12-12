#!/bin/bash

export PETSC_DIR=`pwd`/../perlmutter/code/petsc
export PETSC_ARCH=arch-linux-c-opt

FC=ftn
rm -rf build
mkdir build
cd build
cmake ../ \
      -DCMAKE_CXX_COMPILER=CC \
      -DCMAKE_C_COMPILER=cc \
      -DCMAKE_Fortran_COMPILER=ftn \
      -DCMAKE_BUILD_TYPE=Release \

make
cd ../
