import 'package:cognito/utils/colors.dart';
import 'package:cognito/utils/design.dart';
import 'package:cognito/widgets/welcome_message.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {},
          icon: const Icon(Iconsax.arrow_left_2, color: AppColor.iconColor),
        ),
        automaticallyImplyLeading: true,
        actions: [
          Container(
            decoration: BoxDecoration(
                color: AppColor.iconBackgroundColor,
                borderRadius: BorderRadius.circular(20)),
            child: IconButton(
                onPressed: () {},
                icon: const Icon(
                  Iconsax.user,
                  color: AppColor.iconColor,
                )),
          ),
          const SizedBox(
            width: 10,
          )
        ],
        forceMaterialTransparency: true,
        elevation: 0,
      ),
      body: Container(
        height: height,
        width: width,
        color: AppColor.backgroundColor,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(
              height: 100,
            ),
            Divider(
              thickness: 0.25,
              color: AppColor.primaryTextColor,
            ),
            WelcomeMessage(),
            Divider(
              thickness: 0.25,
              color: AppColor.primaryTextColor,
            ),
            SizedBox(
              height: 100,
            ),
            Expanded(
                child: Container(
              child: ListView.builder(
                padding: EdgeInsets.all(20),
                itemCount: 10,
                scrollDirection: Axis.horizontal,
                itemBuilder: (context, index) {
                  return Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          SquareBoxDesign(
                            text: "Hello",
                          ),
                          SquareBoxDesign(
                            text: "Hello",
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Row(
                        children: [
                          SquareBoxDesign(
                            text: "Hello",
                          ),
                          SquareBoxDesign(
                            text: "Hello",
                          ),
                        ],
                      )
                    ],
                  );
                },
              ),
            )),
            Container(
              decoration: BoxDecoration(
                color: AppColor.appBarColor,
                boxShadow: [
                  BoxShadow(
                      color: AppColor.secondaryTextColor,
                      blurRadius: 10,
                      spreadRadius: 1)
                ],
                border: Border.all(
                  color: AppColor.borderColor,
                ),
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20)),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      width: 100,
                      child: Row(
                        children: [
                          IconButton(
                              onPressed: () {},
                              icon: const Icon(
                                Iconsax.folder_add5,
                                color: AppColor.iconColor,
                              )),
                          IconButton(
                              onPressed: () {},
                              icon: const Icon(Iconsax.microphone5,
                                  color: AppColor.iconColor)),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Container(
                        height: 50,
                        margin: EdgeInsets.symmetric(vertical: 5),
                        padding: EdgeInsets.symmetric(horizontal: 5),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all()),
                        child: TextFormField(
                          decoration: InputDecoration(
                              border: InputBorder.none,
                              hintStyle: TextStyle(color: AppColor.hintColor),
                              hintText: "Message cognito.."),
                        ),
                      ),
                    ),
                    IconButton(
                        onPressed: () {},
                        icon: const Icon(Iconsax.send_15,
                            color: AppColor.iconColor))
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
