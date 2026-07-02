import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:udah_absen/models/training_model.dart';

import '../injection.dart';
import '../models/user_model.dart';

class EditProfilePage extends StatefulWidget {
  final UserModel user;

  const EditProfilePage({super.key, required this.user});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _batchIdController;
  // late final TextEditingController _trainingIdController;

  final List<TrainingModel> _trainings = [];
  TrainingModel? _selectedTraining;
  bool _isLoadingTrainings = true;
  String? _selectedJenisKelamin;
  bool _isLoading = false;
  bool _isUploadingPhoto = false;

  late AnimationController _shimmerController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user.name);
    _emailController = TextEditingController(text: widget.user.email);
    _batchIdController = TextEditingController(
      text: widget.user.batchId?.toString() ?? '',
    );
    _selectedJenisKelamin = widget.user.jenisKelamin;

    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();

    _loadTrainings();
  }

  Future<void> _loadTrainings() async {
    try {
      final trainings = await Injection.authRepository.getTrainings();
      if (mounted) {
        setState(() {
          _trainings.clear();
          _trainings.addAll(trainings);
          if (widget.user.trainingId != null) {
            _selectedTraining = _trainings.cast<TrainingModel?>().firstWhere(
              (t) => t?.id == widget.user.trainingId,
              orElse: () => null,
            );
          }
          _isLoadingTrainings = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingTrainings = false);
        _showSnackBar('Gagal memuat daftar training', isError: true);
      }
    }
    _selectedJenisKelamin = widget.user.jenisKelamin;

    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _batchIdController.dispose();
    // _trainingIdController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  // ── Design Tokens ──────────────────────────────────────────────────────
  static const _bgColor = Color(0xFF0F0F1A);
  static const _surfaceColor = Color(0xFF1A1A2E);
  static const _cardSurface = Color(0xFF16213E);
  static const _primaryColor = Color(0xFF4CAF50);
  static const _accentColor = Color(0xFF00D2FF);
  static const _borderColor = Color(0xFF2A2A4A);
  static const _textMuted = Color(0xFF8888AA);
  static const _errorColor = Color(0xFFFF6B6B);

  static const _gradient = LinearGradient(
    colors: [Color(0xFF4CAF50), Color(0xFF00D2FF)],
  );

  // ── Photo Picking ──────────────────────────────────────────────────────
  Future<void> _pickAndUploadPhoto() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image == null) return;

    setState(() => _isUploadingPhoto = true);

    try {
      await Injection.authRepository.updateProfilePhoto(File(image.path));
      if (!mounted) return;
      _showSnackBar('Foto profil berhasil diperbarui', isError: false);
    } catch (e) {
      if (!mounted) return;
      _showSnackBar('Gagal memperbarui foto: $e', isError: true);
    } finally {
      if (mounted) setState(() => _isUploadingPhoto = false);
    }
  }

  // ── Save Profile ──────────────────────────────────────────────────────
  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await Injection.authRepository.updateProfile(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        jenisKelamin: _selectedJenisKelamin!,
        batchId: int.parse(_batchIdController.text.trim()),
        trainingId: _selectedTraining!.id, // Assuming trainingId is an int
      );
      if (!mounted) return;
      _showSnackBar('Profil berhasil diperbarui', isError: false);
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      _showSnackBar('Gagal menyimpan: $e', isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String message, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.check_circle_outline,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: isError ? _errorColor : _primaryColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // ── Build ──────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: Container(
          margin: const EdgeInsets.only(left: 8),
          child: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _surfaceColor.withOpacity(0.7),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _borderColor, width: 1),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new,
                color: Colors.white,
                size: 18,
              ),
            ),
          ),
        ),
        centerTitle: true,
        title: const Text(
          'Edit Profil',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
      ),
      body: Stack(
        children: [
          // ── Background decorations ──
          Positioned(
            top: -80,
            right: -60,
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [_primaryColor.withOpacity(0.15), Colors.transparent],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -100,
            left: -80,
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [_accentColor.withOpacity(0.08), Colors.transparent],
                ),
              ),
            ),
          ),

          // ── Main content ──
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    const SizedBox(height: 12),
                    _buildPhotoSection(),
                    const SizedBox(height: 32),
                    _buildFormCard(),
                    const SizedBox(height: 32),
                    _buildSaveButton(),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Photo Section ──────────────────────────────────────────────────────
  Widget _buildPhotoSection() {
    return Column(
      children: [
        // Avatar with gradient ring
        GestureDetector(
          onTap: _isUploadingPhoto ? null : _pickAndUploadPhoto,
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: _gradient,
            ),
            child: Container(
              padding: const EdgeInsets.all(3),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: _bgColor,
              ),
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: _cardSurface,
                    backgroundImage:
                        (widget.user.profilePhotoUrl != null &&
                            widget.user.profilePhotoUrl!.isNotEmpty)
                        ? NetworkImage(widget.user.profilePhotoUrl!)
                        : null,
                    child:
                        (widget.user.profilePhotoUrl == null ||
                            widget.user.profilePhotoUrl!.isEmpty)
                        ? Text(
                            _getInitials(widget.user.name),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.w700,
                            ),
                          )
                        : null,
                  ),
                  if (_isUploadingPhoto)
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _bgColor.withOpacity(0.65),
                        ),
                        child: const Center(
                          child: SizedBox(
                            width: 30,
                            height: 30,
                            child: CircularProgressIndicator(
                              strokeWidth: 3,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                _accentColor,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),

        // 'Ubah Foto' button
        GestureDetector(
          onTap: _isUploadingPhoto ? null : _pickAndUploadPhoto,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              gradient: _gradient,
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: _primaryColor.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.camera_alt_outlined, color: Colors.white, size: 16),
                SizedBox(width: 8),
                Text(
                  'Ubah Foto',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ── Form Card (Glassmorphism) ──────────────────────────────────────────
  Widget _buildFormCard() {
    return Container(
      decoration: BoxDecoration(
        color: _cardSurface.withOpacity(0.55),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _borderColor.withOpacity(0.6), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Section header
              Row(
                children: [
                  ShaderMask(
                    shaderCallback: (bounds) => _gradient.createShader(bounds),
                    child: const Icon(
                      Icons.edit_note_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'Informasi Pribadi',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Container(
                height: 2,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      _primaryColor.withOpacity(0.6),
                      _accentColor.withOpacity(0.6),
                      Colors.transparent,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
              const SizedBox(height: 24),

              // 1. Name
              _buildLabel('Nama Lengkap'),
              const SizedBox(height: 8),
              _buildTextField(
                controller: _nameController,
                hint: 'Masukkan nama lengkap',
                icon: Icons.person_outlined,
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Nama wajib diisi' : null,
              ),
              const SizedBox(height: 20),

              // 2. Email
              _buildLabel('Email'),
              const SizedBox(height: 8),
              _buildTextField(
                controller: _emailController,
                hint: 'Masukkan email',
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Email wajib diisi';
                  if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(v.trim())) {
                    return 'Format email tidak valid';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // 3. Jenis Kelamin
              _buildLabel('Jenis Kelamin'),
              const SizedBox(height: 8),
              _buildDropdown(),
              const SizedBox(height: 20),

              // 4. Batch ID
              _buildLabel('Batch ID'),
              const SizedBox(height: 8),
              _buildTextField(
                controller: _batchIdController,
                hint: 'Masukkan Batch ID',
                icon: Icons.groups_outlined,
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Batch ID wajib diisi';
                  }
                  if (int.tryParse(v.trim()) == null) {
                    return 'Masukkan angka yang valid';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // 5. Training ID
              _buildLabel('Training ID'),
              const SizedBox(height: 8),
              //   _buildTextField(
              //     controller: _trainingIdController,
              //     hint: 'Masukkan Training ID',
              //     icon: Icons.school_outlined,
              //     keyboardType: TextInputType.number,
              //     validator: (v) {
              //       if (v == null || v.trim().isEmpty) {
              //         return 'Training ID wajib diisi';
              //       }
              //       if (int.tryParse(v.trim()) == null) {
              //         return 'Masukkan angka yang valid';
              //       }
              //       return null;
              //     },
              //   ),
              _buildTrainingIdDropdown(),
            ],
          ),
        ),
      ),
    );
  }

  // ── Save Button ────────────────────────────────────────────────────────
  Widget _buildSaveButton() {
    return GestureDetector(
      onTap: _isLoading ? null : _saveProfile,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          gradient: _isLoading
              ? LinearGradient(
                  colors: [
                    _primaryColor.withOpacity(0.5),
                    _accentColor.withOpacity(0.5),
                  ],
                )
              : _gradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: _isLoading
              ? []
              : [
                  BoxShadow(
                    color: _primaryColor.withOpacity(0.35),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
        ),
        child: Center(
          child: _isLoading
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.save_rounded, color: Colors.white, size: 20),
                    SizedBox(width: 10),
                    Text(
                      'Simpan Perubahan',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  // ── Reusable Widgets ──────────────────────────────────────────────────
  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: _textMuted,
        fontSize: 13,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 15,
        fontWeight: FontWeight.w500,
      ),
      cursorColor: _accentColor,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
          color: _textMuted.withOpacity(0.6),
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
        prefixIcon: ShaderMask(
          shaderCallback: (bounds) => _gradient.createShader(bounds),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
        filled: true,
        fillColor: _surfaceColor.withOpacity(0.6),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: _borderColor.withOpacity(0.5)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: _borderColor.withOpacity(0.5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _accentColor, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _errorColor, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _errorColor, width: 1.5),
        ),
        errorStyle: const TextStyle(
          color: _errorColor,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildDropdown() {
    return DropdownButtonFormField<String>(
      isExpanded: true,
      initialValue: _selectedJenisKelamin,
      onChanged: (value) => setState(() => _selectedJenisKelamin = value),
      validator: (v) =>
          (v == null || v.isEmpty) ? 'Jenis kelamin wajib dipilih' : null,
      dropdownColor: _cardSurface,
      icon: ShaderMask(
        shaderCallback: (bounds) => _gradient.createShader(bounds),
        child: const Icon(
          Icons.keyboard_arrow_down_rounded,
          color: Colors.white,
        ),
      ),
      style: const TextStyle(
        color: Colors.white,
        fontSize: 15,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        prefixIcon: ShaderMask(
          shaderCallback: (bounds) => _gradient.createShader(bounds),
          child: const Icon(Icons.wc_outlined, color: Colors.white, size: 20),
        ),
        filled: true,
        fillColor: _surfaceColor.withOpacity(0.6),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: _borderColor.withOpacity(0.5)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: _borderColor.withOpacity(0.5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _accentColor, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _errorColor, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _errorColor, width: 1.5),
        ),
        errorStyle: const TextStyle(
          color: _errorColor,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
      items: const [
        DropdownMenuItem(value: 'L', child: Text('Laki-laki')),
        DropdownMenuItem(value: 'P', child: Text('Perempuan')),
      ],
    );
  }

  Widget _buildTrainingIdDropdown() {
    return DropdownButtonFormField<TrainingModel>(
      isExpanded: true,
      initialValue: _selectedTraining,
      onChanged: (value) {
        setState(() {
          _selectedTraining = value;
        });
      },
      validator: (v) => (v == null) ? 'Training ID wajib dipilih' : null,
      dropdownColor: _cardSurface,
      icon: ShaderMask(
        shaderCallback: (bounds) => _gradient.createShader(bounds),
        child: const Icon(
          Icons.keyboard_arrow_down_rounded,
          color: Colors.white,
        ),
      ),
      style: const TextStyle(
        color: Colors.white,
        fontSize: 15,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        prefixIcon: ShaderMask(
          shaderCallback: (bounds) => _gradient.createShader(bounds),
          child: const Icon(
            Icons.school_outlined,
            color: Colors.white,
            size: 20,
          ),
        ),
        filled: true,
        fillColor: _surfaceColor.withOpacity(0.6),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: _borderColor.withOpacity(0.5)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: _borderColor.withOpacity(0.5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _accentColor, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _errorColor, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _errorColor, width: 1.5),
        ),
        errorStyle: const TextStyle(
          color: _errorColor,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
      items: _trainings.map((training) {
        return DropdownMenuItem<TrainingModel>(
          value: training,
          child: Text(
            training.title,
            style: const TextStyle(color: Colors.white),
          ),
        );
      }).toList(),
      hint: _isLoadingTrainings
          ? const Text('Memuat...', style: TextStyle(color: Colors.white))
          : null,
    );
  }

  String _getInitials(String? name) {
    if (name == null || name.trim().isEmpty) return '?';
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return parts[0][0].toUpperCase();
  }
}
