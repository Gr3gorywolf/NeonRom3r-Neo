import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

class KeyboardPopWrapper extends StatelessWidget {
  final Widget child;

  const KeyboardPopWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Focus(
      autofocus: true,
      child: Shortcuts(
        shortcuts: <ShortcutActivator, Intent>{
          const SingleActivator(LogicalKeyboardKey.escape): const _PopIntent(),
          const SingleActivator(
            LogicalKeyboardKey.arrowLeft,
            alt: true,
          ): const _PopIntent(),
        },
        child: Actions(
          actions: <Type, Action<Intent>>{
            _PopIntent: CallbackAction<_PopIntent>(
              onInvoke: (intent) {
                if (GoRouter.of(context).canPop()) {
                  context.pop();
                }
                return null;
              },
            ),
          },
          child: child,
        ),
      ),
    );
  }
}

class _PopIntent extends Intent {
  const _PopIntent();
}
