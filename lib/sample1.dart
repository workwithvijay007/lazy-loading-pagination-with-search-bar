import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Paginated DataTable Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: PaginatedDataTableDemo(),
    );
  }
}

class PaginatedDataTableDemo extends StatefulWidget {
  @override
  _PaginatedDataTableDemoState createState() => _PaginatedDataTableDemoState();
}

class _PaginatedDataTableDemoState extends State<PaginatedDataTableDemo> {
  List<Map<String, dynamic>> _data = List.generate(
    100,
        (index) => {'id': index, 'name': 'Item ${index + 1}'},
  );

  List<Map<String, dynamic>> _filteredData = [];

  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _filteredData.addAll(_data);
  }

  void _filterData(String query) {
    _filteredData.clear();
    if (query.isEmpty) {
      _filteredData.addAll(_data);
    } else {
      _filteredData.addAll(_data.where((item) =>
      item['id'].toString().contains(query) ||
          item['name'].toString().toLowerCase().contains(query.toLowerCase())));
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Paginated DataTable Example'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: _filterData,
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: PaginatedDataTable(
                header: Text('Items'),
                rowsPerPage: 10,
                columns: [
                  DataColumn(label: Text('ID')),
                  DataColumn(label: Text('Name')),
                ],
                source: _DataSource(context, _filteredData),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DataSource extends DataTableSource {
  final BuildContext context;
  final List<Map<String, dynamic>> _data;

  _DataSource(this.context, this._data);

  @override
  DataRow getRow(int index) {
    final item = _data[index];
    return DataRow(
      cells: [
        DataCell(Text('${item['id']}')),
        DataCell(Text('${item['name']}')),
      ],
    );
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => _data.length;

  @override
  int get selectedRowCount => 0;
}
