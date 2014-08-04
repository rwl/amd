/**
 * AMD, Copyright (C) 2009-2011 by Timothy A. Davis, Patrick R. Amestoy,
 * and Iain S. Duff.  All Rights Reserved.
 * Copyright (C) 2011-2014 Richard Lincoln
 *
 * AMD is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 *
 * AMD is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with AMD; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110-1301
 */
part of edu.ufl.cise.amd;

/**
 * User-callable AMD minimum degree ordering routine.
 */
int order(int n, final Int32List Ap, final Int32List Ai, Int32List P, List<num> Control, List<num> Info) {
  Int32List Len, Pinv, Rp, Ri, Cp, Ci;
  int nz, i, info, status, ok;
  int nzaat, slen;
  double mem = 0.0;

  if (!NDEBUG) {
    //amd_debug_init ("amd") ;
  }

  /* clear the Info array, if it exists */
  info = Info != null ? 1 : 0;
  if (info != 0) {
    for (i = 0; i < AMD_INFO; i++) {
      Info[i] = EMPTY;
    }
    Info[AMD_N] = n;
    Info[AMD_STATUS] = AMD_OK;
  }

  /* make sure inputs exist and n is >= 0 */
  if (Ai == null || Ap == null || P == null || n < 0) {
    if (info != 0) Info[AMD_STATUS] = AMD_INVALID;
    return (AMD_INVALID);
    /* arguments are invalid */
  }

  if (n == 0) {
    return (AMD_OK);
    /* n is 0 so there's nothing to do */
  }

  nz = Ap[n];
  if (info != 0) {
    Info[AMD_NZ] = nz;
  }
  if (nz < 0) {
    if (info != 0) Info[AMD_STATUS] = AMD_INVALID;
    return (AMD_INVALID);
  }

  /* FIXME: check if n or nz will cause size_t overflow */
  /*if (n >= Int_MAX //SIZE_T_MAX / sizeof (int)
   || nz >= Int_MAX) //SIZE_T_MAX / sizeof (int))
  {
  if (Info [AMD_STATUS] == AMD_OUT_OF_MEMORY)
  return (AMD_OUT_OF_MEMORY) ;	    /* problem too large */
  }*/

  /* check the input matrix:	AMD_OK, AMD_INVALID, or AMD_OK_BUT_JUMBLED */
  status = valid(n, n, Ap, Ai);

  if (status == AMD_INVALID) {
    if (Info[AMD_STATUS] == AMD_INVALID) return (AMD_INVALID);
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
    return (AMD_OUT_OF_MEMORY);
  }

  if (status == AMD_OK_BUT_JUMBLED) {
    /* sort the input matrix and remove duplicate entries */
    AMD_DEBUG1(("Matrix is jumbled\n"));
    try {
      Rp = new Int32List(n + 1);
      Ri = new Int32List(MAX(nz, 1));
      mem += (n + 1);
      mem += MAX(nz, 1);
    } on OutOfMemoryError catch (e) {
      /* :: out of memory :: */
      Rp = null;
      Ri = null;
      Len = null;
      Pinv = null;
      return (AMD_OUT_OF_MEMORY);
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

  nzaat = aat(n, Cp, Ci, Len, P, Info);
  AMD_DEBUG1("nzaat: $nzaat\n");
  ASSERT((MAX(nz - n, 0) <= nzaat) && (nzaat <= 2 * nz));

  /* --------------------------------------------------------------------- */
  /* allocate workspace for matrix, elbow room, and 6 size-n vectors */
  /* --------------------------------------------------------------------- */

  slen = nzaat;
  /* space for matrix */
  ok = ((slen + nzaat / 5) >= slen) ? 1 : 0;
  /* check for size_t overflow */
  slen += (nzaat ~/ 5);
  /* add elbow room */
  for (i = 0; ok != 0 && i < 7; i++) {
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
    AMD_DEBUG1("slen $slen\n");
  } on OutOfMemoryError catch (e) {
    /* :: out of memory :: (or problem too large) */
    Rp = null;
    Ri = null;
    Len = null;
    Pinv = null;
    return (AMD_OUT_OF_MEMORY);
  }
  if (info != 0) {
    /* memory usage, in bytes. */
    Info[AMD_MEMORY] = mem * 4; //sizeof (int) ;
  }

  /* --------------------------------------------------------------------- */
  /* order the matrix */
  /* --------------------------------------------------------------------- */

  amd_1(n, Cp, Ci, P, Pinv, Len, slen, Control, Info);

  /* --------------------------------------------------------------------- */
  /* free the workspace */
  /* --------------------------------------------------------------------- */

  Rp = null;
  Ri = null;
  Len = null;
  Pinv = null;
  if (info != 0) Info[AMD_STATUS] = status;
  return (status);
  /* successful ordering */
}
