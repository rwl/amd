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
library amd.test.unsorted;

import 'dart:io';
import 'dart:typed_data';

import 'package:unittest/unittest.dart';
import 'package:amd/src/amd.dart' as amd;

/// The symmetric can_24 Harwell/Boeing matrix (jumbled, and not symmetric).
/// Since AMD operates on A+A', only A(i,j) or A(j,i) need to be specified,
/// or both.  The diagonal entries are optional (some are missing).
/// There are many duplicate entries, which must be removed. */
const n = 24;
final Ap = [ 0, 9, 14, 20, 28, 33, 37, 44, 53, 58, 63, 63, 66, 69, 72, 75,
    78, 82, 86, 91, 97, 101, 112, 112, 116 ];
final Ai = [
  /* column  0: */    0, 17, 18, 21, 5, 12, 5, 0, 13,
  /* column  1: */    14, 1, 8, 13, 17,
  /* column  2: */    2, 20, 11, 6, 11, 22,
  /* column  3: */    3, 3, 10, 7, 18, 18, 15, 19,
  /* column  4: */    7, 9, 15, 14, 16,
  /* column  5: */    5, 13, 6, 17,
  /* column  6: */    5, 0, 11, 6, 12, 6, 23,
  /* column  7: */    3, 4, 9, 7, 14, 16, 15, 17, 18,
  /* column  8: */    1, 9, 14, 14, 14,
  /* column  9: */    7, 13, 8, 1, 17,
  /* column 10: */
  /* column 11: */    2, 12, 23,
  /* column 12: */    5, 11, 12,
  /* column 13: */    0, 13, 17,
  /* column 14: */    1, 9, 14,
  /* column 15: */    3, 15, 16,
  /* column 16: */    16, 4, 4, 15,
  /* column 17: */    13, 17, 19, 17,
  /* column 18: */    15, 17, 19, 9, 10,
  /* column 19: */    17, 19, 20, 0, 6, 10,
  /* column 20: */    22, 10, 20, 21,
  /* column 21: */    6, 2, 10, 19, 20, 11, 21, 22, 22, 22, 22,
  /* column 22: */
  /* column 23: */    12, 11, 12, 23 ];

/// A simple test that illustrates the use of the Dart interface
/// to AMD.
///
/// Identical to [test_amd.dart], except that it operates on an input matrix
/// that has unsorted columns and duplicate entries.
main() {
  test('demo2', () {
    final P = new Int32List(24);
    final Pinv = new Int32List(24);
    //int i, j, k, jnew, p, inew, result;
    final Control = new List<num>(amd.CONTROL);
    final Info = new List<num>(amd.INFO);
    final A = new List<List<String>>.generate(24, (i) => new List(24));

    amd.log = true;

    stdout.write("AMD demo, with a jumbled version of the 24-by-24\n");
    stdout.write("Harwell/Boeing matrix, can_24:\n");

    /* get the default parameters, and print them */
    amd.defaults(Control);
    amd.control(Control);

    /* print the input matrix */
    int nz = Ap[n];
    stdout.write("\nJumbled input matrix:  $n-by-$n, with $nz entries.\n" +
        "   Note that for a symmetric matrix such as this one, only the\n" +
        "   strictly lower or upper triangular parts would need to be\n" +
        "   passed to AMD, since AMD computes the ordering of A+A'.  The\n" +
        "   diagonal entries are also not needed, since AMD ignores them.\n" +
        "   This version of the matrix has jumbled columns and duplicate\n" +
        "   row indices.\n");
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
    stdout.write("\nPlot of (jumbled) input matrix pattern:\n");
    for (int j = 0; j < n; j++) {
      for (int i = 0; i < n; i++) A[i][j] = '.';
      for (int p = Ap[j]; p < Ap[j + 1]; p++) {
        int i = Ai[p];
        A[i][j] = 'X';
      }
    }
    stdout.write("   ");
    for (int j = 0; j < n; j++) stdout.write(" ${j % 10}");
    stdout.write("\n");
    for (int i = 0; i < n; i++) {
      stdout.write("$i: ");
      for (int j = 0; j < n; j++) {
        stdout.write(" ${A [i][j]}");
      }
      stdout.write("\n");
    }

    /* print a character plot of the matrix A+A'. */
    stdout.write("\nPlot of symmetric matrix to be ordered by amd_order:\n");
    for (int j = 0; j < n; j++) {
      for (int i = 0; i < n; i++) A[i][j] = '.';
    }
    for (int j = 0; j < n; j++) {
      A[j][j] = 'X';
      for (int p = Ap[j]; p < Ap[j + 1]; p++) {
        int i = Ai[p];
        A[i][j] = 'X';
        A[j][i] = 'X';
      }
    }
    stdout.write("   ");
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
    final result = amd.order(n, Ap, Ai, P, Control, Info);
    stdout.write("return value from amd_order: $result (should be ${amd.OK_BUT_JUMBLED})\n");

    /* print the statistics */
    amd.info(Info);

    if (result != amd.OK_BUT_JUMBLED) {
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
    stdout.write("\nPlot of (symmetrized) permuted matrix pattern:\n");
    for (int j = 0; j < n; j++) {
      for (int i = 0; i < n; i++) A[i][j] = '.';
    }
    for (int jnew = 0; jnew < n; jnew++) {
      final j = P[jnew];
      A[jnew][jnew] = 'X';
      for (int p = Ap[j]; p < Ap[j + 1]; p++) {
        final inew = Pinv[Ai[p]];
        A[inew][jnew] = 'X';
        A[jnew][inew] = 'X';
      }
    }
    stdout.write("   ");
    for (int j = 0; j < n; j++) stdout.write(" ${j % 10}");
    stdout.write("\n");
    for (int i = 0; i < n; i++) {
      stdout.write("$i: ");
      for (int j = 0; j < n; j++) {
        stdout.write(" ${A [i][j]}");
      }
      stdout.write("\n");
    }

    expect(amd.OK_BUT_JUMBLED, equals(result));
  });
}
