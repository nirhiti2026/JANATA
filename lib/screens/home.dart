import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';
import 'citizen_home.dart';
import 'politician_home.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  JanataUser? _profile;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final auth = Provider.of<AuthService>(context, listen: false);
    final uid = auth.currentUid;
    if (uid == null) return setState(() => _loading = false);
    final profile = await auth.getProfile(uid);
    setState(() {
      _profile = profile;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    if (_profile == null) return Scaffold(body: Center(child: Text('Profile not found')));
    if (_profile!.role == 'politician') {
      return PoliticianHome(profile: _profile!);
    }
    return CitizenHome(profile: _profile!);
  }
}
