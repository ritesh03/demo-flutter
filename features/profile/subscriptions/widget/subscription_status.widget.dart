import 'package:flutter/material.dart'  hide SearchBar;
import 'package:kwotcommon/kwotcommon.dart';
import 'package:kwotdata/models/models.dart';
import 'package:kwotmusic/components/kit/kit.dart';
import 'package:kwotmusic/features/profile/subscriptions/subscription_detail.model.dart';
import 'package:kwotmusic/util/util.dart';

class SubscriptionStatusWidget extends StatelessWidget {
  const SubscriptionStatusWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Result<SubscriptionDetail>?>(
        stream: locator<SubscriptionDetailModel>().subscriptionDetailStream,
        builder: (_, snapshot) {
          final result = snapshot.data;
          if (result == null) {
            return _Wrapper(
              color: Colors.grey.shade400,
              child: const Text('fetching subscription detail.'),
            );
          }

          if (!result.isSuccess()) {
            return _Wrapper(
              color: Colors.red.shade200,
              child: const Text("something went wrong"),
            );
          }

          if (result.isEmpty()) {
            return const SizedBox.shrink();
          }

          final detail = result.data();
          final activation = detail.activation;
          if (activation == null) {
            return _Wrapper(
              color: Colors.red.shade200,
              child: const Text("not subscribed"),
            );
          }

          return _Wrapper(
            color: Colors.lightGreen.shade200,
            child: Row(children: [
              Text(detail.plan!.name??""),
              const Text(" · "),
              Text(activation.status?.name??"",
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              const Spacer(),
              Text(activation.endDate.toDefaultDateFormat()),
              const Text(" "),
              Text(activation.endDate.toHourMinuteFormat()),
            ]),
          );
        });
  }
}

class _Wrapper extends StatelessWidget {
  const _Wrapper({
    Key? key,
    required this.color,
    required this.child,
  }) : super(key: key);

  final Color color;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
        width: double.infinity,
        padding: EdgeInsets.all(ComponentInset.smaller.r),
        color: color,
        child: child);
  }
}
