import 'package:flutter/material.dart';

import '../injection.dart';
import '../models/user_model.dart';
import 'checkin_map_page.dart';
import 'edit_profile_page.dart';
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

  @override
  void initState() {
    super.initState();
    _profileFuture = Injection.authRepository.getProfile();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1A),
      body: IndexedStack(
        index: _currentIndex,
        children: [_buildHomeTab(), const ProfilePage()],
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
          selectedItemColor: const Color(0xFF6C63FF),
          unselectedItemColor: const Color(0xFF555577),
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
                  const Color(0xFF6C63FF).withOpacity(0.15),
                  const Color(0xFF6C63FF).withOpacity(0.0),
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
                  const Color(0xFF6C63FF).withOpacity(0.10),
                  const Color(0xFF6C63FF).withOpacity(0.0),
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
            colors: [Color(0xFF6C63FF), Color(0xFF00D2FF)],
          ).createShader(bounds),
          child: const Text(
            'Selamat Datang',
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
              colors: [Color(0xFF6C63FF), Color(0xFF00D2FF)],
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
                  colors: [Color(0xFF6C63FF), Color(0xFF00D2FF)],
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
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFF00D2FF).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.school_rounded,
                  color: Color(0xFF00D2FF),
                  size: 26,
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
        splashColor: const Color(0xFF6C63FF).withOpacity(0.15),
        highlightColor: const Color(0xFF6C63FF).withOpacity(0.08),
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
                    colors: [Color(0xFF6C63FF), Color(0xFF00D2FF)],
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
              Row(
                children: [
                  const Icon(
                    Icons.location_on_outlined,
                    color: Colors.white,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'PPKD Jakarta Pusat',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Hadir',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Rabu, 1 Juli 2026',
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: Column(
                  children: const [
                    Text(
                      'CHECK IN',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        letterSpacing: 1.2,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '-',
                      style: TextStyle(
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
                  children: const [
                    Text(
                      'CHECK OUT',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        letterSpacing: 1.2,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '-',
                      style: TextStyle(
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
          onPressed: () {
            if (snapshot.hasData) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CheckinMapPage(
                    userName: snapshot.data!.name ?? 'User',
                    isCheckIn: false, // Set to true if hasn't checked in
                  ),
                ),
              );
            }
          },
          style: snapshot.connectionState == ConnectionState.waiting
              ? ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6C63FF).withOpacity(0.5),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                )
              : ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6C63FF),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
          child: const Text(
            'Check In / Out',
            style: TextStyle(
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
