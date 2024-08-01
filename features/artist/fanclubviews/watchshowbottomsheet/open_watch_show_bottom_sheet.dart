import 'package:flutter/material.dart'  hide SearchBar;
import 'package:kwotdata/models/artist/get.artist.events.dart';
import 'package:kwotmusic/components/widgets/bottomsheet/material_bottom_sheet.dart';
import 'package:kwotmusic/features/artist/fanclubviews/watchshowbottomsheet/watch_show_bottom_sheet_view.dart';

class OpenWatchShowBottomSheet extends StatefulWidget {
  //=
  static Future<bool?> show(
      BuildContext context,
      {required VoidCallback onTapWatch, required String image,
      required String title,
      required String tokens,
      required String artistName}) {
    return showMaterialBottomSheet<bool>(
      context,
      expand: false,
      builder: (_, __) => OpenWatchShowBottomSheet( onTapWatch: onTapWatch, image: image, title: title, artistName: artistName, tokens: tokens,),
    );
  }

  OpenWatchShowBottomSheet({
    Key? key,required this.image,required this.onTapWatch,required this.title,required this.artistName,required this.tokens
  }) : super(key: key);
  String image;
  String title;
  String tokens;
  String artistName;
  VoidCallback onTapWatch;

  @override
  State<OpenWatchShowBottomSheet> createState() => _OpenWatchShowBottomSheetState();
}

class _OpenWatchShowBottomSheetState extends State<OpenWatchShowBottomSheet> {
  @override
  Widget build(BuildContext context) {
    return WatchShowBottomSheet( onTapWatch: widget.onTapWatch, title: widget.title, image: widget.image, artistName: widget.artistName, tokens: widget.tokens,);
  }
}
