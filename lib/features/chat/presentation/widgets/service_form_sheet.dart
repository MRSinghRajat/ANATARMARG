import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/models/spiritual_service.dart';

/// Bottom sheet form for collecting user data based on selected service.
class ServiceFormSheet extends StatefulWidget {
  final SpiritualServiceType service;
  final Function(Map<String, dynamic>) onSubmit;

  const ServiceFormSheet({
    super.key,
    required this.service,
    required this.onSubmit,
  });

  @override
  State<ServiceFormSheet> createState() => _ServiceFormSheetState();
}

class _ServiceFormSheetState extends State<ServiceFormSheet> {
  final _formKey = GlobalKey<FormState>();
  final Map<ServiceFormField, TextEditingController> _controllers = {};
  final Map<ServiceFormField, DateTime?> _dateValues = {};
  final Map<ServiceFormField, File?> _imageFiles = {};
  final Map<ServiceFormField, String?> _imageBase64 = {};
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    for (final field in widget.service.requiredFields) {
      _controllers[field] = TextEditingController();
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _submitForm() {
    // Check image fields separately since they don't use controllers
    bool hasAllImages = true;
    for (final field in widget.service.requiredFields) {
      if (field.isImageField && _imageBase64[field] == null) {
        hasAllImages = false;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please upload ${field.label}')),
        );
        break;
      }
    }
    
    if (!hasAllImages) return;
    
    if (_formKey.currentState?.validate() ?? false) {
      final formData = <String, dynamic>{};
      for (final field in widget.service.requiredFields) {
        if (field.isDateField && _dateValues[field] != null) {
          formData[field.name] = DateFormat('dd/MM/yyyy').format(_dateValues[field]!);
        } else if (field.isImageField) {
          formData[field.name] = _imageBase64[field];
        } else {
          formData[field.name] = _controllers[field]?.text ?? '';
        }
      }
      widget.onSubmit(formData);
    }
  }

