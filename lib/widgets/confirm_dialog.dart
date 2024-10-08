import 'package:flutter/material.dart';

class ConfirmationDialog extends StatelessWidget {
  final String title;
  final String content;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;
  final bool initialDontShowAgain;
  final Function(bool) onDontShowAgainChanged;

  const ConfirmationDialog({
    required this.title,
    required this.content,
    required this.onConfirm,
    required this.onCancel,
    required this.initialDontShowAgain,
    required this.onDontShowAgainChanged,
  });

  @override
  Widget build(BuildContext context) {
    bool localDontShowAgain = initialDontShowAgain;

    return StatefulBuilder(
      builder: (BuildContext context, StateSetter setState) {
        return AlertDialog(
          title: Text(title),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Checkbox(
                    value: localDontShowAgain,
                    onChanged: (bool? value) {
                     //if (mounted) {
                      setState(() {
                        localDontShowAgain = value ?? false;
                        onDontShowAgainChanged(localDontShowAgain);
                      }); //}
                    },
                  ),
                  Text("Don't show again"),
                ],
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: onCancel,
              child: Text('No'),
            ),
            TextButton(
              onPressed: onConfirm,
              child: Text('Yes'),
            ),
          ],
        );
      },
    );
  }
}
