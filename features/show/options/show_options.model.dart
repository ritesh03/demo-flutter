import 'package:flutter/material.dart'  hide SearchBar;
import 'package:kwotdata/kwotdata.dart';

class ShowOptionsArgs {
  ShowOptionsArgs({
    required this.show,
    this.canMinimize = false,
  });

  final Show show;
  final bool canMinimize;
}

class ShowOptionsModel with ChangeNotifier {
  //=

  final Show _show;
  final bool canMinimize;

  ShowOptionsModel({
    required ShowOptionsArgs args,
  })  : _show = args.show,
        canMinimize = args.canMinimize;

  Show get show => _show;

  bool get canWatch => !show.isPaid || (show.isPaid && show.isPurchased);
}
