import 'package:flutter/material.dart'  hide SearchBar;

class RootNavigation {
  @optionalTypeArgs
  static Future<T?> pushNamed<T extends Object?>(
    BuildContext context,
    String routeName, {
    Object? arguments,
  }) {
    return Navigator.of(context, rootNavigator: true)
        .pushNamed<T>(routeName, arguments: arguments);
  }

  @optionalTypeArgs
  static Future<T?> pushReplacementNamed<T extends Object?, TO extends Object?>(
    BuildContext context,
    String routeName, {
    TO? result,
    Object? arguments,
  }) {
    return Navigator.of(context, rootNavigator: true)
        .pushReplacementNamed<T, TO>(
      routeName,
      arguments: arguments,
      result: result,
    );
  }

  @optionalTypeArgs
  static Future<T?> popAndPushNamed<T extends Object?, TO extends Object?>(
    BuildContext context,
    String routeName, {
    TO? result,
    Object? arguments,
  }) {
    return Navigator.of(context, rootNavigator: true).popAndPushNamed<T, TO>(
        routeName,
        arguments: arguments,
        result: result);
  }

  @optionalTypeArgs
  static Future<T?> pushNamedAndRemoveUntil<T extends Object?>(
    BuildContext context,
    String newRouteName,
    RoutePredicate predicate, {
    Object? arguments,
  }) {
    return Navigator.of(context, rootNavigator: true)
        .pushNamedAndRemoveUntil<T>(newRouteName, predicate,
            arguments: arguments);
  }

  @optionalTypeArgs
  static void pop<T extends Object?>(BuildContext context, [T? result]) {
    Navigator.of(context, rootNavigator: true).pop<T>(result);
  }

  static void popUntil(BuildContext context, RoutePredicate predicate) {
    Navigator.of(context, rootNavigator: true).popUntil(predicate);
  }

  static void popUntilRoot(BuildContext context) {
    Navigator.of(context, rootNavigator: true).popUntil((route) {
      return route.settings.name == "/";
    });
  }
}
