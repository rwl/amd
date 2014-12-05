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

final _log = new logging.Logger("AMD");

/// Enable debugging.
void set debug(bool d) {
  _ndebug = !d;
}

bool _ndebug = true;

/// Enable printing and diagnostics.
void set log(bool l) {
  _nprint = !l;
}

bool _nprint = true;

/// FLIP is a "negation about -1", and is used to mark an integer i that is
/// normally non-negative.  FLIP (EMPTY) is EMPTY.  FLIP of a number > EMPTY
/// is negative, and FLIP of a number < EMTPY is positive.  FLIP (FLIP (i)) = i
/// for all integers i.  UNFLIP (i) is >= EMPTY. */
const int empty = -1;

int flip(int i) {
  return (-(i) - 2);
}

int unflip(int i) {
  return ((i < empty) ? flip(i) : (i));
}

num max(num a, num b) {
  return (((a) > (b)) ? (a) : (b));

}

num min(num a, num b) {
  return (((a) < (b)) ? (a) : (b));
}

/// logical expression of p implies q:
bool implies(bool p, bool q) {
  return (!(p) || (q));
}

final int _true = 1;
final int _false = 0;

void _print(String format) {
  if (!_nprint) {
    _log.info(format);
  }
}

void _assert(bool a) {
  if (!_ndebug) {
    assert(a);
  }
}

void _assertInt(int a) {
  _assert(a != 0);
}

void debug0(String format) {
  if (!_ndebug) {
    _print(format);
  }
}

void debug1(String format) {
  if (!_ndebug) {
    if (debugLevel >= 1) _print(format);
  }
}

void debug2(String format) {
  if (!_ndebug) {
    if (debugLevel >= 2) _print(format);
  }
}

void debug3(String format) {
  if (!_ndebug) {
    if (debugLevel >= 3) _print(format);
  }
}

void debug4(String format) {
  if (!_ndebug) {
    if (debugLevel >= 4) _print(format);
  }
}
