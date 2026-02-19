import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/charity_organization.dart';
import '../services/firestore_service.dart';
import '../services/auth_service.dart';

class CharityFunding extends StatefulWidget {
  const CharityFunding({super.key});

  @override
  State<CharityFunding> createState() => _CharityFundingState();
}

class _CharityFundingState extends State<CharityFunding> {
  final List<CharityOrganization> _dummyOrganizations = [
    CharityOrganization(
      id: 'org_1',
      name: 'Red Cross Nepal',
      mission: 'Provide emergency relief, healthcare, and disaster management',
      targetAmount: 1000000,
      currentAmountCollected: 450000,
      description:
          'The Red Cross Nepal is dedicated to helping vulnerable populations during humanitarian crises. We provide medical aid, shelter, and emergency relief to those affected by natural disasters.',
      category: 'Health & Emergency',
      imageUrl: null,
    ),
    CharityOrganization(
      id: 'org_2',
      name: 'Nepal Wildlife Fund',
      mission: 'Protect and conserve endangered species and natural habitats',
      targetAmount: 800000,
      currentAmountCollected: 320000,
      description:
          'Our mission is to preserve Nepal\'s unique biodiversity. We work to protect endangered species like the snow leopard and red panda through habitat conservation and community education.',
      category: 'Environment',
      imageUrl: null,
    ),
    CharityOrganization(
      id: 'org_3',
      name: 'Education for All',
      mission: 'Provide quality education to underprivileged children',
      targetAmount: 600000,
      currentAmountCollected: 280000,
      description:
          'We believe every child deserves access to quality education regardless of their economic background. Our schools provide scholarships, teaching materials, and nutritious meals.',
      category: 'Education',
      imageUrl: null,
    ),
    CharityOrganization(
      id: 'org_4',
      name: 'Clean Water Initiative',
      mission: 'Ensure access to clean drinking water in rural communities',
      targetAmount: 900000,
      currentAmountCollected: 540000,
      description:
          'Providing clean water systems and sanitation facilities to rural villages where waterborne diseases are common. We maintain wells, filtration systems, and conduct hygiene awareness programs.',
      category: 'Health & Environment',
      imageUrl: null,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Charity & Funding'),
        backgroundColor: Colors.purple.shade600,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.purple.shade300, Colors.purple.shade600],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Help Make a Difference',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Support meaningful causes that improve lives and communities',
                    style: TextStyle(color: Colors.white, fontSize: 14),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      '💡 Every donation, no matter the size, makes an impact!',
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Organizations List
            Text(
              'Featured Organizations',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _dummyOrganizations.length,
              itemBuilder: (context, index) {
                final org = _dummyOrganizations[index];
                return _buildOrganizationCard(context, org);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrganizationCard(
      BuildContext context, CharityOrganization org) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Organization Header
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.purple.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.favorite,
                    size: 32,
                    color: Colors.purple,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        org.name,
                        style:
                            Theme.of(context).textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.purple.shade100,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          org.category,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Colors.purple,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Mission
            Text(
              org.mission,
              style: Theme.of(context).textTheme.bodySmall,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
            // Progress Bar
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Fund Progress',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    Text(
                      '${org.progressPercentage.toStringAsFixed(1)}%',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.purple,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: org.progressPercentage / 100,
                    minHeight: 8,
                    backgroundColor: Colors.grey.shade300,
                    valueColor:
                        AlwaysStoppedAnimation<Color>(Colors.purple.shade600),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Rs ${org.currentAmountCollected.toStringAsFixed(0)} / Rs ${org.targetAmount.toStringAsFixed(0)}',
                  style: Theme.of(context).textTheme.labelSmall,
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Buttons Row
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _showOrgDetails(context, org),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.purple),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Learn More'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _showDonationForm(context, org),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple.shade600,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    icon: const Icon(Icons.favorite),
                    label: const Text('Donate'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showOrgDetails(
      BuildContext context, CharityOrganization org) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      org.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'About',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Text(org.description),
              const SizedBox(height: 16),
              Text(
                'Impact',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              _buildImpactRow('Target', 'Rs ${org.targetAmount.toStringAsFixed(0)}'),
              _buildImpactRow('Collected', 'Rs ${org.currentAmountCollected.toStringAsFixed(0)}'),
              _buildImpactRow('Needed', 'Rs ${(org.targetAmount - org.currentAmountCollected).toStringAsFixed(0)}'),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    _showDonationForm(context, org);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple.shade600,
                  ),
                  icon: const Icon(Icons.favorite),
                  label: const Text('Make a Donation'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImpactRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  void _showDonationForm(BuildContext context, CharityOrganization org) {
    final amountCtrl = TextEditingController();
    final nameCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final messageCtrl = TextEditingController();
    String? selectedMethod;
    bool isLoading = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Make a Donation'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'To: ${org.name}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.purple,
                  ),
                ),
                const SizedBox(height: 20),
                // Amount
                TextField(
                  controller: amountCtrl,
                  decoration: InputDecoration(
                    labelText: 'Donation Amount (NRS)',
                    prefixText: 'Rs ',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                // Payment Method
                DropdownButtonFormField<String>(
                  value: selectedMethod,
                  items: ['Bank Transfer', 'Mobile Payment', 'Cash']
                      .map((method) => DropdownMenuItem<String>(
                            value: method,
                            child: Text(method),
                          ))
                      .toList(),
                  onChanged: (value) =>
                      setDialogState(() => selectedMethod = value),
                  decoration: InputDecoration(
                    labelText: 'Payment Method',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // Donor Name
                TextField(
                  controller: nameCtrl,
                  decoration: InputDecoration(
                    labelText: 'Your Name',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // Donor Email
                TextField(
                  controller: emailCtrl,
                  decoration: InputDecoration(
                    labelText: 'Your Email',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 12),
                // Message
                TextField(
                  controller: messageCtrl,
                  decoration: InputDecoration(
                    labelText: 'Message (Optional)',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  maxLines: 3,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: isLoading ? null : () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: isLoading
                  ? null
                  : () async {
                      if (amountCtrl.text.isEmpty ||
                          selectedMethod == null ||
                          nameCtrl.text.isEmpty ||
                          emailCtrl.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Please fill required fields'),
                          ),
                        );
                        return;
                      }

                      setDialogState(() => isLoading = true);

                      try {
                        final auth = Provider.of<AuthService>(context,
                            listen: false);
                        final fs = Provider.of<FirestoreService>(context,
                            listen: false);

                        await fs.submitDonation(
                          amount: double.parse(amountCtrl.text),
                          organizationId: org.id,
                          donorId: auth.currentUid ?? 'anonymous',
                          donorName: nameCtrl.text.trim(),
                          donorEmail: emailCtrl.text.trim(),
                          paymentMethod: selectedMethod!,
                          message: messageCtrl.text.trim(),
                        );

                        if (mounted) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                  'Thank you! Your donation has been received.'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        }
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error: $e')),
                        );
                        setDialogState(() => isLoading = false);
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple.shade600,
              ),
              child: isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text('Donate Now'),
            ),
          ],
        ),
      ),
    );
  }
}