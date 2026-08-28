// Helper for creating consistent checkboxes
import 'package:flutter/material.dart';

class BuildCheckbox extends StatelessWidget {
  final String title;
  final bool value;
  final Function(bool?) onChanged;

  const BuildCheckbox({
    super.key,
    required this.title,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Checkbox(
          value: value,
          onChanged: onChanged,
          activeColor: const Color(0xFF1D3A8A),
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          visualDensity: VisualDensity.compact,
        ),
        GestureDetector(
          onTap: () => onChanged(!value),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 13,
              color: Colors.black87,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}

class BuildLabel extends StatelessWidget {
  final String text;
  const BuildLabel({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 13,
          color: Colors.black87,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class RadioButton extends StatelessWidget {
  final String title;
  final String value;
  final String groupValue;
  final Function(String?) onChanged;

  const RadioButton({
    super.key,
    required this.title,
    required this.value,
    required this.groupValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onChanged(value),
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      child: Row(
        mainAxisSize: MainAxisSize.min, // This stops the infinite width crash!
        children: [
          SizedBox(
            height: 24, 
            width: 24, 
            child: Radio<String>(
              value: value, 
              groupValue: groupValue, 
              activeColor: const Color(0xFF1D3A8A), 
              onChanged: onChanged
            ),
          ),
          const SizedBox(width: 6),
          Text(title, style: const TextStyle(fontSize: 13, color: Colors.black87)),
        ],
      ),
    );
  }
}

class SelectDropDown extends StatelessWidget {
  final List<String> items;
  final String? currentValue;
  final Function(String?) onChanged;
  final String? hint;

  const SelectDropDown({
    super.key,
    required this.items,
    required this.currentValue,
    required this.onChanged,
    required this.hint,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: const Color(0xFFE9ECEF),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.grey.shade300),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          value: currentValue,
          hint: hint != null
              ? Text(
                  hint!,
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
                )
              : null,
          icon: const Icon(Icons.keyboard_arrow_down, color: Colors.black54),
          style: const TextStyle(fontSize: 13, color: Colors.black87),
          items: items.map((String value) {
            return DropdownMenuItem<String>(value: value, child: Text(value));
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}

class GreyTextField extends StatelessWidget {
  final TextEditingController controller;
  final IconData? icon;
  final String? hint;
  final bool isNumber;
  final bool isReadOnly;

  const GreyTextField({
    super.key,
    required this.controller,
    this.icon,
    this.hint,
    this.isNumber = false,
    this.isReadOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: isReadOnly ? Colors.grey.shade300 : const Color(0xFFE9ECEF),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: TextFormField(
        controller: controller,
        readOnly: isReadOnly,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        style: TextStyle(
          fontSize: 13,
          color: isReadOnly ? Colors.grey.shade700 : Colors.black,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 13),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 14,
          ),
          isDense: true,
          suffixIcon: icon != null ? Icon(icon, color: Colors.black54) : null,
        ),
      ),
    );
  }
}
