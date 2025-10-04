import 'package:ecom_task/common/app_colors/app_colors.dart';
import 'package:flutter/material.dart';

Widget commonCustomAppBar(
    BuildContext context,String ScreenName, VoidCallback onPressed,{Color? bgColor,
      bool? searchIcon = false,
      void Function()? searchIconTap,
      bool? arrowHide = false
    }) {
  return ClipPath(
    clipper: BottomCornerClipper(),
    child: Container(
      height: MediaQuery.of(context).size.height * 0.13,
      decoration: BoxDecoration(
        color:bgColor  ?? AppColor().primaryColor,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child:  Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(height:1,),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    if(arrowHide ==  true) SizedBox()
                    else
                      IconButton(
                      icon:  const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: onPressed,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      ScreenName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 21,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                  ],
                ),
              ),
              if(searchIcon == true) GestureDetector(
                onTap: searchIconTap ?? (){},
                child: Container(
                  margin: const EdgeInsets.only(right: 20),
                  height: 20,
                  width: 20,
                  child: Image.asset("assets/icons/search.png"),
                ),
              )


            ],
          ),
        ],
      ),
    ),
  );
}

class BottomCornerClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    const double carveRadius = 40;

    Path path = Path();
    path.moveTo(0, 0);
    path.lineTo(0, size.height - carveRadius);

    path.quadraticBezierTo(
      0,
      size.height,
      carveRadius,
      size.height,
    );

    path.lineTo(size.width - carveRadius, size.height);

    path.quadraticBezierTo(
      size.width,
      size.height,
      size.width,
      size.height - carveRadius,
    );

    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}


