module faster_lmm_d.kinship;

import std.stdio;
import std.exception;

import faster_lmm_d.dmatrix;
import faster_lmm_d.optmatrix;
import faster_lmm_d.helpers;

dmatrix compute_W(int job, dmatrix G, int n, int snps, int compute_size)
{
  //"""
  //Read 1000 SNPs at a time into matrix and return the result
  //"""
  int m = compute_size;
  dmatrix W;
  W = zerosMatrix(n,m); //* np.nan; // W matrix has dimensions individuals x SNPs (initially all NaNs)
  for(int j = 0; j < compute_size; j++){ // j in range(0,compute_size):
    int pos = job*m + j; //# real position
    if(pos >= snps) {
      //W = W[:,range(0,j)];
      enforce(true, "HUH?");
      break;
    }
    dmatrix snp = G;
  }
  return W;
}

dmatrix kinship_full(dmatrix G)
{
  //"""
  //Calculate the Kinship matrix using a full dot multiplication
  //"""
  writeln("Full kinship matrix used");
  int m = G.shape[0]; // snps
  int n = G.shape[1]; // inds
  writeln(m," SNPs");
  assert(m>n, "n should be larger than m");
  dmatrix temp = matrixTranspose(G);
  dmatrix dot = matrixMult(temp, G);
  dmatrix K = divideDmatrixNum(dot, G.shape[0]);
  writeln("kinship_full K");
  writeln(K[0][0]);
  return K;
}

dmatrix kinshipComp(dmatrix G, int computeSize=1000)
{
  writeln("G => ");
  prettyPrint(G);
  int n = G.shape[1]; // inds
  int inds = n;
  int m = G.shape[0]; // snps
  int snps = m;
  writeln("%d SNPs",m);
  if(snps>=inds) {
    writeln("WARNING: less snps than inds (%d snps, %d inds)",(snps,inds));
  }
  dmatrix K;

  int iterations = snps/computeSize + 1;
  K = zerosMatrix(n,n);  // The Kinship matrix has dimension individuals x individuals
  for(int job = 0; job < iterations; job++) {
    writefln("Processing job %d first %d SNPs",job, ((job+1)*computeSize));
    dmatrix W = compute_W(job,G,n,snps,computeSize);
    compute_matrixMult(job,W);
    dmatrix x;
    dmatrix K_j = x;
    K = addDmatrix(K,K_j);
  }
  K = divideDmatrixNum(K, cast(double)snps);
  return K;
}

int compute_matrixMult(int job, dmatrix W)
{
  //"""
  // Compute Kinship(W)*j
  //For every set of SNPs matrixMult is used to multiply matrices T(W)*W
  //"""
  dmatrix res = matrixMultT(W, W);
  writeln(res);
  return job;
}

eighTuple kvakve(dmatrix K)
{
  //"""
  //Obtain eigendecomposition for K and return Kva,Kve where Kva is cleaned
  //of small values < 1e-6 (notably smaller than zero)
  //"""
  writefln("Obtaining eigendecomposition for %dx%d matrix",K.shape[0],K.shape[1]);
  return eigh(K);

}
