import 'package:flutter/material.dart'  hide SearchBar;
import 'package:kwotmusic/components/kit/kit.dart';
import 'package:kwotmusic/components/widgets/indicator/indicators.dart';
import 'package:kwotmusic/components/widgets/list/item_list.model.dart';
import 'package:provider/provider.dart';
import 'package:wrapped_infinite_scroll_pagination/infinite_scroll_pagination.dart';

typedef ShouldShowListItemSeparator<ITEM> = bool Function(ITEM item, int index);

class ItemListWidget<ITEM, MODEL extends ItemListModel<ITEM>>
    extends StatefulWidget {
  //=
  final MODEL? model;
  final ScrollController? controller;
  final List<Widget> headerSlivers;
  final List<Widget> footerSlivers;
  final Widget Function(BuildContext context, ITEM item, int index) itemBuilder;
  final ShouldShowListItemSeparator<ITEM>? shouldShowListItemSeparator;
  final int columnCount;
  final double columnItemSpacing;
  final EdgeInsets padding;
  final ScrollPhysics? physics;
  final Function(ITEM item)? onItemTap;
  final bool useRefreshIndicator;
  final Widget? emptyFirstPageIndicator;

  const ItemListWidget({
    Key? key,
    this.model,
    this.controller,
    this.headerSlivers = const [],
    this.footerSlivers = const [],
    required this.itemBuilder,
    this.columnCount = 1,
    this.shouldShowListItemSeparator,
    this.columnItemSpacing = 0,
    this.padding = EdgeInsets.zero,
    this.physics,
    this.onItemTap,
    this.useRefreshIndicator = true,
    this.emptyFirstPageIndicator,
  }) : super(key: key);

  const ItemListWidget.optionalSeparator({
    Key? key,
    this.model,
    this.controller,
    this.headerSlivers = const [],
    this.footerSlivers = const [],
    required this.itemBuilder,
    required this.shouldShowListItemSeparator,
    this.columnItemSpacing = 0,
    this.padding = EdgeInsets.zero,
    this.physics,
    this.onItemTap,
    this.useRefreshIndicator = true,
    this.emptyFirstPageIndicator,
  })  : columnCount = 1,
        super(key: key);

  @override
  State<ItemListWidget> createState() => _ItemListWidgetState<ITEM, MODEL>();
}

class _ItemListWidgetState<ITEM, MODEL extends ItemListModel<ITEM>>
    extends State<ItemListWidget<ITEM, MODEL>> {
  //=
  MODEL get _model => widget.model ?? context.read<MODEL>();

  @override
  Widget build(BuildContext context) {
    //=
    final builderDelegate = PagedChildBuilderDelegate<ITEM>(
      itemBuilder: widget.itemBuilder,
      firstPageProgressIndicatorBuilder: (_) {
        return const _FirstPageProgressIndicator();
      },
      firstPageErrorIndicatorBuilder: (_) {
        return _FirstPageErrorIndicator(
          error: _model.controller().error,
          onTryAgain: () => _model.refresh(resetPageKey: true),
        );
      },
      newPageProgressIndicatorBuilder: (_) {
        return const _NewPageProgressIndicator();
      },
      newPageErrorIndicatorBuilder: (_) {
        return _NewPageErrorIndicator(
          error: _model.controller().error,
          onTryAgain: () => _model.refresh(resetPageKey: false),
        );
      },
      noItemsFoundIndicatorBuilder: (_) {
        return widget.emptyFirstPageIndicator ?? const _NoItemsFoundIndicator();
      },
    );

    return _RefreshIndicator(
        useRefreshIndicator: widget.useRefreshIndicator,
        onRefresh: () {
          _model.refresh(resetPageKey: true, isForceRefresh: true);
        },
        child: CustomScrollView(
            controller: widget.controller,
            physics: widget.physics,
            slivers: [
              for (final sliver in widget.headerSlivers) sliver,
              SliverPadding(
                padding: widget.padding,
                sliver: _SliverContent<ITEM>(
                  builderDelegate: builderDelegate,
                  columnCount: widget.columnCount,
                  columnItemSpacing: widget.columnItemSpacing,
                  controller: _model.controller(),
                  shouldShowListItemSeparator:
                      widget.shouldShowListItemSeparator,
                ),
              ),
              for (final sliver in widget.footerSlivers) sliver,
            ]));
  }
}

