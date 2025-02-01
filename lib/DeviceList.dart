import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class DeviceListScreen extends StatefulWidget {
  @override
  _DeviceListScreenState createState() => _DeviceListScreenState();
}

class _DeviceListScreenState extends State<DeviceListScreen> {
  final DatabaseReference _databaseRef =
      FirebaseDatabase.instance.ref().child('Device');
  Map<dynamic, dynamic> _data = {};
  bool _isLoading = true; // Add loading state

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  void _fetchData() {
    _databaseRef.onValue.listen((DatabaseEvent event) {
      final data = event.snapshot.value;
      print("Data fetched: $data"); // Debug print

      if (data != null && data is Map<dynamic, dynamic>) {
        setState(() {
          _data = data;
          _isLoading = false; // Stop loading
        });
      } else {
        setState(() {
          _data = {};
          _isLoading = false; // Stop loading even if no data
        });
        print("No data found in the database"); // Debug print
      }
    }, onError: (error) {
      print("Failed to fetch data: $error"); // Debug print
      setState(() {
        _isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Device List')),
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 20),
                  Text("Loading data..."),
                ],
              ),
            )
          : _data.isEmpty
              ? Center(child: Text("No data available."))
              : ListView.builder(
                  itemCount: _data.length,
                  itemBuilder: (context, index) {
                    String key = _data.keys.elementAt(index);
                    var device = _data[key];

                    return Card(
                      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      child: ListTile(
                        title: Text(device['name'] ?? 'No Name',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Status: ${device['status'] ?? 'No Status'}'),
                            Text('Description: ${device['description'] ?? 'No Description'}'),
                          ],
                        ),
                        leading: Icon(Icons.devices),
                        trailing: Icon(Icons.arrow_forward_ios, size: 16),
                      ),
                    );
                  },
                ),
    );
  }
}
