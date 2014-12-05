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

/// Post-ordering of a supernodal elimination tree.
///
/// [root]: root of the tree
/// [k]: start numbering at k
/// [Child]: input argument of size nn, undefined on
/// output.  Child [i] is the head of a link
/// list of all nodes that are children of node
/// i in the tree.
/// [Sibling]: input argument of size nn, not modified.
/// If f is a node in the link list of the
/// children of node i, then Sibling [f] is the
/// next child of node i.
/// [Order]: output order, of size nn.  Order [i] = k
/// if node i is the kth node of the reordered tree.
/// [Stack]: workspace of size nn
/// [nn]: nodes are in the range 0..nn-1.
int post_tree(int root, int k, List<int> child, final List<int> sibling, List<int> order, List<int> stack, [int nn = 0]) {
  /*if (false) {
    // recursive version (Stack [ ] is not used):
    // this is simple, but can can cause stack overflow if nn is large
    i = root;
    for (f = Child[i]; f != EMPTY; f = Sibling[f]) {
      k = post_tree(f, k, Child, Sibling, Order, Stack, nn);
    }
    Order[i] = k++;
    return (k);
  }*/

  /* --------------------------------------------------------------------- */
  /* non-recursive version, using an explicit stack */
  /* --------------------------------------------------------------------- */

  /* push root on the stack */
  int head = 0;
  stack[0] = root;

  while (head >= 0) {
    /* get head of stack */
    _assert(head < nn);
    int i = stack[head];
    debug1("head of stack $i ");
    _assert(i >= 0 && i < nn);

    if (child[i] != empty) {
      /* the children of i are not yet ordered */
      /* push each child onto the stack in reverse order */
      /* so that small ones at the head of the list get popped first */
      /* and the biggest one at the end of the list gets popped last */
      for (int f = child[i]; f != empty; f = sibling[f]) {
        head++;
        _assert(head < nn);
        _assert(f >= 0 && f < nn);
      }
      int h = head;
      _assert(head < nn);
      for (int f = child[i]; f != empty; f = sibling[f]) {
        _assert(h > 0);
        stack[h--] = f;
        debug1("push $f on stack");
        _assert(f >= 0 && f < nn);
      }
      _assert(stack[h] == i);

      /* delete child list so that i gets ordered next time we see it */
      child[i] = empty;
    } else {
      /* the children of i (if there were any) are already ordered */
      /* remove i from the stack and order it.  Front i is kth front */
      head--;
      debug1("pop $i order $k");
      order[i] = k++;
      _assert(k <= nn);
    }

    if (!_ndebug) {
      String d1 = "\nStack:";
      for (int h = head; h >= 0; h--) {
        int j = stack[h];
        d1 += " $j";
        _assert(j >= 0 && j < nn);
      }
      debug1("$d1\n");
      _assert(head < nn);
    }

  }
  return (k);
}
