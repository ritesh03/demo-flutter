import 'package:flutter/material.dart'  hide SearchBar;
import 'package:kwotdata/kwotdata.dart';
import 'package:kwotmusic/components/kit/kit.dart';
import 'package:kwotmusic/components/widgets/bottomsheet/bottomsheet_drag_handle.widget.dart';
import 'package:kwotmusic/components/widgets/bottomsheet/material_bottom_sheet.dart';
import 'package:kwotmusic/core.dart';
import 'package:kwotmusic/l10n/localizations.dart';

import 'contact_reason_item.widget.dart';

class ContactReasonSelectionBottomSheet extends StatefulWidget {
  //=
  static Future show(
    BuildContext context, {
    required List<ContactReason> reasons,
    ContactReason? selectedReason,
  }) {
    return showMaterialBottomSheet<void>(
      context,
      expand: false,
      builder: (_, __) => ContactReasonSelectionBottomSheet(
        reasons: reasons,
        selectedReason: selectedReason,
      ),
    );
  }

  const ContactReasonSelectionBottomSheet({
    Key? key,
    required this.reasons,
    required this.selectedReason,
  }) : super(key: key);

  final List<ContactReason> reasons;
  final ContactReason? selectedReason;

  @override
  State<ContactReasonSelectionBottomSheet> createState() =>
      _ContactReasonSelectionBottomSheetState();
}

class _ContactReasonSelectionBottomSheetState
    extends State<ContactReasonSelectionBottomSheet> {
  //=

  @override
  Widget build(BuildContext context) {
    return Column(mainAxisSize: MainAxisSize.min, children: [
      const BottomSheetDragHandle(),
      SizedBox(height: ComponentInset.small.h),
      _buildTitle(),
      SizedBox(height: ComponentInset.normal.h),
      Expanded(child: _buildContactReasons()),
    ]);
  }

  Widget _buildTitle() {
    return Container(
        height: ComponentSize.smaller.h,
        alignment: Alignment.center,
        child: Text(LocaleResources.of(context).contactReasonSelectionHint,
            style: TextStyles.boldBody));
  }

  Widget _buildContactReasons() {
    final reasons = widget.reasons;
    return ListView.separated(
        padding: EdgeInsets.only(
            left: ComponentInset.normal.r,
            right: ComponentInset.normal.r,
            bottom: ComponentInset.normal.r),
        itemBuilder: (_, index) => _buildContactReason(reasons[index]),
        separatorBuilder: (_, __) => SizedBox(height: ComponentInset.normal.r),
        itemCount: reasons.length);
  }

  Widget _buildContactReason(ContactReason reason) {
    final selectedReason = widget.selectedReason;
    final isSelected = (selectedReason?.id == reason.id);
    return ContactReasonItemWidget(
        reason: reason,
        isSelected: isSelected,
        onPressed: (reason) {
          RootNavigation.pop(context, reason);
        });
  }
}
