static char help[] = "Solves a 3D Helmholtz problem.\n\
Input parameters include:\n\
  -n <mesh>       : number of mesh points\n\n";

#include <iostream>
#include <complex>
#include <algorithm>

#include <petscksp.h>
#include <petscsys.h>

// ideally configured by CMake
#define FC_GLOBAL(name,NAME) name##_
#define FC_GLOBAL_(name,NAME) name##_
#define FC_MODULE(mod_name,name, mod_NAME,NAME) __##mod_name##_MOD_##name
#define FC_MODULE_(mod_name,name, mod_NAME,NAME) __##mod_name##_MOD_##name


extern "C" {
  void FC_GLOBAL_(genmatrix3d_anal,GENMATRIX3D_ANAL)
    (void*,void*,void*,void*,void*,void*,void*,void*,void*,void*);
  void FC_GLOBAL(genmatrix3d,GENMATRIX3D)
    (void*,void*,void*,void*,void*,void*,void*,void*,
     void*,void*,void*,void*,void*);
}


int main(int argc, char* argv[]) {
  int thread_level, rank, P;
  MPI_Init_thread(&argc, &argv, MPI_THREAD_MULTIPLE, &thread_level);
  MPI_Comm_rank(MPI_COMM_WORLD, &rank);
  MPI_Comm_size(MPI_COMM_WORLD, &P);
  if (thread_level != MPI_THREAD_MULTIPLE && rank == 0)
    std::cout << "MPI implementation does not support MPI_THREAD_MULTIPLE"
              << std::endl;

  PetscCall(PetscInitialize(&argc, &argv, (char *)0, help));

  PetscInt n_in = 20;
  PetscCall(PetscOptionsGetInt(NULL, NULL, "-n", &n_in, NULL));
  std::int64_t nx = n_in;

  char datafile[] = "void";
  std::int64_t fromfile = 0, npml = 8, nnz, n;
  std::int64_t nx_ex = nx;
  nx = std::max(std::int64_t(1), nx - 2 * npml);
  std::int64_t n_local = std::round(std::floor(float(nx_ex) / P));
  std::int64_t remainder = nx_ex%P, low_f, high_f;
  if (rank+1 <= remainder) {
    high_f = (rank+1)*(n_local+1);
    low_f = high_f - (n_local+1) + 1;
  } else {
    high_f = remainder*(n_local+1)+(rank+1-remainder)*n_local;
    low_f = high_f - (n_local) + 1;
  }
  n_local = high_f - low_f + 1;
  FC_GLOBAL(genmatrix3d_anal,GENMATRIX3D_ANAL)
    (&nx, &nx, &nx, &n_local, &npml, &n, &nnz, &fromfile, datafile, &rank);

  std::vector<std::int64_t> rowind(nnz), colind(nnz);
  std::vector<std::complex<float>> val(nnz);
  FC_GLOBAL(genmatrix3d,GENMATRIX3D)
    (rowind.data(), colind.data(), val.data(), &nx, &nx, &nx,
     &low_f, &high_f, &npml, &nnz, &fromfile, datafile, &rank);

  Mat A;
  PetscCall(MatCreate(PETSC_COMM_SELF, &A));
  PetscCall(MatSetSizes(A, PETSC_DECIDE, PETSC_DECIDE, n, n));
  PetscCall(MatSetFromOptions(A));
  PetscCall(MatSetUp(A));

  // TODO
  // PetscCall(MatMPIAIJSetPreallocation(A, 5, NULL, 5, NULL));

  for (std::int64_t i=0; i<nnz; i++) {
    PetscInt r = rowind[i], c = colind[i];
    PetscComplex v = val[i];
    PetscCall(MatSetValues(A, 1, &r, 1, &c, &v, INSERT_VALUES));
  }
  PetscCall(MatAssemblyBegin(A, MAT_FINAL_ASSEMBLY));
  PetscCall(MatAssemblyEnd(A, MAT_FINAL_ASSEMBLY));

  Vec x, b, u;
  PetscCall(VecCreate(PETSC_COMM_SELF, &x));
  PetscCall(PetscObjectSetName((PetscObject)x, "Solution"));
  PetscCall(VecSetSizes(x, PETSC_DECIDE, n));
  PetscCall(VecSetFromOptions(x));
  PetscCall(VecDuplicate(x, &b));
  PetscCall(VecDuplicate(x, &u));

  PetscCall(VecSet(u, 1.0));
  PetscCall(MatMult(A, u, b));

  KSP ksp;
  PetscCall(KSPCreate(PETSC_COMM_SELF, &ksp));
  PetscCall(KSPSetOperators(ksp, A, A));
  PetscCall(KSPSetFromOptions(ksp));
  PetscCall(KSPSolve(ksp, b, x));

  PetscReal norm;
  PetscInt its;
  PetscCall(VecAXPY(x, -1.0, u));
  PetscCall(VecNorm(x, NORM_2, &norm));
  PetscCall(KSPGetIterationNumber(ksp, &its));
  PetscCall(PetscPrintf(PETSC_COMM_SELF, "Norm of error %g, Iterations %" PetscInt_FMT "\n", (double)norm, its));

  
  PetscCall(KSPDestroy(&ksp));
  PetscCall(VecDestroy(&x));
  PetscCall(VecDestroy(&u));
  PetscCall(VecDestroy(&b));
  PetscCall(MatDestroy(&A));

  PetscCall(PetscFinalize());
  return 0;
}
