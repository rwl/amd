/// AMD, Copyright (C) 2009-2011 by Timothy A. Davis, Patrick R. Amestoy,
/// and Iain S. Duff.  All Rights Reserved.
/// Copyright (C) 2011-2014 Richard Lincoln
///
/// AMD is free software; you can redistribute it and/or
/// modify it under the terms of the GNU Lesser General Public
/// License as published by the Free Software Foundation; either
/// version 2.1 of the License, or (at your option) any later version.
///
/// AMD is distributed in the hope that it will be useful,
/// but WITHOUT ANY WARRANTY; without even the implied warranty of
/// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
/// Lesser General Public License for more details.
///
/// You should have received a copy of the GNU Lesser General Public
/// License along with AMD; if not, write to the Free Software
/// Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110-1301
part of edu.ufl.cise.amd;

/// Compute the symmetry of the pattern of A, and count the number of
/// nonzeros each column of A+A' (excluding the diagonal).  Assumes the input
/// matrix has no errors, with sorted columns and no duplicates
/// (valid(n, n, Ap, Ai) must be AMD_OK, but this condition is not
/// checked).
///
/// [Len]: Len[j]: length of column j of A+A', excl diagonal
/// [Tp]: workspace of size n
int aat(int n, final List<int> Ap, final List<int> Ai, List<int> Len, List<int> Tp, List<num> info) {
  if (!_ndebug) {
    //amd_debug_init ("AMD AAT") ;
    for (int k = 0; k < n; k++) Tp[k] = empty;
    _assert(valid(n, n, Ap, Ai) == OK);
  }

  if (info != null) {
    /* clear the Info array, if it exists */
    for (int i = 0; i < INFO; i++) {
      info[i] = empty;
    }
    info[STATUS] = OK;
  }

  for (int k = 0; k < n; k++) {
    Len[k] = 0;
  }

  int nzdiag = 0;
  int nzboth = 0;
  final nz = Ap[n];

  for (int k = 0; k < n; k++) {
    int p, pj;
    int p1 = Ap[k];
    int p2 = Ap[k + 1];
    debug2("\nAAT Column: $k p1: $p1 p2: $p2");

    /* construct A+A' */
    for (p = p1; p < p2; ) {
      /* scan the upper triangular part of A */
      int j = Ai[p];
      if (j < k) {
        /* entry A (j,k) is in the strictly upper triangular part,
     * add both A (j,k) and A (k,j) to the matrix A+A' */
        Len[j]++;
        Len[k]++;
        debug3("    upper ($j,$k) ($k,$j)");
        p++;
      } else if (j == k) {
        /* skip the diagonal */
        p++;
        nzdiag++;
        break;
      } else /* j > k */
      {
        /* first entry below the diagonal */
        break;
      }
      /* scan lower triangular part of A, in column j until reaching
     * row k.  Start where last scan left off. */
      _assert(Tp[j] != empty);
      _assert(Ap[j] <= Tp[j] && Tp[j] <= Ap[j + 1]);
      int pj2 = Ap[j + 1];
      for (pj = Tp[j]; pj < pj2; ) {
        int i = Ai[pj];
        if (i < k) {
          /* A (i,j) is only in the lower part, not in upper.
           * add both A (i,j) and A (j,i) to the matrix A+A' */
          Len[i]++;
          Len[j]++;
          debug3("    lower ($i,$j) ($j,$i)");
          pj++;
        } else if (i == k) {
          /* entry A (k,j) in lower part and A (j,k) in upper */
          pj++;
          nzboth++;
          break;
        } else /* i > k */
        {
          /* consider this entry later, when k advances to i */
          break;
        }
      }
      Tp[j] = pj;
    }
    /* Tp [k] points to the entry just below the diagonal in column k */
    Tp[k] = p;
  }

  /* clean up, for remaining mismatched entries */
  for (int j = 0; j < n; j++) {
    for (int pj = Tp[j]; pj < Ap[j + 1]; pj++) {
      int i = Ai[pj];
      /* A (i,j) is only in the lower part, not in upper.
     * add both A (i,j) and A (j,i) to the matrix A+A' */
      Len[i]++;
      Len[j]++;
      debug3("    lower cleanup ($i,$j) ($j,$i)");
    }
  }

  /* --------------------------------------------------------------------- */
  /* compute the symmetry of the nonzero pattern of A */
  /* --------------------------------------------------------------------- */

  /* Given a matrix A, the symmetry of A is:
   * B = tril (spones (A), -1) + triu (spones (A), 1) ;
   *  sym = nnz (B & B') / nnz (B) ;
   *  or 1 if nnz (B) is zero.
   */

  double sym;
  if (nz == nzdiag) {
    sym = 1.0;
  } else {
    sym = (2 * nzboth) / (nz - nzdiag);
  }

  int nzaat = 0;
  for (int k = 0; k < n; k++) {
    nzaat += Len[k];
  }

  debug1("AMD nz in A+A', excluding diagonal (nzaat) = $nzaat");
  debug1("   nzboth: $nzboth nz: $nz nzdiag: $nzdiag symmetry: $sym");

  if (info != null) {
    info[STATUS] = OK;
    info[N] = n;
    info[NZ] = nz;
    info[SYMMETRY] = sym;
    /* symmetry of pattern of A */
    info[NZDIAG] = nzdiag;
    /* nonzeros on diagonal of A */
    info[NZ_A_PLUS_AT] = nzaat;
    /* nonzeros in A+A' */
  }

  return (nzaat);
}
