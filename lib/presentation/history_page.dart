import 'package:flutter/material.dart';

class HistoryPage extends StatelessWidget {
  final DateTime? checkInTime;
  final DateTime? checkOutTime;

  const HistoryPage({super.key, this.checkInTime, this.checkOutTime});

  static const _bgColor = Color(0xFF0F0F1A);
  static const _surfaceColor = Color(0xFF1A1A2E);
  static const _cardSurface = Color(0xFF16213E);
  static const _borderColor = Color(0xFF2A2A4A);
  static const _textMuted = Color(0xFF8888AA);

  @override
  Widget build(BuildContext context) {
    final hasData = checkInTime != null;

    return Scaffold(
      backgroundColor: _bgColor,
      appBar: AppBar(
        backgroundColor: _surfaceColor,
        title: const Text('Riwayat Absensi', style: TextStyle(color: Colors.white)),
        elevation: 0,
        centerTitle: true,
      ),
      body: !hasData
          ? const Center(
              child: Text(
                'Belum ada riwayat absensi hari ini.',
                style: TextStyle(color: _textMuted, fontSize: 16),
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _cardSurface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: _borderColor),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${checkInTime!.day}/${checkInTime!.month}/${checkInTime!.year}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Check In: ${checkInTime!.hour.toString().padLeft(2, '0')}:${checkInTime!.minute.toString().padLeft(2, '0')} | '
                              'Check Out: ${checkOutTime != null ? '${checkOutTime!.hour.toString().padLeft(2, '0')}:${checkOutTime!.minute.toString().padLeft(2, '0')}' : '-'}',
                              style: const TextStyle(
                                  color: _textMuted, fontSize: 14),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Status: Hadir',
                              style: const TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.w600,
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
}
