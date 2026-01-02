import 'package:flutter/material.dart';
import '../../../config/routes/navigation_service.dart';
import '../../../config/constants/app_colors.dart';

class CallHistoryPage extends StatefulWidget {
  const CallHistoryPage({super.key});

  @override
  State<CallHistoryPage> createState() => _CallHistoryPageState();
}

class _CallHistoryPageState extends State<CallHistoryPage> {
  final List<Map<String, dynamic>> callHistory = [
    {
      'name': 'Unit 1',
      'duration': '2:34',
      'timestamp': 'Today, 10:30',
      'type': 'incoming', // incoming, outgoing, missed
    },
    {
      'name': 'Unit 2',
      'duration': '5:12',
      'timestamp': 'Today, 09:15',
      'type': 'outgoing',
    },
    {
      'name': 'Command Center',
      'duration': '1:45',
      'timestamp': 'Today, 08:00',
      'type': 'incoming',
    },
    {
      'name': 'Unit 3',
      'duration': '0:00',
      'timestamp': 'Yesterday, 18:30',
      'type': 'missed',
    },
    {
      'name': 'Unit 4',
      'duration': '3:20',
      'timestamp': 'Yesterday, 14:00',
      'type': 'outgoing',
    },
    {
      'name': 'Unit 1',
      'duration': '4:56',
      'timestamp': 'Yesterday, 11:00',
      'type': 'incoming',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.primaryDark,
        title: const Text(
          'Call History',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => NavigationService.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.white),
            onPressed: () {
              _showClearHistoryDialog();
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: callHistory.length,
        itemBuilder: (context, index) {
          final call = callHistory[index];
          return Container(
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Colors.grey.shade200,
                  width: 1,
                ),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              child: Row(
                children: [
                  // Avatar with call type indicator
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: AppColors.primary,
                        child: Text(
                          call['name'][0],
                          style: const TextStyle(
                            color: AppColors.primaryDark,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          width: 18,
                          height: 18,
                          decoration: BoxDecoration(
                            color: _getCallTypeColor(call['type']),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white,
                              width: 2,
                            ),
                          ),
                          child: Icon(
                            _getCallTypeIcon(call['type']),
                            color: Colors.white,
                            size: 10,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 12),
                  // Call info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          call['name'],
                          style: const TextStyle(
                            color: AppColors.primaryDark,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Text(
                              call['timestamp'],
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(width: 8),
                            if (call['duration'] != '0:00')
                              Text(
                                '• ${call['duration']}',
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 12,
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Action buttons
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.call_outlined,
                          size: 20,
                          color: AppColors.primaryDark,
                        ),
                        onPressed: () {
                          // Call again
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Color _getCallTypeColor(String type) {
    switch (type) {
      case 'incoming':
        return Colors.green;
      case 'outgoing':
        return Colors.blue;
      case 'missed':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getCallTypeIcon(String type) {
    switch (type) {
      case 'incoming':
        return Icons.call_received;
      case 'outgoing':
        return Icons.call_made;
      case 'missed':
        return Icons.call_missed;
      default:
        return Icons.call;
    }
  }

  void _showClearHistoryDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear History'),
        content: const Text('Are you sure you want to delete all call history?'),
        actions: [
          TextButton(
            onPressed: () => NavigationService.pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              NavigationService.pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Call history cleared')),
              );
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
