import 'package:flutter/material.dart';
import 'package:flutwork/screens/dashboard/components/my_files.dart';

import '../../constants/style_constants.dart';
import '../../models/user.dart';
import '../../responsive.dart';
import '../../widgets/header.dart';
import '../../widgets/sub_header.dart';
import 'components/recent_files.dart';
import 'components/storage_details.dart';

class DashboardScreen extends StatelessWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;
  final User user;

  const DashboardScreen({
    super.key,
    required this.scaffoldKey,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    // Content only: [MainScreen] already owns the [Scaffold]. Nested scaffolds can
    // leave the parent FAB layer unlaid-out while still receiving hit tests.
    return SingleChildScrollView(
      primary: false,
      padding: EdgeInsets.all(defaultPadding),
      child: Column(
        children: [
          Header(
            title: 'Dashboard',
            scaffoldKey: scaffoldKey,
          ),
          SizedBox(height: defaultPadding),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 5,
                child: Column(
                  children: [
                    SubHeader(subtitle: 'Dashboard ${user.fullName}'),
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
              if (!Responsive.isMobile(context))
                Expanded(
                  flex: 2,
                  child: StorageDetails(),
                ),
            ],
          )
        ],
      ),
    );
  }
}
