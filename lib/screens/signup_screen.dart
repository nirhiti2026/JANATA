import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../utils/error_formatter.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmPassCtrl = TextEditingController();
  String _role = 'citizen';
  int? _selectedYear;
  int? _selectedMonth;
  int? _selectedDay;
  bool _loading = false;
  String _error = '';

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthService>(context, listen: false);
    return Scaffold(
      appBar: AppBar(title: const Text('JANATA Sign Up')),
      body: Center(
        child: SizedBox(
          width: 520,
          child: Card(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(controller: _nameCtrl, decoration: const InputDecoration(hintText: 'Name')),
                    const SizedBox(height: 8),
                    TextField(controller: _emailCtrl, decoration: const InputDecoration(hintText: 'Email')),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _role,
                      items: const [
                        DropdownMenuItem(value: 'citizen', child: Text('Citizen')),
                        DropdownMenuItem(value: 'politician', child: Text('Politician')),
                      ],
                      onChanged: (v) => setState(() => _role = v ?? 'citizen'),
                      decoration: const InputDecoration(labelText: 'Account Type'),
                    ),
                    const SizedBox(height: 12),
                    const Align(alignment: Alignment.centerLeft, child: Text('Date of Birth', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14))),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        SizedBox(
                          width: 130,
                          child: DropdownButtonFormField<int>(
                            value: _selectedYear,
                            hint: const Text('Year'),
                            items: List.generate(50, (i) => DateTime.now().year - i)
                                .map((y) => DropdownMenuItem(value: y, child: Text(y.toString())))
                                .toList(),
                            onChanged: (v) => setState(() => _selectedYear = v),
                          ),
                        ),
                        SizedBox(
                          width: 100,
                          child: DropdownButtonFormField<int>(
                            value: _selectedMonth,
                            hint: const Text('Month'),
                            items: List.generate(12, (i) => i + 1)
                                .map((m) => DropdownMenuItem(value: m, child: Text(m.toString().padLeft(2, '0'))))
                                .toList(),
                            onChanged: (v) => setState(() => _selectedMonth = v),
                          ),
                        ),
                        SizedBox(
                          width: 100,
                          child: DropdownButtonFormField<int>(
                            value: _selectedDay,
                            hint: const Text('Day'),
                            items: List.generate(31, (i) => i + 1)
                                .map((d) => DropdownMenuItem(value: d, child: Text(d.toString().padLeft(2, '0'))))
                                .toList(),
                            onChanged: (v) => setState(() => _selectedDay = v),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextField(controller: _passCtrl, decoration: const InputDecoration(hintText: 'Password'), obscureText: true),
                    const SizedBox(height: 8),
                    TextField(controller: _confirmPassCtrl, decoration: const InputDecoration(hintText: 'Confirm Password'), obscureText: true),
                    const SizedBox(height: 12),
                    if (_error.isNotEmpty) Text(_error, style: const TextStyle(color: Colors.red, fontSize: 12)),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _loading
                            ? null
                            : () async {
                                if (_passCtrl.text != _confirmPassCtrl.text) {
                                  setState(() => _error = 'Passwords do not match');
                                  return;
                                }
                                setState(() {
                                  _loading = true;
                                  _error = '';
                                });
                                try {
                                  await auth.signUp(_nameCtrl.text.trim(), _emailCtrl.text.trim(), _passCtrl.text, _role).timeout(const Duration(seconds: 25), onTimeout: () => throw Exception('Sign up timed out. Check your network or Firebase configuration.'));
                                  if (!mounted) return;
                                  Navigator.pop(context);
                                } catch (e) {
                                  if (mounted) {
                                    setState(() {
                                      _error = FirebaseErrorFormatter.formatAuthError(e);
                                    });
                                  }
                                } finally {
                                  if (mounted) {
                                    setState(() {
                                      _loading = false;
                                    });
                                  }
                                }
                              },
                        child: _loading
                            ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(strokeWidth: 3))
                            : const Padding(
                                padding: EdgeInsets.symmetric(vertical: 12.0),
                                child: Text('Create Account', style: TextStyle(fontSize: 18)),
                              ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
