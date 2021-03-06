// Copyright 2016 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:meta/meta.dart';
import 'package:test/test.dart';

import 'finders.dart';

/// Asserts that the [Finder] matches no widgets in the widget tree.
///
/// ## Sample code
///
/// ```dart
/// expect(find.text('Save'), findsNothing);
/// ```
///
/// See also:
///
///  * [findsWidgets], when you want the finder to find one or more widgets.
///  * [findsOneWidget], when you want the finder to find exactly one widget.
///  * [findsNWidgets], when you want the finder to find a specific number of widgets.
const Matcher findsNothing = const _FindsWidgetMatcher(null, 0);

/// Asserts that the [Finder] locates at least one widget in the widget tree.
///
/// ## Sample code
///
/// ```dart
/// expect(find.text('Save'), findsWidgets);
/// ```
///
/// See also:
///
///  * [findsNothing], when you want the finder to not find anything.
///  * [findsOneWidget], when you want the finder to find exactly one widget.
///  * [findsNWidgets], when you want the finder to find a specific number of widgets.
const Matcher findsWidgets = const _FindsWidgetMatcher(1, null);

/// Asserts that the [Finder] locates at exactly one widget in the widget tree.
///
/// ## Sample code
///
/// ```dart
/// expect(find.text('Save'), findsOneWidget);
/// ```
///
/// See also:
///
///  * [findsNothing], when you want the finder to not find anything.
///  * [findsWidgets], when you want the finder to find one or more widgets.
///  * [findsNWidgets], when you want the finder to find a specific number of widgets.
const Matcher findsOneWidget = const _FindsWidgetMatcher(1, 1);

/// Asserts that the [Finder] locates the specified number of widgets in the widget tree.
///
/// ## Sample code
///
/// ```dart
/// expect(find.text('Save'), findsNWidgets(2));
/// ```
///
/// See also:
///
///  * [findsNothing], when you want the finder to not find anything.
///  * [findsWidgets], when you want the finder to find one or more widgets.
///  * [findsOneWidget], when you want the finder to find exactly one widget.
Matcher findsNWidgets(int n) => new _FindsWidgetMatcher(n, n);

/// Asserts that the [Finder] locates the a single widget that has at
/// least one [Offstage] widget ancestor.
///
/// It's important to use a full finder, since by default finders exclude
/// offstage widgets.
///
/// ## Sample code
///
/// ```dart
/// expect(find.text('Save', skipOffstage: false), isOffstage);
/// ```
///
/// See also:
///
///  * [isOnstage], the opposite.
const Matcher isOffstage = const _IsOffstage();

/// Asserts that the [Finder] locates the a single widget that has no
/// [Offstage] widget ancestors.
///
/// See also:
///
///  * [isOffstage], the opposite.
const Matcher isOnstage = const _IsOnstage();

/// Asserts that the [Finder] locates the a single widget that has at
/// least one [Card] widget ancestor.
///
/// See also:
///
///  * [isNotInCard], the opposite.
const Matcher isInCard = const _IsInCard();

/// Asserts that the [Finder] locates the a single widget that has no
/// [Card] widget ancestors.
///
/// This is equivalent to `isNot(isInCard)`.
///
/// See also:
///
///  * [isInCard], the opposite.
const Matcher isNotInCard = const _IsNotInCard();

/// Asserts that an object's toString() is a plausible one-line description.
///
/// Specifically, this matcher checks that the string does not contains newline
/// characters, and does not have leading or trailing whitespace, is not
/// empty, and does not contain the default `Instance of ...` string.
const Matcher hasOneLineDescription = const _HasOneLineDescription();

/// Asserts that an object's toStringDeep() is a plausible multi-line
/// description.
///
/// Specifically, this matcher checks that an object's
/// `toStringDeep(prefixLineOne, prefixOtherLines)`:
///
///  * Does not have leading or trailing whitespace.
///  * Does not contain the default `Instance of ...` string.
///  * The last line has characters other than tree connector characters and
///    whitespace. For example: the line ` │ ║ ╎` has only tree connector
///    characters and whitespace.
///  * Does not contain lines with trailing white space.
///  * Has multiple lines.
///  * The first line starts with `prefixLineOne`
///  * All subsequent lines start with `prefixOtherLines`.
const Matcher hasAGoodToStringDeep = const _HasGoodToStringDeep();

