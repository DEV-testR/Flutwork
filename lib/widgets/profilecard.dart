import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../constants/style_constants.dart';
import '../responsive.dart';
import '../providers/auth_provider.dart';
import '../screens/sign_in_screen.dart';

class ProfileCard extends StatelessWidget {
  const ProfileCard({super.key});

  // ปรับค่า Offset ให้ใกล้เคียง 0 หรือบวกเล็กน้อย
  // เพื่อให้เมนูอยู่กึ่งกลางหรือเยื้องไปทางขวาใต้ปุ่มโปรไฟล์
  // ลองใช้ค่า 15.0 หรือ 20.0 เป็นจุดเริ่มต้น
  static const double _offsetX = 15.0; // เลื่อนเมนูไปทางขวา 15 หน่วย

  @override
  Widget build(BuildContext context) {
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

      // ใช้ PopupMenuButton ครอบ Row
      child: PopupMenuButton<String>(

        // **1. ปรับ Offset** ให้เป็นค่าบวกเล็กน้อย เพื่อให้เมนูวางตัวใต้ปุ่มอย่างสวยงาม
        offset: const Offset(_offsetX, 55),

        // **2. เปลี่ยนสีเมนู** เป็นสีพื้นหลังที่สว่าง (cardColor)
        color: secondaryColor,

        // **ส่วนที่แก้ไข/เพิ่มเติม: ใช้ shape เพื่อกำหนด borderRadius**
        shape: RoundedRectangleBorder(
          // ใช้ค่า Radius เดียวกับ Container (10)
          borderRadius: const BorderRadius.all(Radius.circular(10)),
          // คุณอาจเพิ่มเส้นขอบเพื่อให้เมนูดูโดดเด่นขึ้นได้
          // side: const BorderSide(color: Colors.white10),
        ),

        onSelected: (value) async {
          if (value == 'logout') {
            final authProvider =
            Provider.of<AuthProvider>(context, listen: false);

            await authProvider.logout();

            if (context.mounted) {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => SignInScreen()),
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
                Text("Logout", style: TextStyle(color: Colors.redAccent)),
              ],
            ),
          ),
        ],

        child: Row(
          children: [
            ClipOval(
              child: Image.asset(
                "assets/images/profile_pic.png",
                height: 38,
                width: 38, // เพิ่ม width ให้เท่ากับ height เพื่อให้รูปเป็นวงกลมสมบูรณ์
                fit: BoxFit.cover, // ให้รูปภาพเติมเต็มพื้นที่วงกลม
              ),
            ),
            if (!Responsive.isMobile(context))
              Padding(
                padding: EdgeInsets.symmetric(horizontal: defaultPadding / 2),
                child: Text(
                  "Angelina Jolie",
                  style: TextStyle(color: defaultTextColor),
                ),
              ),
            const SizedBox(width: 5), // เพิ่มช่องว่าง 10 หน่วย (หรือปรับค่าตามต้องการ)
            Icon(Icons.keyboard_arrow_down, color: defaultTextColor),
          ],
        ),
      ),
    );
  }
}