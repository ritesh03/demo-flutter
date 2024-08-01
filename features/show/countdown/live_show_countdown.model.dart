import 'package:flutter/material.dart'  hide SearchBar;
import 'package:kwotdata/kwotdata.dart';
import 'package:kwotdata/models/liveshows/live_shows.dart';

class LiveShowCountdownArgs {
  LiveShowCountdownArgs({
    required this.show,
  });

 // final Show show;
  final LiveShow show;
}

class LiveShowCountdownModel with ChangeNotifier {
  final LiveShow _show;

  LiveShowCountdownModel({
    required LiveShowCountdownArgs args,
  }) : _show = args.show;

  LiveShow get show => _show;

  String get showTitle => show.showTitle??"";
  bool get canWatchShow => true;

 // bool get canWatchShow => show.isFreeEvent??true && (show.isCurrentLiveShow??false || show.date!.isBefore(DateTime.now()));

  void update() {
    Future.delayed(const Duration(seconds: 1), () {
      notifyListeners();
    });
  }
}
