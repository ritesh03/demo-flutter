import 'package:flutter/material.dart'  hide SearchBar;
import 'package:kwotmusic/components/kit/kit.dart';
import 'package:kwotmusic/components/widgets/bottomsheet/bottomsheet_drag_handle.widget.dart';
import 'package:kwotmusic/components/widgets/button.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class VideoPagePanel extends StatelessWidget {
  const VideoPagePanel({
    Key? key,
    required this.title,
    this.maxWidth,
    required this.maxHeight,
    required this.onClose,
    this.onPanelSlide,
    this.onPanelClosed,
    required this.panelController,
    required this.builder,
  }) : super(key: key);

  final Widget title;
  final double? maxWidth;
  final double maxHeight;
  final VoidCallback onClose;
  final ValueSetter<double>? onPanelSlide;
  final VoidCallback? onPanelClosed;
  final PanelController panelController;
  final ScrollableWidgetBuilder builder;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragUpdate: (_) {},
      onVerticalDragUpdate: (_) {},
      child: SlidingUpPanel(
          controller: panelController,
          dragHeader: _buildDragHeader(context),
          dragMode: DragMode.HEADER,
          maxWidth: maxWidth,
          minHeight: 0,
          maxHeight: maxHeight,
          onPanelSlide: onPanelSlide,
          onPanelClosed: onPanelClosed,
          panelBuilder: (controller) => builder(context, controller)),
    );
  }

  Widget _buildDragHeader(BuildContext context) {
    return Container(
        width: double.infinity,
        color: DynamicTheme.get(context).neutral60(),
        child: Column(children: [
          const BottomSheetDragHandle(),
          Container(
            alignment: Alignment.centerLeft,
            padding: EdgeInsets.symmetric(horizontal: ComponentInset.normal.r),
            // child: title,
            child: Row(children: [
              /// LABEL
              Expanded(child: title),

              /// CLOSE BUTTON
              AppIconButton(
                  width: ComponentSize.normal.r,
                  height: ComponentSize.normal.r,
                  assetColor: DynamicTheme.get(context).white(),
                  assetPath: Assets.iconCrossBold,
                  padding: EdgeInsets.all(ComponentInset.small.r),
                  onPressed: onClose),
            ]),
          ),
          SizedBox(height: ComponentInset.small.r),
        ]));
  }
}
