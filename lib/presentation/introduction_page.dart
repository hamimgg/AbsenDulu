import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../injection.dart';
import 'login_page.dart';
import 'main_screen.dart';

class IntroductionPage extends StatefulWidget {
  final bool isFromProfile;

  const IntroductionPage({super.key, this.isFromProfile = false});

  @override
  State<IntroductionPage> createState() => _IntroductionPageState();
}

class _IntroductionPageState extends State<IntroductionPage> {
  final _introKey = GlobalKey<IntroductionScreenState>();

  Future<void> _onIntroEnd(BuildContext context) async {
    if (widget.isFromProfile) {
      Navigator.pop(context);
    } else {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('seen_introduction', true);

      final isLoggedIn = await Injection.authRepository.isLoggedIn();

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => isLoggedIn ? const MainScreen() : const LoginPage(),
          ),
        );
      }
    }
  }

  // ─── CUSTOM GRAPHIC WIDGETS FOR TUTORIAL ───────────────────────────────

  // Slide 1: Welcome / Logo
  Widget _buildWelcomeGraphic() {
    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer glowing background
          Container(
            width: 180,
            height: 180,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  const Color(0xFF4CAF50).withOpacity(0.2),
                  const Color(0xFF00D2FF).withOpacity(0.0),
                ],
              ),
            ),
          ),
          // Gradient Ring
          Container(
            width: 130,
            height: 130,
            padding: const EdgeInsets.all(4),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [Color(0xFF4CAF50), Color(0xFF00D2FF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Container(
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFF0F0F1A),
              ),
              padding: const EdgeInsets.all(12),
              child: Image.asset(
                'lib/assets/images/logo.png',
                fit: BoxFit.contain,
              ),
            ),
          ),
          // Orbital dots
          Positioned(
            top: 15,
            right: 15,
            child: _buildOrbitalDot(const Color(0xFF4CAF50), 10),
          ),
          Positioned(
            bottom: 20,
            left: 10,
            child: _buildOrbitalDot(const Color(0xFF00D2FF), 8),
          ),
          Positioned(
            bottom: 40,
            right: 5,
            child: _buildOrbitalDot(const Color(0xFF4CAF50), 12),
          ),
        ],
      ),
    );
  }

  Widget _buildOrbitalDot(Color color, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.6),
            blurRadius: size,
            spreadRadius: 2,
          ),
        ],
      ),
    );
  }

  // Slide 2: Map & GPS Location
  Widget _buildLocationGraphic() {
    return Container(
      width: 260,
      height: 180,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF16213E),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF2A2A4A)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Map simulation representation
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A2E),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF2A2A4A)),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Map grid lines
                  Positioned.fill(
                    child: GridView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 6,
                          ),
                      itemCount: 24,
                      itemBuilder: (context, index) {
                        return Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: const Color(0xFF2A2A4A).withOpacity(0.3),
                              width: 0.5,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  // Radar Pulse
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF4CAF50).withOpacity(0.15),
                      border: Border.all(
                        color: const Color(0xFF4CAF50).withOpacity(0.4),
                        width: 1.5,
                      ),
                    ),
                  ),
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF4CAF50).withOpacity(0.25),
                    ),
                  ),
                  // Location Marker
                  const Icon(
                    Icons.location_on_rounded,
                    color: Color(0xFF4CAF50),
                    size: 28,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Address details card mock
          Row(
            children: [
              const Icon(
                Icons.my_location_rounded,
                color: Color(0xFF00D2FF),
                size: 16,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'PPKD Jakarta Pusat',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFF4CAF50).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'GPS AKTIF',
                  style: TextStyle(
                    color: Color(0xFF4CAF50),
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Slide 3: History list representation
  Widget _buildHistoryGraphic() {
    return Container(
      width: 260,
      height: 180,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF16213E),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF2A2A4A)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Riwayat Hari Ini',
                style: TextStyle(
                  color: Color(0xFF8888AA),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Icon(
                Icons.calendar_month_rounded,
                color: Color(0xFF4CAF50),
                size: 18,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ListView(
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildMockHistoryItem(
                  date: 'Senin, 07 Jul',
                  inTime: '08:00',
                  outTime: '16:00',
                  status: 'Hadir',
                  statusColor: const Color(0xFF4CAF50),
                ),
                const SizedBox(height: 8),
                _buildMockHistoryItem(
                  date: 'Selasa, 08 Jul',
                  inTime: '07:55',
                  outTime: '--:--',
                  status: 'Sedang Berlangsung',
                  statusColor: const Color(0xFF00D2FF),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMockHistoryItem({
    required String date,
    required String inTime,
    required String outTime,
    required String status,
    required Color statusColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF2A2A4A).withOpacity(0.5)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  date,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  'In: $inTime | Out: $outTime',
                  style: const TextStyle(
                    color: Color(0xFF8888AA),
                    fontSize: 10,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              status,
              style: TextStyle(
                color: statusColor,
                fontSize: 9,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Slide 4: Leave Form & List representation
  Widget _buildLeaveGraphic() {
    return Container(
      width: 260,
      height: 180,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF16213E),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF2A2A4A)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Status Permohonan Izin',
                style: TextStyle(
                  color: Color(0xFF8888AA),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Icon(
                Icons.note_alt_rounded,
                color: Color(0xFF4CAF50),
                size: 18,
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Form Mock representation
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A2E),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFF2A2A4A).withOpacity(0.5),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF9800).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.warning_amber_rounded,
                    color: Color(0xFFFF9800),
                    size: 18,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Text(
                        'Izin Sakit Demam',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Tanggal: 07/07/2026',
                        style: TextStyle(
                          color: Color(0xFF8888AA),
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF9800).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'Menunggu',
                    style: TextStyle(
                      color: Color(0xFFFF9800),
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          // Prompt to add leave
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
              decoration: BoxDecoration(
                border: Border.all(
                  color: const Color(0xFF4CAF50).withOpacity(0.4),
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(
                    Icons.add_circle_outline_rounded,
                    color: Color(0xFF4CAF50),
                    size: 12,
                  ),
                  SizedBox(width: 4),
                  Text(
                    'Ajukan Izin Baru',
                    style: TextStyle(
                      color: Color(0xFF4CAF50),
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Slide 5: Profile & Active Training Info representation
  Widget _buildProfileGraphic() {
    return Container(
      width: 260,
      height: 180,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF16213E),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF2A2A4A)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [Color(0xFF4CAF50), Color(0xFF00D2FF)],
                  ),
                ),
                padding: const EdgeInsets.all(2),
                child: Container(
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFF1A1A2E),
                  ),
                  child: const Center(
                    child: Text(
                      'AD',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Peserta Training',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'absendulu@example.com',
                      style: TextStyle(color: Color(0xFF8888AA), fontSize: 10),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.verified_user_rounded,
                color: Color(0xFF00D2FF),
                size: 20,
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Active training info box
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A2E),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFF2A2A4A).withOpacity(0.5),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.school_rounded,
                  color: Color(0xFF4CAF50),
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Mobile Programming',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Batch 6 • PPKD Jakpus',
                        style: TextStyle(
                          color: Color(0xFF8888AA),
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── BUILD ─────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    const pageDecoration = PageDecoration(
      titleTextStyle: TextStyle(
        fontSize: 24.0,
        fontWeight: FontWeight.w800,
        color: Colors.white,
        letterSpacing: -0.5,
      ),
      bodyTextStyle: TextStyle(
        fontSize: 14.0,
        color: Color(0xFF8888AA),
        height: 1.5,
      ),
      imagePadding: EdgeInsets.only(top: 60, bottom: 20),
      titlePadding: EdgeInsets.only(top: 10, bottom: 12),
      bodyPadding: EdgeInsets.symmetric(horizontal: 24),
      pageColor: Color(0xFF0F0F1A),
    );

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1A),
      body: SafeArea(
        child: IntroductionScreen(
          key: _introKey,
          globalBackgroundColor: const Color(0xFF0F0F1A),
          pages: [
            PageViewModel(
              title: "Selamat Datang!",
              body:
                  "AbsenDulu adalah aplikasi absensi digital untuk mempermudah Anda melakukan presensi training secara real-time dan terintegrasi.",
              image: _buildWelcomeGraphic(),
              decoration: pageDecoration,
            ),
            PageViewModel(
              title: "Presensi GPS",
              body:
                  "Lakukan Check In dan Check Out berbasis lokasi GPS secara presisi. Aplikasi akan mencatat koordinat dan alamat Anda saat ini secara otomatis.",
              image: _buildLocationGraphic(),
              decoration: pageDecoration,
            ),
            PageViewModel(
              title: "Pantau Riwayat",
              body:
                  "Lihat ringkasan kehadiran harian Anda dengan mudah. Waktu Check In dan Check Out tercatat dengan lengkap dan transparan.",
              image: _buildHistoryGraphic(),
              decoration: pageDecoration,
            ),
            PageViewModel(
              title: "Izin & Cuti Mudah",
              body:
                  "Berhalangan hadir atau sakit? Anda dapat mengajukan permohonan izin langsung dari aplikasi dengan menuliskan keterangan secara praktis.",
              image: _buildLeaveGraphic(),
              decoration: pageDecoration,
            ),
            PageViewModel(
              title: "Profil & Kelas",
              body:
                  "Akses detail akun, pastikan Anda berada di training dan batch yang sesuai, serta perbarui foto profil untuk verifikasi.",
              image: _buildProfileGraphic(),
              decoration: pageDecoration,
            ),
          ],
          onDone: () => _onIntroEnd(context),
          onSkip: () => _onIntroEnd(context),
          showSkipButton: true,
          skip: const Text(
            "LEWATI",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF8888AA),
              fontSize: 13,
            ),
          ),
          next: const Icon(
            Icons.arrow_forward_rounded,
            color: Color(0xFF4CAF50),
          ),
          done: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF4CAF50),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF4CAF50).withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Text(
              "MULAI",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontSize: 13,
              ),
            ),
          ),
          curve: Curves.fastOutSlowIn,
          controlsMargin: const EdgeInsets.all(16),
          controlsPadding: const EdgeInsets.symmetric(vertical: 8),
          dotsDecorator: DotsDecorator(
            size: const Size(8.0, 8.0),
            color: const Color(0xFF2A2A4A),
            activeSize: const Size(20.0, 8.0),
            activeColor: const Color(0xFF4CAF50),
            activeShape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(25.0)),
            ),
          ),
        ),
      ),
    );
  }
}
