import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';

class ReportPolitician extends StatefulWidget {
  final String politicianId;
  final String politicianName;

  const ReportPolitician({
    super.key,
    required this.politicianId,
    required this.politicianName,
  });

  @override
  State<ReportPolitician> createState() => _ReportPoliticianState();
}

class _ReportPoliticianState extends State<ReportPolitician> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionCtrl = TextEditingController();
  final _imagePicker = ImagePicker();
  String? _selectedReason;
  String? _selectedType;
  bool _loading = false;
  String _message = '';
  File? _selectedImage;
  File? _selectedVideo;
  String? _imageFileName;
  String? _videoFileName;

  final List<String> _complaintReasons = [
    'Corruption',
    'Poor Performance',
    'Misuse of Public Funds',
    'Misconduct',
    'Lack of Accountability',
    'Other',
  ];

  final List<String> _complaintTypes = [
    'Urgent',
    'Normal',
  ];

  @override
  void dispose() {
    _descriptionCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );
      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
          _imageFileName = pickedFile.name;
          _message = '';
        });
      }
    } catch (e) {
      setState(() => _message = 'Error picking image: $e');
    }
  }

  Future<void> _pickVideo() async {
    try {
      final XFile? pickedFile = await _imagePicker.pickVideo(
        source: ImageSource.gallery,
        maxDuration: const Duration(minutes: 5),
      );
      if (pickedFile != null) {
        setState(() {
          _selectedVideo = File(pickedFile.path);
          _videoFileName = pickedFile.name;
          _message = '';
        });
      }
    } catch (e) {
      setState(() => _message = 'Error picking video: $e');
    }
  }

  Future<void> _submitReport() async {
    if (!_formKey.currentState!.validate() ||
        _selectedReason == null ||
        _selectedType == null) {
      setState(() => _message = 'Please fill all fields');
      return;
    }

    setState(() {
      _loading = true;
      _message = '';
    });

    try {
      final auth = Provider.of<AuthService>(context, listen: false);
      final fs = Provider.of<FirestoreService>(context, listen: false);
      final citizenId = auth.currentUid ?? '';

      if (citizenId.isEmpty) {
        throw Exception('Not logged in');
      }

      // Upload media if selected
      String? imageUrl;
      String? videoUrl;
      
      if (_selectedImage != null) {
        imageUrl = await fs.uploadReportImage(widget.politicianId, _selectedImage!);
      }
      
      if (_selectedVideo != null) {
        videoUrl = await fs.uploadReportVideo(widget.politicianId, _selectedVideo!);
      }

      await fs.submitPoliticianComplaint(
        politicianId: widget.politicianId,
        politicianName: widget.politicianName,
        citizenId: citizenId,
        reason: _selectedReason!,
        description: _descriptionCtrl.text.trim(),
        complaintType: _selectedType!,
        imageUrl: imageUrl,
        videoUrl: videoUrl,
      );

      if (mounted) {
        setState(() {
          _message = 'Report submitted successfully!';
          _loading = false;
        });

        await Future.delayed(const Duration(seconds: 2));
        if (mounted) Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _message = 'Error: ${e.toString()}';
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Report Politician'),
        backgroundColor: Colors.red.shade700,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Report: ${widget.politicianName}',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.red.shade700,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Please provide details about your complaint. All reports are confidential and reviewed by the administrator.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 24),
              // Complaint Reason
              Text(
                'Complaint Reason *',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedReason,
                items: _complaintReasons
                    .map((reason) => DropdownMenuItem<String>(
                          value: reason,
                          child: Text(reason),
                        ))
                    .toList(),
                onChanged: (value) => setState(() => _selectedReason = value),
                decoration: InputDecoration(
                  hintText: 'Select reason for complaint',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  prefixIcon: const Icon(Icons.warning_amber),
                ),
                validator: (v) => v == null ? 'Please select a reason' : null,
              ),
              const SizedBox(height: 20),
              // Complaint Type
              Text(
                'Complaint Type *',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedType,
                items: _complaintTypes
                    .map((type) => DropdownMenuItem<String>(
                          value: type,
                          child: Text(type),
                        ))
                    .toList(),
                onChanged: (value) => setState(() => _selectedType = value),
                decoration: InputDecoration(
                  hintText: 'Select complaint type',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  prefixIcon: const Icon(Icons.flag),
                ),
                validator: (v) => v == null ? 'Please select type' : null,
              ),
              const SizedBox(height: 20),
              // Description
              Text(
                'Detailed Description *',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _descriptionCtrl,
                decoration: InputDecoration(
                  hintText: 'Provide detailed information about your complaint...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  prefixIcon: const Icon(Icons.description),
                ),
                maxLines: 6,
                minLines: 4,
                validator: (v) {
                  if (v?.trim().isEmpty ?? true) {
                    return 'Description is required';
                  }
                  if ((v?.length ?? 0) < 20) {
                    return 'Description must be at least 20 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              // Media Upload Section
              Text(
                'Evidence (Optional)',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _pickImage,
                      icon: const Icon(Icons.image),
                      label: const Text('Add Image'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _pickVideo,
                      icon: const Icon(Icons.videocam),
                      label: const Text('Add Video'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Media Preview
              if (_imageFileName != null || _videoFileName != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    border: Border.all(color: Colors.blue.shade200),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_imageFileName != null)
                        Row(
                          children: [
                            const Icon(Icons.check_circle, color: Colors.green, size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Image: $_imageFileName',
                                style: const TextStyle(fontSize: 12),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            GestureDetector(
                              onTap: () => setState(() => _selectedImage = null),
                              child: const Icon(Icons.close, size: 18, color: Colors.red),
                            ),
                          ],
                        ),
                      if (_imageFileName != null && _videoFileName != null)
                        const SizedBox(height: 8),
                      if (_videoFileName != null)
                        Row(
                          children: [
                            const Icon(Icons.check_circle, color: Colors.green, size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Video: $_videoFileName',
                                style: const TextStyle(fontSize: 12),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            GestureDetector(
                              onTap: () => setState(() => _selectedVideo = null),
                              child: const Icon(Icons.close, size: 18, color: Colors.red),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              const SizedBox(height: 24),
              // Message
              if (_message.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _message.contains('success')
                        ? Colors.green.shade50
                        : Colors.red.shade50,
                    border: Border.all(
                      color: _message.contains('success')
                          ? Colors.green
                          : Colors.red,
                    ),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _message.contains('success')
                            ? Icons.check_circle
                            : Icons.error,
                        color: _message.contains('success')
                            ? Colors.green
                            : Colors.red,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _message,
                          style: TextStyle(
                            color: _message.contains('success')
                                ? Colors.green.shade700
                                : Colors.red.shade700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 20),
              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: _loading ? null : _submitReport,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade700,
                    disabledBackgroundColor: Colors.grey.shade300,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  icon: _loading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Icon(Icons.send),
                  label: Text(
                    _loading ? 'Submitting...' : 'Submit Report',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Info message
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  border: Border.all(color: Colors.blue),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info, color: Colors.blue),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Your report will be reviewed by administrators. False reports may result in penalties.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.blue.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
