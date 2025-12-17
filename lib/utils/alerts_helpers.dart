import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AlertsHelpers {
  /* static showSnackbar(BuildContext ctx, String text,
      {String title = "Error",
      IconData icon = null,
      int duration = 1,
      FlushbarPosition position = FlushbarPosition.BOTTOM,
      Function onTap}) {
    if (icon == null) {
      icon = Icons.info;
    }
    Flushbar(
      margin: EdgeInsets.all(8),
      borderRadius: BorderRadius.circular(8),
      duration: Duration(seconds: duration),
      title: title,
      flushbarPosition: position,
      message: text,
      onTap: (bar) {
        if (onTap != null) onTap();
      },
      icon: Icon(
        icon,
        color: Colors.white,
      ),
    ).show(ctx);
  }

  static showErrorSnackbar(BuildContext ctx,
      {NetworkException nException,
      Exception exception,
      FlushbarPosition position = FlushbarPosition.BOTTOM}) {
    var title = "Error";
    var text = "Wow, an unexpected error happened";
    if (exception != null) {
      text = exception.toString();
    } else if (nException != null) {
      text = ExceptionsHelpers.getExceptionMessage(nException);
    }
    Flushbar(
      margin: EdgeInsets.all(8),
      borderRadius: BorderRadius.circular(8),
      duration: Duration(seconds: 4),
      title: title,
      backgroundColor: Colors.red,
      flushbarPosition: position,
      message: text,
      icon: Icon(
        Icons.error,
        color: Colors.white,
      ),
    ).show(ctx);
  }

  static Future<String> showPrompt(BuildContext ctx, String title,
      {String message, TextInputType inputType = TextInputType.text}) {
    var completer = Completer<String>();
    var value = "";
    showDialog(
        context: ctx,
        builder: (cont) {
          return AlertDialog(
            title: Text(title),
            content: CustomFormField(
              keyboardType: inputType,
              onChanged: (text) {
                value = text;
              },
            ),
            actions: [
              TextButton(
                  textColor: Colors.red,
                  onPressed: () {
                    Navigator.pop(ctx);
                    completer.complete(null);
                  },
                  child: Text("Cancel")),
              TextButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    completer.complete(value);
                  },
                  child: Text("Ok"))
            ],
          );
        });

    return completer.future;
  }*/

  static showAlert(BuildContext ctx, String title, String text,
      {Function? callback = null,
      Function? onClose = null,
      bool cancelable = false,
      String acceptTitle = "Ok",
      TextButton? additionalAction = null}) {
    showDialog(
        context: ctx,
        barrierDismissible: cancelable,
        builder: (cont) {
          return AlertDialog(
            title: Text(
              title,
              style: TextStyle(color: Colors.green),
            ),
            backgroundColor: Colors.grey[900],
            content: Text(text, style: TextStyle(color: Colors.green)),
            actions: [
              if (cancelable || onClose != null)
                TextButton(
                    style: TextButton.styleFrom(
                        textStyle: TextStyle(color: Colors.red)),
                    onPressed: () {
                      Navigator.pop(ctx);
                      if (onClose != null) {
                        onClose();
                      }
                    },
                    child: Text("Cancel")),
              SizedBox(
                width: 10,
              ),
              if (additionalAction != null)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    additionalAction,
                    SizedBox(
                      width: 10,
                    ),
                  ],
                ),
              TextButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    if (callback != null) {
                      callback();
                    }
                  },
                  child: Text(acceptTitle))
            ],
          );
        });
  }
}
