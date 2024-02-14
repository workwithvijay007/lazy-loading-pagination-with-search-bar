import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'country.dart';
import 'package:fl_chart/fl_chart.dart';


void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) => GetMaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'Lazy Loading JSON',
    theme: ThemeData(primarySwatch: Colors.blue),
    home: CountryPage(),
  );
}

class CountryPage extends StatelessWidget {
  final CountryController _controller = Get.put(CountryController());

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Countries'),
      actions: [
        _buildUploadDropdown(),
        _buildDownloadDropdown(),
      ],
    ),
    body: SingleChildScrollView(
      child: Column(
        children: [
          Obx(() {
            if (_controller.loading.value) {
              return const Center(child: CircularProgressIndicator());
            } else {
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Column(
                  children: [
                    _buildPopulationBarGraph(),
                    DataTable(
                      sortAscending: _controller.sortAscending.value,
                      sortColumnIndex: _controller.sortedColumnIndex.value,
                      columns: [
                        _buildDataColumn(
                            label: const Text('Name'), columnIndex: 0),
                        _buildDataColumn(
                            label: const Text('Population (2020)'), columnIndex: 1),
                        _buildDataColumn(
                            label: const Text('Yearly Change'), columnIndex: 2),
                        _buildDataColumn(
                            label: const Text('Net Change'), columnIndex: 3),
                        _buildDataColumn(
                            label: const Text('Density (P/Km²)'), columnIndex: 4),
                        _buildDataColumn(
                            label: const Text('Land Area (Km²)'), columnIndex: 5),
                        _buildDataColumn(
                            label: const Text('Migrants (net)'), columnIndex: 6),
                        _buildDataColumn(
                            label: const Text('Fert. Rate'), columnIndex: 7),
                        _buildDataColumn(
                            label: const Text('Med. Age'), columnIndex: 8),
                        _buildDataColumn(
                            label: const Text('Urban Pop %'), columnIndex: 9),
                        _buildDataColumn(
                            label: const Text('World Share'), columnIndex: 10),
                      ],
                      rows: _controller.countries.map((country) => DataRow(
                        cells: [
                          DataCell(Text(country.name)),
                          DataCell(Text(country.population2020.toString())),
                          DataCell(Text(country.yearlyChange)),
                          DataCell(Text(country.netChange.toString())),
                          DataCell(Text(country.density.toString())),
                          DataCell(Text(country.landArea.toString())),
                          DataCell(Text(country.migrants.toString())),
                          DataCell(Text(country.fertilityRate.toString())),
                          DataCell(Text(country.medianAge.toString())),
                          DataCell(Text(country.urbanPopulationPercentage)),
                          DataCell(Text(country.worldShare)),
                        ],
                      )).toList(),
                    ),
                  ],
                ),
              );
            }
          }),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _controller.loadMoreData,
            child: const Text('Load More'),
          ),
          const SizedBox(height: 20),
        ],
      ),
    ),
  );


  Widget _buildPopulationBarGraph() {
    final List<Country> countries = _controller.countries;
    final List<Widget> bars = [];

    // Find maximum population for scaling purposes
    int maxPopulation = 0;
    for (final country in countries) {
      if (country.population2020 > maxPopulation) {
        maxPopulation = country.population2020;
      }
    }

    // Generate bars
    for (final country in countries) {
      final double barHeight = (country.population2020 / maxPopulation) * 200.0; // Adjust the height as needed
      bars.add(
        Column(
          children: [
            Text(country.name),
            Container(
              height: barHeight,
              width: 30.0, // Adjust the width as needed
              color: Colors.blue,
              alignment: Alignment.center,
              child: Text(country.population2020.toString()),
            ),
          ],
        ),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: bars,
    );
  }

  DataColumn _buildDataColumn({required Widget label, required int columnIndex}) =>
      DataColumn(
        label: label,
        onSort: (columnIndex, ascending) =>
            _controller.sortData(columnIndex, ascending),
      );

  Widget _buildUploadDropdown() => DropdownButton<String>(
    onChanged: (value) async {
      if (value == null) return;
      final filePicker =
      await FilePicker.platform.pickFiles(type: FileType.any);
      if (filePicker == null) return;
      String? filePath = filePicker.files.single.path;
      if (filePath == null) return;
      _controller.uploadFile(filePath);
    },
    items: const [
      DropdownMenuItem(value: 'csv', child: Text('.csv')),
      DropdownMenuItem(value: 'xls', child: Text('.xls')),
    ],
    icon: const Icon(Icons.file_upload),
    underline: Container(),
  );

  Widget _buildDownloadDropdown() => DropdownButton<String>(
    onChanged: (value) async {
      if (value == null) return;
      final downloadsDirectory = await getDownloadsDirectory();
      final timeStamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'Emp$timeStamp.$value';
      final filePath = '$downloadsDirectory/$fileName';

      if (value == 'csv') {
        saveAsCSV(_controller.countries, filePath);
      } else if (value == 'json') {
        saveAsJSON(_controller.countries, filePath);
      }

      print('Download file: $filePath');
    },
    items: const [
      DropdownMenuItem(value: 'csv', child: Text('.csv')),
      DropdownMenuItem(value: 'json', child: Text('.json')),
    ],
    icon: const Icon(Icons.file_download),
    underline: Container(),
  );

  Future<void> saveAsCSV(List<Country> data, String filePath) async {
    final file = File(filePath);
    final csv = data.map((country) =>
    '${country.name},${country.population2020},${country.yearlyChange},${country.netChange},${country.density},${country.landArea},${country.migrants},${country.fertilityRate},${country.medianAge},${country.urbanPopulationPercentage},${country.worldShare}')
        .join('\n');
    await file.writeAsString(csv);
    print('Data saved as CSV to $filePath');
  }

  Future<void> saveAsJSON(List<Country> data, String filePath) async {
    final file = File(filePath);
    final jsonData = jsonEncode(data);
    await file.writeAsString(jsonData);
    print('Data saved as JSON to $filePath');
  }


  Future<String> getDownloadsDirectory() async {
    final String? downloadsDir = '${Platform.environment['USERPROFILE']}\\Downloads';
    if (downloadsDir != null) {
      return downloadsDir;
    } else {
      throw Exception('Unable to get downloads directory on Windows');
    }
  }


}

