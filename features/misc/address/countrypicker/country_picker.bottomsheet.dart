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

import 'country_picker.model.dart';
import 'country_picker_item.widget.dart';

class CountryPickerBottomSheet extends StatefulWidget {
  //=
  static Future<Country?> show(BuildContext context, Country? selectedCountry) {
    return AppBottomSheet.show<Country, CountryPickerModel>(
      context,
      changeNotifier: CountryPickerModel(selectedCountry: selectedCountry),
      builder: (context, controller) {
        return CountryPickerBottomSheet(controller: controller);
      },
    );
  }

  const CountryPickerBottomSheet({
    Key? key,
    this.controller,
  }) : super(key: key);

  final ScrollController? controller;

  @override
  State<CountryPickerBottomSheet> createState() =>
      _CountryPickerBottomSheetState();
}

class _CountryPickerBottomSheetState extends State<CountryPickerBottomSheet> {
  //=

  @override
  void initState() {
    super.initState();
    countryPickerModelOf(context).fetchCountries();
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      const BottomSheetDragHandle(),
      SizedBox(height: ComponentInset.small.h),
      _buildTitle(),
      SizedBox(height: ComponentInset.normal.h),
      _buildSearchBar(),
      Expanded(child: _buildCountries()),
    ]);
  }

  Widget _buildTitle() {
    return Container(
        height: ComponentSize.smaller.h,
        alignment: Alignment.center,
        child: Text(LocaleResources.of(context).countryPickerTitle,
            style: TextStyles.boldBody));
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: EdgeInsets.all(ComponentInset.normal.r),
      child: SearchBar(
          backgroundColor: DynamicTheme.get(context).background(),
          hintText: LocaleResources.of(context).searchPageSearchHint,
          onQueryChanged: countryPickerModelOf(context).updateSearchQuery,
          onQueryCleared: countryPickerModelOf(context).clearSearchQuery),
    );
  }

  Widget _buildCountries() {
    return Selector<CountryPickerModel, Result<List<Country>>?>(
        selector: (_, model) => model.countriesResult,
        builder: (_, result, __) {
          //=

          if (result == null) {
            return const LoadingIndicator();
          }

          if (!result.isSuccess()) {
            return ErrorIndicator(
                error: result.error(),
                onTryAgain: () {
                  countryPickerModelOf(context).fetchCountries();
                });
          }

          final countries = result.data();
          if (countries.isEmpty) {
            return const EmptyIndicator();
          }

          final selectedCountry = countryPickerModelOf(context).selectedCountry;
          return ListView.builder(
              controller: widget.controller,
              itemCount: countries.length,
              itemBuilder: (_, index) {
                final country = countries[index];
                final isSelected =
                    (selectedCountry?.isoCode == country.isoCode);
                return CountryPickerItemWidget(
                    country: country,
                    isSelected: isSelected,
                    onPressed: (country) {
                      RootNavigation.pop(context, country);
                    });
              });
        });
  }

  CountryPickerModel countryPickerModelOf(BuildContext context) {
    return context.read<CountryPickerModel>();
  }
}
