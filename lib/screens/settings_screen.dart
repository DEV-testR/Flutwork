import 'package:flutter/material.dart';

import '../constants/style_constants.dart';
import '../widgets/header.dart';
import '../widgets/sub_header.dart';

class SettingsScreen extends StatelessWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;
  const SettingsScreen({super.key, required this.scaffoldKey});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: SingleChildScrollView(
          primary: false,
          padding: EdgeInsets.all(defaultPadding),
          child: Column(
            children: [
              Header(title: "Settings", scaffoldKey: scaffoldKey,),
              SizedBox(height: defaultPadding),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 5,
                    child: Column(
                      children: [
                        SubHeader(subtitle : 'Settings'),
                      ],
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
