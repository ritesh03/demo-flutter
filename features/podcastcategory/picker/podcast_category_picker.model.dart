import 'package:flutter/material.dart'  hide SearchBar;
import 'package:kwotcommon/kwotcommon.dart';
import 'package:kwotdata/kwotdata.dart';
import 'package:kwotmusic/l10n/localizations.dart';

import 'podcast_category_picker.bottomsheet.dart';

class PodcastCategoryPickerModel with ChangeNotifier {
  PodcastCategoryPickerModel({
    required PodcastCategoryPickerArgs args,
  }) : selectedCategories = args.selectedCategories;

  late final PodcastCategory defaultCategory;
  final List<PodcastCategory> selectedCategories;
  Result<List<PodcastCategory>>? podcastCategoriesResult;

  void init(BuildContext context) async {
    defaultCategory = PodcastCategory(
        id: "all",
        title: LocaleResources.of(context).allCategories,
        thumbnail: "");

    fetchPodcastCategories();
  }

  void fetchPodcastCategories() async {
    if (podcastCategoriesResult != null) {
      podcastCategoriesResult = null;
      notifyListeners();
    }

    final request = PodcastCategoriesRequest(query: null);
    final result = await locator<KwotData>()
        .podcastsRepository
        .fetchPodcastCategories(request);
    if (result.isSuccess()) {
      final allCategories = <PodcastCategory>[];
      allCategories.add(defaultCategory);

      final receivedCategories = result.peek();
      if (receivedCategories != null) {
        allCategories.addAll(receivedCategories);
      }

      podcastCategoriesResult = Result.success(allCategories);
    } else {
      podcastCategoriesResult = result;
    }

    notifyListeners();
  }

  bool canClearSelection() {
    final result = podcastCategoriesResult;
    if (result == null || !result.isSuccess()) {
      return false;
    }

    // 0: defaultCategory
    // 1/1+: Categories
    return ((result.peek()?.length) ?? 0) > 1;
  }

  bool canApplySelection() {
    return canClearSelection();
  }

  bool isPodcastCategorySelected(PodcastCategory category) {
    if (category.id == defaultCategory.id) {
      return selectedCategories.isEmpty;
    }

    final index =
        selectedCategories.indexWhere((element) => (element.id == category.id));
    return index != -1;
  }

  void toggleCategorySelection(PodcastCategory category) {
    if (category.id == defaultCategory.id) {
      selectedCategories.clear();
      notifyListeners();
      return;
    }

    if (isPodcastCategorySelected(category)) {
      selectedCategories.removeWhere((element) => (element.id == category.id));
    } else {
      selectedCategories.add(category);
    }
    notifyListeners();
  }
}