  Future<void> _pickImage(ServiceFormField field, ImageSource source) async {
    try {
      // Use ImagePicker with explicit settings
      final ImagePicker picker = ImagePicker();
      final XFile? pickedFile = await picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
        requestFullMetadata: false, // Reduces permissions needed
      );
      
      if (pickedFile != null) {
        final bytes = await pickedFile.readAsBytes();
        final base64Image = base64Encode(bytes);
        
        setState(() {
          _imageFiles[field] = File(pickedFile.path);
          _imageBase64[field] = base64Image;
        });
      }
    } catch (e) {
      print('Error picking image: $e');
      if (mounted) {
        String errorMsg = 'Failed to pick image. Please try again.';
        
        // Check for specific platform errors
        if (e.toString().contains('channel-error') || e.toString().contains('PlatformException')) {
          errorMsg = 'Please restart the app and try again. If the issue persists, check camera/storage permissions in Settings.';
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMsg),
            duration: const Duration(seconds: 4),
            action: SnackBarAction(
              label: 'OK',
              onPressed: () {},
            ),
          ),
        );
      }
    }
  }

  void _showImageSourceDialog(ServiceFormField field) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.ashramBackgroundDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Upload Palm Image',
                style: GoogleFonts.cormorantGaramond(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: AppColors.ashramAccentGold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'For best results, take a clear photo of your open palm in good lighting',
                style: GoogleFonts.outfit(
                  fontSize: 13,
                  color: Colors.white.withOpacity(0.6),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: _ImageSourceButton(
                      icon: Icons.camera_alt,
                      label: 'Camera',
                      onTap: () {
                        Navigator.pop(context);
                        _pickImage(field, ImageSource.camera);
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _ImageSourceButton(
                      icon: Icons.photo_library,
                      label: 'Gallery',
                      onTap: () {
                        Navigator.pop(context);
                        _pickImage(field, ImageSource.gallery);
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _selectDate(ServiceFormField field) async {
    final now = DateTime.now();
    final initialDate = _dateValues[field] ?? DateTime(1990, 1, 1);
    
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1900),
      lastDate: now,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.ashramSaffron,
              surface: AppColors.ashramBackgroundDark,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null) {
      setState(() {
        _dateValues[field] = picked;
        _controllers[field]?.text = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

  Future<void> _selectTime(ServiceFormField field) async {
    final initialTime = TimeOfDay.now();
    
    final picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.ashramSaffron,
              surface: AppColors.ashramBackgroundDark,
            ),
          ),
          child: MediaQuery(
            data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
            child: child!,
          ),
        );
      },
    );
    
    if (picked != null) {
      setState(() {
        _controllers[field]?.text = 
          '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;
    
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: BoxDecoration(
        color: AppColors.ashramBackgroundDark,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(
          top: BorderSide(
            color: AppColors.ashramSaffron.withOpacity(0.3),
            width: 1,
          ),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.only(bottom: bottomPadding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 48,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
              child: Column(
                children: [
                  Text(
                    widget.service.emoji,
                    style: const TextStyle(fontSize: 40),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Enter Your Details',
                    style: GoogleFonts.cormorantGaramond(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: AppColors.ashramAccentGold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'For your ${widget.service.title} reading',
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),
            // Form
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      ...widget.service.requiredFields.map((field) => 
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: _buildFormField(field),
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Submit button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _submitForm,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.ashramSaffron,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 0,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.auto_awesome, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                'Get My Reading',
                                style: GoogleFonts.outfit(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormField(ServiceFormField field) {
    if (field.isImageField) {
      return _buildImageField(field);
    }
    
    final controller = _controllers[field]!;
    
    if (field.isDateField) {
      return _buildDateField(field, controller);
    } else if (field.isTimeField) {
      return _buildTimeField(field, controller);
    } else if (field.isMultiline) {
      return _buildMultilineField(field, controller);
    } else {
      return _buildTextField(field, controller);
    }
  }

  Widget _buildImageField(ServiceFormField field) {
    final hasImage = _imageFiles[field] != null;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          field.label,
          style: GoogleFonts.outfit(
            fontSize: 14,
            color: AppColors.ashramAccentGold.withOpacity(0.8),
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () => _showImageSourceDialog(field),
          child: Container(
            height: 180,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: hasImage 
                    ? AppColors.ashramSaffron.withOpacity(0.5)
                    : Colors.white.withOpacity(0.1),
                width: hasImage ? 2 : 1,
              ),
            ),
            child: hasImage
                ? Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(11),
                        child: Image.file(
                          _imageFiles[field]!,
                          width: double.infinity,
                          height: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: GestureDetector(
                          onTap: () => _showImageSourceDialog(field),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.6),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.edit,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 8,
                        left: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.8),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.check_circle, color: Colors.white, size: 16),
                              const SizedBox(width: 6),
                              Text(
                                'Palm image uploaded',
                                style: GoogleFonts.outfit(
                                  fontSize: 12,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.ashramSaffron.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.back_hand_outlined,
                          color: AppColors.ashramSaffron,
                          size: 40,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Tap to upload palm image',
                        style: GoogleFonts.outfit(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.7),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        field.hint,
                        style: GoogleFonts.outfit(
                          fontSize: 12,
                          color: Colors.white.withOpacity(0.4),
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(ServiceFormField field, TextEditingController controller) {
    return TextFormField(
      controller: controller,
      style: GoogleFonts.outfit(
        fontSize: 14,
        color: Colors.white,
      ),
      cursorColor: AppColors.ashramSaffron,
      decoration: _inputDecoration(field),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return '${field.label} is required';
        }
        return null;
      },
    );
  }

  Widget _buildMultilineField(ServiceFormField field, TextEditingController controller) {
    return TextFormField(
      controller: controller,
      style: GoogleFonts.outfit(
        fontSize: 14,
        color: Colors.white,
      ),
      cursorColor: AppColors.ashramSaffron,
      maxLines: 4,
      minLines: 3,
      decoration: _inputDecoration(field),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return '${field.label} is required';
        }
        return null;
      },
    );
  }

  Widget _buildDateField(ServiceFormField field, TextEditingController controller) {
    return TextFormField(
      controller: controller,
      style: GoogleFonts.outfit(
        fontSize: 14,
        color: Colors.white,
      ),
      cursorColor: AppColors.ashramSaffron,
      readOnly: true,
      onTap: () => _selectDate(field),
      decoration: _inputDecoration(field).copyWith(
        suffixIcon: Icon(
          Icons.calendar_today,
          color: AppColors.ashramSaffron.withOpacity(0.7),
          size: 20,
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return '${field.label} is required';
        }
        return null;
      },
    );
  }

  Widget _buildTimeField(ServiceFormField field, TextEditingController controller) {
    return TextFormField(
      controller: controller,
      style: GoogleFonts.outfit(
        fontSize: 14,
        color: Colors.white,
      ),
      cursorColor: AppColors.ashramSaffron,
      readOnly: true,
      onTap: () => _selectTime(field),
      decoration: _inputDecoration(field).copyWith(
        suffixIcon: Icon(
          Icons.access_time,
          color: AppColors.ashramSaffron.withOpacity(0.7),
          size: 20,
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return '${field.label} is required';
        }
        return null;
      },
    );
  }

  InputDecoration _inputDecoration(ServiceFormField field) {
    return InputDecoration(
      labelText: field.label,
      hintText: field.hint,
      labelStyle: GoogleFonts.outfit(
        fontSize: 14,
        color: AppColors.ashramAccentGold.withOpacity(0.9),
      ),
      hintStyle: GoogleFonts.outfit(
        fontSize: 13,
        color: Colors.white.withOpacity(0.4),
      ),
      floatingLabelStyle: GoogleFonts.outfit(
        fontSize: 14,
        color: AppColors.ashramSaffron,
      ),
      filled: true,
      fillColor: AppColors.ashramBackgroundDark.withOpacity(0.8),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: Colors.white.withOpacity(0.1),
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: Colors.white.withOpacity(0.1),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: AppColors.ashramSaffron.withOpacity(0.5),
          width: 2,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: Colors.redAccent,
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: Colors.redAccent,
          width: 2,
        ),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }
}

class _ImageSourceButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ImageSourceButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.ashramSaffron.withOpacity(0.3),
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: AppColors.ashramSaffron,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: GoogleFonts.outfit(
                fontSize: 14,
                color: Colors.white.withOpacity(0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