/// A matcher for functions that throw [FlutterError].
///
/// This is equivalent to `throwsA(const isInstanceOf<FlutterError>())`.
///
/// See also:
///
///  * [throwsAssertionError], to test if a function throws any [AssertionError].
///  * [isFlutterError], to test if any object is a [FlutterError].
///  * [isAssertionError], to test if any object is any kind of [AssertionError].
Matcher throwsFlutterError = throwsA(isFlutterError);

/// A matcher for functions that throw [AssertionError].
///
/// This is equivalent to `throwsA(const isInstanceOf<AssertionError>())`.
///
/// See also:
///
///  * [throwsFlutterError], to test if a function throws a [FlutterError].
///  * [isFlutterError], to test if any object is a [FlutterError].
///  * [isAssertionError], to test if any object is any kind of [AssertionError].
Matcher throwsAssertionError = throwsA(isAssertionError);

/// A matcher for [FlutterError].
///
/// This is equivalent to `const isInstanceOf<FlutterError>()`.
///
/// See also:
///
///  * [throwsFlutterError], to test if a function throws a [FlutterError].
///  * [throwsAssertionError], to test if a function throws any [AssertionError].
///  * [isAssertionError], to test if any object is any kind of [AssertionError].
const Matcher isFlutterError = const isInstanceOf<FlutterError>();

/// A matcher for [AssertionError].
///
/// This is equivalent to `const isInstanceOf<AssertionError>()`.
///
/// See also:
///
///  * [throwsFlutterError], to test if a function throws a [FlutterError].
///  * [throwsAssertionError], to test if a function throws any [AssertionError].
///  * [isFlutterError], to test if any object is a [FlutterError].
const Matcher isAssertionError = const isInstanceOf<AssertionError>();

/// Asserts that two [double]s are equal, within some tolerated error.
///
/// Two values are considered equal if the difference between them is within
/// 1e-10 of the larger one. This is an arbitrary value which can be adjusted
/// using the `epsilon` argument. This matcher is intended to compare floating
/// point numbers that are the result of different sequences of operations, such
/// that they may have accumulated slightly different errors.
///
/// See also:
///
///  * [closeTo], which is identical except that the epsilon argument is
///    required and not named.
///  * [inInclusiveRange], which matches if the argument is in a specified
///    range.
Matcher moreOrLessEquals(double value, { double epsilon: 1e-10 }) {
  return new _MoreOrLessEquals(value, epsilon);
}

/// Asserts that two [String]s are equal after normalizing likely hash codes.
///
/// A `#` followed by 5 hexadecimal digits is assumed to be a short hash code
/// and is normalized to #00000.
///
/// See Also:
///
///  * [describeIdentity], a method that generates short descriptions of objects
///    with ids that match the pattern #[0-9a-f]{5}.
///  * [shortHash], a method that generates a 5 character long hexadecimal
///    [String] based on [Object.hashCode].
///  * [TreeDiagnosticsMixin.toStringDeep], a method that returns a [String]
///    typically containing multiple hash codes.
Matcher equalsIgnoringHashCodes(String value) {
  return new _EqualsIgnoringHashCodes(value);
}

/// A matcher for [MethodCall]s, asserting that it has the specified
/// method [name] and [arguments].
///
/// Arguments checking implements deep equality for [List] and [Map] types.
Matcher isMethodCall(String name, {@required dynamic arguments}) {
  return new _IsMethodCall(name, arguments);
}

class _FindsWidgetMatcher extends Matcher {
  const _FindsWidgetMatcher(this.min, this.max);

  final int min;
  final int max;

