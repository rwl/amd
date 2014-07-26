/**
 * AMD, Copyright (C) 2009-2011 by Timothy A. Davis, Patrick R. Amestoy,
 * and Iain S. Duff.  All Rights Reserved.
 * Copyright (C) 2011 Richard Lincoln
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
import 'package:unittest/unittest.dart';
import 'package:amd/amd.dart';

/*package edu.ufl.cise.amd.tdouble.test;

import edu.ufl.cise.amd.tdouble.Damd_internal;
import junit.framework.TestCase;

import static edu.ufl.cise.amd.tdouble.Damd.AMD_CONTROL;
import static edu.ufl.cise.amd.tdouble.Damd.AMD_INFO;
import static edu.ufl.cise.amd.tdouble.Damd.AMD_VERSION;
import static edu.ufl.cise.amd.tdouble.Damd.AMD_MAIN_VERSION;
import static edu.ufl.cise.amd.tdouble.Damd.AMD_SUB_VERSION;
import static edu.ufl.cise.amd.tdouble.Damd.AMD_DATE;
import static edu.ufl.cise.amd.tdouble.Damd.AMD_OK;
import static edu.ufl.cise.amd.tdouble.Damd.AMD_VERSION_CODE;

import static edu.ufl.cise.amd.tdouble.Damd_defaults.amd_defaults;
import static edu.ufl.cise.amd.tdouble.Damd_control.amd_control;
import static edu.ufl.cise.amd.tdouble.Damd_order.amd_order;
import static edu.ufl.cise.amd.tdouble.Damd_info.amd_info;*/

/**
 * A simple C main program that illustrates the use of the interface
 * to AMD.
 */
//public class Damd_demo extends TestCase {


/* The symmetric can_24 Harwell/Boeing matrix, including upper and lower
 * triangular parts, and the diagonal entries.  Note that this matrix is
 * 0-based, with row and column indices in the range 0 to n-1. */
int n = 24, nz;
List<int> Ap = [ 0, 9, 15, 21, 27, 33, 39, 48, 57, 61, 70, 76, 82, 88, 94, 100,
		106, 110, 119, 128, 137, 143, 152, 156, 160 ];
List<int> Ai = [
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
	/* column 23: */    6, 11, 12, 23 ] ;


main() {
  test('', () {
  	List<int> P = new List<int>(24) ;
  	List<int> Pinv = new List<int>(24) ;
  	int i, j, k, jnew, p, inew, result ;
  	List<num> Control = new List<num>(AMD_CONTROL) ;
  	List<num> Info = new List<num>(AMD_INFO) ;
  	List<List<String>> A = new List<List<String>>(24);//[24] ;
    for (i = 0 ; i < n ; i++) A[i] = new List<String>(24);

  	NPRINT = false;
  	//Damd_internal.NDEBUG = false;
  	//Damd.AMD_debug = 1;

  	/* here is an example of how to use AMD_VERSION.  This code will work in
  	 * any version of AMD. */
  	if (AMD_VERSION != 0 && AMD_VERSION >= AMD_VERSION_CODE(1,2))
  	{
  		print ("AMD version $AMD_MAIN_VERSION.$AMD_SUB_VERSION, date: $AMD_DATE\n") ;
  	} else {
  		print ("AMD version: 1.1 or earlier\n") ;
  	}

  	print ("AMD demo, with the 24-by-24 Harwell/Boeing matrix, can_24:\n") ;

  	/* get the default parameters, and print them */
  	defaults (Control) ;
  	control  (Control) ;

  	/* print the input matrix */
  	nz = Ap [n] ;
  	print ("\nInput matrix:  $n-by-$n, with $nz entries.\n" +
  			"   Note that for a symmetric matrix such as this one, only the\n" +
  			"   strictly lower or upper triangular parts would need to be\n" +
  			"   passed to AMD, since AMD computes the ordering of A+A'.  The\n" +
  			"   diagonal entries are also not needed, since AMD ignores them.\n") ;
  	for (j = 0 ; j < n ; j++)
  	{
  		print ("\nColumn: $j, number of entries: ${Ap [j+1] - Ap [j]}, with row indices in" +
  				" Ai [${Ap [j]} ... ${Ap [j+1]-1}]:\n    row indices:") ;
  	for (p = Ap [j] ; p < Ap [j+1] ; p++)
  	{
  		i = Ai [p] ;
  		print (" $i") ;
  	}
  	print ("\n") ;
  	}

  	/* print a character plot of the input matrix.  This is only reasonable
  	 * because the matrix is small. */
  	print ("\nPlot of input matrix pattern:\n") ;
  	for (j = 0 ; j < n ; j++)
  	{
  		for (i = 0 ; i < n ; i++) A [i][j] = '.' ;
  		for (p = Ap [j] ; p < Ap [j+1] ; p++)
  		{
  			i = Ai [p] ;
  			A [i][j] = 'X' ;
  		}
  	}
  	print ("    ") ;
  	for (j = 0 ; j < n ; j++) print (" ${j % 10}") ;
  	print ("\n") ;
  	for (i = 0 ; i < n ; i++)
  	{
  		print ("$i: ") ;
  		for (j = 0 ; j < n ; j++)
  		{
  		    print (" ${A [i][j]}") ;
  		}
  		print ("\n") ;
  	}

  	/* order the matrix */
  	result = order (n, Ap, Ai, P, Control, Info) ;
  	print ("return value from amd_order: $result (should be $AMD_OK)\n") ;

  	/* print the statistics */
  	info (Info) ;

  	if (result != AMD_OK)
  	{
  		print ("AMD failed\n") ;
  		fail('') ;
  	}

  	/* print the permutation vector, P, and compute the inverse permutation */
  	print ("Permutation vector:\n") ;
  	for (k = 0 ; k < n ; k++)
  	{
  		/* row/column j is the kth row/column in the permuted matrix */
  		j = P [k] ;
  		Pinv [j] = k ;
  		print (" $j") ;
  	}
  	print ("\n\n") ;

  	print ("Inverse permutation vector:\n") ;
  	for (j = 0 ; j < n ; j++)
  	{
  		k = Pinv [j] ;
  		print (" $k") ;
  	}
  	print ("\n\n") ;

  	/* print a character plot of the permuted matrix. */
  	print ("\nPlot of permuted matrix pattern:\n") ;
  	for (jnew = 0 ; jnew < n ; jnew++)
  	{
  		j = P [jnew] ;
  		for (inew = 0 ; inew < n ; inew++) A [inew][jnew] = '.' ;
  		for (p = Ap [j] ; p < Ap [j+1] ; p++)
  		{
  		    inew = Pinv [Ai [p]] ;
  		    A [inew][jnew] = 'X' ;
  		}
  	}
  	print ("    ") ;
  	for (j = 0 ; j < n ; j++) print (" ${j % 10}") ;
  	print ("\n") ;
  	for (i = 0 ; i < n ; i++)
  	{
  		print ("$i: ") ;
  		for (j = 0 ; j < n ; j++)
  		{
  			print (" ${A [i][j]}") ;
  		}
  		print ("\n") ;
  	}

  	expect(AMD_OK, equals(result)) ;
  });
}

//}
