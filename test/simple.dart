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

//package edu.ufl.cise.amd.tdouble.test;

//import junit.framework.TestCase;

//import static edu.ufl.cise.amd.tdouble.Damd_order.amd_order;

main() {

	int n = 5 ;
	List<int> Ap = [ 0,   2,       6,       10,  12, 14] ;
	List<int> Ai = [ 0,1, 0,1,2,4, 1,2,3,4, 2,3, 1,4   ] ;
	List<int> P = new List<int>(5) ;
	List<int> sol = [0, 3, 2, 4, 1] ;

	test('', () {
	    int k ;
	    order (n, Ap, Ai, P, null, null) ;
	    for (k = 0 ; k < n ; k++)
		    expect(sol [k], equals(P [k])) ;
	});

}