  @override
  bool matches(covariant Finder finder, Map<dynamic, dynamic> matchState) {
    assert(min != null || max != null);
    assert(min == null || max == null || min <= max);
    matchState[Finder] = finder;
    int count = 0;
    final Iterator<Element> iterator = finder.evaluate().iterator;
    if (min != null) {
      while (count < min && iterator.moveNext())
        count += 1;
      if (count < min)
        return false;
    }
    if (max != null) {
      while (count <= max && iterator.moveNext())
        count += 1;
      if (count > max)
        return false;
    }
    return true;
  }

  @override
  Description describe(Description description) {
    assert(min != null || max != null);
    if (min == max) {
      if (min == 1)
        return description.add('exactly one matching node in the widget tree');
      return description.add('exactly $min matching nodes in the widget tree');
    }
    if (min == null) {
      if (max == 0)
        return description.add('no matching nodes in the widget tree');
      if (max == 1)
        return description.add('at most one matching node in the widget tree');
      return description.add('at most $max matching nodes in the widget tree');
    }
    if (max == null) {
      if (min == 1)
        return description.add('at least one matching node in the widget tree');
      return description.add('at least $min matching nodes in the widget tree');
    }
    return description.add('between $min and $max matching nodes in the widget tree (inclusive)');
  }

  @override
  Description describeMismatch(
    dynamic item,
    Description mismatchDescription,
    Map<dynamic, dynamic> matchState,
    bool verbose
  ) {
    final Finder finder = matchState[Finder];
    final int count = finder.evaluate().length;
    if (count == 0) {
      assert(min != null && min > 0);
      if (min == 1 && max == 1)
        return mismatchDescription.add('means none were found but one was expected');
      return mismatchDescription.add('means none were found but some were expected');
    }
    if (max == 0) {
      if (count == 1)
        return mismatchDescription.add('means one was found but none were expected');
      return mismatchDescription.add('means some were found but none were expected');
    }
    if (min != null && count < min)
      return mismatchDescription.add('is not enough');
    assert(max != null && count > min);
    return mismatchDescription.add('is too many');
  }
}

bool _hasAncestorMatching(Finder finder, bool predicate(Widget widget)) {
  final Iterable<Element> nodes = finder.evaluate();
  if (nodes.length != 1)
    return false;
  bool result = false;
  nodes.single.visitAncestorElements((Element ancestor) {
    if (predicate(ancestor.widget)) {
      result = true;
      return false;
    }
    return true;
  });
  return result;
}

bool _hasAncestorOfType(Finder finder, Type targetType) {
  return _hasAncestorMatching(finder, (Widget widget) => widget.runtimeType == targetType);
}

class _IsOffstage extends Matcher {
  const _IsOffstage();

  @override
  bool matches(covariant Finder finder, Map<dynamic, dynamic> matchState) {
    return _hasAncestorMatching(finder, (Widget widget) {
      if (widget is Offstage)
        return widget.offstage;
      return false;
    });
  }

  @override
  Description describe(Description description) => description.add('offstage');
}

class _IsOnstage extends Matcher {
  const _IsOnstage();

  @override
  bool matches(covariant Finder finder, Map<dynamic, dynamic> matchState) {
    final Iterable<Element> nodes = finder.evaluate();
    if (nodes.length != 1)
      return false;
    bool result = true;
    nodes.single.visitAncestorElements((Element ancestor) {
      final Widget widget = ancestor.widget;
      if (widget is Offstage) {
        result = !widget.offstage;
        return false;
      }
      return true;
    });
    return result;
  }

  @override
  Description describe(Description description) => description.add('onstage');
}

class _IsInCard extends Matcher {
  const _IsInCard();

  @override
  bool matches(covariant Finder finder, Map<dynamic, dynamic> matchState) => _hasAncestorOfType(finder, Card);

  @override
  Description describe(Description description) => description.add('in card');
}

class _IsNotInCard extends Matcher {
  const _IsNotInCard();

  @override
  bool matches(covariant Finder finder, Map<dynamic, dynamic> matchState) => !_hasAncestorOfType(finder, Card);

