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

/// User-callable AMD minimum degree ordering routine.
int order(int n, final List<int> Ap, final List<int> Ai, List<int> P, List<num> control, List<num> info) {
  List<int> Len, Pinv, Rp, Ri, Cp, Ci;
  var mem = 0.0;

  if (!_ndebug) {
    //amd_debug_init ("amd") ;
  }

  /* clear the Info array, if it exists */
  int hasInfo = info != null ? 1 : 0;
  if (hasInfo != 0) {
    for (int i = 0; i < INFO; i++) {
      info[i] = empty;
    }
    info[N] = n;
    info[STATUS] = OK;
  }

  /* make sure inputs exist and n is >= 0 */
  if (Ai == null || Ap == null || P == null || n < 0) {
    if (hasInfo != 0) info[STATUS] = INVALID;
    return (INVALID);
    /* arguments are invalid */
  }

  if (n == 0) {
    return (OK);
    /* n is 0 so there's nothing to do */
  }

  final nz = Ap[n];
  if (hasInfo != 0) {
    info[NZ] = nz;
  }
  if (nz < 0) {
    if (hasInfo != 0) info[STATUS] = INVALID;
    return (INVALID);
  }

  /* FIXME: check if n or nz will cause size_t overflow */
  /*if (n >= Int_MAX //SIZE_T_MAX / sizeof (int)
   || nz >= Int_MAX) //SIZE_T_MAX / sizeof (int))
  {
  if (Info [AMD_STATUS] == AMD_OUT_OF_MEMORY)
  return (AMD_OUT_OF_MEMORY) ;	    /* problem too large */
  }*/

  /* check the input matrix:	AMD_OK, AMD_INVALID, or AMD_OK_BUT_JUMBLED */
  final status = valid(n, n, Ap, Ai);

  if (status == INVALID) {
    if (info[STATUS] == INVALID) return (INVALID);
    /* matrix is invalid */
  }

  /* allocate two size-n integer workspaces */
  try {
    Len = new Int32List(n);
    Pinv = new Int32List(n);
    mem += n;
    mem += n;
  } on OutOfMemoryError catch (e) {
    /* :: out of memory :: */
    Len = null;
    Pinv = null;
    return (OUT_OF_MEMORY);
  }

  if (status == OK_BUT_JUMBLED) {
    /* sort the input matrix and remove duplicate entries */
    debug1(("Matrix is jumbled"));
    try {
      Rp = new Int32List(n + 1);
      Ri = new Int32List(max(nz, 1));
      mem += (n + 1);
      mem += max(nz, 1);
    } on OutOfMemoryError catch (e) {
      /* :: out of memory :: */
      Rp = null;
      Ri = null;
      Len = null;
      Pinv = null;
      return (OUT_OF_MEMORY);
    }
    /* use Len and Pinv as workspace to create R = A' */
    preprocess(n, Ap, Ai, Rp, Ri, Len, Pinv);
    Cp = Rp;
    Ci = Ri;
  } else {
    /* order the input matrix as-is.  No need to compute R = A' first */
    Rp = null;
    Ri = null;
    Cp = Ap;
    Ci = Ai;
  }

  /* --------------------------------------------------------------------- */
  /* determine the symmetry and count off-diagonal nonzeros in A+A' */
  /* --------------------------------------------------------------------- */

  final nzaat = aat(n, Cp, Ci, Len, P, info);
  debug1("nzaat: $nzaat");
  _assert((max(nz - n, 0) <= nzaat) && (nzaat <= 2 * nz));

  /* --------------------------------------------------------------------- */
  /* allocate workspace for matrix, elbow room, and 6 size-n vectors */
  /* --------------------------------------------------------------------- */

  int slen = nzaat;
  /* space for matrix */
  int ok = ((slen + nzaat / 5) >= slen) ? 1 : 0;
  /* check for size_t overflow */
  slen += (nzaat ~/ 5);
  /* add elbow room */
  for (int i = 0; ok != 0 && i < 7; i++) {
    ok = ((slen + n) > slen) ? 1 : 0;
    /* check for size_t overflow */
    slen += n;
    /* size-n elbow room, 6 size-n work */
  }
  mem += slen;
  //ok = (ok != 0 && (slen < Int_MAX)) ? 1 : 0 ;  /* check for overflow */
  ok = (ok != 0/* && (slen < Int_MAX)*/) ? 1 : 0;
  /* S[i] for int i must be OK */
  try {
    if (ok != 0) {
      //S = new int[slen] ;
    }
    debug1("slen $slen");
  } on OutOfMemoryError catch (e) {
    /* :: out of memory :: (or problem too large) */
    Rp = null;
    Ri = null;
    Len = null;
    Pinv = null;
    return (OUT_OF_MEMORY);
  }
  if (hasInfo != 0) {
    /* memory usage, in bytes. */
    info[MEMORY] = mem * 4; //sizeof (int) ;
  }

  /* --------------------------------------------------------------------- */
  /* order the matrix */
  /* --------------------------------------------------------------------- */

  amd_1(n, Cp, Ci, P, Pinv, Len, slen, control, info);

  /* --------------------------------------------------------------------- */
  /* free the workspace */
  /* --------------------------------------------------------------------- */

  Rp = null;
  Ri = null;
  Len = null;
  Pinv = null;
  if (hasInfo != 0) info[STATUS] = status;
  return (status);
  /* successful ordering */
}
