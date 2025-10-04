import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CommonTextField extends StatefulWidget {
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final String? hintText;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final bool obscureText;
  final bool enabled;
  final int maxLength;
  final int? maxLines;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final FormFieldValidator<String>? validator;
  final TextInputFormatter? inputFormatter;

  const CommonTextField({
    Key? key,
    this.controller,
    this.focusNode,
    this.hintText,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.done,
    this.obscureText = false,
    this.enabled = true,
    this.maxLength = 50,
    this.maxLines,
    this.prefixIcon,
    this.suffixIcon,
    this.onChanged,
    this.onSubmitted,
    this.validator,
    this.inputFormatter,
  }) : super(key: key);

  @override
  _CommonTextFieldState createState() => _CommonTextFieldState();
}
class _CommonTextFieldState extends State<CommonTextField> {
  late TextEditingController _controller;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _focusNode = widget.focusNode ?? FocusNode();
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: _controller,
      focusNode: _focusNode,
      decoration: InputDecoration(
        hintText: widget.hintText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14)
        ),
        prefixIcon: widget.prefixIcon,
        suffixIcon: widget.suffixIcon,
        counterText: '',
      ),
      keyboardType: widget.keyboardType,
      textInputAction: widget.textInputAction,
      obscureText: widget.obscureText,
      enabled: widget.enabled,
      maxLength: widget.maxLength,
      maxLines: widget.maxLines,
      onChanged: widget.onChanged,
      onFieldSubmitted: widget.onSubmitted,
      validator: widget.validator,
      inputFormatters: widget.inputFormatter != null ? [widget.inputFormatter!] : null,
    );
  }
}

