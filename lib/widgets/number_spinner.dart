import 'package:flutter/material.dart';

class NumberSpinner extends StatefulWidget {
  final int initialValue;
  final Function(int) onChanged;

  NumberSpinner({required this.initialValue, required this.onChanged});

  @override
  _NumberSpinnerState createState() => _NumberSpinnerState();
}

class _NumberSpinnerState extends State<NumberSpinner> {
  late int _value;
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _value = widget.initialValue;
    _controller = TextEditingController(text: _value.toString());
  }

  void _increment() {
    if (mounted) {
      setState(() {
        _value++;
        _controller.text = _value.toString();
        widget.onChanged(_value);
      });
    }
  }

  void _decrement() {
    if (mounted) {
      setState(() {
        if (_value > 1) {
          _value--;
          _controller.text = _value.toString();
          widget.onChanged(_value);
        }
      });
    }
  }

  void _onChanged(String text) {
    if (mounted) {
      setState(() {
        final int? value = int.tryParse(text);
        if (value != null && value > 0) {
          _value = value;
          widget.onChanged(_value);
        } else {
          _controller.text = _value.toString();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool isLightTheme = theme.brightness == Brightness.light;
    final Color textColor = isLightTheme ? Color(0xFF20493C) : Colors.white;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: const Icon(Icons.remove),
          onPressed: _decrement,
        ),
        Container(
          width: 50,
          child: TextField(
            controller: _controller,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              focusedBorder:
                  OutlineInputBorder(borderSide: BorderSide(color: textColor)),
            ),
            onChanged: _onChanged,
            cursorColor: textColor,
          ),
        ),
        IconButton(
          icon: const Icon(Icons.add),
          onPressed: _increment,
        ),
      ],
    );
  }
}
