import 'package:neonrom3r/models/contracts/json_serializable.dart';
import 'package:neonrom3r/models/rom_info.dart';
import 'package:neonrom3r/models/toolbar_elements.dart';

class FilterHelpers {
  static List<T> handleDynamicFilter<T extends JsonSerializable>(
      List<T> subjects, ToolbarValue filters,
      {nameField = 'name'}) {
    List<T> filteredSubjects = subjects;
    var sort = filters.sortBy;

    if (filters.search.isNotEmpty) {
      filteredSubjects = filteredSubjects
          .where((subject) => subject
              .toJson()[nameField]
              ?.toLowerCase()
              ?.contains(filters.search.toLowerCase()))
          .toList();
    }

    for (var filter in filters.filters) {
      filteredSubjects = filteredSubjects.where((subject) {
        var subjectValue = subject.toJson()[filter.field]?.toString() ?? '';
        return subjectValue == filter.value;
      }).toList();
    }
    if (sort != null) {
      filteredSubjects.sort((a, b) {
        var aValue = a.toJson()[sort.field];
        var bValue = b.toJson()[sort.field];
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
