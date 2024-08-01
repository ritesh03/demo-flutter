import 'package:flutter/material.dart'  hide SearchBar;
import 'package:kwotdata/models/models.dart';
import 'package:kwotmusic/components/kit/kit.dart';
import 'package:kwotmusic/util/util.dart';

class ShowDurationWidget extends StatefulWidget {
  const ShowDurationWidget({
    Key? key,
    required this.show,
  }) : super(key: key);

  final Show show;

  @override
  State<ShowDurationWidget> createState() => _ShowDurationWidgetState();
}

class _ShowDurationWidgetState extends State<ShowDurationWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 1));
    _controller.addListener(() => setState(() {}));
    _controller.repeat();
  }

  @override
  Widget build(BuildContext context) {
    final duration = calculateDuration();
    final durationText = duration?.toHoursMinutesSeconds();
    if (durationText == null) {
      return Container();
    }

    return Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
            color: DynamicTheme.displayBlack.withOpacity(0.5),
            borderRadius: BorderRadius.circular(ComponentRadius.normal.r)),
        margin: EdgeInsets.all(ComponentInset.small.r),
        padding: EdgeInsets.symmetric(
            horizontal: ComponentInset.small.r,
            vertical: ComponentInset.smaller.r),
        child: Text(durationText,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyles.heading6
                .copyWith(color: DynamicTheme.get(context).white())));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Duration? calculateDuration() {
    final show = widget.show;
    final currentDateTime = DateTime.now();
    if (show.isStreamingNow) {
      // Elapsed time: how long the show has been going on
      if (currentDateTime.isAfter(show.startDateTime)) {
        return currentDateTime.difference(show.startDateTime);
      }

      // Current time is before start time
      return null;
    }

    if (!show.isFreeOrPurchased) {
      // Do not show start time for paid shows if they're not purchased
      return null;
    }

    if (show.startDateTime.isAfter(currentDateTime)) {
      final duration = show.startDateTime.difference(currentDateTime);
      if (duration.inHours >= 24) {
        // Do not show start time if start-time is more than 24 hours away
        return null;
      }

      // Show countdown timer if show is starting in next 24 hours
      return duration;
    }

    // Current time is past start time
    return null;
  }
}
