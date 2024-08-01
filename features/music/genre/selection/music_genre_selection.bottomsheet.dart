import 'package:flutter/material.dart'  hide SearchBar;
import 'package:kwotdata/kwotdata.dart';
import 'package:kwotmusic/components/kit/kit.dart';
import 'package:kwotmusic/components/widgets/bottomsheet/bottomsheet_drag_handle.widget.dart';
import 'package:kwotmusic/components/widgets/bottomsheet/material_bottom_sheet.dart';
import 'package:kwotmusic/components/widgets/button.dart';
import 'package:kwotmusic/components/widgets/chip/chip.widget.dart';
import 'package:kwotmusic/components/widgets/indicator/indicators.dart';
import 'package:kwotmusic/components/widgets/textfield/search/searchbar.widget.dart';
import 'package:kwotmusic/core.dart';
import 'package:kwotmusic/l10n/localizations.dart';
import 'package:provider/provider.dart';

import 'music_genre_selection.model.dart';

class MusicGenreSelectionBottomSheet extends StatefulWidget {
  //=
  static Future<List<MusicGenre>?> show(
    BuildContext context,
    List<MusicGenre> selectedGenres,
  ) {
    return showMaterialBottomSheet<List<MusicGenre>?>(context,
        builder: (context, controller) {
      return ChangeNotifierProvider(
          create: (_) =>
              MusicGenreSelectionModel(selectedGenres: selectedGenres),
          child: MusicGenreSelectionBottomSheet(controller: controller));
    });
  }

  const MusicGenreSelectionBottomSheet({
    Key? key,
    this.controller,
  }) : super(key: key);

  final ScrollController? controller;

  @override
  State<MusicGenreSelectionBottomSheet> createState() =>
      _MusicGenreSelectionBottomSheetState();
}

class _MusicGenreSelectionBottomSheetState
    extends State<MusicGenreSelectionBottomSheet> {
  //=
  MusicGenreSelectionModel get _model =>
      context.read<MusicGenreSelectionModel>();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _model.fetchMusicGenres();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      const BottomSheetDragHandle(),
      SizedBox(height: ComponentInset.small.h),
      _buildTitle(),
      SizedBox(height: ComponentInset.normal.h),
      _buildSearchBar(),
      SizedBox(height: ComponentInset.normal.h),
      Expanded(child: _buildGenres()),
    ]);
  }

  Widget _buildTitle() {
    return Container(
        margin: EdgeInsets.symmetric(horizontal: ComponentInset.normal.w),
        height: ComponentSize.smaller.h,
        child: Stack(children: [
          Positioned.fill(
              child: Text(LocaleResources.of(context).musicGenre,
                  style: TextStyles.boldBody, textAlign: TextAlign.center)),
          Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              child: _buildClearSelectedGenresButton()),
          Positioned(
              right: 0,
              top: 0,
              bottom: 0,
              child: _buildApplySelectedGenresButton()),
        ]));
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: ComponentInset.normal.r),
      child: SearchBar(
          backgroundColor: DynamicTheme.get(context).background(),
          hintText: LocaleResources.of(context).search,
          onQueryChanged: _model.updateSearchQuery,
          onQueryCleared: _model.clearSearchQuery),
    );
  }

  Widget _buildClearSelectedGenresButton() {
    return Selector<MusicGenreSelectionModel, bool>(
        selector: (_, model) => model.canClearSelection(),
        builder: (_, canClearSelection, __) {
          if (!canClearSelection) return Container();

          return AppIconTextButton(
              color: DynamicTheme.get(context).neutral10(),
              height: ComponentSize.smaller.h,
              iconPath: Assets.iconResetMedium,
              text: LocaleResources.of(context).clear,
              onPressed: _onClearSelectionButtonTapped);
        });
  }

  Widget _buildApplySelectedGenresButton() {
    return Selector<MusicGenreSelectionModel, bool>(
        selector: (_, model) => model.canApplySelection(),
        builder: (_, canApplySelection, __) {
          if (!canApplySelection) return Container();

          return Button(
              height: ComponentSize.smaller.h,
              text: LocaleResources.of(context).apply,
              type: ButtonType.text,
              onPressed: _onApplySelectionButtonTapped);
        });
  }

  Widget _buildGenres() {
    return Selector<MusicGenreSelectionModel, Result<List<MusicGenre>>?>(
        selector: (_, model) => model.genresResult,
        builder: (_, result, __) {
          //=

          if (result == null) {
            return const LoadingIndicator();
          }

          if (!result.isSuccess()) {
            return ErrorIndicator(
                error: result.error(), onTryAgain: _model.fetchMusicGenres);
          }

          final genres = result.data();
          if (genres.isEmpty) {
            return const EmptyIndicator();
          }

          return SingleChildScrollView(
              padding: EdgeInsets.all(ComponentInset.normal.r),
              child: SizedBox(
                width: double.infinity,
                child: Wrap(
                    alignment: WrapAlignment.start,
                    crossAxisAlignment: WrapCrossAlignment.start,
                    spacing: ComponentInset.normal.r,
                    runSpacing: ComponentInset.normal.r,
                    children: genres.map(_buildGenreChip).toList()),
              ));
        });
  }

  Widget _buildGenreChip(MusicGenre genre) {
    return Selector<MusicGenreSelectionModel, bool>(
        selector: (_, model) => model.isGenreSelected(id: genre.id),
        builder: (_, isSelected, __) {
          return ChipWidget(
            data: genre,
            text: genre.title,
            selected: isSelected,
            onPressed: (_) => _onGenreTap(genre),
          );
        });
  }

  void _onClearSelectionButtonTapped() {
    RootNavigation.pop(context, <MusicGenre>[]);
  }

  void _onApplySelectionButtonTapped() {
    RootNavigation.pop(context, _model.selectedGenres);
  }

  void _onGenreTap(MusicGenre genre) {
    _model.toggleGenreSelection(genre);
  }
}
