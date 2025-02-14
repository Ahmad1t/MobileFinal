import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'DeviceDetails.dart';

class DeviceListPage extends StatefulWidget {
  @override
  _DeviceListPageState createState() => _DeviceListPageState();
}

class _DeviceListPageState extends State<DeviceListPage> {
  final CollectionReference devices =
      FirebaseFirestore.instance.collection('Device');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Devices')),
      body: StreamBuilder(
        stream: devices.snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No devices found.'));
          }
          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var device = snapshot.data!.docs[index];
              return ListTile(
                title: Text(device['name']),
                subtitle: Text((device.data() as Map<String, dynamic>)['description'] ?? 'No description available'),
                trailing: Switch(
                  value: device['status'] ?? false,
                  onChanged: (bool newValue) {
                    devices.doc(device.id).update({'status': newValue});
                  },
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DeviceDetails(deviceId: device.id),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDeviceDialog,
        child: Icon(Icons.add),
      ),
    );
  }

  void _showAddDeviceDialog() {
    TextEditingController nameController = TextEditingController();
    TextEditingController descriptionController = TextEditingController();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Enter Device Details'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameController, decoration: InputDecoration(labelText: 'Name')),
              TextField(controller: descriptionController, decoration: InputDecoration(labelText: 'Description')),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                String deviceName = nameController.text.trim();
                String deviceDescription = descriptionController.text.trim();
                if (deviceName.isNotEmpty) {
                  await devices.add({'name': deviceName, 'description': deviceDescription, 'status': false});
                }
                Navigator.of(context).pop();
              },
              child: Text('Add'),
            ),
          ],
        );
      },
    );
  }
}