  @override
  Description describe(Description description) => description.add('not in card');
}

class _HasOneLineDescription extends Matcher {
  const _HasOneLineDescription();

  @override
  bool matches(Object object, Map<dynamic, dynamic> matchState) {
    final String description = object.toString();
    return description.isNotEmpty
        && !description.contains('\n')
        && !description.contains('Instance of ')
        && description.trim() == description;
  }

  @override
  Description describe(Description description) => description.add('one line description');
}

class _EqualsIgnoringHashCodes extends Matcher {
  _EqualsIgnoringHashCodes(String v) : _value = _normalize(v);

  final String _value;

  static final Object _mismatchedValueKey = new Object();

  static String _normalize(String s) {
    return s.replaceAll(new RegExp(r'#[0-9a-f]{5}'), '#00000');
  }

  @override
  bool matches(dynamic object, Map<dynamic, dynamic> matchState) {
    final String description = _normalize(object);
    if (_value != description) {
      matchState[_mismatchedValueKey] = description;
      return false;
    }
    return true;
  }

  @override
  Description describe(Description description) {
    return description.add('multi line description equals $_value');
  }

  @override
  Description describeMismatch(
    dynamic item,
    Description mismatchDescription,
    Map<dynamic, dynamic> matchState,
    bool verbose
  ) {
    if (matchState.containsKey(_mismatchedValueKey)) {
      final String actualValue = matchState[_mismatchedValueKey];
      // Leading whitespace is added so that lines in the multi-line
      // description returned by addDescriptionOf are all indented equally
      // which makes the output easier to read for this case.
      return mismatchDescription
          .add('expected normalized value\n  ')
          .addDescriptionOf(_value)
          .add('\nbut got\n  ')
          .addDescriptionOf(actualValue);
    }
    return mismatchDescription;
  }
}

/// Returns true if [c] represents a whitespace code unit.
bool _isWhitespace(int c) => (c <= 0x000D && c >= 0x0009) || c == 0x0020;

/// Returns true if [c] represents a vertical line unicode line art code unit.
///
/// See [https://en.wikipedia.org/wiki/Box-drawing_character]. This method only
/// specifies vertical line art code units currently used by Flutter line art.
/// There are other line art characters that technically also represent vertical
/// lines.
bool _isVerticalLine(int c) {
  return c == 0x2502 || c == 0x2503 || c == 0x2551 || c == 0x254e;
}

/// Returns whether a [line] is all vertical tree connector characters.
///
/// Example vertical tree connector characters: `│ ║ ╎`.
/// The last line of a text tree contains only vertical tree connector
/// characters indicates a poorly formatted tree.
bool _isAllTreeConnectorCharacters(String line) {
  for (int i = 0; i < line.length; ++i) {
    final int c = line.codeUnitAt(i);
    if (!_isWhitespace(c) && !_isVerticalLine(c))
      return false;
  }
  return true;
}

class _HasGoodToStringDeep extends Matcher {
  const _HasGoodToStringDeep();

  static final Object _toStringDeepErrorDescriptionKey = new Object();

