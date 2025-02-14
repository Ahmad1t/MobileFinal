import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DeviceDetails extends StatelessWidget {
  final String deviceId;

  DeviceDetails({required this.deviceId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Device Details')),
      body: FutureBuilder(
        future: FirebaseFirestore.instance.collection('Device').doc(deviceId).get(),
        builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(child: Text('Device not found.'));
          }
          var deviceData = snapshot.data!.data() as Map<String, dynamic>;
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Name: ${deviceData['name']}', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                SizedBox(height: 10),
                Text('Description: ${deviceData['description'] ?? 'No description available'}', style: TextStyle(fontSize: 16)),
                SizedBox(height: 10),
                Row(
                  children: [
                    Text('Status: ', style: TextStyle(fontSize: 16)),
                    Switch(
                      value: deviceData['status'] ?? false,
                      onChanged: (bool newValue) {
                        FirebaseFirestore.instance.collection('Device').doc(deviceId).update({'status': newValue});
                      },
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}