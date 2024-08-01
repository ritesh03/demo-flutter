import 'package:flutter/material.dart'  hide SearchBar;
import 'package:kwotmusic/components/kit/kit.dart';
import 'package:kwotmusic/components/widgets/button.dart';
import 'package:kwotmusic/components/widgets/sliverheader/sliver_header.dart';
import 'package:kwotmusic/core.dart';

class SliverHeaderSamplePage extends StatefulWidget {
  const SliverHeaderSamplePage({Key? key}) : super(key: key);

  @override
  State<SliverHeaderSamplePage> createState() => _SliverHeaderSamplePageState();
}

class _SliverHeaderSamplePageState extends State<SliverHeaderSamplePage> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
        top: false,
        child: Scaffold(
          body: CustomScrollView(slivers: [
            _buildSliverHeader(),
            _buildSliverList(),
          ]),
        ));
  }

  Widget _buildSliverHeader() {
    return SliverPersistentHeader(
        pinned: true,
        delegate: BasicSliverHeaderDelegate(
          context,
          toolbarHeight: 48.h,
          expandedHeight: 96.h,
          topBar: Row(children: [
            AppIconButton(
                width: ComponentSize.large.r,
                height: ComponentSize.large.r,
                assetColor: DynamicTheme.get(context).neutral20(),
                assetPath: Assets.iconArrowLeft,
                padding: EdgeInsets.all(ComponentInset.small.r),
                onPressed: () => DashboardNavigation.pop(context)),
          ]),
          horizontalTitlePadding: ComponentInset.normal.w,
          title: Text("hmmmmmmmmmmmmmmmmmm hm", style: TextStyles.boldHeading3),
        ));
  }

  Widget _buildSliverList() {
    return SliverList(delegate: SliverChildBuilderDelegate((_, index) {
      return Container(
        color: Colors.deepOrangeAccent,
        height: 60,
        margin: const EdgeInsets.all(16),
      );
    }));
  }
}
