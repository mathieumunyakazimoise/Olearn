import 'package:flutter/material.dart';
import 'package:olearn/theme/app_theme.dart';
import 'package:olearn/l10n/app_localizations.dart';

class SharingScreen extends StatefulWidget {
  const SharingScreen({super.key});

  @override
  State<SharingScreen> createState() => _SharingScreenState();
}

class _SharingScreenState extends State<SharingScreen> {
  bool _isDiscovering = false;
  bool _isSharing = false;

  // Sample nearby devices
  final List<Map<String, dynamic>> _nearbyDevices = [
    {
      'name': 'John\'s Phone',
      'type': 'Android',
      'distance': 'Nearby',
      'isConnected': false,
    },
    {
      'name': 'Sarah\'s Tablet',
      'type': 'Android',
      'distance': 'Far',
      'isConnected': false,
    },
  ];

  // Sample shareable content
  final List<Map<String, dynamic>> _shareableContent = [
    {
      'title': 'Mathematics Basics',
      'type': 'Course',
      'size': '45.2 MB',
      'isSelected': false,
    },
    {
      'title': 'Science Experiments',
      'type': 'Course',
      'size': '128.7 MB',
      'isSelected': false,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Share Content'),
      ),
      body: Column(
        children: [
          // Connection Status
          Container(
            padding: const EdgeInsets.all(16),
            color: AppTheme.primaryColor.withOpacity(0.1),
            child: Row(
              children: [
                Icon(
                  _isDiscovering ? Icons.bluetooth_searching : Icons.bluetooth,
                  color: AppTheme.primaryColor,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _isDiscovering ? 'Discovering Devices...' : 'Bluetooth Ready',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Text(
                        _isDiscovering
                            ? 'Searching for nearby devices'
                            : 'Tap to start discovery',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: _isDiscovering,
                  onChanged: (value) {
                    setState(() {
                      _isDiscovering = value;
                    });
                  },
                ),
              ],
            ),
          ),
          // Nearby Devices
          Expanded(
            child: DefaultTabController(
              length: 2,
              child: Column(
                children: [
                  TabBar(
                    tabs: const [
                      Tab(text: 'Nearby Devices'),
                      Tab(text: 'Shareable Content'),
                    ],
                    labelColor: AppTheme.primaryColor,
                    unselectedLabelColor: AppTheme.textSecondaryColor,
                    indicatorColor: AppTheme.primaryColor,
                  ),
                  Expanded(
                    child: TabBarView(
                      children: [
                        // Nearby Devices Tab
                        _nearbyDevices.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.devices_outlined,
                                      size: 64,
                                      color: AppTheme.primaryColor.withOpacity(0.5),
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      AppLocalizations.of(context)!.noDevicesFound,
                                      style: Theme.of(context).textTheme.titleLarge,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      AppLocalizations.of(context)!.bluetoothInstruction,
                                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                            color: AppTheme.textSecondaryColor,
                                          ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              )
                            : ListView.builder(
                                padding: const EdgeInsets.all(16),
                                itemCount: _nearbyDevices.length,
                                itemBuilder: (context, index) {
                                  final device = _nearbyDevices[index];
                                  return Card(
                                    margin: const EdgeInsets.only(bottom: 16),
                                    child: ListTile(
                                      contentPadding: const EdgeInsets.all(16),
                                      leading: Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: AppTheme.primaryColor.withOpacity(0.1),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          Icons.phone_android,
                                          color: AppTheme.primaryColor,
                                        ),
                                      ),
                                      title: Text(
                                        device['name'],
                                        style: Theme.of(context).textTheme.titleMedium,
                                      ),
                                      subtitle: Text(
                                        '${device['type']} • ${device['distance']}',
                                        style: Theme.of(context).textTheme.bodySmall,
                                      ),
                                      trailing: ElevatedButton(
                                        onPressed: () {
                                          setState(() {
                                            device['isConnected'] = !device['isConnected'];
                                          });
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: device['isConnected']
                                              ? Colors.green
                                              : AppTheme.primaryColor,
                                        ),
                                        child: Text(
                                          device['isConnected'] ? 'Connected' : 'Connect',
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                        // Shareable Content Tab
                        ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _shareableContent.length,
                          itemBuilder: (context, index) {
                            final content = _shareableContent[index];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 16),
                              child: CheckboxListTile(
                                value: content['isSelected'],
                                onChanged: (value) {
                                  setState(() {
                                    content['isSelected'] = value;
                                  });
                                },
                                title: Text(
                                  content['title'],
                                  style: Theme.of(context).textTheme.titleMedium,
                                ),
                                subtitle: Text(
                                  '${content['type']} • ${content['size']}',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                                secondary: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: AppTheme.primaryColor.withOpacity(0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.folder_outlined,
                                    color: AppTheme.primaryColor,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Share Button
          if (_shareableContent.any((content) => content['isSelected']))
            Padding(
              padding: const EdgeInsets.all(16),
              child: ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    _isSharing = true;
                  });
                  // Simulate sharing
                  Future.delayed(const Duration(seconds: 2), () {
                    setState(() {
                      _isSharing = false;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Content shared successfully!'),
                      ),
                    );
                  });
                },
                icon: _isSharing
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Icon(Icons.share),
                label: Text(_isSharing ? 'Sharing...' : 'Share Selected'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 56),
                ),
              ),
            ),
        ],
      ),
    );
  }
} 