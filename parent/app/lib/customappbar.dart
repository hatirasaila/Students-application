
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {




  @override
  Size get preferredSize => Size.fromHeight(100);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          height: 1000,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/icons/appBar.png"),
              fit: BoxFit.cover,
            ),
          ),
        ),
        AppBar(
  automaticallyImplyLeading: false,
          backgroundColor: Colors.transparent,
          elevation: 0,
          toolbarHeight: preferredSize.height,
          titleSpacing: 0,
  
        ),
      ],
    );
  }
}
