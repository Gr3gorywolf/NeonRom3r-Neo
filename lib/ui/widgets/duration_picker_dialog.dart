import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DurationPickerDialog extends StatefulWidget {
  final int initialMinutes;
  final ValueChanged<int> onSubmit;

  const DurationPickerDialog({
    Key? key,
    required this.initialMinutes,
    required this.onSubmit,
  }) : super(key: key);

  @override
  State<DurationPickerDialog> createState() => _DurationPickerDialogState();
}

class _DurationPickerDialogState extends State<DurationPickerDialog> {
  late TextEditingController _hoursController;
  late int _minutes;

  @override
  void initState() {
    super.initState();
    final initialHours = widget.initialMinutes ~/ 60;
    _minutes = widget.initialMinutes % 60;

    _hoursController = TextEditingController(text: initialHours.toString());
  }

  @override
  void dispose() {
    _hoursController.dispose();
    super.dispose();
  }

  int _parseHours() {
    return int.tryParse(_hoursController.text) ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Select Duration'),
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
                TextField(
                  controller: _hoursController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: const InputDecoration(
                      hintText: '0',
                      contentPadding: EdgeInsets.only(bottom: 0)),
                ),
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
                DropdownButton<int>(
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
        ElevatedButton(
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
