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

part of edu.ufl.cise.amd;

//public class Damd_internal extends Damd {

/**
 * Enable debugging.
 */
bool NDEBUG = true ;

/**
 * Enable printing and diagnostics.
 */
bool NPRINT = true ;

//final int Int_MAX = int.MAX_VALUE;

/* FLIP is a "negation about -1", and is used to mark an integer i that is
 * normally non-negative.  FLIP (EMPTY) is EMPTY.  FLIP of a number > EMPTY
 * is negative, and FLIP of a number < EMTPY is positive.  FLIP (FLIP (i)) = i
 * for all integers i.  UNFLIP (i) is >= EMPTY. */
final int EMPTY = (-1) ;

int FLIP (int i)
{
	return (-(i)-2) ;
}

int UNFLIP (int i)
{
	return ((i < EMPTY) ? FLIP (i) : (i)) ;
}

double sqrt (double a)
{
	return math.sqrt (a) ;
}

/*int MAX(int a, int b)
{
	return (((a) > (b)) ? (a) : (b)) ;

}

int MIN(int a, int b)
{
	return (((a) < (b)) ? (a) : (b)) ;
}*/

num MAX(num a, num b)
{
	return (((a) > (b)) ? (a) : (b)) ;

}

num MIN(num a, num b)
{
	return (((a) < (b)) ? (a) : (b)) ;
}

/**
 * logical expression of p implies q:
 */
bool IMPLIES(bool p, bool q)
{
	return (!(p) || (q)) ;
}

final int TRUE = (1) ;
final int FALSE = (0) ;

//String ID = "%d" ;

void PRINTF (String format)//, [List<Object> args])
{
	if (!NPRINT)
	{
		print (format);//, args) ;
	}
}

void ASSERT (bool a)
{
	if (!NDEBUG)
	{
		assert(a) ;
	}
}

void ASSERT_INT (int a)
{
	ASSERT (a != 0) ;
}

void AMD_DEBUG0 (String format)//, [List<Object> args])
{
	if (!NDEBUG)
	{
		PRINTF (format);//, args) ;
	}
}

void AMD_DEBUG1(String format)//, [List<Object> args])
{
	if (!NDEBUG)
	{
		if (AMD_debug >= 1) PRINTF (format);//, args) ;
	}
}

void AMD_DEBUG2(String format)//, [List<Object> args])
{
	if (!NDEBUG)
	{
		if (AMD_debug >= 2) PRINTF (format);//, args) ;
	}
}

void AMD_DEBUG3(String format)//, [List<Object> args])
{
	if (!NDEBUG)
	{
		if (AMD_debug >= 3) PRINTF (format);//, args) ;
	}
}

void AMD_DEBUG4(String format)//, [List<Object> args])
{
	if (!NDEBUG)
	{
		if (AMD_debug >= 4) PRINTF (format);//, args) ;
	}
}

//}
