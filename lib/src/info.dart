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

/// User-callable. Prints the output statistics for AMD. If the Info array
/// is not present, nothing is printed.
void info(List<num> info) {
  _print("\nAMD version $MAIN_VERSION.$SUB_VERSION.$SUBSUB_VERSION, $DATE, results:");

  if (info == null || info.length == 0) {
    return;
  }

  final n = info[N].toDouble();
  final ndiv = info[NDIV];
  final nmultsubs_ldl = info[NMULTSUBS_LDL];
  final nmultsubs_lu = info[NMULTSUBS_LU];
  final lnz = info[LNZ];
  final lnzd = (n >= 0 && lnz >= 0) ? (n + lnz) : (-1);

  /* AMD return status */
  _print("    status: ");
  if (info[STATUS] == OK) {
    _print("OK");
  } else if (info[STATUS] == OUT_OF_MEMORY) {
    _print("out of memory");
  } else if (info[STATUS] == INVALID) {
    _print("invalid matrix");
  } else if (info[STATUS] == OK_BUT_JUMBLED) {
    _print("OK, but jumbled");
  } else {
    _print("unknown");
  }

  /* statistics about the input matrix */
  _print("    n, dimension of A:                                  $n");
  _print("    nz, number of nonzeros in A:                        ${info [NZ]}");
  _print("    symmetry of A:                                      ${info [SYMMETRY]}");
  _print("    number of nonzeros on diagonal:                     ${info [NZDIAG]}");
  _print("    nonzeros in pattern of A+A' (excl. diagonal):       ${info [NZ_A_PLUS_AT]}");
  _print("    # dense rows/columns of A+A':                       ${info [NDENSE]}");

  /* statistics about AMD's behavior  */
  _print("    memory used, in bytes:                              ${info [MEMORY]}");
  _print("    # of memory compactions:                            ${info [NCMPA]}");

  /* statistics about the ordering quality */
  _print("\n" + "    The following approximate statistics are for a subsequent\n" + "    factorization of A(P,P) + A(P,P)'.  They are slight upper\n" + "    bounds if there are no dense rows/columns in A+A', and become\n" + "    looser if dense rows/columns exist.\n");

  _print("    nonzeros in L (excluding diagonal):                 $lnz");
  _print("    nonzeros in L (including diagonal):                 $lnzd");
  _print("    # divide operations for LDL' or LU:                 $ndiv");
  _print("    # multiply-subtract operations for LDL':            $nmultsubs_ldl");
  _print("    # multiply-subtract operations for LU:              $nmultsubs_lu");
  _print("    max nz. in any column of L (incl. diagonal):        ${info [DMAX]}");

  /* total flop counts for various factorizations */

  if (n >= 0 && ndiv >= 0 && nmultsubs_ldl >= 0 && nmultsubs_lu >= 0) {
    _print("\n" + "    chol flop count for real A, sqrt counted as 1 flop: ${n + ndiv + 2*nmultsubs_ldl}\n" + "    LDL' flop count for real A:                         ${ndiv + 2*nmultsubs_ldl}\n" + "    LDL' flop count for complex A:                      ${9*ndiv + 8*nmultsubs_ldl}\n" + "    LU flop count for real A (with no pivoting):        ${ndiv + 2*nmultsubs_lu}\n" + "    LU flop count for complex A (with no pivoting):     ${9*ndiv + 8*nmultsubs_lu}\n");
  }
}
