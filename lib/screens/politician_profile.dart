import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';
import 'election_results_detail.dart';
import 'report_politician.dart';

class PoliticianProfile extends StatefulWidget {
  final String uid;
  const PoliticianProfile({super.key, required this.uid});

  @override
  State<PoliticianProfile> createState() => _PoliticianProfileState();
}

class _PoliticianProfileState extends State<PoliticianProfile> {
  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthService>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Politician Profile'),
        elevation: 0,
      ),
      body: FutureBuilder<JanataUser?>(
        future: auth.getProfile(widget.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final profile = snapshot.data;
          if (profile == null) {
            return const Center(child: Text('Profile not found'));
          }
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Card with Profile Picture
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        // Profile Avatar
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.teal.shade100,
                          ),
                          child: Icon(
                            Icons.person,
                            size: 60,
                            color: Colors.teal.shade700,
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Name
                        Text(
                          profile.name,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        // Role Badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.teal.shade50,
                            border: Border.all(color: Colors.teal.shade300),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            profile.role.toUpperCase(),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.teal.shade700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Basic Information Section
                _buildSectionTitle('Basic Information', Icons.info_outline),
                const SizedBox(height: 12),
                _buildInfoCard(
                  icon: Icons.email,
                  label: 'Email',
                  value: profile.email,
                  color: Colors.blue,
                ),
                const SizedBox(height: 8),
                _buildInfoCard(
                  icon: Icons.phone,
                  label: 'Phone',
                  value: profile.phone ?? 'Not provided',
                  color: Colors.green,
                ),
                const SizedBox(height: 8),
                _buildInfoCard(
                  icon: Icons.location_on,
                  label: 'Province',
                  value: profile.province ?? 'Not provided',
                  color: Colors.orange,
                ),
                const SizedBox(height: 8),
                _buildInfoCard(
                  icon: Icons.wc,
                  label: 'Gender',
                  value: profile.gender ?? 'Not provided',
                  color: Colors.purple,
                ),
                const SizedBox(height: 24),

                // Bio Section
                if (profile.bio != null && profile.bio!.isNotEmpty) ...[
                  _buildSectionTitle('About', Icons.description),
                  const SizedBox(height: 12),
                  Card(
                    elevation: 1,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        profile.bio!,
                        style: const TextStyle(
                          fontSize: 14,
                          height: 1.6,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                // Professional Information Section
                if ((profile.education != null && profile.education!.isNotEmpty) ||
                    (profile.works != null && profile.works!.isNotEmpty)) ...[
                  _buildSectionTitle('Professional', Icons.work_outline),
                  const SizedBox(height: 12),
                  if (profile.education != null && profile.education!.isNotEmpty) ...[
                    _buildInfoCard(
                      icon: Icons.school,
                      label: 'Education',
                      value: profile.education!,
                      color: Colors.indigo,
                    ),
                    const SizedBox(height: 8),
                  ],
                  if (profile.works != null && profile.works!.isNotEmpty)
                    _buildInfoCard(
                      icon: Icons.business,
                      label: 'Occupation',
                      value: profile.works!,
                      color: Colors.brown,
                    ),
                  const SizedBox(height: 24),
                ],

                // Action Buttons
                _buildSectionTitle('Actions', Icons.touch_app),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            ElectionResultsDetail(politicianName: profile.name),
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    icon: const Icon(Icons.how_to_vote),
                    label: const Text('View Election Results'),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ReportPolitician(
                          politicianId: widget.uid,
                          politicianName: profile.name,
                        ),
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade700,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    icon: const Icon(Icons.flag),
                    label: const Text('Report Politician'),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: Colors.teal, size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}