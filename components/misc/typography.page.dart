import 'package:flutter/material.dart'  hide SearchBar;
import 'package:kwotmusic/components/kit/kit.dart';
import 'package:kwotmusic/components/widgets/animation/sonar_animated_widget.dart';
import 'package:kwotmusic/components/widgets/blocking_progress.dialog.dart';
import 'package:kwotmusic/components/widgets/filter/filter_chip.widget.dart';
import 'package:kwotmusic/components/widgets/indexed_page_indicator.dart';
import 'package:kwotmusic/components/widgets/notificationbar/notification_bar.dart';
import 'package:kwotmusic/components/widgets/segmented_control_tabs.widget.dart';
import 'package:kwotmusic/components/widgets/textfield.dart';
import 'package:kwotmusic/components/widgets/toggle_chip.dart';
import 'package:kwotmusic/components/widgets/toggle_switch.dart';

import '../widgets/button.dart';

class TypographyPage extends StatefulWidget {
  const TypographyPage({Key? key}) : super(key: key);

  @override
  State<TypographyPage> createState() => _TypographyPageState();
}

class _TypographyPageState extends State<TypographyPage> {
  bool isPasswordVisibilityOn = false;
  bool isToggleSwitchChecked = false;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return SafeArea(
        child: Scaffold(
            body: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Container(
                    width: size.width,
                    padding: EdgeInsets.all(ComponentInset.normal.r),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ...iconButtons(),
                        ...textFields(),
                        ...buttons(),
                        ...textStyles(),
                        ...otherWidgets(),
                      ],
                    )))));
  }

  List<Widget> iconButtons() {
    return [
      SizedBox(height: ComponentInset.larger.h),
      ScrollConfiguration(
        behavior: const ScrollBehavior().copyWith(overscroll: false),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            for (int index = 1; index <= 3; index++)
              AppIconButton(
                  width: ComponentSize.normal.h * index,
                  height: ComponentSize.normal.h * index,
                  assetPath: Assets.graphicInstagram,
                  borderRadius: BorderRadius.circular(ComponentRadius.normal.r),
                  margin: EdgeInsets.only(right: ComponentInset.normal.w),
                  onPressed: () {}),
          ]),
        ),
      )
    ];
  }

  List<Widget> textFields() {
    final passwordController = TextEditingController();
    passwordController.text = "SomePassw0rd";

    return [
      SizedBox(height: ComponentInset.larger.h),
      TextInputField(
        controller: TextEditingController(),
        hintText: "Default Hint",
        labelText: "Default Label",
      ),
      SizedBox(height: ComponentInset.normal.h),
      TextInputField(
          controller: passwordController,
          hintText: "Password Hint + Icon",
          labelText: "Password Label + Icon",
          isPassword: !isPasswordVisibilityOn,
          suffixes: [
            PasswordVisibilityToggleSuffix(
                isPasswordVisible: isPasswordVisibilityOn,
                onPressed: () {
                  setState(() {
                    isPasswordVisibilityOn = !isPasswordVisibilityOn;
                  });
                }),
          ]),
      SizedBox(height: ComponentInset.normal.h),
      TextInputField(
        controller: TextEditingController(),
        hintText: "Disabled Hint",
        labelText: "Disabled Label",
        enabled: false,
      ),
      SizedBox(height: ComponentInset.normal.h),
      TextInputField(
        controller: TextEditingController(),
        hintText: "Error Hint",
        labelText: "Error Label",
        errorText: "Something is wrong",
      ),
      SizedBox(height: ComponentInset.normal.h),
      TextInputField(
          height: ComponentSize.large.h,
          controller: TextEditingController(),
          hintText: "Large Hint",
          labelText: "Large Label"),
    ];
  }

  List<Widget> buttons() {
    return [
      SizedBox(height: ComponentInset.larger.h),
      Button(
          margin: EdgeInsets.all(ComponentInset.small.r),
          text: "button.primary",
          padding: EdgeInsets.symmetric(horizontal: ComponentInset.normal.w),
          onPressed: () => {}),
      Button(
          enabled: false,
          margin: EdgeInsets.all(ComponentInset.small.r),
          text: "button.primary + disabled",
          padding: EdgeInsets.symmetric(horizontal: ComponentInset.normal.w),
          onPressed: () => {}),
      Button(
          type: ButtonType.secondary,
          margin: EdgeInsets.all(ComponentInset.small.r),
          text: "button.secondary",
          padding: EdgeInsets.symmetric(horizontal: ComponentInset.normal.w),
          onPressed: () => {}),
      Button(
          type: ButtonType.secondary,
          margin: EdgeInsets.all(ComponentInset.small.r),
          text: "button.secondary + disabled",
          padding: EdgeInsets.symmetric(horizontal: ComponentInset.normal.w),
          enabled: false,
          onPressed: () => {}),
      Button(
          type: ButtonType.text,
          margin: EdgeInsets.all(ComponentInset.small.r),
          text: "button.text",
          padding: EdgeInsets.symmetric(horizontal: ComponentInset.normal.w),
          onPressed: () => {}),
      Button(
          type: ButtonType.text,
          margin: EdgeInsets.all(ComponentInset.small.r),
          text: "button.text + disabled",
          padding: EdgeInsets.symmetric(horizontal: ComponentInset.normal.w),
          enabled: false,
          onPressed: () => {}),
      Button(
          type: ButtonType.error,
          margin: EdgeInsets.all(ComponentInset.small.r),
          text: "button.error",
          padding: EdgeInsets.symmetric(horizontal: ComponentInset.normal.w),
          onPressed: () => {}),
      Button(
          type: ButtonType.error,
          margin: EdgeInsets.all(ComponentInset.small.r),
          text: "button.error + disabled",
          padding: EdgeInsets.symmetric(horizontal: ComponentInset.normal.w),
          enabled: false,
          onPressed: () => {}),
      Button(
        width: 0.5.sw,
        height: ComponentSize.small.h,
        margin: EdgeInsets.all(ComponentInset.small.r),
        text: "Small Button",
        padding: EdgeInsets.symmetric(horizontal: ComponentInset.normal.w),
        onPressed: () => {},
      ),
      Button(
        width: 0.7.sw,
        height: ComponentSize.large.h,
        margin: EdgeInsets.all(ComponentInset.small.r),
        text: "Large Button",
        padding: EdgeInsets.symmetric(horizontal: ComponentInset.normal.w),
        onPressed: () => {},
      ),
      SizedBox(height: ComponentInset.normal.h),
      AppIconTextButton(
          color: DynamicTheme.get(context).neutral10(),
          height: ComponentSize.smaller.h,
          iconPath: Assets.iconResetMedium,
          text: "Button",
          onPressed: () => {})
    ];
  }

  List<Widget> textStyles() {
    return [
      //= TEXT BOLD
      SizedBox(height: ComponentInset.larger.h),
      Text("Bold Heading 1", style: TextStyles.boldHeading1),
      Text("Bold Heading 2", style: TextStyles.boldHeading2),
      Text("Bold Heading 3", style: TextStyles.boldHeading3),
      Text("Bold Heading 4", style: TextStyles.boldHeading4),
      Text("Bold Heading 5", style: TextStyles.boldHeading5),
      Text("Bold Heading 6", style: TextStyles.boldHeading6),
      Text("Bold Body", style: TextStyles.boldBody),
      Text("Bold Caption", style: TextStyles.boldCaption),
      //= TEXT REGULAR
      SizedBox(height: ComponentInset.larger.h),
      Text("Regular Heading 1", style: TextStyles.heading1),
      Text("Regular Heading 2", style: TextStyles.heading2),
      Text("Regular Heading 3", style: TextStyles.heading3),
      Text("Regular Heading 4", style: TextStyles.heading4),
      Text("Regular Heading 5", style: TextStyles.heading5),
      Text("Regular Heading 6", style: TextStyles.heading6),
      Text("Body", style: TextStyles.body),
      Text("Caption", style: TextStyles.caption),
      //= TEXT LIGHT
      SizedBox(height: ComponentInset.larger.h),
      Text("Light Heading 1", style: TextStyles.lightHeading1),
      Text("Light Heading 2", style: TextStyles.lightHeading2),
      Text("Light Heading 3", style: TextStyles.lightHeading3),
      Text("Light Heading 4", style: TextStyles.lightHeading4),
      Text("Light Heading 5", style: TextStyles.lightHeading5),
      Text("Light Heading 6", style: TextStyles.lightHeading6),
      Text("Light Body", style: TextStyles.lightBody),
      Text("Light Caption", style: TextStyles.lightCaption),
    ];
  }

  List<Widget> otherWidgets() {
    return [
      //= Notification Bar Button
      SizedBox(height: ComponentInset.larger.h),
      Button(
          margin: EdgeInsets.all(ComponentInset.small.r),
          text: "Tap to show Notification Bar",
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: ComponentInset.normal.w),
          onPressed: () {
            showDefaultNotificationBar(NotificationBarInfo.success(
              title: "Success notification with title!",
              message:
                  "A success notification can have a message of at most 6 lines, and look it has a title as well!",
              actionText: "Action Button",
              actionCallback: (context) {},
            ));
          }),

      //= TOGGLE SWITCHES
      SizedBox(height: ComponentInset.larger.h),
      Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
        ToggleSwitch(
            height: ComponentSize.small.h,
            checked: isToggleSwitchChecked,
            enabled: true,
            onChanged: (checked) {
              setState(() {
                isToggleSwitchChecked = checked;
              });
            }),
        ToggleSwitch(
            height: ComponentSize.smaller.h,
            checked: isToggleSwitchChecked,
            enabled: false,
            onChanged: (checked) {
              setState(() {
                isToggleSwitchChecked = checked;
              });
            }),
        ToggleSwitch(
            height: ComponentSize.smallest.h,
            checked: isToggleSwitchChecked,
            enabled: false,
            onChanged: (checked) {
              setState(() {
                isToggleSwitchChecked = checked;
              });
            }),
      ]),

      //= SEGMENTED CONTROL
      SizedBox(height: ComponentInset.larger.h),
      SegmentedControlTabsWidget<String>(
        height: ComponentSize.normal.h,
        items: const ["Ice", "Fire", "Earth", "Wind"],
        itemTitle: (item) => item,
        onChanged: (item) {},
        selectedItemIndex: 0,
      ),

      //= CHIPS
      SizedBox(height: ComponentInset.larger.h),
      Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
        ToggleChip(
            item: ChipItem(identifier: "1", text: "Chip", selected: false),
            onPressed: (item) {}),
        ToggleChip(
            item: ChipItem(
                identifier: "2",
                text: "Chip",
                size: ChipSize.small,
                selected: true),
            onPressed: (item) {}),
        FilterChipWidget(
            title: "Filter Chip",
            iconPath: Assets.iconCrossBold,
            onIconTap: () {})
      ]),

      //= INDICATOR
      SizedBox(height: ComponentInset.larger.h),
      Center(
          child: IndexedPageIndicator(
        count: 3,
        size: 12.h,
        selectedIndex: 0,
        onPressed: (index) {},
      )),

      //= PIN INPUT
      SizedBox(height: ComponentInset.larger.h),
      Divider(color: DynamicTheme.get(context).secondary100()),
      Text("OTP / Pin Entry Field", style: TextStyles.heading5),
      SizedBox(height: ComponentInset.small.h),
      PinInputField(
          height: ComponentSize.large.h,
          pinLength: 6,
          controller: TextEditingController()),

      //= BLOCKING PROGRESS
      SizedBox(height: ComponentInset.normal.h),
      Divider(color: DynamicTheme.get(context).secondary100()),
      Text("Blocking Progress", style: TextStyles.heading5),
      SizedBox(height: ComponentInset.small.h),
      const BlockingProgressDialog(isDismissible: true),

      //= SONAR ANIMATION
      SizedBox(height: ComponentInset.normal.h),
      Divider(color: DynamicTheme.get(context).secondary100()),
      Text("Sonar Animation", style: TextStyles.heading5),
      SizedBox(height: ComponentInset.small.h),
      Sonar(
          duration: const Duration(seconds: 4),
          size: 180.r,
          waveColor: Colors.blue,
          waveStrokeWidth: 3.r,
          child: Container(
              width: 40.r,
              height: 40.r,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ))),
    ];
  }
}
