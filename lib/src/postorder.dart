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

/// Perform a postordering (via depth-first search) of an assembly tree.
///
/// [nn]: nodes are in the range 0..nn-1
/// [Parent]: Parent [j] is the parent of j, or EMPTY if root
/// [Nv]: Nv [j] > 0 number of pivots represented by node j,
/// or zero if j is not a node.
/// [Fsize]: Fsize [j]: size of node j
/// [Order]: output post-order
/// [Child]: size nn
/// [Sibling]: size nn
/// [Stack]: size nn
void postorder(int nn, List<int> parent, List<int> Nv, List<int> Fsize,
    List<int> order, List<int> child, List<int> sibling, List<int> stack) {
  int nchild = 0;

  for (int j = 0; j < nn; j++) {
    child[j] = empty;
    sibling[j] = empty;
  }

  /* --------------------------------------------------------------------- */
  /* place the children in link lists - bigger elements tend to be last */
  /* --------------------------------------------------------------------- */

  for (int j = nn - 1; j >= 0; j--) {
    if (Nv[j] > 0) {
      /* this is an element */
      final p = parent[j];
      if (p != empty) {
        /* place the element in link list of the children its parent */
        /* bigger elements will tend to be at the end of the list */
        sibling[j] = child[p];
        child[p] = j;
      }
    }
  }

  if (!_ndebug) {
    int nels, ff;
    debug1("\n\n================================ AMD_postorder:");
    nels = 0;
    for (int j = 0; j < nn; j++) {
      if (Nv[j] > 0) {
        debug1("$j :  nels $nels npiv ${Nv [j]} size ${Fsize [j]}" + " parent ${parent [j]} maxfr ${Fsize [j]}");
        /* this is an element */
        /* dump the link list of children */
        nchild = 0;
        String d1 = "    Children: ";
        for (ff = child[j]; ff != empty; ff = sibling[ff]) {
          d1 += "$ff ";
          _assert(parent[ff] == j);
          nchild++;
          _assert(nchild < nn);
        }
        debug1(d1);
        final p = parent[j];
        if (p != empty) {
          _assert(Nv[p] > 0);
        }
        nels++;
      }
    }
    debug1("\n\nGo through the children of each node, and put\n" + "the biggest child last in each list:");
  }

  /* --------------------------------------------------------------------- */
  /* place the largest child last in the list of children for each node */
  /* --------------------------------------------------------------------- */

  for (int i = 0; i < nn; i++) {
    if (Nv[i] > 0 && child[i] != empty) {

      if (!_ndebug) {
        debug1("Before partial sort, element $i");
        nchild = 0;
        for (int f = child[i]; f != empty; f = sibling[f]) {
          _assert(f >= 0 && f < nn);
          debug1("      f: $f  size: ${Fsize [f]}");
          nchild++;
          _assert(nchild <= nn);
        }
      }

      /* find the biggest element in the child list */
      int fprev = empty;
      int maxfrsize = empty;
      int bigfprev = empty;
      int bigf = empty;
      for (int f = child[i]; f != empty; f = sibling[f]) {
        _assert(f >= 0 && f < nn);
        final frsize = Fsize[f];
        if (frsize >= maxfrsize) {
          /* this is the biggest seen so far */
          maxfrsize = frsize;
          bigfprev = fprev;
          bigf = f;
        }
        fprev = f;
      }
      _assert(bigf != empty);

      int fnext = sibling[bigf];

      debug1("bigf $bigf maxfrsize $maxfrsize bigfprev $bigfprev fnext $fnext" + " fprev $fprev");

      if (fnext != empty) {
        /* if fnext is EMPTY then bigf is already at the end of list */

        if (bigfprev == empty) {
          /* delete bigf from the element of the list */
          child[i] = fnext;
        } else {
          /* delete bigf from the middle of the list */
          sibling[bigfprev] = fnext;
        }

        /* put bigf at the end of the list */
        sibling[bigf] = empty;
        _assert(child[i] != empty);
        _assert(fprev != bigf);
        _assert(fprev != empty);
        sibling[fprev] = bigf;
      }

      if (!_ndebug) {
        debug1("After partial sort, element $i");
        for (int f = child[i]; f != empty; f = sibling[f]) {
          _assert(f >= 0 && f < nn);
          debug1("        $f  ${Fsize [f]}");
          _assert(Nv[f] > 0);
          nchild--;
        }
        _assert(nchild == 0);
      }

    }
  }

  /* --------------------------------------------------------------------- */
  /* postorder the assembly tree */
  /* --------------------------------------------------------------------- */

  for (int i = 0; i < nn; i++) {
    order[i] = empty;
  }

  int k = 0;
  for (int i = 0; i < nn; i++) {
    if (parent[i] == empty && Nv[i] > 0) {
      debug1("Root of assembly tree $i");
      if (!_ndebug) {
        k = post_tree(i, k, child, sibling, order, stack);
      } else {
        k = post_tree(i, k, child, sibling, order, stack, nn);
      }
    }
  }
}
