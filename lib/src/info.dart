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

void PRI(String format) {
  PRINTF(format);
}

/**
 * User-callable. Prints the output statistics for AMD. If the Info array
 * is not present, nothing is printed.
 */
void info(List<num> Info) {
  double n, ndiv, nmultsubs_ldl, nmultsubs_lu, lnz, lnzd;

  PRINTF("\nAMD version $AMD_MAIN_VERSION.$AMD_SUB_VERSION.$AMD_SUBSUB_VERSION, $AMD_DATE, results:\n");

  if (Info == null || Info.length == 0) {
    return;
  }

  n = Info[AMD_N].toDouble();
  ndiv = Info[AMD_NDIV];
  nmultsubs_ldl = Info[AMD_NMULTSUBS_LDL];
  nmultsubs_lu = Info[AMD_NMULTSUBS_LU];
  lnz = Info[AMD_LNZ];
  lnzd = (n >= 0 && lnz >= 0) ? (n + lnz) : (-1);

  /* AMD return status */
  PRINTF("    status: ");
  if (Info[AMD_STATUS] == AMD_OK) {
    PRINTF("OK\n");
  } else if (Info[AMD_STATUS] == AMD_OUT_OF_MEMORY) {
    PRINTF("out of memory\n");
  } else if (Info[AMD_STATUS] == AMD_INVALID) {
    PRINTF("invalid matrix\n");
  } else if (Info[AMD_STATUS] == AMD_OK_BUT_JUMBLED) {
    PRINTF("OK, but jumbled\n");
  } else {
    PRINTF("unknown\n");
  }

  /* statistics about the input matrix */
  PRI("    n, dimension of A:                                  $n\n");
  PRI("    nz, number of nonzeros in A:                        ${Info [AMD_NZ]}\n");
  PRI("    symmetry of A:                                      ${Info [AMD_SYMMETRY]}\n");
  PRI("    number of nonzeros on diagonal:                     ${Info [AMD_NZDIAG]}\n");
  PRI("    nonzeros in pattern of A+A' (excl. diagonal):       ${Info [AMD_NZ_A_PLUS_AT]}\n");
  PRI("    # dense rows/columns of A+A':                       ${Info [AMD_NDENSE]}\n");

  /* statistics about AMD's behavior  */
  PRI("    memory used, in bytes:                              ${Info [AMD_MEMORY]}\n");
  PRI("    # of memory compactions:                            ${Info [AMD_NCMPA]}\n");

  /* statistics about the ordering quality */
  PRINTF("\n" + "    The following approximate statistics are for a subsequent\n" + "    factorization of A(P,P) + A(P,P)'.  They are slight upper\n" + "    bounds if there are no dense rows/columns in A+A', and become\n" + "    looser if dense rows/columns exist.\n\n");

  PRI("    nonzeros in L (excluding diagonal):                 $lnz\n");
  PRI("    nonzeros in L (including diagonal):                 $lnzd\n");
  PRI("    # divide operations for LDL' or LU:                 $ndiv\n");
  PRI("    # multiply-subtract operations for LDL':            $nmultsubs_ldl\n");
  PRI("    # multiply-subtract operations for LU:              $nmultsubs_lu\n");
  PRI("    max nz. in any column of L (incl. diagonal):        ${Info [AMD_DMAX]}\n");

  /* total flop counts for various factorizations */

  if (n >= 0 && ndiv >= 0 && nmultsubs_ldl >= 0 && nmultsubs_lu >= 0) {
    PRINTF("\n" + "    chol flop count for real A, sqrt counted as 1 flop: ${n + ndiv + 2*nmultsubs_ldl}\n" + "    LDL' flop count for real A:                         ${ndiv + 2*nmultsubs_ldl}\n" + "    LDL' flop count for complex A:                      ${9*ndiv + 8*nmultsubs_ldl}\n" + "    LU flop count for real A (with no pivoting):        ${ndiv + 2*nmultsubs_lu}\n" + "    LU flop count for complex A (with no pivoting):     ${9*ndiv + 8*nmultsubs_lu}\n\n");
  }
}
