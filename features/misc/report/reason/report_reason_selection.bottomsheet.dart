import 'package:flutter/material.dart'  hide SearchBar;
import 'package:kwotdata/kwotdata.dart';
import 'package:kwotmusic/components/kit/kit.dart';
import 'package:kwotmusic/components/widgets/bottomsheet/bottomsheet_drag_handle.widget.dart';
import 'package:kwotmusic/components/widgets/bottomsheet/material_bottom_sheet.dart';
import 'package:kwotmusic/core.dart';
import 'package:kwotmusic/l10n/localizations.dart';

import 'report_reason_item.widget.dart';

class ReportReasonSelectionBottomSheet extends StatefulWidget {
  //=
  static Future show(
    BuildContext context, {
    required List<ReportReason> reportReasons,
    ReportReason? selectedReportReason,
  }) {
    return showMaterialBottomSheet<void>(
      context,
      expand: false,
      builder: (_, __) => ReportReasonSelectionBottomSheet(
        reportReasons: reportReasons,
        selectedReportReason: selectedReportReason,
      ),
    );
  }

  const ReportReasonSelectionBottomSheet({
    Key? key,
    required this.reportReasons,
    required this.selectedReportReason,
  }) : super(key: key);

  final List<ReportReason> reportReasons;
  final ReportReason? selectedReportReason;

  @override
  State<ReportReasonSelectionBottomSheet> createState() =>
      _ReportReasonSelectionBottomSheetState();
}

class _ReportReasonSelectionBottomSheetState
    extends State<ReportReasonSelectionBottomSheet> {
  //=

  @override
  Widget build(BuildContext context) {
    return Column(mainAxisSize: MainAxisSize.min, children: [
      const BottomSheetDragHandle(),
      SizedBox(height: ComponentInset.small.h),
      _buildTitle(),
      SizedBox(height: ComponentInset.normal.h),
      Expanded(child: _buildReportReasons()),
    ]);
  }

  Widget _buildTitle() {
    return Container(
        height: ComponentSize.smaller.h,
        alignment: Alignment.center,
        child: Text(LocaleResources.of(context).reportReasonSelectionHint,
            style: TextStyles.boldBody));
  }

  Widget _buildReportReasons() {
    final reportReasons = widget.reportReasons;
    return ListView.separated(
        padding: EdgeInsets.only(
            left: ComponentInset.normal.r,
            right: ComponentInset.normal.r,
            bottom: ComponentInset.normal.r),
        itemBuilder: (_, index) => _buildReportReason(reportReasons[index]),
        separatorBuilder: (_, __) => SizedBox(height: ComponentInset.normal.r),
        itemCount: reportReasons.length);
  }

  Widget _buildReportReason(ReportReason reportReason) {
    final selectedReportReason = widget.selectedReportReason;
    final isSelected = (selectedReportReason?.id == reportReason.id);
    return ReportReasonItemWidget(
        reportReason: reportReason,
        isSelected: isSelected,
        onPressed: (reportReason) {
          RootNavigation.pop(context, reportReason);
        });
  }
}
