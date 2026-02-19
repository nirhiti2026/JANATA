import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../services/firestore_service.dart';
import '../services/auth_service.dart';
import '../models/problem.dart';

class SubmitSolutionsEnhanced extends StatefulWidget {
  const SubmitSolutionsEnhanced({super.key});

  @override
  State<SubmitSolutionsEnhanced> createState() => _SubmitSolutionsEnhancedState();
}

class _SubmitSolutionsEnhancedState extends State<SubmitSolutionsEnhanced> {
  final _solutionCtrl = TextEditingController();
  Problem? _selectedProblem;
  File? _selectedImage;
  File? _selectedVideo;
  bool _loading = false;
  String _message = '';
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    // Listen to text changes so button enables/disables automatically
    _solutionCtrl.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _solutionCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );
      if (pickedFile != null) {
        setState(() => _selectedImage = File(pickedFile.path));
        _showSuccess('Image selected successfully');
      }
    } catch (e) {
      final errorMsg = e.toString();
      if (errorMsg.contains('Platform') || errorMsg.contains('operatingSystem')) {
        _showError('Image selection not available on this device. You can still submit description only.');
      } else {
        _showError('Failed to pick image: $e');
      }
    }
  }

  Future<void> _pickVideo() async {
    try {
      final pickedFile = await _picker.pickVideo(
        source: ImageSource.gallery,
        maxDuration: const Duration(minutes: 5),
      );
      if (pickedFile != null) {
        setState(() => _selectedVideo = File(pickedFile.path));
        _showSuccess('Video selected successfully');
      }
    } catch (e) {
      final errorMsg = e.toString();
      if (errorMsg.contains('Platform') || errorMsg.contains('operatingSystem')) {
        _showError('Video selection not available on this device. You can still submit description only.');
      } else {
        _showError('Failed to pick video: $e');
      }
    }
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  void _showError(String error) {
    setState(() => _message = error);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(error), backgroundColor: Colors.red),
    );
  }

  Future<void> _submitSolution() async {
    if (_selectedProblem == null) {
      _showError('Please select a problem');
      return;
    }
    // Solution description is required; media is optional
    if (_solutionCtrl.text.trim().isEmpty) {
      _showError('Please enter a solution description.');
      return;
    }

    setState(() {
      _loading = true;
      _message = '';
    });

    try {
      final fs = Provider.of<FirestoreService>(context, listen: false);

      String? imageUrl;
      String? videoUrl;

      // Try to upload image if selected (media is optional, skip if fails)
      if (_selectedImage != null) {
        try {
          imageUrl = await fs.uploadSolutionImage(_selectedProblem!.id, _selectedImage!);
        } catch (e) {
          // Silently skip image upload if it fails
          // Solution will be submitted with description only
          final errorMsg = e.toString().toLowerCase();
          if (errorMsg.contains('permission')) {
            _showError('Image upload permission denied. Submitting solution description only.');
          }
          // Otherwise just skip the media silently
        }
      }

      // Try to upload video if selected (media is optional, skip if fails)
      if (_selectedVideo != null) {
        try {
          videoUrl = await fs.uploadSolutionVideo(_selectedProblem!.id, _selectedVideo!);
        } catch (e) {
          // Silently skip video upload if it fails
          // Solution will be submitted with description only
          final errorMsg = e.toString().toLowerCase();
          if (errorMsg.contains('permission')) {
            _showError('Video upload permission denied. Submitting solution description only.');
          }
          // Otherwise just skip the media silently
        }
      }

      // Submit solution with or without media (description is always included)
      await fs.submitSolutionWithMedia(
        _selectedProblem!.id,
        _solutionCtrl.text.trim(),
        imageUrl: imageUrl,
        videoUrl: videoUrl,
      );

      setState(() {
        _message = 'Solution submitted successfully!';
        _solutionCtrl.clear();
        _selectedProblem = null;
        _selectedImage = null;
        _selectedVideo = null;
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Solution submitted successfully!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      _showError('Error submitting solution: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _markAsResolved() async {
    if (_selectedProblem == null) return;

    // Solution description is required to mark as resolved; media is optional
    if (_solutionCtrl.text.trim().isEmpty) {
      _showError('Please enter a solution description before marking as resolved.');
      return;
    }

    setState(() {
      _loading = true;
      _message = '';
    });

    try {
      final fs = Provider.of<FirestoreService>(context, listen: false);

      // Update problem status to 'solved'
      await fs.updateProblemStatus(_selectedProblem!.id, 'solved');

      setState(() {
        _message = 'Problem marked as resolved!';
        _solutionCtrl.clear();
        _selectedProblem = null;
        _selectedImage = null;
        _selectedVideo = null;
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Problem marked as resolved!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      _showError('Error marking as resolved: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthService>(context, listen: false);
    final fs = Provider.of<FirestoreService>(context, listen: false);
    final uid = auth.currentUid ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Submit Solutions'),
        backgroundColor: Colors.teal,
      ),
      body: StreamBuilder<List<Problem>>(
        stream: fs.streamAllPendingProblems(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading problems',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    snapshot.error.toString(),
                    style: Theme.of(context).textTheme.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final problems = snapshot.data ?? <Problem>[];

          if (problems.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.check_circle, size: 48, color: Colors.green),
                  const SizedBox(height: 16),
                  Text(
                    'No pending problems',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  const Text('All problems have been resolved!'),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Available Problems',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 16),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: problems.length,
                  itemBuilder: (context, index) {
                    final problem = problems[index];
                    final isAssigned = problem.assignedTo == uid;
                    final isSelected = _selectedProblem?.id == problem.id;

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedProblem = problem;
                          _solutionCtrl.clear();
                          _message = '';
                          _selectedImage = null;
                          _selectedVideo = null;
                        });
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: isSelected ? Colors.teal : Colors.grey.shade300,
                            width: isSelected ? 2 : 1,
                          ),
                          borderRadius: BorderRadius.circular(8),
                          color: isSelected ? Colors.teal.shade50 : Colors.white,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    problem.title,
                                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                ),
                                if (isAssigned)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.green.shade100,
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(color: Colors.green),
                                    ),
                                    child: const Text(
                                      'Assigned to you',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.green,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              problem.description,
                              style: Theme.of(context).textTheme.bodySmall,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Chip(
                                  label: Text(problem.province),
                                  avatar: const Icon(Icons.location_on, size: 16),
                                ),
                                const SizedBox(width: 8),
                                Chip(
                                  label: Text(problem.problemType),
                                  avatar: const Icon(Icons.category, size: 16),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                if (_selectedProblem != null) ...[
                  const SizedBox(height: 24),
                  // Problem Details Card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.teal.shade200),
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.teal.shade50,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Problem Details',
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.teal.shade800,
                              ),
                        ),
                        const SizedBox(height: 12),
                        _buildDetailRow('Title', _selectedProblem!.title),
                        _buildDetailRow('Description', _selectedProblem!.description),
                        _buildDetailRow('Province', _selectedProblem!.province),
                        _buildDetailRow('Ward', _selectedProblem!.wardNo),
                        _buildDetailRow('Type', _selectedProblem!.problemType),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Solution Text
                  Text(
                    'Solution Description',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _solutionCtrl,
                    decoration: InputDecoration(
                      hintText: 'Describe your solution in detail...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                      prefixIcon: const Icon(Icons.description),
                    ),
                    maxLines: 5,
                    minLines: 3,
                  ),
                  const SizedBox(height: 20),
                  // Media Upload Section
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.grey.shade50,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.image, color: Colors.teal),
                            const SizedBox(width: 8),
                            Text(
                              'Add Media (Optional)',
                              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Image Upload
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: _loading ? null : _pickImage,
                                icon: const Icon(Icons.image),
                                label: const Text('Pick Image'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue.shade400,
                                  foregroundColor: Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            if (_selectedImage != null)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  color: Colors.green.shade100,
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: Colors.green),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.check, color: Colors.green),
                                    const SizedBox(width: 6),
                                    const Text('Image selected'),
                                  ],
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        // Video Upload
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: _loading ? null : _pickVideo,
                                icon: const Icon(Icons.videocam),
                                label: const Text('Pick Video'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.purple.shade400,
                                  foregroundColor: Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            if (_selectedVideo != null)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  color: Colors.green.shade100,
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: Colors.green),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.check, color: Colors.green),
                                    const SizedBox(width: 6),
                                    const Text('Video selected'),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Error/Success Message
                  if (_message.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _message.contains('successfully')
                            ? Colors.green.shade50
                            : Colors.red.shade50,
                        border: Border.all(
                          color: _message.contains('successfully')
                              ? Colors.green
                              : Colors.red,
                        ),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _message.contains('successfully')
                                ? Icons.check_circle
                                : Icons.error,
                            color: _message.contains('successfully')
                                ? Colors.green
                                : Colors.red,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _message,
                              style: TextStyle(
                                color: _message.contains('successfully')
                                    ? Colors.green.shade700
                                    : Colors.red.shade700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 20),
                  // Role-based Buttons
                  if (_selectedProblem != null)
                    if (_selectedProblem!.assignedTo == uid)
                      // Assigned politician: Show both buttons
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _loading || _solutionCtrl.text.trim().isEmpty ? null : _submitSolution,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.teal,
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
                                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                      ),
                                    )
                                  : const Icon(Icons.check_circle),
                              label: Text(
                                _loading ? 'Submitting...' : 'Submit Solution',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _loading ? null : _markAsResolved,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
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
                                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                      ),
                                    )
                                  : const Icon(Icons.done_all),
                              label: Text(
                                _loading ? 'Processing...' : 'Mark Resolved',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      )
                    else
                      // Unassigned politician: Show only Submit Solution
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton.icon(
                          onPressed: _loading || _solutionCtrl.text.trim().isEmpty ? null : _submitSolution,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.teal,
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
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                )
                              : const Icon(Icons.check_circle),
                          label: Text(
                            _loading ? 'Submitting...' : 'Submit Solution',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 13),
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ),
        ],
      ),
    );
  }
}
