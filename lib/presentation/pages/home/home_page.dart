import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:robandigital/presentation/providers/home_provider.dart';
import '../talk/talk_page.dart';
import '../channel/channel_page.dart';
import '../channel/channel_chat_page.dart';
import '../profile/profile_page.dart';
import '../video_conference/video_conference_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _selectedMonth = 'Januari 2026';
  bool _showFabMenu = false;
  
  final List<String> _months = [
    'Januari 2026',
    'Februari 2026',
    'Maret 2026',
    'April 2026',
    'Mei 2026',
    'Juni 2026',
    'Juli 2026',
    'Agustus 2026',
    'September 2026',
    'Oktober 2026',
    'November 2026',
    'Desember 2026',
  ];
  
  @override
  void initState() {
    super.initState();
    // Set status bar color to match the header
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Color(0xFF2F678F),
        statusBarIconBrightness: Brightness.light,
      ),
    );
    
    // Load user data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HomeProvider>().initializeUserData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Main Content
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Section
                _buildHeader(),
                
                const SizedBox(height: 15),
                
                // Menu Grid
                _buildMenuGrid(),
                
                const SizedBox(height: 17),
                
                // Attendance Summary Title
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 25),
                  child: Text(
                    'Attendance Summary',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                  ),
                ),
                
                const SizedBox(height: 18),
                
                // Month Selector
                _buildMonthSelector(),
                
                const SizedBox(height: 15),
                
                // Attendance Summary Cards
                _buildAttendanceSummary(),
                
                const SizedBox(height: 100), // Bottom padding for FAB
              ],
            ),
          ),
          
          // Floating Menu Items (shown when FAB is tapped)
          if (_showFabMenu) ...[
            // Backdrop to close menu
            Positioned.fill(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _showFabMenu = false;
                  });
                },
                child: Container(
                  color: Colors.transparent,
                ),
              ),
            ),
            
            // Talk Menu Item
            Positioned(
              right: 16,
              bottom: 160,
              child: _buildMenuButton(
                label: 'Talk',
                icon: Icons.mic,
                onTap: () {
                  setState(() {
                    _showFabMenu = false;
                  });
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const TalkPage()),
                  );
                },
              ),
            ),
            
            // Absen Menu Item
            Positioned(
              right: 16,
              bottom: 95,
              child: _buildMenuButton(
                label: 'Absen',
                icon: Icons.person_pin,
                onTap: () {
                  setState(() {
                    _showFabMenu = false;
                  });
                  // Navigate to attendance page
                },
              ),
            ),
          ],
          
          // Floating Action Button
          Positioned(
            right: 16,
            bottom: 26,
            child: _buildFloatingActionButton(),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuButton({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 50,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF1B3C53),
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.3),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Color(0xFF1B3C53),
      ),
      child: Column(
        children: [
          // Status Bar Area
          Container(
            height: MediaQuery.of(context).padding.top > 0 
                ? MediaQuery.of(context).padding.top 
                : 32,
            color: const Color(0xFF2F678F),
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 25),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '9:41',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
          
          // Profile Section
          Container(
            height: 60,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Consumer<HomeProvider>(
                        builder: (context, homeProvider, _) {
                          return Text(
                            homeProvider.userName ?? 'User',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 2),
                      Consumer<HomeProvider>(
                        builder: (context, homeProvider, _) {
                          return Text(
                            homeProvider.userEmail ?? 'user@example.com',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w400,
                              color: Colors.white70,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ProfilePage(),
                      ),
                    );
                  },
                  child: Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white,
                        width: 2,
                      ),
                    ),
                    child: ClipOval(
                      child: Image.asset(
                        'assets/images/home/profile_picture.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuGrid() {
    final screenWidth = MediaQuery.of(context).size.width;
    final horizontalPadding = screenWidth * 0.05;
    final iconSize = screenWidth * 0.09;
    
    final menuItems = [
      {
        'icon': 'assets/images/home/icon_channel.png',
        'label': 'Channel',
      },
      {
        'icon': 'assets/images/home/icon_talk.png',
        'label': 'Talk',
      },
      {
        'icon': 'assets/images/home/icon_chat.png',
        'label': 'Chat',
      },
      {
        'icon': 'assets/images/home/icon_absensi.png',
        'label': 'Absensi',
      },
      {
        'icon': 'assets/images/home/icon_video_conference.png',
        'label': 'Video\nConference',
      },
      {
        'icon': 'assets/images/home/icon_riwayat.png',
        'label': 'Riwayat',
      },
    ];

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 20,
          mainAxisSpacing: 15,
          childAspectRatio: 1.0,
        ),
        itemCount: menuItems.length,
        itemBuilder: (context, index) {
          return _buildMenuItem(
            menuItems[index]['icon']!,
            menuItems[index]['label']!,
            index,
            iconSize,
          );
        },
      ),
    );
  }

  Widget _buildMenuItem(String iconPath, String label, int index, double iconSize) {
    return InkWell(
      onTap: () {
        // Navigate to Channel page when Channel menu item is tapped (index 0)
        if (index == 0) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ChannelPage()),
          );
        }
        // Navigate to Talk page when Talk menu item is tapped (index 1)
        else if (index == 1) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const TalkPage()),
          );
        }
        // Navigate to Chat page when Chat menu item is tapped (index 2)
        else if (index == 2) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ChannelChatPage(
                channelName: 'General',
                isOnline: true,
              ),
            ),
          );
        }
        // Navigate to Video Conference page when Video Conference menu item is tapped (index 4)
        else if (index == 4) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const VideoConferencePage()),
          );
        }
        // Add navigation for other menu items here
      },
      borderRadius: BorderRadius.circular(10),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.white),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(5, 5),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              iconPath,
              width: iconSize,
              height: iconSize,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthSelector() {
    final screenWidth = MediaQuery.of(context).size.width;
    
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
      child: GestureDetector(
        onTap: () {
          showModalBottomSheet(
            context: context,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            builder: (context) => Container(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Pilih Bulan',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Divider(),
                  Flexible(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: _months.length,
                      itemBuilder: (context, index) {
                        final month = _months[index];
                        final isSelected = month == _selectedMonth;
                        return ListTile(
                          title: Text(
                            month,
                            style: TextStyle(
                              color: isSelected
                                  ? const Color(0xFF2D9CDB)
                                  : Colors.black,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                            ),
                          ),
                          trailing: isSelected
                              ? const Icon(
                                  Icons.check,
                                  color: Color(0xFF2D9CDB),
                                )
                              : null,
                          onTap: () {
                            setState(() {
                              _selectedMonth = month;
                            });
                            Navigator.pop(context);
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
        child: Container(
          width: screenWidth * 0.4,
          height: 27,
          padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFF2D9CDB).withValues(alpha: 0.19),
            border: Border.all(
              color: const Color(0xFF2D9CDB).withValues(alpha: 0.86),
              width: 0.5,
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  _selectedMonth,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF636363),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const Icon(
                Icons.arrow_drop_down,
                size: 16,
                color: Color(0xFF636363),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAttendanceSummary() {
    final screenWidth = MediaQuery.of(context).size.width;
    final horizontalPadding = screenWidth * 0.05;
    
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildAttendanceCard(
                  'Kehadiran',
                  '21',
                  const Color(0xFFD9FFD1),
                  const Color(0xFF00FF2F),
                  Icons.check,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildAttendanceCard(
                  'Tidak Hadir',
                  '21',
                  const Color(0xFFFFEAEA),
                  const Color(0xFFFF3030),
                  Icons.close,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _buildAttendanceCard(
                  'Terlambat',
                  '21',
                  const Color(0xFFFFFDEA),
                  const Color(0xFFFFD500),
                  Icons.watch_later_outlined,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildAttendanceCard(
                  'Izin',
                  '21',
                  const Color(0xFFEAF8FF),
                  const Color(0xFF57B5DA),
                  Icons.calendar_today,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceCard(
    String label,
    String value,
    Color bgColor,
    Color accentColor,
    IconData icon,
  ) {
    return Container(
      height: 71,
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: bgColor,
        border: Border.all(color: accentColor),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Text(
                    label,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.black,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(height: 3),
                Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      value,
                      style: const TextStyle(
                        fontSize: 32,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 4),
          Container(
            width: 19,
            height: 19,
            decoration: BoxDecoration(
              color: accentColor,
              borderRadius: BorderRadius.circular(5),
            ),
            child: Icon(
              icon,
              size: 12,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return GestureDetector(
      onTap: () {
        setState(() {
          _showFabMenu = !_showFabMenu;
        });
      },
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: const Color(0xFF1B3C53),
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.3),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Icon(
          _showFabMenu ? Icons.close : Icons.more_vert,
          color: Colors.white,
          size: 24,
        ),
      ),
    );
  }
}
