import 'package:flutter/material.dart'  hide SearchBar;
import 'package:kwotdata/kwotdata.dart';
import 'package:kwotmusic/components/kit/kit.dart';
import 'package:kwotmusic/components/widgets/bottomsheet/app_bottomsheet.dart';
import 'package:kwotmusic/components/widgets/bottomsheet/bottomsheet_drag_handle.widget.dart';
import 'package:kwotmusic/components/widgets/indicator/indicators.dart';
import 'package:kwotmusic/components/widgets/textfield.dart';
import 'package:kwotmusic/core.dart';
import 'package:kwotmusic/l10n/localizations.dart';
import 'package:provider/provider.dart';

import 'province_picker.model.dart';
import 'province_picker_item.widget.dart';

class ProvincePickerBottomSheet extends StatefulWidget {
  //=
  static Future<Province?> show(
    BuildContext context, {
    required String countryId,
    Province? selectedProvince,
  }) {
    return AppBottomSheet.show<Province, ProvincePickerModel>(
      context,
      changeNotifier: ProvincePickerModel(
        countryId: countryId,
        selectedProvince: selectedProvince,
      ),
      builder: (context, controller) {
        return ProvincePickerBottomSheet(controller: controller);
      },
    );
  }

  const ProvincePickerBottomSheet({
    Key? key,
    this.controller,
  }) : super(key: key);

  final ScrollController? controller;

  @override
  State<ProvincePickerBottomSheet> createState() =>
      _ProvincePickerBottomSheetState();
}

class _ProvincePickerBottomSheetState extends State<ProvincePickerBottomSheet> {
  //=

  @override
  void initState() {
    super.initState();
    provincePickerModelOf(context).fetchProvinces();
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      const BottomSheetDragHandle(),
      SizedBox(height: ComponentInset.small.h),
      _buildTitle(),
      SizedBox(height: ComponentInset.normal.h),
      _buildSearchBar(),
      Expanded(child: _buildProvinces()),
    ]);
  }

  Widget _buildTitle() {
    return Container(
        height: ComponentSize.smaller.h,
        alignment: Alignment.center,
        child: Text(LocaleResources.of(context).provinceState,
            style: TextStyles.boldBody));
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: EdgeInsets.all(ComponentInset.normal.r),
      child: SearchBar(
          backgroundColor: DynamicTheme.get(context).background(),
          hintText: LocaleResources.of(context).searchPageSearchHint,
          onQueryChanged: provincePickerModelOf(context).updateSearchQuery,
          onQueryCleared: provincePickerModelOf(context).clearSearchQuery),
    );
  }

  Widget _buildProvinces() {
    return Selector<ProvincePickerModel, Result<List<Province>>?>(
        selector: (_, model) => model.provincesResult,
        builder: (_, result, __) {
          //=

          if (result == null) {
            return const LoadingIndicator();
          }

          if (!result.isSuccess()) {
            return ErrorIndicator(
                error: result.error(),
                onTryAgain: () {
                  provincePickerModelOf(context).fetchProvinces();
                });
          }

          final provinces = result.data();
          if (provinces.isEmpty) {
            return const EmptyIndicator();
          }

          final selectedProvince =
              provincePickerModelOf(context).selectedProvince;
          return ListView.builder(
              controller: widget.controller,
              itemCount: provinces.length,
              itemBuilder: (_, index) {
                final province = provinces[index];
                final isSelected = (selectedProvince?.id == province.id);
                return ProvincePickerItemWidget(
                    province: province,
                    isSelected: isSelected,
                    onPressed: (country) {
                      RootNavigation.pop(context, country);
                    });
              });
        });
  }

  ProvincePickerModel provincePickerModelOf(BuildContext context) {
    return context.read<ProvincePickerModel>();
  }
}
