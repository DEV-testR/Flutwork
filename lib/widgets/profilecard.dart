import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../constants/style_constants.dart';
import '../responsive.dart';
import '../providers/auth_provider.dart';
import '../providers/user_provider.dart';
import '../screens/sign_in_screen.dart';

class ProfileCard extends StatelessWidget {
  const ProfileCard({super.key});

  static const double _offsetX = 15.0;

  @override
  Widget build(BuildContext context) {
    final displayName = context.select<UserProvider, String>(
      (p) {
        final name = p.currentUser?.fullName.trim();
        if (name != null && name.isNotEmpty) return name;
        return 'User';
      },
    );

    return Container(
      margin: EdgeInsets.only(left: defaultPadding),
      padding: EdgeInsets.symmetric(
        horizontal: defaultPadding,
        vertical: defaultPadding / 2,
      ),
      decoration: BoxDecoration(
        color: secondaryColor,
        borderRadius: const BorderRadius.all(Radius.circular(10)),
        border: Border.all(color: Colors.white10),
      ),
      child: PopupMenuButton<String>(
        offset: const Offset(_offsetX, 55),
        color: secondaryColor,
        shape: RoundedRectangleBorder(
          borderRadius: const BorderRadius.all(Radius.circular(10)),
        ),
        onSelected: (value) async {
          if (value == 'logout') {
            final authProvider =
                Provider.of<AuthProvider>(context, listen: false);
            final userProvider =
                Provider.of<UserProvider>(context, listen: false);

            userProvider.clearUser();
            await authProvider.logout();

            if (context.mounted) {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const SignInScreen()),
                (route) => false,
              );
            }
          }
        },
        itemBuilder: (context) => [
          PopupMenuItem<String>(
            value: 'logout',
            height: 35,
            child: Row(
              children: [
                Icon(Icons.logout, color: Colors.redAccent, size: 20),
                const SizedBox(width: 10),
                Text('Logout', style: TextStyle(color: Colors.redAccent)),
              ],
            ),
          ),
        ],
        child: Row(
          children: [
            ClipOval(
              child: Image.asset(
                'assets/images/profile_pic.png',
                height: 38,
                width: 38,
                fit: BoxFit.cover,
              ),
            ),
            if (!Responsive.isMobile(context))
              Padding(
                padding: EdgeInsets.symmetric(horizontal: defaultPadding / 2),
                child: Text(
                  displayName,
                  style: TextStyle(color: defaultTextColor),
                ),
              ),
            const SizedBox(width: 5),
            Icon(Icons.keyboard_arrow_down, color: defaultTextColor),
          ],
        ),
      ),
    );
  }
}
