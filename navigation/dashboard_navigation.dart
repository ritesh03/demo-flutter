import 'package:flutter/material.dart'  hide SearchBar;

class DashboardNavigation {
  static final navigatorKey = GlobalKey<NavigatorState>();

  static NavigatorState get _navigatorState => navigatorKey.currentState!;

  @optionalTypeArgs
  static Future<bool> maybePop<T extends Object?>([T? result]) {
    return _navigatorState.maybePop(result);
  }

  @optionalTypeArgs
  static Future<T?> pushNamed<T extends Object?>(
    BuildContext context,
    String routeName, {
    Object? arguments,
  }) {
    return _navigatorState.pushNamed<T>(routeName, arguments: arguments);
  }

  @optionalTypeArgs
  static Future<T?> pushReplacementNamed<T extends Object?, TO extends Object?>(
    BuildContext context,
    String routeName, {
    TO? result,
    Object? arguments,
  }) {
    return _navigatorState.pushReplacementNamed<T, TO>(routeName,
        arguments: arguments, result: result);
  }

  @optionalTypeArgs
  static Future<T?> popAndPushNamed<T extends Object?, TO extends Object?>(
    BuildContext context,
    String routeName, {
    TO? result,
    Object? arguments,
  }) {
    return _navigatorState.popAndPushNamed<T, TO>(routeName,
        arguments: arguments, result: result);
  }

  @optionalTypeArgs
  static Future<T?> pushNamedAndRemoveUntil<T extends Object?>(
    BuildContext context,
    String newRouteName,
    RoutePredicate predicate, {
    Object? arguments,
  }) {
    return _navigatorState.pushNamedAndRemoveUntil<T>(newRouteName, predicate,
        arguments: arguments);
  }

  @optionalTypeArgs
  static void pop<T extends Object?>(BuildContext context, [T? result]) {
    _navigatorState.pop<T>(result);
  }

  static void popUntil(BuildContext context, RoutePredicate predicate) {
    _navigatorState.popUntil(predicate);
  }
}
