import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/problem.dart';
import '../services/firestore_service.dart';
import '../services/auth_service.dart';

class CreateProblem extends StatefulWidget {
  const CreateProblem({super.key});

  @override
  State<CreateProblem> createState() => _CreateProblemState();
}

class _CreateProblemState extends State<CreateProblem> {
  final _formKey = GlobalKey<FormState>();
  final _province = TextEditingController();
  final _ward = TextEditingController();
  final _type = TextEditingController();
  final _desc = TextEditingController();
  String? _assignedPoliticianId;
  bool _loading = false;
  List<Map<String, dynamic>> _politicians = [];

  @override
  void initState() {
    super.initState();
    _loadPoliticians();
  }

  Future<void> _loadPoliticians() async {
    final fs = Provider.of<FirestoreService>(context, listen: false);
    try {
      final list = await fs.getPoliticiansOnce();
      if (list.isEmpty) {
        // Fallback: provide a demo politician when Firestore is empty or unavailable
        setState(() => _politicians = [
              {'uid': 'dev-politician', 'name': 'Demo Politician'}
            ]);
      } else {
        setState(() => _politicians = list);
      }
    } catch (e) {
      // Firestore likely unavailable (no config). Provide demo politician for testing.
      setState(() => _politicians = [
            {'uid': 'dev-politician', 'name': 'Demo Politician'}
          ]);
    }
  }

  @override
  void dispose() {
    _province.dispose();
    _ward.dispose();
    _type.dispose();
    _desc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final fs = Provider.of<FirestoreService>(context, listen: false);
    return Scaffold(
      appBar: AppBar(title: const Text('Submit Problem')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _province,
                decoration: const InputDecoration(
                  labelText: 'Province',
                  hintText: 'e.g., Province 1',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => (v?.trim().isEmpty ?? true) ? 'Province required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _ward,
                decoration: const InputDecoration(
                  labelText: 'Ward No',
                  hintText: 'e.g., 1-33',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => (v?.trim().isEmpty ?? true) ? 'Ward No required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _type,
                decoration: const InputDecoration(
                  labelText: 'Problem Type',
                  hintText: 'e.g., Road, Water, Electricity',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => (v?.trim().isEmpty ?? true) ? 'Problem Type required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _desc,
                decoration: const InputDecoration(
                  labelText: 'Problem Description',
                  hintText: 'Describe the problem in detail',
                  border: OutlineInputBorder(),
                ),
                maxLines: 4,
                validator: (v) => (v?.trim().isEmpty ?? true) ? 'Description required' : null,
              ),
              const SizedBox(height: 12),
              if (_politicians.isNotEmpty)
                DropdownButtonFormField<String>(
                  value: _assignedPoliticianId,
                  items: _politicians
                      .map((p) => DropdownMenuItem<String>(
                            value: p['uid'] as String,
                            child: Text(p['name'] ?? 'Unknown'),
                          ))
                      .toList(),
                  onChanged: (v) => setState(() => _assignedPoliticianId = v),
                  decoration: const InputDecoration(
                    labelText: 'Assign To Politician (Optional)',
                    border: OutlineInputBorder(),
                  ),
                ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _loading
                    ? null
                    : () async {
                        if (!_formKey.currentState!.validate()) return;
                        setState(() => _loading = true);
                        try {
                          final auth = Provider.of<AuthService>(context, listen: false);
                          final problem = Problem(
                            id: '',
                            title: _type.text.trim(),
                            description: _desc.text.trim(),
                            province: _province.text.trim(),
                            wardNo: _ward.text.trim(),
                            problemType: _type.text.trim(),
                            citizenId: auth.currentUid ?? 'unknown',
                            assignedTo: _assignedPoliticianId,
                            status: 'pending',
                            createdAt: Timestamp.now(),
                          );
                          await fs.createProblem(problem);
                          if (!mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Problem submitted successfully!')),
                          );
                          Navigator.pop(context);
                        } catch (e) {
                          if (!mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Error: $e')),
                          );
                        } finally {
                          if (mounted) setState(() => _loading = false);
                        }
                      },
                icon: _loading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.check),
                label: Text(_loading ? 'Submitting...' : 'Submit Problem'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
