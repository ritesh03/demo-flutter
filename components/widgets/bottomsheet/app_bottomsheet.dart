import 'package:flutter/material.dart'  hide SearchBar;
import 'package:kwotmusic/components/kit/kit.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:provider/provider.dart';

class AppBottomSheet extends StatelessWidget {
  //=
  static Future<T?> show<T, MODEL extends ChangeNotifier>(
    BuildContext context, {
    required ScrollableWidgetBuilder builder,
    required MODEL? changeNotifier,
  }) {
    //=
    return showCupertinoModalBottomSheet<T>(
      backgroundColor: Colors.transparent,
      barrierColor: DynamicTheme.get(context).black().withOpacity(0.9),
      builder: (context) {
        final sheetWidget = AppBottomSheet(builder: builder);
        if (changeNotifier != null) {
          return ChangeNotifierProvider<MODEL>(
              create: (context) => changeNotifier,
              builder: (context, __) => sheetWidget);
        }

        return sheetWidget;
      },
      context: context,
      expand: true,
      topRadius: Radius.circular(ComponentRadius.normal.r),
      useRootNavigator: true,
    );
  }

  const AppBottomSheet({
    Key? key,
    required this.builder,
  }) : super(key: key);

  final ScrollableWidgetBuilder builder;

  @override
  Widget build(BuildContext context) {
    final backgroundColor = DynamicTheme.get(context).neutral80();
    final controller = ModalScrollController.of(context)!;

    return SafeArea(
        child: Scaffold(
            body: Container(
                color: backgroundColor, child: builder(context, controller))));
  }
}
