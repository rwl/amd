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

/// Sorts, removes duplicate entries, and transposes from the nonzero pattern of
/// a column-form matrix A, to obtain the matrix R.  The input matrix can have
/// duplicate entries and/or unsorted columns (AMD_valid (n,Ap,Ai) must not be
/// AMD_INVALID).
///
/// This input condition is NOT checked.  This routine is not user-callable.
///
/// [preprocess] does not check its input for errors or allocate workspace.
/// On input, the condition (AMD_valid (n,n,Ap,Ai) != AMD_INVALID) must hold.
///
/// [n]: input matrix: A is n-by-n
/// [Ap]: size n+1
/// [Ai]: size nz = Ap [n]
/// [Rp]: size n+1
/// [Ri]: size nz (or less, if duplicates present)
/// [W]: workspace of size n
/// [Flag]: workspace of size n
void preprocess(int n, final List<int> Ap, final List<int> Ai, List<int> Rp,
                List<int> Ri, List<int> W, List<int> flag) {

  _assert(valid(n, n, Ap, Ai) != INVALID);

  /* ----------------------------------------------------------------- */
  /* count the entries in each row of A (excluding duplicates) */
  /* ----------------------------------------------------------------- */

  for (int i = 0; i < n; i++) {
    W[i] = 0;
    /* # of nonzeros in row i (excl duplicates) */
    flag[i] = empty;
    /* Flag [i] = j if i appears in column j */
  }
  for (int j = 0; j < n; j++) {
    int p2 = Ap[j + 1];
    for (int p = Ap[j]; p < p2; p++) {
      int i = Ai[p];
      if (flag[i] != j) {
        /* row index i has not yet appeared in column j */
        W[i]++;
        /* one more entry in row i */
        flag[i] = j;
        /* flag row index i as appearing in col j*/
      }
    }
  }

  /* ----------------------------------------------------------------- */
  /* compute the row pointers for R */
  /* ----------------------------------------------------------------- */

  Rp[0] = 0;
  for (int i = 0; i < n; i++) {
    Rp[i + 1] = Rp[i] + W[i];
  }
  for (int i = 0; i < n; i++) {
    W[i] = Rp[i];
    flag[i] = empty;
  }

  /* ----------------------------------------------------------------- */
  /* construct the row form matrix R */
  /* ----------------------------------------------------------------- */

  /* R = row form of pattern of A */
  for (int j = 0; j < n; j++) {
    int p2 = Ap[j + 1];
    for (int p = Ap[j]; p < p2; p++) {
      int i = Ai[p];
      if (flag[i] != j) {
        /* row index i has not yet appeared in column j */
        Ri[W[i]++] = j;
        /* put col j in row i */
        flag[i] = j;
        /* flag row index i as appearing in col j*/
      }
    }
  }

  if (!_ndebug) {
    _assert(valid(n, n, Rp, Ri) == OK);
    for (int j = 0; j < n; j++) {
      _assert(W[j] == Rp[j + 1]);
    }
  }
}
