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

/**
 * Perform a postordering (via depth-first search) of an assembly tree.
 *
 * [nn]: nodes are in the range 0..nn-1
 * [Parent]: Parent [j] is the parent of j, or EMPTY if root
 * [Nv]: Nv [j] > 0 number of pivots represented by node j,
 * or zero if j is not a node.
 * [Fsize]: Fsize [j]: size of node j
 * [Order]: output post-order
 * [Child]: size nn
 * [Sibling]: size nn
 * [Stack]: size nn
 */
void postorder(int nn, Int32List Parent, Int32List Nv, Int32List Fsize, Int32List Order, Int32List Child, Int32List Sibling, Int32List Stack) {
  int i, j, k, parent, frsize, f, fprev, maxfrsize, bigfprev, bigf, fnext;
  int nchild = 0;

  for (j = 0; j < nn; j++) {
    Child[j] = EMPTY;
    Sibling[j] = EMPTY;
  }

  /* --------------------------------------------------------------------- */
  /* place the children in link lists - bigger elements tend to be last */
  /* --------------------------------------------------------------------- */

  for (j = nn - 1; j >= 0; j--) {
    if (Nv[j] > 0) {
      /* this is an element */
      parent = Parent[j];
      if (parent != EMPTY) {
        /* place the element in link list of the children its parent */
        /* bigger elements will tend to be at the end of the list */
        Sibling[j] = Child[parent];
        Child[parent] = j;
      }
    }
  }

  if (!NDEBUG) {
    int nels, ff;
    AMD_DEBUG1("\n\n================================ AMD_postorder:\n");
    nels = 0;
    for (j = 0; j < nn; j++) {
      if (Nv[j] > 0) {
        AMD_DEBUG1("$j :  nels $nels npiv ${Nv [j]} size ${Fsize [j]}" + " parent ${Parent [j]} maxfr ${Fsize [j]}\n");
        /* this is an element */
        /* dump the link list of children */
        nchild = 0;
        AMD_DEBUG1("    Children: ");
        for (ff = Child[j]; ff != EMPTY; ff = Sibling[ff]) {
          AMD_DEBUG1("$ff ");
          ASSERT(Parent[ff] == j);
          nchild++;
          ASSERT(nchild < nn);
        }
        AMD_DEBUG1("\n");
        parent = Parent[j];
        if (parent != EMPTY) {
          ASSERT(Nv[parent] > 0);
        }
        nels++;
      }
    }
    AMD_DEBUG1("\n\nGo through the children of each node, and put\n" + "the biggest child last in each list:\n");
  }

  /* --------------------------------------------------------------------- */
  /* place the largest child last in the list of children for each node */
  /* --------------------------------------------------------------------- */

  for (i = 0; i < nn; i++) {
    if (Nv[i] > 0 && Child[i] != EMPTY) {

      if (!NDEBUG) {
        AMD_DEBUG1("Before partial sort, element $i\n");
        nchild = 0;
        for (f = Child[i]; f != EMPTY; f = Sibling[f]) {
          ASSERT(f >= 0 && f < nn);
          AMD_DEBUG1("      f: $f  size: ${Fsize [f]}\n");
          nchild++;
          ASSERT(nchild <= nn);
        }
      }

      /* find the biggest element in the child list */
      fprev = EMPTY;
      maxfrsize = EMPTY;
      bigfprev = EMPTY;
      bigf = EMPTY;
      for (f = Child[i]; f != EMPTY; f = Sibling[f]) {
        ASSERT(f >= 0 && f < nn);
        frsize = Fsize[f];
        if (frsize >= maxfrsize) {
          /* this is the biggest seen so far */
          maxfrsize = frsize;
          bigfprev = fprev;
          bigf = f;
        }
        fprev = f;
      }
      ASSERT(bigf != EMPTY);

      fnext = Sibling[bigf];

      AMD_DEBUG1("bigf $bigf maxfrsize $maxfrsize bigfprev $bigfprev fnext $fnext" + " fprev $fprev\n");

      if (fnext != EMPTY) {
        /* if fnext is EMPTY then bigf is already at the end of list */

        if (bigfprev == EMPTY) {
          /* delete bigf from the element of the list */
          Child[i] = fnext;
        } else {
          /* delete bigf from the middle of the list */
          Sibling[bigfprev] = fnext;
        }

        /* put bigf at the end of the list */
        Sibling[bigf] = EMPTY;
        ASSERT(Child[i] != EMPTY);
        ASSERT(fprev != bigf);
        ASSERT(fprev != EMPTY);
        Sibling[fprev] = bigf;
      }

      if (!NDEBUG) {
        AMD_DEBUG1("After partial sort, element $i\n");
        for (f = Child[i]; f != EMPTY; f = Sibling[f]) {
          ASSERT(f >= 0 && f < nn);
          AMD_DEBUG1("        $f  ${Fsize [f]}\n");
          ASSERT(Nv[f] > 0);
          nchild--;
        }
        ASSERT(nchild == 0);
      }

    }
  }

  /* --------------------------------------------------------------------- */
  /* postorder the assembly tree */
  /* --------------------------------------------------------------------- */

  for (i = 0; i < nn; i++) {
    Order[i] = EMPTY;
  }

  k = 0;

  for (i = 0; i < nn; i++) {
    if (Parent[i] == EMPTY && Nv[i] > 0) {
      AMD_DEBUG1("Root of assembly tree $i\n");
      if (!NDEBUG) {
        k = post_tree(i, k, Child, Sibling, Order, Stack);
      } else {
        k = post_tree(i, k, Child, Sibling, Order, Stack, nn);
      }
    }
  }
}
