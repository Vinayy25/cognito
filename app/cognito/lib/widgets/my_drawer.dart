import 'package:cognito/utils/colors.dart';
import 'package:cognito/utils/text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class MyDrawer extends StatelessWidget {
  const MyDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
            child: Container(
          child: ListTileTheme(
            textColor: AppColor.primaryTextColor,
            iconColor: AppColor.iconBackgroundColor,
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                Hero(
                  tag: "profile",
                  child: Container(
                      width: 128.0,
                      height: 128.0,
                      margin: const EdgeInsets.only(
                        top: 24.0,
                        bottom: 64.0,
                      ),
                      clipBehavior: Clip.antiAlias,
                      decoration: const BoxDecoration(
                        color: AppColor.backgroundColor,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Iconsax.user,
                        color: AppColor.iconBackgroundColor,
                        size: 30,
                      )),
                ),
                ListTile(
                    onTap: () {},
                    title: const AppText(
                      text: 'New conversation',
                      color: AppColor.primaryTextColor,
                    ),
                    leading: const Icon(
                      Iconsax.additem,
                      color: AppColor.iconColor,
                    )),
                const Divider(
                  thickness: 0.25,
                  color: AppColor.primaryTextColor,
                ),
                ListTile(
                    onTap: () {},
                    title: const AppText(
                      text: 'Conversation History',
                      color: AppColor.primaryTextColor,
                    ),
                    leading: const Icon(
                      Iconsax.book_saved4,
                      color: AppColor.iconColor,
                    )),
                const Divider(
                  thickness: 0.25,
                  color: AppColor.primaryTextColor,
                ),
                ListTile(
                  onTap: () {},
                  leading: const Icon(
                    Iconsax.home,
                    color: AppColor.iconColor,
                  ),
                  title: const AppText(
                    text: 'Home',
                    color: AppColor.primaryTextColor,
                  ),
                ),
                const Divider(
                  thickness: 0.25,
                  color: AppColor.primaryTextColor,
                ),
                ListTile(
                  onTap: () {},
                  leading: const Icon(
                    Iconsax.user,
                    color: AppColor.iconColor,
                  ),
                  title: const AppText(
                    text: 'Profile',
                    color: AppColor.primaryTextColor,
                  ),
                ),
                const Divider(
                  thickness: 0.25,
                  color: AppColor.primaryTextColor,
                ),
                ListTile(
                  onTap: () {},
                  leading: const Icon(
                    Iconsax.setting,
                    color: AppColor.iconColor,
                  ),
                  title: const AppText(
                    text: 'Settings',
                    color: AppColor.primaryTextColor,
                  ),
                ),
                const Spacer(),
                DefaultTextStyle(
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.white54,
                  ),
                  child: Container(
                    margin: const EdgeInsets.symmetric(
                      vertical: 16.0,
                    ),
                    child: const AppText(
                      text: 'Terms of Service | Privacy Policy',
                      fontsize: 12,
                      color: AppColor.secondaryTextColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ));
  }
}