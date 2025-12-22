import 'package:neonrom3r/models/contracts/json_serializable.dart';
import 'package:neonrom3r/models/rom_info.dart';
import 'package:neonrom3r/models/toolbar_elements.dart';

class FilterHelpers {
  static _getValueByPath(Map<String, dynamic> json, String path) {
    dynamic current = json;

    for (final key in path.split('.')) {
      if (current is Map<String, dynamic> && current.containsKey(key)) {
        current = current[key];
      } else {
        return null;
      }
    }

    return current;
  }

  static List<T> handleDynamicFilter<T extends JsonSerializable>(
    List<T> subjects,
    ToolbarValue filters, {
    String nameField = 'name',
  }) {
    List<T> filteredSubjects = subjects;
    final sort = filters.sortBy;

    if (filters.search.isNotEmpty) {
      final searchLower = filters.search.toLowerCase();

      filteredSubjects = filteredSubjects.where((subject) {
        final value = _getValueByPath(subject.toJson(), nameField)?.toString();
        return value?.toLowerCase().contains(searchLower) ?? false;
      }).toList();
    }

    for (final filter in filters.filters) {
      filteredSubjects = filteredSubjects.where((subject) {
        final value = _getValueByPath(subject.toJson(), filter.field);
        return value?.toString() == filter.value;
      }).toList();
    }

    if (sort != null) {
      filteredSubjects.sort((a, b) {
        final aValue = _getValueByPath(a.toJson(), sort.field);
        final bValue = _getValueByPath(b.toJson(), sort.field);

        if (aValue is Comparable && bValue is Comparable) {
          return sort.value == ToolBarSortByType.ascending
              ? aValue.compareTo(bValue)
              : bValue.compareTo(aValue);
        }
        return 0;
      });
    }

    return filteredSubjects;
  }
}
