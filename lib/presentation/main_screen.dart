import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../injection.dart';
import '../models/user_model.dart';
import 'checkin_map_page.dart';
import 'edit_profile_page.dart';
import 'history_page.dart';
import 'leave_page.dart';
import 'profile_page.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  // Store future so it doesn't re-fetch on rebuild
  late final Future<UserModel> _profileFuture;
  bool _hasCheckedIn = false;
  DateTime? _checkInTime;
  DateTime? _checkOutTime;
  String _currentAddress = 'PPKD Jakarta Pusat';

  @override
  void initState() {
    super.initState();
    _profileFuture = Injection.authRepository.getProfile();
    _loadAttendanceState();
  }

  Future<void> _loadAttendanceState() async {
    final prefs = await SharedPreferences.getInstance();
    final today = _getFormattedDate();
    final savedDate = prefs.getString('attendance_date');

    if (savedDate == today) {
      setState(() {
        _hasCheckedIn = prefs.getBool('has_checked_in') ?? false;
        final inTimeStr = prefs.getString('check_in_time');
        final outTimeStr = prefs.getString('check_out_time');
        if (inTimeStr != null) _checkInTime = DateTime.parse(inTimeStr);
        if (outTimeStr != null) _checkOutTime = DateTime.parse(outTimeStr);
        _currentAddress = prefs.getString('current_address') ?? _currentAddress;
      });
    } else {
      // Reset for a new day
      await prefs.setString('attendance_date', today);
      await prefs.setBool('has_checked_in', false);
      await prefs.remove('check_in_time');
      await prefs.remove('check_out_time');
      await prefs.remove('current_address');
    }
  }

  Future<void> _saveAttendanceState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_checked_in', _hasCheckedIn);
    if (_checkInTime != null) {
      await prefs.setString('check_in_time', _checkInTime!.toIso8601String());
    }
    if (_checkOutTime != null) {
      await prefs.setString('check_out_time', _checkOutTime!.toIso8601String());
    }
    await prefs.setString('current_address', _currentAddress);
  }

  String _getFormattedDate() {
    final now = DateTime.now();
    const days = [
      'Senin',
      'Selasa',
      'Rabu',
      'Kamis',
      'Jumat',
      'Sabtu',
      'Minggu',
    ];
    const months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];
    return '${days[now.weekday - 1]}, ${now.day} ${months[now.month - 1]} ${now.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1A),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _buildHomeTab(),
          HistoryPage(checkInTime: _checkInTime, checkOutTime: _checkOutTime),
          const LeavePage(),
          const ProfilePage(),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Color(0xFF1A1A2E),
          border: Border(top: BorderSide(color: Color(0xFF2A2A4A), width: 1)),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          backgroundColor: const Color(0xFF1A1A2E),
          selectedItemColor: const Color(0xFF4CAF50),
          unselectedItemColor: const Color(0xFF00D2FF),
          type: BottomNavigationBarType.fixed,
          elevation: 0,
          selectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
          unselectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 12,
          ),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_rounded),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.history_rounded),
              label: 'Riwayat',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.note_alt_rounded),
              label: 'Izin',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_rounded),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }

  // ─── HOME TAB ─────────────────────────────────────────────────────────
  Widget _buildHomeTab() {
    return Stack(
      children: [
        // Decorative gradient circle – top right
        Positioned(
          top: -80,
          right: -60,
          child: Container(
            width: 220,
            height: 220,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  const Color(0xFF4CAF50).withValues(),
                  const Color(0xFF4CAF50).withValues(),
                ],
              ),
            ),
          ),
        ),
        // Decorative gradient circle – bottom left
        Positioned(
          bottom: -100,
          left: -80,
          child: Container(
            width: 260,
            height: 260,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  const Color(0xFF00D2FF).withOpacity(0.10),
                  const Color(0xFF00D2FF).withOpacity(0.0),
                ],
              ),
            ),
          ),
        ),
        // Decorative gradient circle – center left
        Positioned(
          top: 300,
          left: -40,
          child: Container(
            width: 160,
            height: 160,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  const Color(0xFF4CAF50).withOpacity(0.10),
                  const Color(0xFF4CAF50).withOpacity(0.0),
                ],
              ),
            ),
          ),
        ),

        // ── Main content ──────────────────────────────────────────────
        SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: FutureBuilder<UserModel>(
              future: _profileFuture,
              builder: (context, snapshot) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Greeting ──────────────────────────────────────
                    _buildGreetingSection(snapshot),
                    const SizedBox(height: 28),

                    // ── Check In Card ────────────────────────────
                    _buildAttendanceCard(snapshot),
                    const SizedBox(height: 16),
                    _buildCheckInAction(snapshot),
                    const SizedBox(height: 32),

                    // ── Training Info Card ────────────────────────────
                    _buildTrainingInfoCard(snapshot),
                    const SizedBox(height: 32),

                    // ── Quick Actions ─────────────────────────────────
                    const Text(
                      'Quick Actions',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildQuickActions(snapshot),
                    const SizedBox(height: 24),
                  ],
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  // ─── GREETING SECTION ─────────────────────────────────────────────────
  Widget _buildGreetingSection(AsyncSnapshot<UserModel> snapshot) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [Color(0xFF4CAF50), Color(0xFF00D2FF)],
          ).createShader(bounds),
          child: const Text(
            'AbsenDulu',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: Colors.white, // required for ShaderMask
              height: 1.2,
            ),
          ),
        ),
        const SizedBox(height: 8),
        if (snapshot.connectionState == ConnectionState.waiting)
          _buildShimmerPlaceholder(width: 180, height: 20)
        else if (snapshot.hasData)
          ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              colors: [Color(0xFF4CAF50), Color(0xFF00D2FF)],
            ).createShader(bounds),
            child: Text(
              '${snapshot.data!.name}! 👋',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
      ],
    );
  }

  // ─── TRAINING INFO CARD ───────────────────────────────────────────────
  Widget _buildTrainingInfoCard(AsyncSnapshot<UserModel> snapshot) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF2A2A4A), width: 1),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Row(
          children: [
            // Left accent gradient strip
            Container(
              width: 4,
              height: 110,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF4CAF50), Color(0xFF00D2FF)],
                ),
              ),
            ),
            // Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 18,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Training Aktif',
                      style: TextStyle(
                        color: Color(0xFF8888AA),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (snapshot.connectionState ==
                        ConnectionState.waiting) ...[
                      _buildShimmerPlaceholder(width: 200, height: 16),
                      const SizedBox(height: 6),
                      _buildShimmerPlaceholder(width: 120, height: 14),
                    ] else if (snapshot.hasData) ...[
                      Text(
                        snapshot.data!.trainingTitle ?? '-',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Batch ${snapshot.data!.batchKe ?? '-'}',
                        style: const TextStyle(
                          color: Color(0xFF8888AA),
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            // Icon
            Padding(
              padding: const EdgeInsets.only(right: 18),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: const Icon(
                  Icons.school_rounded,
                  color: Color(0xFF4CAF50),
                  size: 32,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── QUICK ACTIONS ────────────────────────────────────────────────────
  Widget _buildQuickActions(AsyncSnapshot<UserModel> snapshot) {
    return Row(
      children: [
        Expanded(
          child: _buildActionCard(
            icon: Icons.person_outline,
            label: 'Profil Saya',
            onTap: () => setState(() => _currentIndex = 1),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: _buildActionCard(
            icon: Icons.edit_outlined,
            label: 'Edit Profil',
            onTap: () {
              if (snapshot.hasData) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => EditProfilePage(user: snapshot.data!),
                  ),
                );
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        splashColor: const Color(0xFF4CAF50).withValues(),
        highlightColor: const Color(0xFF4CAF50).withValues(),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 16),
          decoration: BoxDecoration(
            color: const Color(0xFF16213E),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF2A2A4A), width: 1),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  gradient: const LinearGradient(
                    colors: [Color(0xFF4CAF50), Color(0xFF00D2FF)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Icon(icon, color: Colors.white, size: 24),
              ),
              const SizedBox(height: 12),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── ATTENDANCE CARD ───────────────────────────────────────────────
  Widget _buildAttendanceCard(AsyncSnapshot<UserModel> snapshot) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      color: Colors.white,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _currentAddress,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: _hasCheckedIn
                      ? const Color(0xFF4CAF50).withOpacity(0.2)
                      : Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _hasCheckedIn ? 'Hadir' : 'Belum Absen',
                  style: TextStyle(
                    color: _hasCheckedIn
                        ? const Color(0xFF4CAF50)
                        : Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _getFormattedDate(),
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    const Text(
                      'CHECK IN',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _checkInTime != null
                          ? "${_checkInTime!.hour.toString().padLeft(2, '0')}:${_checkInTime!.minute.toString().padLeft(2, '0')}"
                          : '-',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 1,
                height: 40,
                color: Colors.white.withOpacity(0.3),
              ),
              Expanded(
                child: Column(
                  children: [
                    const Text(
                      'CHECK OUT',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _checkOutTime != null
                          ? "${_checkOutTime!.hour.toString().padLeft(2, '0')}:${_checkOutTime!.minute.toString().padLeft(2, '0')}"
                          : '-',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─── CHECK IN ACTION CARD ───────────────────────────────────────────────
  Widget _buildCheckInAction(AsyncSnapshot<UserModel> snapshot) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: (_hasCheckedIn && _checkOutTime != null)
              ? null
              : () async {
                  if (snapshot.hasData) {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CheckinMapPage(
                          userName: snapshot.data!.name ?? 'User',
                          isCheckIn:
                              !_hasCheckedIn, // Set to true if hasn't checked in
                        ),
                      ),
                    );

                    if (result != null && result is Map<String, dynamic>) {
                      setState(() {
                        _currentAddress = result['address'] ?? _currentAddress;
                        if (!_hasCheckedIn) {
                          _hasCheckedIn = true;
                          _checkInTime = result['time'];
                        } else {
                          _checkOutTime = result['time'];
                        }
                      });
                      await _saveAttendanceState();
                    }
                  }
                },
          style: snapshot.connectionState == ConnectionState.waiting
              ? ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4CAF50).withValues(),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                )
              : ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4CAF50),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
          child: Text(
            _hasCheckedIn && _checkOutTime != null
                ? 'Absen Selesai Hari Ini'
                : (_hasCheckedIn ? 'Check Out' : 'Check In'),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          // Container(
          //   padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          //   decoration: BoxDecoration(
          //     color: Colors.white,
          //     borderRadius: BorderRadius.circular(24),
          //   ),
          //   child: Row(
          //     mainAxisAlignment: MainAxisAlignment.center,
          //     children: [
          //       // Row(
          //       //   children: [
          //       //     // Container(
          //       //     //   padding: const EdgeInsets.all(10),
          //       //     //   decoration: BoxDecoration(
          //       //     //     color: const Color(0xFFE8F5E9),
          //       //     //     shape: BoxShape.circle,
          //       //     //   ),
          //       //     //   child: const Icon(
          //       //     //     Icons.access_time_filled,
          //       //     //     color: Color(0xFF1976D2),
          //       //     //     size: 24,
          //       //     //   ),
          //       //     // ),
          //       //     // const SizedBox(width: 16),
          //       //     // Column(
          //       //     //   crossAxisAlignment: CrossAxisAlignment.start,
          //       //     //   children: const [
          //       //     //     Text(
          //       //     //       'Masuk: -',
          //       //     //       style: TextStyle(
          //       //     //         color: Colors.black87,
          //       //     //         fontWeight: FontWeight.bold,
          //       //     //         fontSize: 14,
          //       //     //       ),
          //       //     //     ),
          //       //     //     SizedBox(height: 4),
          //       //     //     Text(
          //       //     //       'Pulang: -',
          //       //     //       style: TextStyle(color: Colors.black54, fontSize: 14),
          //       //     //     ),
          //       //     //   ],
          //       //     // ),
          //       //   ],
          //       // ),
          //       // ElevatedButton(
          //       //   onPressed: () {
          //       //     if (snapshot.hasData) {
          //       //       Navigator.push(
          //       //         context,
          //       //         MaterialPageRoute(
          //       //           builder: (_) => CheckinMapPage(
          //       //             userName: snapshot.data!.name ?? 'User',
          //       //             isCheckIn: false, // Set to true if hasn't checked in
          //       //           ),
          //       //         ),
          //       //       );
          //       //     }
          //       //   },
          //       //   style: ElevatedButton.styleFrom(
          //       //     backgroundColor: const Color(0xFFEF5350), // Red button
          //       //     shape: RoundedRectangleBorder(
          //       //       borderRadius: BorderRadius.circular(20),
          //       //     ),
          //       //     padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          //       //     elevation: 0,
          //       //   ),
          //       //   child: const Text(
          //       //     'Check Out',
          //       //     style: TextStyle(
          //       //       color: Colors.white,
          //       //       fontWeight: FontWeight.bold,
          //       //     ),
          //       //   ),
          //       // ),
          //     ],
          //   ),
          // ),
        ),
      ),
    );
  }

  // ─── SHIMMER PLACEHOLDER ──────────────────────────────────────────────
  Widget _buildShimmerPlaceholder({
    required double width,
    required double height,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        gradient: const LinearGradient(
          colors: [Color(0xFF2A2A4A), Color(0xFF1A1A2E), Color(0xFF2A2A4A)],
          stops: [0.0, 0.5, 1.0],
        ),
      ),
    );
  }
}
