import 'package:flutter/material.dart';

class usableButton extends StatelessWidget {
  usableButton(
      {required this.selectedcolor,
      required this.selectedText,
      required this.onTap});
  final Color selectedcolor;
  final String selectedText;
  final Function() onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 16.0),
      child: Material(
        elevation: 5.0,
        color: selectedcolor,
        borderRadius: BorderRadius.circular(30.0),
        child: MaterialButton(
          onPressed: onTap,
          minWidth: 200.0,
          height: 42.0,
          child: Text(
            selectedText,
          ),
        ),
      ),
    );
  }
}
