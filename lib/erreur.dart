import 'package:flutter/material.dart';

class ErrorDialog extends StatelessWidget
{
  final String? message;
  ErrorDialog({this.message});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      key: key,
      content: Text(message!),
      actions: [
        ElevatedButton(
          child: const Center(
            child: Text("OK"),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Color.fromARGB(255, 91, 6, 0),
          ),
          onPressed: ()
          {
            Navigator.pop(context);
          },
        ),
      ],
    );
  }
}
