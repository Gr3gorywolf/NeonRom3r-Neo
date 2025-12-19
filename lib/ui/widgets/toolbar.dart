import 'package:neonrom3r/models/toolbar_elements.dart';
import 'package:flutter/material.dart';
import 'package:neonrom3r/utils/screen_helpers.dart';

class Toolbar extends StatefulWidget implements PreferredSizeWidget {
  final ToolbarSettings settings;
  final ToolbarValue? initialValues;
  final Function(ToolbarValue)? onChanged;
  const Toolbar(
      {Key? key, required this.settings, this.initialValues, this.onChanged})
      : super(key: key);
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
  @override
  State<Toolbar> createState() => _ToolbarState();
}

class _ToolbarState extends State<Toolbar> {
  bool isSearching = false;
  String searchText = '';
  TextEditingController _controller = TextEditingController();
  ToolBarSortByElement? sortBy;
  List<ToolBarFilterElement>? filters = [];
  @override
  void initState() {
    if (widget.initialValues != null) {
      searchText = widget.initialValues?.search ?? "";
      sortBy = widget.initialValues?.sortBy;
      filters = widget.initialValues?.filters;
    }
    super.initState();
  }

  void _notifyChange() {
    if (widget.onChanged != null) {
      widget.onChanged!(
        ToolbarValue(
          search: searchText,
          sortBy: sortBy,
          filters: filters ?? [],
        ),
      );
    }
  }

  Widget buildTitle() {
    var titleText = Text(widget?.settings?.title ?? 'Search');
    if (isSearching) {
      var isLargeScreen = MediaQuery.of(context).size.width > 800;
      var textField = TextField(
          controller: _controller,
          autofocus: true,
          onChanged: (value) {
            setState(() {
              searchText = value;
            });
            Future.delayed(const Duration(milliseconds: 200), () {
              if (value == searchText) {
                _notifyChange();
              }
            });
          },
          decoration: InputDecoration(
            hintText: widget.settings.searchHint ?? 'Search...',
            prefixIcon: const Icon(Icons.search),
            isDense: true,
            filled: true,
            contentPadding: const EdgeInsets.symmetric(vertical: 8),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
          ));
      return isLargeScreen
          ? Row(
              children: [
                titleText,
                Spacer(),
                SizedBox(width: 300, child: textField),
              ],
            )
          : textField;
    }
    return titleText;
  }

  Widget buildSortBy() {
    // Build sort by options based on widget.settings.sorts
    List<String> sortOptions =
        widget.settings.sorts?.map((e) => e.label).toList() ?? [];
    return PopupMenuButton<String>(
      icon: const Icon(Icons.sort),
      onSelected: (value) {
        setState(() {
          if (sortBy?.label == value) {
            if (sortBy?.value == ToolBarSortByType.descending) {
              sortBy = null;
              _notifyChange();
              return;
            }
            sortBy = ToolBarSortByElement(
              label: sortBy!.label,
              field: sortBy!.field,
              value: sortBy!.value == ToolBarSortByType.ascending
                  ? ToolBarSortByType.descending
                  : ToolBarSortByType.ascending,
            );
          } else {
            var foundSort = widget.settings.sorts!
                .firstWhere((element) => element.label == value);
            sortBy = ToolBarSortByElement(
              label: foundSort.label,
              field: foundSort.field,
              value: ToolBarSortByType.ascending,
            );
          }
        });
        _notifyChange();
      },
      itemBuilder: (context) {
        return sortOptions
            .map(
              (option) => PopupMenuItem(
                value: option,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(option),
                    Spacer(),
                    if (sortBy != null && sortBy!.label == option)
                      Icon(
                        sortBy!.value == ToolBarSortByType.ascending
                            ? Icons.arrow_upward
                            : Icons.arrow_downward,
                        size: 16,
                      ),
                  ],
                ),
              ),
            )
            .toList();
      },
    );
  }

  Widget buildFilters() {
    final filterGroups = widget.settings.filters ?? [];
    bool _sameFilter(ToolBarFilterElement a, ToolBarFilterElement b) {
      return a.value == b.value && a.field == b.field;
    }

    bool _isFilterSelected(ToolBarFilterElement filter) {
      return filters?.any((f) => _sameFilter(f, filter)) ?? false;
    }

    return PopupMenuButton<ToolBarFilterElement>(
      icon: const Icon(Icons.filter_list),
      onSelected: (value) {
        setState(() {
          if (_isFilterSelected(value)) {
            filters = filters!.where((f) => !_sameFilter(f, value)).toList();
          } else {
            filters = [...?filters, value];
          }
        });
        _notifyChange();
      },
      itemBuilder: (context) {
        final List<PopupMenuEntry<ToolBarFilterElement>> entries = [];

        for (final group in filterGroups) {
          entries.add(
            PopupMenuItem<ToolBarFilterElement>(
              enabled: false,
              child: Text(
                group.groupName,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          );

          for (final filter in group.filters) {
            entries.add(
              PopupMenuItem<ToolBarFilterElement>(
                value: filter,
                child: Row(
                  children: [
                    Text(filter.label),
                    const Spacer(),
                    if (_isFilterSelected(filter))
                      const Icon(Icons.check, size: 16),
                  ],
                ),
              ),
            );
          }

          entries.add(const PopupMenuDivider());
        }

        return entries;
      },
    );
  }

  @override
  AppBar build(BuildContext context) {
    return AppBar(
      title: buildTitle(),
      actions: [
        if (isSearching)
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              setState(() {
                isSearching = false;
                searchText = '';
                _controller.clear();
              });
              _notifyChange();
            },
          )
        else
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              setState(() {
                isSearching = true;
              });
            },
          ),
        if (widget.settings.sorts != null && widget.settings.sorts!.isNotEmpty)
          buildSortBy(),
        if (widget.settings.filters != null &&
            widget.settings.filters!.isNotEmpty)
          buildFilters(),
      ],
    );
  }
}
