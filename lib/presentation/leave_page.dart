import 'package:flutter/material.dart';

class LeavePage extends StatefulWidget {
  const LeavePage({super.key});

  @override
  State<LeavePage> createState() => _LeavePageState();
}

class LeaveRecord {
  String id;
  String reason;
  DateTime startDate;
  DateTime endDate;
  String status;

  LeaveRecord({
    required this.id,
    required this.reason,
    required this.startDate,
    required this.endDate,
    required this.status,
  });
}

class _LeavePageState extends State<LeavePage> {
  // Mock Data
  final List<LeaveRecord> _records = [
    LeaveRecord(
      id: '1',
      reason: 'Sakit Demam',
      startDate: DateTime.now().subtract(const Duration(days: 5)),
      endDate: DateTime.now().subtract(const Duration(days: 4)),
      status: 'Disetujui',
    ),
    LeaveRecord(
      id: '2',
      reason: 'Acara Keluarga',
      startDate: DateTime.now().add(const Duration(days: 2)),
      endDate: DateTime.now().add(const Duration(days: 3)),
      status: 'Menunggu',
    ),
  ];

  static const _bgColor = Color(0xFF0F0F1A);
  static const _surfaceColor = Color(0xFF1A1A2E);
  static const _cardSurface = Color(0xFF16213E);
  static const _primaryColor = Color(0xFF4CAF50);
  static const _borderColor = Color(0xFF2A2A4A);
  static const _textMuted = Color(0xFF8888AA);

  void _showFormDialog({LeaveRecord? record}) {
    final isEditing = record != null;
    final reasonCtrl = TextEditingController(text: record?.reason ?? '');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: _surfaceColor,
        title: Text(
          isEditing ? 'Edit Izin' : 'Ajukan Izin',
          style: const TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: reasonCtrl,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Alasan / Keterangan',
                labelStyle: TextStyle(color: _textMuted),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: _borderColor),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Untuk demo, tanggal izin otomatis di-set ke hari ini',
              style: TextStyle(color: _textMuted, fontSize: 12),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal', style: TextStyle(color: _textMuted)),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                if (isEditing) {
                  record.reason = reasonCtrl.text;
                } else {
                  _records.insert(
                    0,
                    LeaveRecord(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      reason: reasonCtrl.text,
                      startDate: DateTime.now(),
                      endDate: DateTime.now(),
                      status: 'Menunggu',
                    ),
                  );
                }
              });
              Navigator.pop(ctx);
            },
            child: const Text('Simpan', style: TextStyle(color: _primaryColor)),
          ),
        ],
      ),
    );
  }

  void _deleteRecord(String id) {
    setState(() {
      _records.removeWhere((r) => r.id == id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      appBar: AppBar(
        backgroundColor: _surfaceColor,
        title: const Text('Izin & Cuti', style: TextStyle(color: Colors.white)),
        elevation: 0,
        centerTitle: true,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _records.length,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final record = _records[index];
          return Container(
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
                        record.reason,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Tanggal: ${record.startDate.day}/${record.startDate.month}/${record.startDate.year}',
                        style: const TextStyle(color: _textMuted, fontSize: 14),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Status: ${record.status}',
                        style: TextStyle(
                          color: record.status == 'Disetujui'
                              ? Colors.green
                              : Colors.orange,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit, color: _primaryColor),
                  onPressed: () => _showFormDialog(record: record),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.redAccent),
                  onPressed: () => _deleteRecord(record.id),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showFormDialog(),
        backgroundColor: _primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
