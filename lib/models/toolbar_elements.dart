class ToolbarSettings {
  String? searchHint = "Search...";
  String? title = "Search";
  List<ToolBarSortByElement>? sorts = [];
  List<ToolBarFilterGroup>? filters = [];
  ToolbarSettings({this.sorts, this.filters, this.title, this.searchHint});
}

class ToolbarValue {
  String search;
  ToolBarSortByElement? sortBy;
  List<ToolBarFilterElement> filters;
  ToolbarValue({required this.search, this.sortBy, required this.filters});
}

enum ToolBarSortByType { ascending, descending }

class ToolBarSortByElement {
  String label;
  String field;
  ToolBarSortByType value;
  ToolBarSortByElement(
      {required this.label, required this.field, required this.value});
}

class ToolBarFilterGroup {
  String groupName;
  List<ToolBarFilterElement> filters;
  ToolBarFilterGroup({required this.groupName, required this.filters});
}

class ToolBarFilterElement {
  String label;
  String field;
  String value;
  ToolBarFilterElement(
      {required this.label, required this.field, required this.value});
}
