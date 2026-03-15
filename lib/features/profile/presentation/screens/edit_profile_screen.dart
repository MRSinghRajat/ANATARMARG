import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/services/supabase_service.dart';
import '../../data/repositories/app_profile_repository.dart';

/// Edit profile: name, email, gender, profile image.
/// Updates Supabase Auth user metadata and optionally Storage for avatar.
class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  String? _gender;
  String? _avatarPath;
  File? _pickedImageFile;
  bool _saving = false;
  String? _error;

  static const List<String> genderOptions = ['Prefer not to say', 'Male', 'Female', 'Other'];

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
  }

  void _loadCurrentUser() {
    final user = SupabaseService().client?.auth.currentUser;
    if (user != null) {
      _nameController.text =
          user.userMetadata?['full_name']?.toString() ??
              user.userMetadata?['name']?.toString() ??
              user.email?.split('@').first ??
              '';
      _emailController.text = user.email ?? '';
      setState(() {
        _gender = user.userMetadata?['gender']?.toString();
        _avatarPath = user.userMetadata?['avatar_url']?.toString();
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final picker = ImagePicker();
      final source = await showModalBottomSheet<ImageSource>(
        context: context,
        backgroundColor: AppColors.ashramBackgroundDark,
        builder: (ctx) => SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Profile photo',
                  style: GoogleFonts.outfit(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextButton.icon(
                        onPressed: () => Navigator.pop(ctx, ImageSource.camera),
                        icon: const Icon(Icons.camera_alt, color: Colors.white70),
                        label: const Text('Camera', style: TextStyle(color: Colors.white70)),
                      ),
                    ),
                    Expanded(
                      child: TextButton.icon(
                        onPressed: () => Navigator.pop(ctx, ImageSource.gallery),
                        icon: const Icon(Icons.photo_library, color: Colors.white70),
                        label: const Text('Gallery', style: TextStyle(color: Colors.white70)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
      if (source == null || !mounted) return;
      final XFile? file = await picker.pickImage(
        source: source,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );
      if (file != null && mounted) {
        setState(() {
          _pickedImageFile = File(file.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not pick image: $e')),
        );
      }
    }
  }

  Future<String?> _uploadAvatarIfPicked() async {
    if (_pickedImageFile == null || !_pickedImageFile!.existsSync()) return _avatarPath;
    final client = SupabaseService().client;
    if (client == null) return _avatarPath;
    final userId = SupabaseService().currentUserId;
    if (userId == null) return _avatarPath;
    try {
      final path = '$userId/avatar.jpg';
      await client.storage.from('avatars').upload(
            path,
            _pickedImageFile!,
            fileOptions: const FileOptions(upsert: true),
          );
      return client.storage.from('avatars').getPublicUrl(path);
    } catch (e) {
      debugPrint('Avatar upload error: $e');
      return _avatarPath;
    }
  }

  Future<void> _save() async {
    _error = null;
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _saving = true);
    try {
      final newAvatarUrl = await _uploadAvatarIfPicked();
      final name = _nameController.text.trim();
      final email = _emailController.text.trim();
      final data = <String, dynamic>{
        'full_name': name,
        if (newAvatarUrl != null) 'avatar_url': newAvatarUrl,
        if (_gender != null) 'gender': _gender,
      };
      final currentEmail = SupabaseService().client?.auth.currentUser?.email ?? '';
      await SupabaseService().client!.auth.updateUser(
        UserAttributes(
          data: data,
          email: email.isEmpty || email == currentEmail ? null : email,
        ),
      );
      await SupabaseService().client!.auth.refreshSession();
      await AppProfileRepository().upsertProfile(
        displayName: name.isNotEmpty ? name : null,
        avatarUrl: newAvatarUrl,
      );
      if (mounted) {
        Navigator.of(context).pop(true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated')),
        );
      }
    } on AuthException catch (e) {
      setState(() {
        _error = e.message;
        _saving = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _saving = false;
      });
    }
    if (mounted) setState(() => _saving = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        title: Text(
          'Edit Profile',
          style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white70),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          TextButton(
            onPressed: _saving ? null : _save,
            child: _saving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white70),
                  )
                : Text('Save', style: GoogleFonts.poppins(color: AppColors.primaryOrange, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: GestureDetector(
                  onTap: _pickImage,
                  child: Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.white12,
                        backgroundImage: _pickedImageFile != null
                            ? FileImage(_pickedImageFile!)
                            : (_avatarPath != null && _avatarPath!.isNotEmpty)
                                ? NetworkImage(_avatarPath!) as ImageProvider
                                : null,
                        child: _pickedImageFile == null &&
                                (_avatarPath == null || _avatarPath!.isEmpty)
                            ? Icon(Icons.person, size: 50, color: Colors.white38)
                            : null,
                      ),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: AppColors.primaryOrange,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 28),
              Text(
                'Name',
                style: GoogleFonts.poppins(color: Colors.white70, fontSize: 12),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _nameController,
                style: GoogleFonts.poppins(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Your name',
                  hintStyle: GoogleFonts.poppins(color: Colors.white38),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.08),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Enter your name' : null,
              ),
              const SizedBox(height: 20),
              Text(
                'Email',
                style: GoogleFonts.poppins(color: Colors.white70, fontSize: 12),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                style: GoogleFonts.poppins(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'your@email.com',
                  hintStyle: GoogleFonts.poppins(color: Colors.white38),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.08),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Enter email';
                  if (!v.contains('@') || !v.contains('.')) return 'Enter a valid email';
                  return null;
                },
              ),
              const SizedBox(height: 20),
              Text(
                'Gender',
                style: GoogleFonts.poppins(color: Colors.white70, fontSize: 12),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: genderOptions.map((g) {
                  final selected = _gender == g;
                  return ChoiceChip(
                    label: Text(g, style: GoogleFonts.poppins(fontSize: 13)),
                    selected: selected,
                    onSelected: (v) => setState(() => _gender = g),
                    selectedColor: AppColors.primaryOrange.withOpacity(0.4),
                    labelStyle: TextStyle(
                      color: selected ? Colors.white : Colors.white70,
                    ),
                  );
                }).toList(),
              ),
              if (_error != null) ...[
                const SizedBox(height: 16),
                Text(
                  _error!,
                  style: GoogleFonts.poppins(color: Colors.redAccent, fontSize: 13),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
