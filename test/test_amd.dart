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
library amd.test.order;

import 'dart:io';
import 'dart:typed_data';

import 'package:unittest/unittest.dart';
import 'package:amd/amd.dart' as amd;

/// The symmetric can_24 Harwell/Boeing matrix, including upper and lower
/// triangular parts, and the diagonal entries.  Note that this matrix is
/// 0-based, with row and column indices in the range 0 to n-1.
const int n = 24;
final Ap = [ 0, 9, 15, 21, 27, 33, 39, 48, 57, 61, 70, 76, 82, 88, 94, 100,
    106, 110, 119, 128, 137, 143, 152, 156, 160 ];
final Ai = [
  /* column  0: */    0, 5, 6, 12, 13, 17, 18, 19, 21,
  /* column  1: */    1, 8, 9, 13, 14, 17,
  /* column  2: */    2, 6, 11, 20, 21, 22,
  /* column  3: */    3, 7, 10, 15, 18, 19,
  /* column  4: */    4, 7, 9, 14, 15, 16,
  /* column  5: */    0, 5, 6, 12, 13, 17,
  /* column  6: */    0, 2, 5, 6, 11, 12, 19, 21, 23,
  /* column  7: */    3, 4, 7, 9, 14, 15, 16, 17, 18,
  /* column  8: */    1, 8, 9, 14,
  /* column  9: */    1, 4, 7, 8, 9, 13, 14, 17, 18,
  /* column 10: */    3, 10, 18, 19, 20, 21,
  /* column 11: */    2, 6, 11, 12, 21, 23,
  /* column 12: */    0, 5, 6, 11, 12, 23,
  /* column 13: */    0, 1, 5, 9, 13, 17,
  /* column 14: */    1, 4, 7, 8, 9, 14,
  /* column 15: */    3, 4, 7, 15, 16, 18,
  /* column 16: */    4, 7, 15, 16,
  /* column 17: */    0, 1, 5, 7, 9, 13, 17, 18, 19,
  /* column 18: */    0, 3, 7, 9, 10, 15, 17, 18, 19,
  /* column 19: */    0, 3, 6, 10, 17, 18, 19, 20, 21,
  /* column 20: */    2, 10, 19, 20, 21, 22,
  /* column 21: */    0, 2, 6, 10, 11, 19, 20, 21, 22,
  /* column 22: */    2, 20, 21, 22,
  /* column 23: */    6, 11, 12, 23 ];

/// A simple test that illustrates the use of the interface to AMD.
main() {
  test('', () {
    final P = new Int32List(24);
    final Pinv = new Int32List(24);
    final Control = new List<num>(amd.CONTROL);
    final Info = new List<num>(amd.INFO);
    final A = new List<List<String>>(24);//[24] ;
    for (int i = 0; i < n; i++) A[i] = new List<String>(24);

    amd.log = true;
    //NDEBUG = false;
    //amd.debugLevel = 1;

    /* Here is an example of how to use AMD_VERSION. This code will work in
  	 * any version of AMD. */
    if (amd.VERSION != 0 && amd.VERSION >= amd.VERSION_CODE(1, 2)) {
      stdout.write("AMD version ${amd.MAIN_VERSION}.${amd.SUB_VERSION}, date: ${amd.DATE}\n");
    } else {
      stdout.write("AMD version: 1.1 or earlier\n");
    }

    stdout.write("AMD demo, with the 24-by-24 Harwell/Boeing matrix, can_24:\n");

    /* get the default parameters, and print them */
    amd.defaults(Control);
    amd.control(Control);

    /* print the input matrix */
    final nz = Ap[n];
    stdout.write("\nInput matrix:  $n-by-$n, with $nz entries.\n" + "   Note that for a symmetric matrix such as this one, only the\n" + "   strictly lower or upper triangular parts would need to be\n" + "   passed to AMD, since AMD computes the ordering of A+A'.  The\n" + "   diagonal entries are also not needed, since AMD ignores them.\n");
    for (int j = 0; j < n; j++) {
      stdout.write("\nColumn: $j, number of entries: ${Ap [j+1] - Ap [j]}, with row indices in" +
          " Ai [${Ap [j]} ... ${Ap [j+1]-1}]:\n    row indices:");
      for (int p = Ap[j]; p < Ap[j + 1]; p++) {
        int i = Ai[p];
        stdout.write(" $i");
      }
      stdout.write("\n");
    }

    /* print a character plot of the input matrix.  This is only reasonable
  	 * because the matrix is small. */
    stdout.write("\nPlot of input matrix pattern:\n");
    for (int j = 0; j < n; j++) {
      for (int i = 0; i < n; i++) A[i][j] = '.';
      for (int p = Ap[j]; p < Ap[j + 1]; p++) {
        int i = Ai[p];
        A[i][j] = 'X';
      }
    }
    stdout.write("    ");
    for (int j = 0; j < n; j++) stdout.write(" ${j % 10}");
    stdout.write("\n");
    for (int i = 0; i < n; i++) {
      stdout.write("$i: ");
      for (int j = 0; j < n; j++) {
        stdout.write(" ${A [i][j]}");
      }
      stdout.write("\n");
    }

    /* order the matrix */
    int result = amd.order(n, Ap, Ai, P, Control, Info);
    stdout.write("return value from amd_order: $result (should be ${amd.OK})\n");

    /* print the statistics */
    amd.info(Info);

    if (result != amd.OK) {
      stdout.write("AMD failed\n");
      fail('');
    }

    /* print the permutation vector, P, and compute the inverse permutation */
    stdout.write("Permutation vector:\n");
    for (int k = 0; k < n; k++) {
      /* row/column j is the kth row/column in the permuted matrix */
      final j = P[k];
      Pinv[j] = k;
      stdout.write(" $j");
    }
    stdout.write("\n\n");

    stdout.write("Inverse permutation vector:\n");
    for (int j = 0; j < n; j++) {
      final k = Pinv[j];
      stdout.write(" $k");
    }
    stdout.write("\n\n");

    /* print a character plot of the permuted matrix. */
    stdout.write("\nPlot of permuted matrix pattern:\n");
    for (int jnew = 0; jnew < n; jnew++) {
      final j = P[jnew];
      for (int inew = 0; inew < n; inew++) A[inew][jnew] = '.';
      for (int p = Ap[j]; p < Ap[j + 1]; p++) {
        int inew = Pinv[Ai[p]];
        A[inew][jnew] = 'X';
      }
    }
    stdout.write("    ");
    for (int j = 0; j < n; j++) stdout.write(" ${j % 10}");
    stdout.write("\n");
    for (int i = 0; i < n; i++) {
      stdout.write("$i: ");
      for (int j = 0; j < n; j++) {
        stdout.write(" ${A [i][j]}");
      }
      stdout.write("\n");
    }

    expect(amd.OK, equals(result));
  });
}
