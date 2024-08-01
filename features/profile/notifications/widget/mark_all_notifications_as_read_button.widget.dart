import 'dart:async';

import 'package:flutter/material.dart'  hide SearchBar;
import 'package:kwotcommon/kwotcommon.dart';
import 'package:kwotmusic/components/kit/kit.dart';
import 'package:kwotmusic/components/widgets/button.dart';
import 'package:kwotmusic/components/widgets/indicator/indicators.dart';
import 'package:kwotmusic/features/profile/notifications/list/notifications.model.dart';
import 'package:kwotmusic/features/profile/notifications/unread_notifications_count_monitor.dart';
import 'package:kwotmusic/l10n/localizations.dart';
import 'package:provider/provider.dart';

class MarkAllNotificationsAsReadButton extends StatefulWidget {
  const MarkAllNotificationsAsReadButton({Key? key}) : super(key: key);

  @override
  State<MarkAllNotificationsAsReadButton> createState() =>
      _MarkAllNotificationsAsReadButtonState();
}

class _MarkAllNotificationsAsReadButtonState
    extends State<MarkAllNotificationsAsReadButton> {
  late _ButtonState _buttonState;
  late StreamSubscription _unreadNotificationsCountSubscription;

  @override
  void initState() {
    super.initState();

    _buttonState = _ButtonState.enabled;

    final countStream = locator<UnreadNotificationsCountMonitor>().stream;
    _unreadNotificationsCountSubscription = countStream.listen((count) {
      final updatedButtonState =
          (count > 0) ? _ButtonState.enabled : _ButtonState.disabled;
      if (updatedButtonState != _buttonState) {
        _setButtonState(updatedButtonState);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_buttonState == _ButtonState.loading) {
      return LoadingIndicator(size: ComponentSize.smaller.r);
    }

    return Button(
      enabled: _buttonState == _ButtonState.enabled,
      height: ComponentSize.small.r,
      onPressed: _onTap,
      text: LocaleResources.of(context).markAllAsRead,
      type: ButtonType.text,
    );
  }

  @override
  void dispose() {
    _unreadNotificationsCountSubscription.cancel();
    super.dispose();
  }

  void _onTap() async {
    _setButtonState(_ButtonState.loading);

    final result =
        await context.read<NotificationsModel>().markAllNotificationAsRead();
    if (result.isSuccess()) {
      _setButtonState(_ButtonState.disabled);
    } else {
      _setButtonState(_ButtonState.enabled);
    }
  }

  void _setButtonState(_ButtonState state) {
    setState(() => _buttonState = state);
  }
}

enum _ButtonState { enabled, disabled, loading }
