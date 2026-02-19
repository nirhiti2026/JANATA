import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';

class EditProfile extends StatefulWidget {
  final JanataUser profile;
  const EditProfile({super.key, required this.profile});

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameCtrl;
  late TextEditingController _bioCtrl;
  late TextEditingController _educationCtrl;
  late TextEditingController _worksCtrl;
  late TextEditingController _phoneCtrl;
  late TextEditingController _provinceCtrl;
  String? _selectedGender;
  bool _loading = false;
  String _message = '';

  final List<String> _genders = ['Male', 'Female', 'Other'];

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.profile.name);
    _bioCtrl = TextEditingController(text: widget.profile.bio ?? '');
    _educationCtrl = TextEditingController(text: widget.profile.education ?? '');
    _worksCtrl = TextEditingController(text: widget.profile.works ?? '');
    _phoneCtrl = TextEditingController(text: widget.profile.phone ?? '');
    _provinceCtrl = TextEditingController(text: widget.profile.province ?? '');
    _selectedGender = widget.profile.gender;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _bioCtrl.dispose();
    _educationCtrl.dispose();
    _worksCtrl.dispose();
    _phoneCtrl.dispose();
    _provinceCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthService>(context, listen: false);
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(
                  labelText: 'Full Name',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => (v?.trim().isEmpty ?? true) ? 'Name required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _phoneCtrl,
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  hintText: 'e.g., +977 9841234567',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _provinceCtrl,
                decoration: const InputDecoration(
                  labelText: 'Province',
                  hintText: 'e.g., Province 1',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _selectedGender,
                items: [
                  const DropdownMenuItem<String>(value: null, child: Text('Select Gender')),
                  ..._genders.map((g) => DropdownMenuItem<String>(value: g, child: Text(g))),
                ],
                onChanged: (v) => setState(() => _selectedGender = v),
                decoration: const InputDecoration(
                  labelText: 'Gender',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _bioCtrl,
                decoration: const InputDecoration(
                  labelText: 'Bio',
                  hintText: 'Tell us about yourself',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _educationCtrl,
                decoration: const InputDecoration(
                  labelText: 'Education',
                  hintText: 'e.g., Bachelor in Engineering',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _worksCtrl,
                decoration: const InputDecoration(
                  labelText: 'Works / Occupation',
                  hintText: 'e.g., Software Engineer',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              if (_message.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: Text(
                    _message,
                    style: TextStyle(
                      color: _message.contains('Saved') ? Colors.green : Colors.red,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ElevatedButton.icon(
                onPressed: _loading
                    ? null
                    : () async {
                        if (!_formKey.currentState!.validate()) return;
                        setState(() {
                          _loading = true;
                          _message = '';
                        });
                        try {
                          await auth.updateProfile(
                            widget.profile.uid,
                            name: _nameCtrl.text.trim(),
                            bio: _bioCtrl.text.trim(),
                            education: _educationCtrl.text.trim(),
                            works: _worksCtrl.text.trim(),
                            phone: _phoneCtrl.text.trim(),
                            gender: _selectedGender,
                            province: _provinceCtrl.text.trim(),
                          );
                          setState(() => _message = 'Profile Saved');
                          
                          // Create updated profile and return it
                          await Future.delayed(const Duration(milliseconds: 500));
                          if (!mounted) return;
                          final updatedProfile = JanataUser(
                            uid: widget.profile.uid,
                            name: _nameCtrl.text.trim(),
                            email: widget.profile.email,
                            role: widget.profile.role,
                            bio: _bioCtrl.text.trim(),
                            education: _educationCtrl.text.trim(),
                            works: _worksCtrl.text.trim(),
                            phone: _phoneCtrl.text.trim(),
                            gender: _selectedGender,
                            province: _provinceCtrl.text.trim(),
                          );
                          Navigator.pop(context, updatedProfile);
                        } catch (e) {
                          setState(() => _message = 'Failed to save: $e');
                        } finally {
                          if (mounted) setState(() => _loading = false);
                        }
                      },
                icon: _loading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.save),
                label: Text(_loading ? 'Saving...' : 'Save Profile'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}