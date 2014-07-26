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

//import static edu.ufl.cise.amd.tdouble.Damd_dump.amd_debug_init;
//import static edu.ufl.cise.amd.tdouble.Damd_valid.amd_valid;

/**
 * AMD_aat:  compute the symmetry of the pattern of A, and count the number of
 * nonzeros each column of A+A' (excluding the diagonal).  Assumes the input
 * matrix has no errors, with sorted columns and no duplicates
 * (AMD_valid (n, n, Ap, Ai) must be AMD_OK, but this condition is not
 * checked).
 */
//public class Damd_aat extends Damd_internal {

/**
 *
 * @param n
 * @param Ap
 * @param Ai
 * @param Len Len [j]: length of column j of A+A', excl diagonal
 * @param Tp workspace of size n
 * @param Info
 * @return
 */
int aat(int n,
		final List<int> Ap,
		final List<int> Ai,
		List<int> Len,
		List<int> Tp,
		List<double> Info)
{
	int p1, p2, p, i, j, pj, pj2, k, nzdiag, nzboth, nz ;
	double sym ;
	int nzaat ;

	if (!NDEBUG)
	{
//			amd_debug_init ("AMD AAT") ;
		for (k = 0 ; k < n ; k++) Tp [k] = EMPTY ;
		ASSERT (valid (n, n, Ap, Ai) == AMD_OK) ;
	}

	if (Info != null)
	{
	/* clear the Info array, if it exists */
	for (i = 0 ; i < AMD_INFO ; i++)
	{
		Info [i] = EMPTY as double ;
	}
	Info [AMD_STATUS] = AMD_OK as double ;
	}

	for (k = 0 ; k < n ; k++)
	{
	Len [k] = 0 ;
	}

	nzdiag = 0 ;
	nzboth = 0 ;
	nz = Ap [n] ;

	for (k = 0 ; k < n ; k++)
	{
	p1 = Ap [k] ;
	p2 = Ap [k+1] ;
	AMD_DEBUG2 ("\nAAT Column: $k p1: $p1 p2: $p2\n") ;

	/* construct A+A' */
	for (p = p1 ; p < p2 ; )
	{
		/* scan the upper triangular part of A */
		j = Ai [p] ;
		if (j < k)
		{
		/* entry A (j,k) is in the strictly upper triangular part,
		 * add both A (j,k) and A (k,j) to the matrix A+A' */
		Len [j]++ ;
		Len [k]++ ;
		AMD_DEBUG3 ("    upper ($j,$k) ($k,$j)\n");
		p++ ;
		}
		else if (j == k)
		{
		/* skip the diagonal */
		p++ ;
		nzdiag++ ;
		break ;
		}
		else /* j > k */
		{
		/* first entry below the diagonal */
		break ;
		}
		/* scan lower triangular part of A, in column j until reaching
		 * row k.  Start where last scan left off. */
		ASSERT (Tp [j] != EMPTY) ;
		ASSERT (Ap [j] <= Tp [j] && Tp [j] <= Ap [j+1]) ;
		pj2 = Ap [j+1] ;
		for (pj = Tp [j] ; pj < pj2 ; )
		{
		i = Ai [pj] ;
		if (i < k)
		{
			/* A (i,j) is only in the lower part, not in upper.
			 * add both A (i,j) and A (j,i) to the matrix A+A' */
			Len [i]++ ;
			Len [j]++ ;
			AMD_DEBUG3 ("    lower ($i,$j) ($j,$i)\n") ;
			pj++ ;
		}
		else if (i == k)
		{
			/* entry A (k,j) in lower part and A (j,k) in upper */
			pj++ ;
			nzboth++ ;
			break ;
		}
		else /* i > k */
		{
			/* consider this entry later, when k advances to i */
			break ;
		}
		}
		Tp [j] = pj ;
	}
	/* Tp [k] points to the entry just below the diagonal in column k */
	Tp [k] = p ;
	}

	/* clean up, for remaining mismatched entries */
	for (j = 0 ; j < n ; j++)
	{
	for (pj = Tp [j] ; pj < Ap [j+1] ; pj++)
	{
		i = Ai [pj] ;
		/* A (i,j) is only in the lower part, not in upper.
		 * add both A (i,j) and A (j,i) to the matrix A+A' */
		Len [i]++ ;
		Len [j]++ ;
		AMD_DEBUG3 ("    lower cleanup ($i,$j) ($j,$i)\n") ;
	}
	}

	/* --------------------------------------------------------------------- */
	/* compute the symmetry of the nonzero pattern of A */
	/* --------------------------------------------------------------------- */

	/* Given a matrix A, the symmetry of A is:
	 *	B = tril (spones (A), -1) + triu (spones (A), 1) ;
	 *  sym = nnz (B & B') / nnz (B) ;
	 *  or 1 if nnz (B) is zero.
	 */

	if (nz == nzdiag)
	{
	sym = 1.0 ;
	}
	else
	{
	sym = (2 * (nzboth as double)) / ((nz - nzdiag) as double) ;
	}

	nzaat = 0 ;
	for (k = 0 ; k < n ; k++)
	{
	nzaat += Len [k] ;
	}

	AMD_DEBUG1 ("AMD nz in A+A', excluding diagonal (nzaat) = $nzaat\n") ;
	AMD_DEBUG1 ("   nzboth: $nzboth nz: $nz nzdiag: $nzdiag symmetry: $sym\n") ;

	if (Info != null)
	{
	Info [AMD_STATUS] = AMD_OK as double ;
	Info [AMD_N] = n as double ;
	Info [AMD_NZ] = nz as double ;
	Info [AMD_SYMMETRY] = sym ;	    /* symmetry of pattern of A */
	Info [AMD_NZDIAG] = nzdiag as double ;	    /* nonzeros on diagonal of A */
	Info [AMD_NZ_A_PLUS_AT] = nzaat as double ;   /* nonzeros in A+A' */
	}

	return (nzaat) ;
}

//}
