import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'view_problems.dart';
import 'submit_solutions_enhanced.dart';
import 'charity_funding.dart';
import 'edit_profile.dart';
import 'change_password.dart';


class PoliticianHome extends StatefulWidget {
  final JanataUser profile;
  const PoliticianHome({super.key, required this.profile});

  @override
  State<PoliticianHome> createState() => _PoliticianHomeState();
}

class _PoliticianHomeState extends State<PoliticianHome> {
  late JanataUser currentProfile;

  @override
  void initState() {
    super.initState();
    currentProfile = widget.profile;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('JANATA APP'),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Row(children: [Text(currentProfile.name), const SizedBox(width: 8), const Icon(Icons.person)]),
          ),
          PopupMenuButton<String>(
            onSelected: (v) async {
              final auth = Provider.of<AuthService>(context, listen: false);
              if (v == 'edit') {
                final result = await Navigator.push<JanataUser?>(
                  context,
                  MaterialPageRoute(builder: (_) => EditProfile(profile: currentProfile)),
                );
                if (result != null) {
                  setState(() => currentProfile = result);
                }
              } else if (v == 'password') {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ChangePasswordScreen()),
                );
              } else if (v == 'logout') {
                try {
                  await auth.signOut();
                } catch (_) {}
              }
            },
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'edit', child: Text('Edit Profile')),
              PopupMenuItem(value: 'password', child: Text('Change Password')),
              PopupMenuItem(value: 'logout', child: Text('Logout')),
            ],
            icon: const Icon(Icons.settings),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12),
            Wrap(
              spacing: 20,
              runSpacing: 20,
              alignment: WrapAlignment.center,
              children: [
                SizedBox(
                  width: 350,
                  height: 120,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.cyan[200],
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      elevation: 2,
                    ),
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ViewProblems())),
                    child: const Padding(
                      padding: EdgeInsets.all(12.0),
                      child: Text('View Problem', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
                    ),
                  ),
                ),
                SizedBox(
                  width: 350,
                  height: 120,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.cyan[200],
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      elevation: 2,
                    ),
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CharityFunding())),
                    child: const Padding(
                      padding: EdgeInsets.all(12.0),
                      child: Text('Charity/Funding', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
                    ),
                  ),
                ),
                SizedBox(
                  width: 350,
                  height: 120,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.cyan[200],
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      elevation: 2,
                    ),
                    onPressed: () async {
                      final result = await Navigator.push<JanataUser?>(
                        context,
                        MaterialPageRoute(builder: (_) => EditProfile(profile: currentProfile)),
                      );
                      if (result != null) {
                        setState(() => currentProfile = result);
                      }
                    },
                    child: const Padding(
                      padding: EdgeInsets.all(12.0),
                      child: Text('Edit Profile', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
                    ),
                  ),
                ),
                SizedBox(
                  width: 350,
                  height: 120,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.cyan[200],
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      elevation: 2,
                    ),
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SubmitSolutionsEnhanced())),
                    child: const Padding(
                      padding: EdgeInsets.all(12.0),
                      child: Text('Submit Solutions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
                    ),
                  ),
                ),
              ],
            ),
            const Spacer(),
            Align(
              alignment: Alignment.bottomRight,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange[700],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () async {
                  await showDialog<void>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Call / Support'),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ListTile(
                            leading: const Icon(Icons.phone),
                            title: const Text('+977 9841000000'),
                            trailing: IconButton(
                              icon: const Icon(Icons.copy),
                              onPressed: () {
                                Clipboard.setData(const ClipboardData(text: '+977 9841000000'));
                                Navigator.of(context).pop();
                              },
                            ),
                          ),
                          ListTile(
                            leading: const Icon(Icons.email),
                            title: const Text('contact@janata.com'),
                            trailing: IconButton(
                              icon: const Icon(Icons.copy),
                              onPressed: () {
                                Clipboard.setData(const ClipboardData(text: 'contact@janata.com'));
                                Navigator.of(context).pop();
                              },
                            ),
                          ),
                        ],
                      ),
                      actions: [TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Close'))],
                    ),
                  );
                },
                icon: const Icon(Icons.call),
                label: const Padding(padding: EdgeInsets.all(8.0), child: Text('Call/Support')),
              ),
            )
          ],
        ),
      ),
    );
  }
}
