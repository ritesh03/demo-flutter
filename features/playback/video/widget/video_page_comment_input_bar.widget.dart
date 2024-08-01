import 'package:flutter/material.dart'  hide SearchBar;
import 'package:flutter/services.dart';
import 'package:kwotmusic/app_config.dart';
import 'package:kwotmusic/components/kit/kit.dart';
import 'package:kwotmusic/components/widgets/indicator/indicators.dart';
import 'package:kwotmusic/components/widgets/textfield.dart';
import 'package:kwotmusic/components/widgets/textfield/fomatter/utf8_length_limiting_formatter.dart';
import 'package:kwotmusic/l10n/localizations.dart';

enum CommentInputStatus { loading, idle }

class CommentInputStatusNotifier extends ValueNotifier<CommentInputStatus> {
  CommentInputStatusNotifier() : super(CommentInputStatus.idle);
}

class VideoPageCommentInputBar extends StatelessWidget {
  const VideoPageCommentInputBar({
    Key? key,
    required this.notifier,
    required this.controller,
    required this.onSubmit,
  }) : super(key: key);

  final CommentInputStatusNotifier notifier;
  final TextEditingController controller;
  final ValueSetter<String> onSubmit;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<CommentInputStatus>(
        valueListenable: notifier,
        builder: (_, status, __) {
          final Widget child;
          switch (status) {
            case CommentInputStatus.idle:
              child = _buildCommentInputWidget(context);
              break;
            case CommentInputStatus.loading:
              child = SizedBox(
                  height: ComponentSize.large.r,
                  child: const LoadingIndicator());
              break;
          }

          return Container(
            color: DynamicTheme.get(context).background(),
            padding: EdgeInsets.all(ComponentInset.normal.r),
            child: child,
          );
        });
  }

  Widget _buildCommentInputWidget(BuildContext context) {
    return CommentInputWidget(
        backgroundColor: DynamicTheme.get(context).neutral60(),
        controller: controller,
        height: ComponentSize.large.r,
        hintText: LocaleResources.of(context).writeCommentHint,
        inputFormatters: [
          Utf8LengthLimitingTextInputFormatter(
              AppConfig.allowedNewCommentLength),
          LengthLimitingTextInputFormatter(AppConfig.allowedNewCommentLength),
        ],
        maxLength: AppConfig.allowedNewCommentLength,
        maxLengthEnforcement: MaxLengthEnforcement.enforced,
        onSubmitted: onSubmit);
  }
}
