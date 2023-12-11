export HTTP_PROXY=http://proxy.alcf.anl.gov:3128
export HTTPS_PROXY=http://proxy.alcf.anl.gov:3128
export http_proxy=http://proxy.alcf.anl.gov:3128
export https_proxy=http://proxy.alcf.anl.gov:3128
git config --global http.proxy http://proxy.alcf.anl.gov:3128

alias e='emacs -nw'

export ZES_ENABLE_SYSMAN=1

module use /soft/modulefiles
module load spack-pe-oneapi
module load oneapi/eng-compiler
module load cmake
module load parmetis
module load python
