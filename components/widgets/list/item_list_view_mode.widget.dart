import 'package:flutter/material.dart'  hide SearchBar;
import 'package:kwotmusic/components/kit/kit.dart';
import 'package:kwotmusic/components/widgets/button.dart';
import 'package:kwotmusic/components/widgets/list/item_list_util.dart';
import 'package:provider/provider.dart';

class ItemListViewModeWidget<MODEL extends ItemListViewModeMixin>
    extends StatelessWidget {
  const ItemListViewModeWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Selector<MODEL, ItemListViewMode>(
        selector: (_, model) => model.viewMode,
        builder: (_, viewMode, __) {
          return Row(mainAxisSize: MainAxisSize.min, children: [
            // LIST
            AppIconButton(
                width: ComponentSize.normal.r,
                height: ComponentSize.normal.r,
                assetColor: viewMode.isListMode
                    ? DynamicTheme.get(context).white()
                    : DynamicTheme.get(context).neutral20(),
                assetPath: Assets.iconList,
                padding: EdgeInsets.all(ComponentInset.smaller.r),
                onPressed: () => context.read<MODEL>().setListViewMode()),

            // GRID
            AppIconButton(
                width: ComponentSize.normal.r,
                height: ComponentSize.normal.r,
                assetColor: viewMode.isGridMode
                    ? DynamicTheme.get(context).white()
                    : DynamicTheme.get(context).neutral20(),
                assetPath: Assets.iconGrid,
                padding: EdgeInsets.all(ComponentInset.smaller.r),
                onPressed: () => context.read<MODEL>().setGridViewMode())
          ]);
        });
  }
}
