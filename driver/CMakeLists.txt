cmake_minimum_required(VERSION 3.21)
project(BLR_GPU VERSION 1.0.0 LANGUAGES CXX C Fortran)

add_executable(Helmholtz Helmholtz.cpp genmatrix3D_core.f)

find_package(STRUMPACK)
target_link_libraries(Helmholtz PUBLIC STRUMPACK::strumpack)


set(CMAKE_INSTALL_RPATH_USE_LINK_PATH TRUE)

# set root of location to find PETSc's pkg-config
set(PETSC $ENV{PETSC_DIR}/$ENV{PETSC_ARCH})
set(ENV{PKG_CONFIG_PATH} ${PETSC}/lib/pkgconfig)

# Remove the lines below if you do not wish to have PETSc determine the compilers
# execute_process ( COMMAND pkg-config PETSc --variable=ccompiler COMMAND tr -d '\n' OUTPUT_VARIABLE C_COMPILER)
# SET(CMAKE_C_COMPILER ${C_COMPILER})
# execute_process ( COMMAND pkg-config PETSc --variable=cxxcompiler COMMAND tr -d '\n' OUTPUT_VARIABLE CXX_COMPILER)
# if (CXX_COMPILER)
#   SET(CMAKE_CXX_COMPILER ${CXX_COMPILER})
# endif (CXX_COMPILER)
# execute_process ( COMMAND pkg-config PETSc --variable=fcompiler COMMAND tr -d '\n' OUTPUT_VARIABLE FORTRAN_COMPILER)
# if (FORTRAN_COMPILER)
#   SET(CMAKE_Fortran_COMPILER ${FORTRAN_COMPILER})
#   enable_language(Fortran)
# endif (FORTRAN_COMPILER)

find_package(PkgConfig REQUIRED)
# list(APPEND PKG_CONFIG_EXECUTABLE "--static")
pkg_search_module(PETSC REQUIRED IMPORTED_TARGET PETSc)
target_link_libraries(Helmholtz PUBLIC PkgConfig::PETSC)

