import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DurationPickerDialog extends StatefulWidget {
  final int initialMinutes;
  String title = "Select Duration";
  final ValueChanged<int> onSubmit;

  DurationPickerDialog(
      {Key? key,
      required this.initialMinutes,
      required this.onSubmit,
      this.title = "Select Duration"})
      : super(key: key);

  @override
  State<DurationPickerDialog> createState() => _DurationPickerDialogState();
}

class _DurationPickerDialogState extends State<DurationPickerDialog> {
  late TextEditingController _hoursController;
  late int _minutes;

  @override
  void initState() {
    final initialHours = widget.initialMinutes ~/ 60;
    _minutes = widget.initialMinutes % 60;
    _hoursController = TextEditingController(text: initialHours.toString());
    super.initState();
  }

  @override
  void dispose() {
    _hoursController.dispose();
    super.dispose();
  }

  int _parseHours() {
    final text = _hoursController.text;
    if (text.isEmpty) return 0;
    return int.tryParse(text) ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Hours'),
                SizedBox(height: 8),
                TextFormField(
                  controller: _hoursController,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                )
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Minutes'),
                SizedBox(height: 8),
                DropdownButtonFormField<int>(
                  value: _minutes,
                  isExpanded: true,
                  items: List.generate(
                    61,
                    (i) => DropdownMenuItem(
                      value: i,
                      child: Text(i.toString()),
                    ),
                  ),
                  onChanged: (value) {
                    setState(() => _minutes = value ?? 0);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            final hours = _parseHours();
            final totalMinutes = (hours * 60) + _minutes;

            widget.onSubmit(totalMinutes);
            Navigator.pop(context);
          },
          child: const Text('Accept'),
        ),
      ],
    );
  }
}