  @override
  bool matches(dynamic object, Map<dynamic, dynamic> matchState) {
    final List<String> issues = <String>[];
    String description = object.toStringDeep();
    if (description.endsWith('\n')) {
      // Trim off trailing \n as the remaining calculations assume
      // the description does not end with a trailing \n.
      description = description.substring(0, description.length - 1);
    } else {
      issues.add('Not terminated with a line break.');
    }

    if (description.trim() != description)
      issues.add('Has trailing whitespace.');

    final List<String> lines = description.split('\n');
    if (lines.length < 2)
      issues.add('Does not have multiple lines.');

    if (description.contains('Instance of '))
      issues.add('Contains text "Instance of ".');

    for (int i = 0; i < lines.length; ++i) {
      final String line = lines[i];
      if (line.isEmpty)
        issues.add('Line ${i+1} is empty.');

      if (line.trimRight() != line)
        issues.add('Line ${i+1} has trailing whitespace.');
    }

    if (_isAllTreeConnectorCharacters(lines.last))
      issues.add('Last line is all tree connector characters.');

    // If a toStringDeep method doesn't properly handle nested values that
    // contain line breaks it can  fail to add the required prefixes to all
    // lined when toStringDeep is called specifying prefixes.
    final String prefixLineOne    = 'PREFIX_LINE_ONE____';
    final String prefixOtherLines = 'PREFIX_OTHER_LINES_';
    final List<String> prefixIssues = <String>[];
    String descriptionWithPrefixes =
        object.toStringDeep(prefixLineOne: prefixLineOne, prefixOtherLines: prefixOtherLines);
    if (descriptionWithPrefixes.endsWith('\n')) {
      // Trim off trailing \n as the remaining calculations assume
      // the description does not end with a trailing \n.
      descriptionWithPrefixes = descriptionWithPrefixes.substring(
          0, descriptionWithPrefixes.length - 1);
    }
    final List<String> linesWithPrefixes = descriptionWithPrefixes.split('\n');
    if (!linesWithPrefixes.first.startsWith(prefixLineOne))
      prefixIssues.add('First line does not contain expected prefix.');

    for (int i = 1; i < linesWithPrefixes.length; ++i) {
      if (!linesWithPrefixes[i].startsWith(prefixOtherLines))
        prefixIssues.add('Line ${i+1} does not contain the expected prefix.');
    }

    final StringBuffer errorDescription = new StringBuffer();
    if (issues.isNotEmpty) {
      errorDescription.writeln('Bad toStringDeep():');
      errorDescription.writeln(description);
      errorDescription.writeAll(issues, '\n');
    }

    if (prefixIssues.isNotEmpty) {
      errorDescription.writeln(
          'Bad toStringDeep(prefixLineOne: "$prefixLineOne", prefixOtherLines: "$prefixOtherLines"):');
      errorDescription.writeln(descriptionWithPrefixes);
      errorDescription.writeAll(prefixIssues, '\n');
    }

    if (errorDescription.isNotEmpty) {
      matchState[_toStringDeepErrorDescriptionKey] =
          errorDescription.toString();
      return false;
    }
    return true;
  }

  @override
  Description describeMismatch(
    dynamic item,
    Description mismatchDescription,
    Map<dynamic, dynamic> matchState,
    bool verbose
  ) {
    if (matchState.containsKey(_toStringDeepErrorDescriptionKey)) {
      return mismatchDescription.add(
          matchState[_toStringDeepErrorDescriptionKey]);
    }
    return mismatchDescription;
  }

  @override
  Description describe(Description description) {
    return description.add('multi line description');
  }
}

/// Computes the distance between two values.
///
/// The distance should be a metric in a metric space (see
/// https://en.wikipedia.org/wiki/Metric_space). Specifically, if `f` is a
/// distance function then the following conditions should hold:
///
/// - f(a, b) >= 0
/// - f(a, b) == 0 if and only if a == b
/// - f(a, b) == f(b, a)
/// - f(a, c) <= f(a, b) + f(b, c), known as triangle inequality
///
/// This makes it useful for comparing numbers, [Color]s, [Offset]s and other
/// sets of value for which a metric space is defined.
typedef num DistanceFunction<T>(T a, T b);

const Map<Type, DistanceFunction<dynamic>> _kStandardDistanceFunctions = const <Type, DistanceFunction<dynamic>>{
  Color: _maxComponentColorDistance,
  Offset: _offsetDistance,
  int: _intDistance,
  double: _doubleDistance,
};

int _intDistance(int a, int b) => (b - a).abs();
double _doubleDistance(double a, double b) => (b - a).abs();
double _offsetDistance(Offset a, Offset b) => (b - a).distance;

double _maxComponentColorDistance(Color a, Color b) {
  int delta = math.max<int>((a.red - b.red).abs(), (a.green - b.green).abs());
  delta = math.max<int>(delta, (a.blue - b.blue).abs());
  delta = math.max<int>(delta, (a.alpha - b.alpha).abs());
  return delta.toDouble();
}

