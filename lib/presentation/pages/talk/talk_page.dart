import 'package:flutter/material.dart';
import 'dart:async';

class TalkPage extends StatefulWidget {
  const TalkPage({super.key});

  @override
  State<TalkPage> createState() => _TalkPageState();
}

class _TalkPageState extends State<TalkPage> {
  bool isMuted = false;
  bool isSpeakerOn = true;
  bool isInCall = false;
  bool isPushingToTalk = false;
  bool showChannelList = false;
  String? selectedChannelName;
  String callDuration = '00:00:00';
  Timer? _callTimer;
  int _seconds = 0;

  @override
  void dispose() {
    _callTimer?.cancel();
    super.dispose();
  }

  void _startCall() {
    setState(() {
      isInCall = true;
      _seconds = 0;
    });
    _callTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _seconds++;
        final hours = (_seconds ~/ 3600).toString().padLeft(2, '0');
        final minutes = ((_seconds % 3600) ~/ 60).toString().padLeft(2, '0');
        final secs = (_seconds % 60).toString().padLeft(2, '0');
        callDuration = '$hours:$minutes:$secs';
      });
    });
  }

  void _endCall() {
    _callTimer?.cancel();
    setState(() {
      isInCall = false;
      _seconds = 0;
      callDuration = '00:00:00';
      isPushingToTalk = false;
    });
  }

  void _showChannelConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFFE53E3E),
                      width: 5,
                    ),
                  ),
                  child: const Icon(
                    Icons.priority_high,
                    color: Color(0xFFE53E3E),
                    size: 50,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Peringatan',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Apakah anda yakin untuk memilih channel ini?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1E3A5F),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Iya',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: const BorderSide(
                            color: Color(0xFFE2E8F0),
                            width: 1,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Tidak',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _onChannelSelected() {
    setState(() {
      showChannelList = !showChannelList;
    });
  }

  Widget _buildChannelItem(String title, String subtitle, int participants, {bool isLast = false}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          setState(() {
            selectedChannelName = title;
            showChannelList = false;
          });
          _showChannelConfirmationDialog();
        },
        borderRadius: BorderRadius.vertical(
          bottom: isLast ? const Radius.circular(16) : Radius.zero,
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            border: isLast
                ? null
                : const Border(
                    bottom: BorderSide(
                      color: Color(0xFFE2E8F0),
                      width: 1,
                    ),
                  ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.language,
                color: Colors.grey[600],
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Color(0xFF1E3A5F),
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: isInCall ? const Color(0xFF4A6B88) : const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E3A5F),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Talk',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
            // Top section with channel selector and dropdown
            Container(
              margin: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Channel selector button
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E3A5F),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: isInCall ? null : _onChannelSelected,
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 16,
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 12,
                                height: 12,
                                decoration: const BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            selectedChannelName ?? 'Nama Channel....',
                            style: const TextStyle(
                              color: Color(0xFF94A3B8),
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        Icon(
                          showChannelList
                              ? Icons.keyboard_arrow_up
                              : Icons.chevron_right,
                          color: Colors.white,
                          size: 24,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
                  
                  // Channel list dropdown
                  if (showChannelList)
                    Container(
                      margin: const EdgeInsets.only(top: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          _buildChannelItem(
                            'KOMDIGI',
                            'Satuan Reserse Kriminal',
                            8,
                          ),
                          _buildChannelItem(
                            'Hukum',
                            'Divisi Hukum dan HAM',
                            12,
                          ),
                          _buildChannelItem(
                            'Intel',
                            'Satuan Intelijen Keamanan',
                            15,
                          ),
                          _buildChannelItem(
                            'Operasi',
                            'Satuan Operasi dan Pengendalian',
                            20,
                          ),
                          _buildChannelItem(
                            'Lalu Lintas',
                            'Direktorat Lalu Lintas',
                            18,
                            isLast: true,
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),

            // Active call info (shown when in call)
            if (isInCall) ...[
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.person,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Jendral Budi Sedang Bicara...',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              Text(
                callDuration,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],

            // Center microphone section
            SizedBox(
              height: 400,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () {
                        if (!isInCall && selectedChannelName != null) {
                          _startCall();
                        }
                      },
                      onLongPressStart: isInCall
                          ? (_) {
                              setState(() {
                                isPushingToTalk = true;
                              });
                            }
                          : null,
                      onLongPressEnd: isInCall
                          ? (_) {
                              setState(() {
                                isPushingToTalk = false;
                              });
                            }
                          : null,
                      child: Container(
                        width: 180,
                        height: 180,
                        decoration: BoxDecoration(
                          color: isInCall
                              ? const Color(0xFF2C4A5F)
                              : const Color(0xFFE2E8F0),
                          shape: BoxShape.circle,
                          border: isInCall
                              ? Border.all(
                                  color: Colors.red,
                                  width: isPushingToTalk ? 6 : 4,
                                )
                              : null,
                        ),
                        child: Center(
                          child: Icon(
                            Icons.mic,
                            size: 80,
                            color: isInCall ? Colors.white : Colors.grey[600],
                          ),
                        ),
                      ),
                    ),
                    if (isInCall) ...[
                      const SizedBox(height: 20),
                      RichText(
                        text: const TextSpan(
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white,
                          ),
                          children: [
                            TextSpan(
                              text: 'Tekan',
                              style: TextStyle(color: Colors.red),
                            ),
                            TextSpan(text: ' dan '),
                            TextSpan(
                              text: 'tahan',
                              style: TextStyle(color: Colors.red),
                            ),
                            TextSpan(text: ' untuk bicara'),
                          ],
                        ),
                      ),
                      const SizedBox(height: 30),
                      // End call button
                      GestureDetector(
                        onTap: _endCall,
                        child: Container(
                          width: 60,
                          height: 60,
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.call_end,
                            color: Colors.white,
                            size: 30,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            // Bottom controls
            Container(
              padding: const EdgeInsets.all(24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Mute button
                  _buildControlButton(
                    icon: isMuted ? Icons.mic_off : Icons.mic_none,
                    onTap: isInCall
                        ? () {
                            setState(() {
                              isMuted = !isMuted;
                            });
                          }
                        : null,
                    isInCall: isInCall,
                  ),
                  
                  // Speaker button
                  _buildControlButton(
                    icon: isSpeakerOn ? Icons.volume_up : Icons.volume_off,
                    onTap: isInCall
                        ? () {
                            setState(() {
                              isSpeakerOn = !isSpeakerOn;
                            });
                          }
                        : null,
                    isInCall: isInCall,
                  ),
                  
                  // SOS button
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.red,
                        width: 2,
                      ),
                      color: Colors.white,
                    ),
                    child: const Center(
                      child: Text(
                        'SOS',
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required VoidCallback? onTap,
    required bool isInCall,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(35),
      child: Container(
        width: 70,
        height: 70,
        decoration: BoxDecoration(
          color: isInCall ? Colors.white : const Color(0xFFE2E8F0),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          size: 32,
          color: isInCall ? Colors.black : Colors.grey[600],
        ),
      ),
    );
  }
}
