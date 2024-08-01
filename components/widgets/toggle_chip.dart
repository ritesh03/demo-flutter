import 'package:flutter/material.dart'  hide SearchBar;
import 'package:flutter_scale_tap/flutter_scale_tap.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:kwotmusic/components/kit/kit.dart';

enum ChipSize { small, normal }

class ChipItem {
  final String identifier;
  bool selected;
  final ChipSize size;
  final String text;

  ChipItem({
    required this.identifier,
    required this.selected,
    this.size = ChipSize.normal,
    required this.text,
  });

  ChipItem.from(ChipItem chipItem)
      : this(
          identifier: chipItem.identifier,
          selected: chipItem.selected,
          size: chipItem.size,
          text: chipItem.text,
        );

  void toggle() {
    selected = !selected;
  }
}

class ToggleChip extends StatefulWidget {
  const ToggleChip({
    Key? key,
    required this.item,
    this.margin = EdgeInsets.zero,
    required this.onPressed,
  }) : super(key: key);

  final ChipItem item;
  final EdgeInsets margin;
  final Function(ChipItem item) onPressed;

  @override
  State<ToggleChip> createState() => _ToggleChipState();
}

class _ToggleChipState extends State<ToggleChip> {
  late final ChipItem chipItem;

  @override
  void initState() {
    super.initState();
    chipItem = ChipItem.from(widget.item);
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTap(
        onPressed: _onToggled,
        child: Container(
          alignment: Alignment.center,
          height: obtainHeight(),
          decoration: BoxDecoration(
              color: obtainBackgroundColor(context),
              borderRadius: BorderRadius.circular(ComponentRadius.normal.r)),
          margin: widget.margin,
          padding: EdgeInsets.symmetric(horizontal: obtainHorizontalPadding()),
          child: Stack(children: [
            /// ACTUAL VISIBLE ITEM
            Text(chipItem.text,
                style: chipItem.selected
                    ? obtainSelectedTextStyle(context)
                    : obtainNormalTextStyle(context)),

            /// SHADOW ITEM: to compensate for changes in width when chip is
            /// selected
            Opacity(
              opacity: 0,
              child:
                  Text(chipItem.text, style: obtainSelectedTextStyle(context)),
            ),
          ]),
        ));
  }

  Color obtainBackgroundColor(BuildContext context) {
    return chipItem.selected
        ? DynamicTheme.get(context).secondary100()
        : DynamicTheme.get(context).black();
  }

  double obtainHeight() {
    switch (chipItem.size) {
      case ChipSize.normal:
        return ComponentSize.normal.h;
      case ChipSize.small:
        return ComponentSize.smaller.h;
    }
  }

  double obtainHorizontalPadding() {
    return ComponentInset.normal.r;
  }

  TextStyle obtainNormalTextStyle(BuildContext context) {
    final textColor = DynamicTheme.get(context).white();

    switch (chipItem.size) {
      case ChipSize.normal:
        return TextStyles.body.copyWith(color: textColor);
      case ChipSize.small:
        return TextStyles.boldHeading6.copyWith(color: textColor);
    }
  }

  TextStyle obtainSelectedTextStyle(BuildContext context) {
    final textColor = DynamicTheme.get(context).black();

    switch (chipItem.size) {
      case ChipSize.normal:
        return TextStyles.boldBody.copyWith(color: textColor);
      case ChipSize.small:
        return TextStyles.boldHeading6.copyWith(color: textColor);
    }
  }

  /*
   * ACTIONS
   */

  void _onToggled() {
    chipItem.toggle();
    setState(() {
      widget.onPressed(chipItem);
    });
  }
}

class ToggleChipMasonryGrid extends StatelessWidget {
  const ToggleChipMasonryGrid({
    Key? key,
    required this.crossAxisCount,
    this.crossAxisSpacing = 0,
    required this.items,
    this.mainAxisSpacing = 0,
    this.padding = EdgeInsets.zero,
    required this.onChipPressed,
    this.scrollDirection = Axis.horizontal,
    this.size = ChipSize.normal,
  }) : super(key: key);

  final int crossAxisCount;
  final double crossAxisSpacing;
  final double mainAxisSpacing;
  final List<ChipItem> items;
  final EdgeInsets padding;
  final Function(ChipItem item) onChipPressed;
  final Axis scrollDirection;
  final ChipSize size;

  @override
  Widget build(BuildContext context) {
    return MasonryGridView.count(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: crossAxisSpacing,
        itemBuilder: (context, index) {
          return ToggleChip(item: items[index], onPressed: onChipPressed);
        },
        itemCount: items.length,
        mainAxisSpacing: mainAxisSpacing,
        padding: padding,
        scrollDirection: scrollDirection,
        shrinkWrap: true);
  }
}
