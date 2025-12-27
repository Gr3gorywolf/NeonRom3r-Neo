import 'dart:async';
import 'package:another_flushbar/flushbar.dart';
import 'package:another_flushbar/flushbar_helper.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:yamata_launcher/services/files_system_service.dart';

class AlertsService {
  static Flushbar? _currentSnackbar;
  static showSnackbar(BuildContext ctx, String message,
      {String? title,
      IconData? icon,
      int duration = 2,
      FlushbarPosition? position = null,
      Function? onTap}) async {
    if (icon == null) {
      icon = Icons.info;
    }
    if (position == null) {
      position = FileSystemService.isDesktop
          ? FlushbarPosition.TOP
          : FlushbarPosition.BOTTOM;
    }
    _currentSnackbar = await Flushbar(
      margin: EdgeInsets.all(8),
      borderRadius: BorderRadius.circular(8),
      duration: Duration(seconds: duration),
      title: title,
      flushbarPosition: position,
      maxWidth: 600,
      flushbarStyle: FlushbarStyle.FLOATING,
      message: message,
      onTap: (bar) {
        if (onTap != null) onTap();
      },
      shouldIconPulse: false,
      icon: Icon(
        icon,
        color: Theme.of(ctx).colorScheme.primary,
      ),
    ).show(ctx);
  }

  static showErrorSnackbar(BuildContext ctx,
      {Exception? exception, FlushbarPosition? position = null}) async {
    var title = "Error";
    var text = "Wow, an unexpected error happened";
    if (exception != null) {
      text = exception.toString();
    }
    if (position == null) {
      position = FileSystemService.isDesktop
          ? FlushbarPosition.TOP
          : FlushbarPosition.BOTTOM;
    }
    _currentSnackbar = await Flushbar(
      margin: EdgeInsets.all(8),
      borderRadius: BorderRadius.circular(8),
      duration: Duration(seconds: 4),
      title: title,
      backgroundColor: Colors.red,
      maxWidth: 600,
      flushbarStyle: FlushbarStyle.FLOATING,
      flushbarPosition: position,
      message: text,
      icon: Icon(
        Icons.error,
        color: Colors.white,
      ),
    ).show(ctx);
  }

  static Future<String?> showPrompt(BuildContext ctx, String title,
      {String? message,
      TextInputType inputType = TextInputType.text,
      String? inputPlaceholder,
      double? minWidth = 300}) {
    var completer = Completer<String>();
    var value = "";
    showDialog(
        context: ctx,
        builder: (cont) {
          return AlertDialog(
            title: Text(title, style: Theme.of(ctx).textTheme.titleMedium),
            contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            titlePadding: EdgeInsets.only(top: 20, left: 13, bottom: 5),
            content: Container(
              width: minWidth,
              child: TextField(
                keyboardType: inputType,
                decoration: InputDecoration(
                  hintText: inputPlaceholder ?? "",
                  helperText: message ?? "",
                  helperMaxLines: 3,
                ),
                onChanged: (text) {
                  value = text;
                },
              ),
            ),
            actions: [
              TextButton(
                  style: TextButton.styleFrom(
                      textStyle: TextStyle(color: Colors.red)),
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
  }

  static _DialogHandle showLoadingAlert(
      BuildContext ctx, String title, String text) {
    showDialog(
        context: ctx,
        barrierDismissible: false,
        builder: (cont) {
          return AlertDialog(
            title: Text(title, style: Theme.of(ctx).textTheme.titleMedium),
            content: Container(
                constraints: BoxConstraints(maxWidth: 500),
                child: Row(
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(
                      width: 20,
                    ),
                    Expanded(child: Text(text)),
                  ],
                )),
          );
        });
    final navigator = Navigator.of(ctx, rootNavigator: true);
    return _DialogHandle(() {
      if (navigator.canPop()) {
        navigator.pop();
      }
    });
  }

  static showAlert(BuildContext ctx, String title, String text,
      {Function? callback = null,
      Function? onClose = null,
      bool cancelable = true,
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
            content: Container(
                constraints: BoxConstraints(maxWidth: 500),
                child: Text(text, style: TextStyle(color: Colors.green))),
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

class _DialogHandle {
  bool _closed = false;
  final VoidCallback _onClose;

  _DialogHandle(this._onClose);

  void close() {
    if (_closed) return;
    _onClose();
    _closed = true;
  }
}
