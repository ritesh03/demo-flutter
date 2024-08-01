import 'package:flutter/material.dart'  hide SearchBar;
import 'package:kwotdata/kwotdata.dart';
import 'package:kwotmusic/components/kit/kit.dart';
import 'package:kwotmusic/components/widgets/blocking_progress.dialog.dart';
import 'package:kwotmusic/components/widgets/button.dart';
import 'package:kwotmusic/components/widgets/button/buttons.dart';
import 'package:kwotmusic/components/widgets/indicator/indicators.dart';
import 'package:kwotmusic/components/widgets/notificationbar/notification_bar.dart';
import 'package:kwotmusic/components/widgets/page/page_state.dart';
import 'package:kwotmusic/components/widgets/textfield.dart';
import 'package:kwotmusic/core.dart';
import 'package:kwotmusic/features/dashboard/dashboard_config.dart';
import 'package:kwotmusic/features/misc/report/widget/report_content_preview.widget.dart';
import 'package:kwotmusic/l10n/localizations.dart';
import 'package:kwotmusic/util/util.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';

import 'reason/report_reason_selection.bottomsheet.dart';
import 'report_content.model.dart';

class ReportContentPage extends StatefulWidget {
  const ReportContentPage({Key? key}) : super(key: key);

  @override
  State<ReportContentPage> createState() => _ReportContentPageState();
}

class _ReportContentPageState extends PageState<ReportContentPage> {
  //=

  @override
  void initState() {
    super.initState();
    modelOf(context).init();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
            appBar: PreferredSize(
                preferredSize: Size.fromHeight(ComponentSize.large.h),
                child: _buildAppBar()),
            body: Selector<ReportContentModel, Result<List<ReportReason>>?>(
                selector: (_, model) => model.reportReasonsResult,
                builder: (_, result, __) {
                  if (result == null) {
                    return const LoadingIndicator();
                  }

                  if (!result.isSuccess()) {
                    return Center(
                        child: ErrorIndicator(
                      error: result.error(),
                      onTryAgain: () => modelOf(context).fetchReportReasons(),
                    ));
                  }

                  return _buildContent();
                })));
  }

  Widget _buildAppBar() {
    return Row(children: [
      AppIconButton(
          width: ComponentSize.large.r,
          height: ComponentSize.large.r,
          assetColor: DynamicTheme.get(context).neutral20(),
          assetPath: Assets.iconArrowLeft,
          padding: EdgeInsets.all(ComponentInset.small.r),
          onPressed: () => DashboardNavigation.pop(context)),
      const Spacer(),
      _buildSendButton(),
      SizedBox(width: ComponentInset.normal.w)
    ]);
  }

  Widget _buildSendButton() {
    return Selector<ReportContentModel, bool>(
        selector: (_, model) => model.canSendReport,
        builder: (_, canSend, __) {
          return Button(
              text: LocaleResources.of(context).send,
              type: ButtonType.text,
              enabled: canSend,
              height: ComponentSize.smaller.h,
              onPressed: _onSendButtonTapped);
        });
  }

  Widget _buildContent() {
    return SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Container(
            padding: EdgeInsets.symmetric(horizontal: ComponentInset.normal.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTitle(),
                SizedBox(height: ComponentInset.medium.h),
                ReportContentPreview(content: modelOf(context).content),
                SizedBox(height: ComponentInset.medium.h),
                _buildReportReasonsDropdown(),
                SizedBox(height: ComponentInset.medium.h),
                _buildDescriptionInput(),
                const DashboardConfigAwareFooter(),
              ],
            )));
  }

  Widget _buildTitle() {
    return Container(
        height: ComponentSize.small.h,
        alignment: Alignment.centerLeft,
        child: Text(LocaleResources.of(context).reportContentPageTitle,
            style: TextStyles.boldHeading2));
  }

  Widget _buildReportReasonsDropdown() {
    return Selector<ReportContentModel, Tuple2<ReportReason?, String?>>(
        selector: (_, model) =>
            Tuple2(model.selectedReportReason, model.reportReasonInputError),
        builder: (_, tuple, __) {
          final selectedReportReason = tuple.item1;
          final error = tuple.item2;
          return DropDownButton(
              height: ComponentSize.large.h,
              hintText: LocaleResources.of(context).reportReasonSelectionHint,
              inputText: selectedReportReason?.title,
              errorText: error,
              labelText: LocaleResources.of(context).reportReasonSelectionLabel,
              onTap: _onSelectReasonButtonTapped);
        });
  }

  Widget _buildDescriptionInput() {
    return Selector<ReportContentModel, String?>(
        selector: (_, model) => model.descriptionInputError,
        builder: (_, error, __) {
          return TextInputField(
            controller: modelOf(context).descriptionInputController,
            errorText: error,
            height: 140.h,
            hintText: LocaleResources.of(context).reportContentDescriptionHint,
            inputBoxCrossAxisAlignment: CrossAxisAlignment.start,
            inputBoxPadding:
                EdgeInsets.symmetric(vertical: ComponentInset.small.r),
            keyboardType: TextInputType.multiline,
            labelText:
                LocaleResources.of(context).reportContentDescriptionLabel,
            maxLines: null,
            minLines: 5,
            onChanged: (text) =>
                modelOf(context).onDescriptionInputChanged(text),
          );
        });
  }

  ReportContentModel modelOf(BuildContext context) {
    return context.read<ReportContentModel>();
  }

  /*
   * ACTIONS
   */

  void _onSelectReasonButtonTapped() async {
    hideKeyboard(context);

    final model = modelOf(context);
    final selectedReportReason = model.selectedReportReason;
    final reportReasons = model.reportReasonsResult?.peek();
    if (reportReasons == null || reportReasons.isEmpty) {
      return;
    }

    final reportReason = await ReportReasonSelectionBottomSheet.show(context,
        reportReasons: reportReasons,
        selectedReportReason: selectedReportReason);

    if (!mounted) return;
    if (reportReason != null && reportReason is ReportReason) {
      modelOf(context).updateSelectedReportReason(reportReason);
    }
  }

  void _onSendButtonTapped() async {
    hideKeyboard(context);

    showBlockingProgressDialog(context);
    final result = await modelOf(context).reportContent(context);

    if (!mounted) return;
    hideBlockingProgressDialog(context);

    if (result == null) return;

    if (!result.isSuccess()) {
      showDefaultNotificationBar(
        NotificationBarInfo.error(message: result.error()),
      );
      return;
    }

    showDefaultNotificationBar(
      NotificationBarInfo.success(message: result.message),
    );

    DashboardNavigation.pop(context);
  }
}
