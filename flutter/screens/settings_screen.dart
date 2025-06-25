import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _autoWatering = false;
  double _moistureThreshold = 30.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: ListView(
        children: [
          SwitchListTile(
            title: Text('Enable Notifications'),
            subtitle: Text('Get alerts about plant condition'),
            value: _notificationsEnabled,
            onChanged: (value) {
              setState(() {
                _notificationsEnabled = value;
              });
            },
          ),
          Divider(),
          SwitchListTile(
            title: Text('Auto Watering'),
            subtitle: Text('Automatically water when moisture is low'),
            value: _autoWatering,
            onChanged: (value) {
              setState(() {
                _autoWatering = value;
              });
            },
          ),
          Divider(),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Moisture Threshold (%)'),
                Slider(
                  min: 0,
                  max: 100,
                  divisions: 10,
                  label: _moistureThreshold.round().toString(),
                  value: _moistureThreshold,
                  onChanged: (value) {
                    setState(() {
                      _moistureThreshold = value;
                    });
                  },
                ),
              ],
            ),
          ),
          Divider(),
          ListTile(
            title: Text('Connect to ESP32 Device'),
            trailing: Icon(Icons.bluetooth),
            onTap: () {
              // Open Bluetooth connection dialog
            },
          ),
          ListTile(
            title: Text('About'),
            trailing: Icon(Icons.info_outline),
            onTap: () {
              // Show about dialog
            },
          ),
        ],
      ),
    );
  }
}
