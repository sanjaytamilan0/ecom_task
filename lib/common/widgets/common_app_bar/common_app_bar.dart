import 'package:ecom_task/common/app_colors/app_colors.dart';
import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showLeading;
  final Color? backgroundColor;
  final List<Widget>? actions;
  final Widget? leading;

  const CustomAppBar({
    Key? key,
    required this.title,
    this.showLeading = true,
    this.backgroundColor,
    this.actions,
    this.leading,
  })  :   super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(color: Colors.white),
      ),
      elevation: 0,
      backgroundColor: backgroundColor ?? AppColor().primaryColor,
      leading: showLeading
          ? (leading ??
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.of(context).maybePop(),
          ))
          : null,
      actions: actions,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
