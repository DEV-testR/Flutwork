import 'package:flutter/material.dart';
import 'package:flutwork/screens/dashboard/components/my_files.dart';

import '../../constants/style_constants.dart';
import '../../responsive.dart';
import '../../widgets/sub_header.dart';
import '../../widgets/header.dart';

import 'components/recent_files.dart';
import 'components/storage_details.dart';

class DashboardScreen extends StatelessWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;
  const DashboardScreen({super.key, required this.scaffoldKey});

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
                Header(
                  title: 'Dashboard',
                  scaffoldKey: scaffoldKey, // ส่ง key เข้าไป
                ),
                SizedBox(height: defaultPadding),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 5,
                      child: Column(
                        children: [
                          SubHeader(subtitle: 'Dashboard'),
                          MyFiles(),
                          SizedBox(height: defaultPadding),
                          RecentFiles(),
                          if (Responsive.isMobile(context))
                            SizedBox(height: defaultPadding),
                          if (Responsive.isMobile(context)) StorageDetails(),
                        ],
                      ),
                    ),
                    if (!Responsive.isMobile(context))
                      SizedBox(width: defaultPadding),
                    // On Mobile means if the screen is less than 850 we don't want to show it
                    if (!Responsive.isMobile(context))
                      Expanded(
                        flex: 2,
                        child: StorageDetails(),
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
