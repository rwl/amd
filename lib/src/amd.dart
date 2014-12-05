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
library edu.ufl.cise.amd;

/// AMD finds a symmetric ordering P of a matrix A so that the Cholesky
/// factorization of P*A*P' has fewer nonzeros and takes less work than the
/// Cholesky factorization of A.  If A is not symmetric, then it performs its
/// ordering on the matrix A+A'.  Two sets of user-callable routines are
/// provided, one for int integers and the other for UF_long integers.
///
/// The method is based on the approximate minimum degree algorithm, discussed
/// in Amestoy, Davis, and Duff, "An approximate degree ordering algorithm",
/// SIAM Journal of Matrix Analysis and Applications, vol. 17, no. 4, pp.
/// 886-905, 1996.  This package can perform both the AMD ordering (with
/// aggressive absorption), and the AMDBAR ordering (without aggressive
/// absorption) discussed in the above paper.  This package differs from the
/// Fortran codes discussed in the paper:
///
/// 1. it can ignore "dense" rows and columns, leading to faster run times
/// 2. it computes the ordering of A+A' if A is not symmetric
/// 3. it is followed by a depth-first post-ordering of the assembly tree
///    (or supernodal elimination tree)

import 'dart:math' as math;
import 'dart:typed_data' show Int32List;
import 'package:logging/logging.dart' as logging;

part 'aat.dart';
part 'amd_1.dart';
part 'amd_2.dart';
part 'control.dart';
part 'defaults.dart';
part 'dump.dart';
part 'info.dart';
part 'internal.dart';
part 'order.dart';
part 'postorder.dart';
part 'post_tree.dart';
part 'preprocess.dart';
part 'valid.dart';

/// Default is no debug printing.
int debugLevel = -999;

/// Size of Control array.
const int CONTROL = 5;

/// Size of Info array.
const int INFO = 20;

/* Contents of Control */

/// "dense" if degree > Control[0] * sqrt(n)
const int DENSE = 0;

/// do aggressive absorption if Control[1] != 0
const int AGGRESSIVE = 1;

/* Default Control settings */

/// Default "dense" degree 10*sqrt(n).
const DEFAULT_DENSE = 10.0;

/// Do aggressive absorption by default.
const int DEFAULT_AGGRESSIVE = 1;

/* Contents of Info */

/// Return value of [order] and [l_order].
const int STATUS = 0;
/// A is n-by-n.
const int N = 1;
/// Number of nonzeros in A.
const int NZ = 2;
/// Symmetry of pattern (1 is sym., 0 is unsym.)
const int SYMMETRY = 3;
/// # of entries on diagonal.
const int NZDIAG = 4;
/// nz in A+A'.
const int NZ_A_PLUS_AT = 5;
/// Number of "dense" rows/columns in A.
const int NDENSE = 6;
/// Amount of memory used by AMD.
const int MEMORY = 7;
/// Number of garbage collections in AMD.
const int NCMPA = 8;
/// Approx. nz in L, excluding the diagonal.
const int LNZ = 9;
/// Number of fl. point divides for LU and LDL'.
const int NDIV = 10;
/// number of fl. point (*,-) pairs for LDL'.
const int NMULTSUBS_LDL = 11;
/// Number of fl. point (*,-) pairs for LU.
const int NMULTSUBS_LU = 12;
/// Max nz. in any column of L, incl. diagonal.
const int DMAX = 13;

/* Return values of AMD */

/// Success.
const int OK = 0;
/// Allocation failed, or problem too large.
const int OUT_OF_MEMORY = -1;
/// Input arguments are not valid.
const int INVALID = -2;
/// input matrix is OK for amd_order, but
/// columns were not sorted, and/or duplicate entries were present. AMD had
/// to do extra work before ordering the matrix.  This is a warning, not an
/// error.
const int OK_BUT_JUMBLED = 1;

/* AMD version */

/* As an example, to test if the version you are using is 1.2 or later:
 *
 *     if (AMD_VERSION >= AMD_VERSION_CODE (1,2)) ...
 */

const String DATE = "Jan 25, 2011";
int VERSION_CODE(int main, int sub) => ((main) * 1000 + (sub));
const int MAIN_VERSION = 2;
const int SUB_VERSION = 2;
const int SUBSUB_VERSION = 2;
final int VERSION = VERSION_CODE(MAIN_VERSION, SUB_VERSION);
