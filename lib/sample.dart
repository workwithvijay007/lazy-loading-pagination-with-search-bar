import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: MyDataTable(),
    );
  }
}

class MyDataTable extends StatefulWidget {
  const MyDataTable({Key? key}) : super(key: key);

  @override
  _MyDataTableState createState() => _MyDataTableState();
}

class _MyDataTableState extends State<MyDataTable> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _data = [];
  List<Map<String, dynamic>> _filteredData = [];
  int? _sortColumnIndex;
  bool _sortAscending = true;

  @override
  void initState() {
    super.initState();
    loadJsonData();
    _searchController.addListener(() {
      setState(() {
        String query = _searchController.text.toLowerCase();
        _filteredData = _data.where((row) {
          return row.values.any((value) {
            return value.toString().toLowerCase().contains(query);
          });
        }).toList();
      });
    });
  }

  Future<void> loadJsonData() async {
    String data = await rootBundle.loadString('assets/sample.json');
    setState(() {
      _data = List<Map<String, dynamic>>.from(json.decode(data));
      _filteredData.addAll(_data);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          decoration: const InputDecoration(
            hintText: 'Search...',
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: PaginatedDataTable(
          header: const Text('Data Table'),
          rowsPerPage: 10,
          sortColumnIndex: _sortColumnIndex,
          sortAscending: _sortAscending,
          columns: [
            DataColumn(
              label: const Text('Country'),
              onSort: (columnIndex, ascending) {
                setState(() {
                  _sortColumnIndex = columnIndex;
                  _sortAscending = ascending;
                  _filteredData.sort((a, b) {
                    String aValue = a['Country (or dependency)'];
                    String bValue = b['Country (or dependency)'];
                    return ascending ? aValue.compareTo(bValue) : bValue.compareTo(aValue);
                  });
                });
              },
            ),
            DataColumn(
              label: const Text('Population (2020)'),
              onSort: (columnIndex, ascending) {
                setState(() {
                  _sortColumnIndex = columnIndex;
                  _sortAscending = ascending;
                  _filteredData.sort((a, b) {
                    int aValue = a['Population (2020)'];
                    int bValue = b['Population (2020)'];
                    return ascending ? aValue.compareTo(bValue) : bValue.compareTo(aValue);
                  });
                });
              },
            ),
            DataColumn(
              label: const Text('Yearly Change'),
              onSort: (columnIndex, ascending) {
                setState(() {
                  _sortColumnIndex = columnIndex;
                  _sortAscending = ascending;
                  _filteredData.sort((a, b) {
                    String aValue = a['Yearly Change'];
                    String bValue = b['Yearly Change'];
                    return ascending ? aValue.compareTo(bValue) : bValue.compareTo(aValue);
                  });
                });
              },
            ),
            DataColumn(
              label: const Text('Net Change'),
              onSort: (columnIndex, ascending) {
                setState(() {
                  _sortColumnIndex = columnIndex;
                  _sortAscending = ascending;
                  _filteredData.sort((a, b) {
                    int aValue = a['Net Change'];
                    int bValue = b['Net Change'];
                    return ascending ? aValue.compareTo(bValue) : bValue.compareTo(aValue);
                  });
                });
              },
            ),
            // Add more DataColumn for other columns
          ],
          source: MyData(_filteredData),
        ),
      ),
    );
  }
}

class MyData extends DataTableSource {
  final List<Map<String, dynamic>> _data;

  MyData(this._data);

  @override
  DataRow getRow(int index) {
    return DataRow(cells: [
      DataCell(Text(_data[index]["Country (or dependency)"])),
      DataCell(Text(_data[index]["Population (2020)"].toString())),
      DataCell(Text(_data[index]["Yearly Change"])),
      DataCell(Text(_data[index]["Net Change"].toString())),
    ]);
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => _data.length;

  @override
  int get selectedRowCount => 0;
}
