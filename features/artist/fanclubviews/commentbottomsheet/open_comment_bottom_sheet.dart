import 'package:flutter/material.dart'  hide SearchBar;

import 'package:kwotmusic/components/widgets/bottomsheet/material_bottom_sheet.dart';
import 'package:provider/provider.dart';

import 'comment_bottom_sheet.dart';
import 'comments_bottom_sheet_model.dart';

class OpenCommentBottomSheet extends StatefulWidget {
  //=
  static Future<bool?> show(
    BuildContext context,
  ) {
    return showMaterialBottomSheet<bool>(
      context,
      expand: false,
      builder: (_, __) => OpenCommentBottomSheet(),
    );
  }

  OpenCommentBottomSheet({
    Key? key,
  }) : super(key: key);

  @override
  State<OpenCommentBottomSheet> createState() => _OpenCommentBottomSheetState();
}

class _OpenCommentBottomSheetState extends State<OpenCommentBottomSheet> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CommentsModel(),
      child: CommentBottomSheetLiveShow(),
    );
  }
}