class CountryController extends GetxController {
  var countries = <Country>[].obs;
  var loading = true.obs;
  var sortedColumnIndex = 0.obs;
  var sortAscending = true.obs;

  @override
  void onInit() {
    super.onInit();
    loadData();
  }

  Future<void> loadData() async {
    String jsonString = await rootBundle.loadString('assets/sample.json');
    List<dynamic> jsonData = jsonDecode(jsonString);
    List<Country> parsedData =
    jsonData.take(20).map((json) => Country.fromJson(json)).toList();
    countries.value = parsedData;
    loading.value = false;
  }

  Future<void> loadMoreData() async {
    loading.value = true;
    await Future.delayed(const Duration(seconds: 2));
    String jsonString = await rootBundle.loadString('assets/sample.json');
    List<dynamic> jsonData = jsonDecode(jsonString);
    List<Country> additionalData = jsonData
        .skip(countries.length)
        .take(10)
        .map((json) => Country.fromJson(json))
        .toList();
    countries.addAll(additionalData);
    loading.value = false;
  }

  void sortData(int columnIndex, bool ascending) {
    switch (columnIndex) {
      case 0:
        countries.sort((a, b) => ascending
            ? a.name.compareTo(b.name)
            : b.name.compareTo(a.name));
        break;
      case 1:
        countries.sort((a, b) => ascending
            ? a.population2020.compareTo(b.population2020)
            : b.population2020.compareTo(a.population2020));
        break;
      case 2:
        countries.sort((a, b) => ascending
            ? a.yearlyChange.compareTo(b.yearlyChange)
            : b.yearlyChange.compareTo(a.yearlyChange));
        break;
      case 3:
        countries.sort((a, b) => ascending
            ? a.netChange.compareTo(b.netChange)
            : b.netChange.compareTo(a.netChange));
        break;
      case 4:
        countries.sort((a, b) => ascending
            ? a.density.compareTo(b.density)
            : b.density.compareTo(a.density));
        break;
      case 5:
        countries.sort((a, b) => ascending
            ? a.landArea.compareTo(b.landArea)
            : b.landArea.compareTo(a.landArea));
        break;
      case 6:
        countries.sort((a, b) => ascending
            ? a.migrants.compareTo(b.migrants)
            : b.migrants.compareTo(a.migrants));
        break;
      case 7:
        countries.sort((a, b) => ascending
            ? a.fertilityRate.compareTo(b.fertilityRate)
            : b.fertilityRate.compareTo(a.fertilityRate));
        break;
      case 8:
        countries.sort((a, b) => ascending
            ? a.medianAge.compareTo(b.medianAge)
            : b.medianAge.compareTo(a.medianAge));
        break;
      case 9:
        countries.sort((a, b) => ascending
            ? a.urbanPopulationPercentage.compareTo(b.urbanPopulationPercentage)
            : b.urbanPopulationPercentage.compareTo(a.urbanPopulationPercentage));
        break;
      case 10:
        countries.sort((a, b) => ascending
            ? a.worldShare.compareTo(b.worldShare)
            : b.worldShare.compareTo(a.worldShare));
        break;
    }
    sortedColumnIndex.value = columnIndex;
    sortAscending.value = ascending;
  }

  Future<void> uploadFile(String filePath) async {
    File file = File(filePath);
    if (!file.existsSync()) {
      print('File not found: $filePath');
      return;
    }

    List<int> bytes = await file.readAsBytes();
    final url = Uri.parse('https://example.com/upload');
    final response = await http.post(url, body: bytes, headers: {'Content-Type': 'application/octet-stream'});

    if (response.statusCode == 200) {
      print('Upload successful!');
    } else {
      print('Upload failed with status: ${response.statusCode}');
    }
  }
}