class _RefreshIndicator extends StatelessWidget {
  const _RefreshIndicator({
    Key? key,
    required this.useRefreshIndicator,
    required this.onRefresh,
    required this.child,
  }) : super(key: key);

  final bool useRefreshIndicator;
  final VoidCallback onRefresh;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (!useRefreshIndicator) {
      return child;
    }

    return RefreshIndicator(
        color: DynamicTheme.get(context).secondary100(),
        backgroundColor: DynamicTheme.get(context).black(),
        onRefresh: () => Future.sync(onRefresh),
        child: child);
  }
}

class _SliverContent<ITEM> extends StatelessWidget {
  const _SliverContent({
    Key? key,
    required this.builderDelegate,
    required this.columnCount,
    required this.columnItemSpacing,
    required this.controller,
    required this.shouldShowListItemSeparator,
  }) : super(key: key);

  final PagedChildBuilderDelegate<ITEM> builderDelegate;
  final int columnCount;
  final double columnItemSpacing;
  final PagingController<int, ITEM> controller;
  final ShouldShowListItemSeparator<ITEM>? shouldShowListItemSeparator;

  @override
  Widget build(BuildContext context) {
    return columnCount == 1
        ? PagedSliverList<int, ITEM>.separated(
            pagingController: controller,
            builderDelegate: builderDelegate,
            separatorBuilder: (_, index) {
              final shouldShow = _checkShouldShowListItemSeparator(index);
              if (!shouldShow) {
                return const SizedBox.shrink();
              }

              return SizedBox(
                width: columnItemSpacing,
                height: columnItemSpacing,
              );
            },
          )
        : PagedStaggeredSliverGrid<int, ITEM>.count(
            pagingController: controller,
            builderDelegate: builderDelegate,
            showNewPageErrorIndicatorAsGridChild: false,
            showNewPageProgressIndicatorAsGridChild: false,
            showNoMoreItemsIndicatorAsGridChild: false,
            mainAxisSpacing: columnItemSpacing,
            crossAxisCount: columnCount,
            crossAxisSpacing: columnItemSpacing,
            staggeredTileBuilder: (index) => const StaggeredTile.fit(1),
          );
  }

  bool _checkShouldShowListItemSeparator(int index) {
    final itemList = controller.itemList;
    if (itemList == null || itemList.isEmpty) return true;

    final verifier = shouldShowListItemSeparator;
    if (verifier == null) return true;

    return verifier.call(itemList[index], index);
  }
}

class _FirstPageProgressIndicator extends StatelessWidget {
  const _FirstPageProgressIndicator({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const LoadingIndicator();
  }
}

class _FirstPageErrorIndicator extends StatelessWidget {
  const _FirstPageErrorIndicator({
    Key? key,
    required this.error,
    required this.onTryAgain,
  }) : super(key: key);

  final dynamic error;
  final VoidCallback onTryAgain;

  @override
  Widget build(BuildContext context) {
    return ErrorIndicator(error: error, onTryAgain: onTryAgain);
  }
}

class _NewPageProgressIndicator extends StatelessWidget {
  const _NewPageProgressIndicator({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(height: 60.h, child: const LoadingIndicator());
  }
}

class _NewPageErrorIndicator extends StatelessWidget {
  const _NewPageErrorIndicator({
    Key? key,
    required this.error,
    required this.onTryAgain,
  }) : super(key: key);

  final dynamic error;
  final VoidCallback onTryAgain;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120.h,
      child: ErrorIndicator(error: error, onTryAgain: onTryAgain),
    );
  }
}

class _NoItemsFoundIndicator extends StatelessWidget {
  const _NoItemsFoundIndicator({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(height: 120.h, child: const EmptyIndicator());
  }
}
