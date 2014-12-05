/// AMD, Copyright (C) 2009-2011 by Timothy A. Davis, Patrick R. Amestoy,
/// and Iain S. Duff.  All Rights Reserved.
/// Copyright (C) 2011-2014 Richard Lincoln
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

/// Construct A+A' for a sparse matrix A and perform the AMD ordering.
///
/// The n-by-n sparse matrix A can be unsymmetric. It is stored in MATLAB-style
/// compressed-column form, with sorted row indices in each column, and no
/// duplicate entries. Diagonal entries may be present, but they are ignored.
/// Row indices of column j of A are stored in Ai [Ap [j] ... Ap[j+1]-1].
/// Ap[0] must be zero, and nz = Ap[n] is the number of entries in A. The
/// size of the matrix, n, must be greater than or equal to zero.
///
/// This routine must be preceded by a call to [aat], which computes the
/// number of entries in each row/column in A+A', excluding the diagonal.
/// Len[j], on input, is the number of entries in row/column j of A+A'. This
/// routine constructs the matrix A+A' and then calls [amd_2]. No error checking
/// is performed (this was done in [valid]).
///
/// [n]: n > 0
/// [Ap]: input of size n+1, not modified
/// [Ai]: input of size nz = Ap [n], not modified
/// [P]: size n output permutation
/// [Pinv]: size n output inverse permutation
/// [Len]: size n input, undefined on output
/// [slen]: slen >= sum (Len [0..n-1]) + 7n,
/// ideally slen = 1.2 * sum (Len) + 8n
/// [S]: size slen workspace
/// [control]: input array of size [CONTROL]
/// [info]: output array of size [INFO]
amd_1(int n, List<int> Ap, final List<int> Ai, List<int> P, List<int> Pinv,
      List<int> Len, int slen, List<num> control, List<num> info) {

  /* --------------------------------------------------------------------- */
  /* Construct the matrix for amd_2 */
  /* --------------------------------------------------------------------- */

  _assert(n > 0);

  final iwlen = slen - 6 * n;
  final Pe = new Int32List(n);
  final Nv = new Int32List(n);
  final Head = new Int32List(n);
  final Elen = new Int32List(n);
  final degree = new Int32List(n);
  final W = new Int32List(n);
  final Iw = new Int32List(iwlen);

  _assert(valid(n, n, Ap, Ai) == OK);

  /* construct the pointers for A+A' */
  final Sp = Nv;
  /* use Nv and W as workspace for Sp and Tp [ */
  final Tp = W;
  int pfree = 0;
  for (int j = 0; j < n; j++) {
    Pe[j] = pfree;
    Sp[j] = pfree;
    pfree += Len[j];
  }

  /* Note that this restriction on iwlen is slightly more restrictive than
   * what is strictly required in AMD_2.  AMD_2 can operate with no elbow
   * room at all, but it will be very slow.  For better performance, at
   * least size-n elbow room is enforced. */
  _assert(iwlen >= pfree + n);

  if (!_ndebug) {
    for (int p = 0; p < iwlen; p++) Iw[p] = empty;
  }

  for (int k = 0; k < n; k++) {
    debug1("Construct row/column k= $k of A+A'");
    int p, pj;
    final p1 = Ap[k];
    final p2 = Ap[k + 1];

    /* construct A+A' */
    for (p = p1; p < p2; ) {
      /* scan the upper triangular part of A */
      final j = Ai[p];
      _assert(j >= 0 && j < n);
      if (j < k) {
        /* entry A (j,k) in the strictly upper triangular part */
        _assert(Sp[j] < (j == n - 1 ? pfree : Pe[j + 1]));
        _assert(Sp[k] < (k == n - 1 ? pfree : Pe[k + 1]));
        Iw[Sp[j]++] = k;
        Iw[Sp[k]++] = j;
        p++;
      } else if (j == k) {
        /* skip the diagonal */
        p++;
        break;
      } else /* j > k */
      {
        /* first entry below the diagonal */
        break;
      }
      /* scan lower triangular part of A, in column j until reaching
       * row k.  Start where last scan left off. */
      _assert(Ap[j] <= Tp[j] && Tp[j] <= Ap[j + 1]);
      final pj2 = Ap[j + 1];
      for (pj = Tp[j]; pj < pj2; ) {
        final i = Ai[pj];
        _assert(i >= 0 && i < n);
        if (i < k) {
          /* A (i,j) is only in the lower part, not in upper */
          _assert(Sp[i] < (i == n - 1 ? pfree : Pe[i + 1]));
          _assert(Sp[j] < (j == n - 1 ? pfree : Pe[j + 1]));
          Iw[Sp[i]++] = j;
          Iw[Sp[j]++] = i;
          pj++;
        } else if (i == k) {
          /* entry A (k,j) in lower part and A (j,k) in upper */
          pj++;
          break;
        } else /* i > k */
        {
          /* consider this entry later, when k advances to i */
          break;
        }
      }
      Tp[j] = pj;
    }
    Tp[k] = p;
  }

  /* clean up, for remaining mismatched entries */
  for (int j = 0; j < n; j++) {
    for (int pj = Tp[j]; pj < Ap[j + 1]; pj++) {
      int i = Ai[pj];
      _assert(i >= 0 && i < n);
      /* A (i,j) is only in the lower part, not in upper */
      _assert(Sp[i] < (i == n - 1 ? pfree : Pe[i + 1]));
      _assert(Sp[j] < (j == n - 1 ? pfree : Pe[j + 1]));
      Iw[Sp[i]++] = j;
      Iw[Sp[j]++] = i;
    }
  }

  if (!_ndebug) {
    for (int j = 0; j < n - 1; j++) _assert(Sp[j] == Pe[j + 1]);
    _assert(Sp[n - 1] == pfree);
  }

  /* Tp and Sp no longer needed ] */

  /* --------------------------------------------------------------------- */
  /* order the matrix */
  /* --------------------------------------------------------------------- */

  amd_2(n, Pe, Iw, Len, iwlen, pfree, Nv, Pinv, P, Head, Elen, degree, W, control, info);
}
