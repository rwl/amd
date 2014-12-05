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

/// Check if a column-form matrix is valid or not.  The matrix A is
/// n_row-by-n_col.  The row indices of entries in column j are in
/// Ai [Ap [j] ... Ap [j+1]-1].  Required conditions are:
///
///     n_row >= 0
///     n_col >= 0
///     nz = Ap [n_col] >= 0     number of entries in the matrix
///     Ap [0] == 0
///     Ap [j] <= Ap [j+1] for all j in the range 0 to n_col.
///          Ai [0 ... nz-1] must be in the range 0 to n_row-1.
///
/// If any of the above conditions hold, AMD_INVALID is returned.  If the
/// following condition holds, AMD_OK_BUT_JUMBLED is returned (a warning,
/// not an error):
///
///     row indices in Ai [Ap [j] ... Ap [j+1]-1] are not sorted in ascending
///         order, and/or duplicate entries exist.
///
/// Otherwise, AMD_OK is returned.
///
/// A is [n_row]-by-[n_col]
/// [Ap]: column pointers of A, of size n_col+1
/// [Ai]: row indices of A, of size nz = Ap [n_col]
int valid(int n_row, int n_col, final List<int> Ap, final List<int> Ai) {
  int result = OK;

  if (n_row < 0 || n_col < 0 || Ap == null || Ai == null) {
    return (INVALID);
  }
  final nz = Ap[n_col];
  if (Ap[0] != 0 || nz < 0) {
    /* column pointers must start at Ap [0] = 0, and Ap [n] must be >= 0 */
    debug0("column 0 pointer bad or nz < 0");
    return (INVALID);
  }
  for (int j = 0; j < n_col; j++) {
    final p1 = Ap[j];
    final p2 = Ap[j + 1];
    debug2("\nColumn: $j p1: $p1 p2: $p2");
    if (p1 > p2) {
      /* column pointers must be ascending */
      debug0("column $j pointer bad");
      return (INVALID);
    }
    int ilast = empty;
    for (int p = p1; p < p2; p++) {
      final i = Ai[p];
      debug3("row: $i");
      if (i < 0 || i >= n_row) {
        /* row index out of range */
        debug0("index out of range, col $j row $i");
        return (INVALID);
      }
      if (i <= ilast) {
        /* row index unsorted, or duplicate entry present */
        debug1("index unsorted/dupl col $j row $i");
        result = OK_BUT_JUMBLED;
      }
      ilast = i;
    }
  }
  return result;
}
