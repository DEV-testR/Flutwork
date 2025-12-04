import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutwork/widgets/profilecard.dart';

import '../constants/style_constants.dart';
import '../responsive.dart';

class Header extends StatelessWidget {
  final String title;
  final GlobalKey<ScaffoldState> scaffoldKey; // เพิ่ม

  const Header({
    super.key,
    required this.title,
    required this.scaffoldKey, // เพิ่ม
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (!Responsive.isDesktop(context))
          IconButton(
            icon: Icon(Icons.menu),
            onPressed: () {
              scaffoldKey.currentState?.openDrawer(); // เปิด Drawer
            },
          ),
        if (!Responsive.isMobile(context))
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge,
          ),
        if (!Responsive.isMobile(context))
          Spacer(flex: Responsive.isDesktop(context) ? 2 : 1),
        /*Expanded(child: SearchField()),*/
        // Spacer นี้จะทำหน้าที่ผลัก ProfileCard ไปสุดขอบขวา
        const Spacer(),
        ProfileCard()
      ],
    );
  }
}



class SearchField extends StatelessWidget {
  const SearchField({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      decoration: InputDecoration(
        hintText: "Search",
        fillColor: secondaryColor,
        filled: true,
        border: OutlineInputBorder(
          borderSide: BorderSide.none,
          borderRadius: const BorderRadius.all(Radius.circular(10)),
        ),
        suffixIcon: InkWell(
          onTap: () {},
          child: Container(
            padding: EdgeInsets.all(defaultPadding * 0.75),
            margin: EdgeInsets.symmetric(horizontal: defaultPadding / 2),
            decoration: BoxDecoration(
              color: primaryColor,
              borderRadius: const BorderRadius.all(Radius.circular(10)),
            ),
            child: SvgPicture.asset("assets/icons/Search.svg"),
          ),
        ),
      ),
    );
  }
}
