import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import '../../../constants/style_constants.dart';
import '../../../controllers/menu_app_controller.dart';

class SideMenu extends StatelessWidget {
  const SideMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: bgColor,
      child: ListView(
        children: [
          DrawerListTile(
            title: "Dashboard",
            svgSrc: "assets/icons/menu_dashboard.svg",
            index: 0,
          ),
          DrawerListTile(
            title: "AI Chat",
            svgSrc: "assets/icons/menu_dashboard.svg",
            index: 1,
          ),
          DrawerListTile(
            title: "Profile",
            svgSrc: "assets/icons/menu_tran.svg",
            index: 2,
          ),
          DrawerListTile(
            title: "Settings",
            svgSrc: "assets/icons/menu_setting.svg",
            index: 3,
          ),
        ],
      ),
    );
  }
}

class DrawerListTile extends StatelessWidget {
  final String title, svgSrc;
  final int index;

  const DrawerListTile({
    super.key,
    required this.title,
    required this.svgSrc,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final menuController = context.read<MenuAppController>();

    return ListTile(
      onTap: () {
        menuController.selectMenu(index);       // เปลี่ยนหน้า
        Navigator.of(context).pop();            // ปิด Drawer
      },
      leading: SvgPicture.asset(svgSrc, height: 16),
      title: Text(title),
    );
  }
}
