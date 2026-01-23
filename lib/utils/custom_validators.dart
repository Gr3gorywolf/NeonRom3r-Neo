import 'package:reactive_forms/reactive_forms.dart';

class CustomValidators {
  static Validator<dynamic> urlValidator = Validators.delegate(
    (AbstractControl<dynamic> control) {
      final raw = control.value;
      final v = (raw is String ? raw : '').trim();

      if (v.isEmpty) return null;

      final uri = Uri.tryParse(v);
      final isValid = uri != null && uri.hasScheme && uri.isAbsolute;

      return isValid ? null : {'url': true};
    },
  );
}
