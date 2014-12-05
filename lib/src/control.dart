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

/// User-callable.  Prints the control parameters for AMD.  See amd.dart
/// for details.  If the Control array is not present, the defaults are
/// printed instead.
void control(List<num> control) {
  double alpha;
  int aggressive;

  if (control != null) {
    alpha = control[DENSE];
    aggressive = control[AGGRESSIVE] != 0 ? 1 : 0;
  } else {
    alpha = DEFAULT_DENSE;
    aggressive = DEFAULT_AGGRESSIVE;
  }

  _print("\nAMD version $MAIN_VERSION.$SUB_VERSION.$SUBSUB_VERSION, $DATE: approximate minimum degree ordering\n" + "    dense row parameter: $alpha");

  if (alpha < 0) {
    _print("    no rows treated as dense");
  } else {
    _print("    (rows with more than max ($alpha * sqrt (n), 16) entries are\n" + "    considered \"dense\", and placed last in output permutation)");
  }

  if (aggressive != 0) {
    _print("    aggressive absorption:  yes");
  } else {
    _print("    aggressive absorption:  no");
  }

  //PRINTF("    size of AMD integer: 4\n\n"); // sizeof (int)
}