/// Asserts that two values are within a certain distance from each other.
///
/// The distance is computed by a [DistanceFunction].
///
/// If `distanceFunction` is null, a standard distance function is used for the
/// `runtimeType` of the `from` argument. Standard functions are defined for
/// the following types:
///
///  * [Color], whose distance is the maximum component-wise delta.
///  * [Offset], whose distance is the Euclidean distance computed using the
///    method [Offset.distance].
///  * [int], whose distance is the absolute difference between two integers.
///  * [double], whose distance is the absolute difference between two doubles.
///
/// See also:
///
///  * [moreOrLessEquals], which is similar to this function, but specializes in
///    [double]s and has an optional `epsilon` parameter.
///  * [closeTo], which specializes in numbers only.
Matcher within<T>({
  @required num distance,
  @required T from,
  DistanceFunction<T> distanceFunction,
}) {
  distanceFunction ??= _kStandardDistanceFunctions[from.runtimeType];

  if (distanceFunction == null) {
    throw new ArgumentError(
      'The specified distanceFunction was null, and a standard distance '
      'function was not found for type ${from.runtimeType} of the provided '
      '`from` argument.'
    );
  }

  return new _IsWithinDistance<T>(distanceFunction, from, distance);
}

class _IsWithinDistance<T> extends Matcher {
  const _IsWithinDistance(this.distanceFunction, this.value, this.epsilon);

  final DistanceFunction<T> distanceFunction;
  final T value;
  final num epsilon;

  @override
  bool matches(Object object, Map<dynamic, dynamic> matchState) {
    if (object is! T)
      return false;
    if (object == value)
      return true;
    final T test = object;
    final num distance = distanceFunction(test, value);
    if (distance < 0) {
      throw new ArgumentError(
        'Invalid distance function was used to compare a ${value.runtimeType} '
        'to a ${object.runtimeType}. The function must return a non-negative '
        'double value, but it returned $distance.'
      );
    }
    return distance <= epsilon;
  }

  @override
  Description describe(Description description) => description.add('$value (±$epsilon)');
}

class _MoreOrLessEquals extends Matcher {
  const _MoreOrLessEquals(this.value, this.epsilon);

  final double value;
  final double epsilon;

  @override
  bool matches(Object object, Map<dynamic, dynamic> matchState) {
    if (object is! double)
      return false;
    if (object == value)
      return true;
    final double test = object;
    return (test - value).abs() <= epsilon;
  }

  @override
  Description describe(Description description) => description.add('$value (±$epsilon)');
}

class _IsMethodCall extends Matcher {
  const _IsMethodCall(this.name, this.arguments);

  final String name;
  final dynamic arguments;

  @override
  bool matches(dynamic item, Map<dynamic, dynamic> matchState) {
    if (item is! MethodCall)
      return false;
    if (item.method != name)
      return false;
    return _deepEquals(item.arguments, arguments);
  }

  bool _deepEquals(dynamic a, dynamic b) {
    if (a == b)
      return true;
    if (a is List)
      return b is List && _deepEqualsList(a, b);
    if (a is Map)
      return b is Map && _deepEqualsMap(a, b);
    return false;
  }

  bool _deepEqualsList(List<dynamic> a, List<dynamic> b) {
    if (a.length != b.length)
      return false;
    for (int i = 0; i < a.length; i++) {
      if (!_deepEquals(a[i], b[i]))
        return false;
    }
    return true;
  }

  bool _deepEqualsMap(Map<dynamic, dynamic> a, Map<dynamic, dynamic> b) {
    if (a.length != b.length)
      return false;
    for (dynamic key in a.keys) {
      if (!b.containsKey(key) || !_deepEquals(a[key], b[key]))
        return false;
    }
    return true;
  }

  @override
  Description describe(Description description) {
    return description
        .add('has method name: ').addDescriptionOf(name)
        .add(' with arguments: ').addDescriptionOf(arguments);
  }
}

