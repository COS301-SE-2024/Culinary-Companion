import 'package:flutter/material.dart';

class MethodItem extends StatelessWidget {
  final String method;

  MethodItem({required this.method});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(method),
    );
  }
}