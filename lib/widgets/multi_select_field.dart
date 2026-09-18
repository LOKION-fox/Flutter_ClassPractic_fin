import 'package:flutter/material.dart';

class MultiSelectField<T> extends StatelessWidget {
  final String label;

  final List<T> items;

  final List<String> selectedIds;

  final String Function(T item) idOf;

  final String Function(T item) labelOf;

  final ValueChanged<List<String>> onChanged;

  final String? Function(List<String>?) validator;

  const MultiSelectField({
    super.key,
    required this.label,
    required this.items,
    required this.selectedIds,
    required this.idOf,
    required this.labelOf,
    required this.onChanged,
    required this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return FormField<List<String>>(
      key: ValueKey(
        '$label-${selectedIds.join('-')}-${items.length}',
      ),
      initialValue: selectedIds,
      validator: validator,
      builder: (field) {
        return InputDecorator(
          decoration: InputDecoration(
            labelText: label,
            border: const OutlineInputBorder(),
            errorText: field.errorText,
          ),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: items.map((item) {
              final id = idOf(item);

              final selected = field.value?.contains(id) ?? false;

              return FilterChip(
                label: Text(labelOf(item)),
                selected: selected,
                onSelected: (_) {
                  final next = List<String>.from(
                    field.value ?? [],
                  );

                  if (selected) {
                    next.remove(id);
                  } else {
                    next.add(id);
                  }

                  field.didChange(next);

                  onChanged(next);
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }
}
