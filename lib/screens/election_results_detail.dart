import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/firestore_service.dart';
import '../models/election_result.dart';

class ElectionResultsDetail extends StatefulWidget {
  final String politicianName;
  const ElectionResultsDetail({super.key, required this.politicianName});

  @override
  State<ElectionResultsDetail> createState() => _ElectionResultsDetailState();
}

class _ElectionResultsDetailState extends State<ElectionResultsDetail> {
  @override
  Widget build(BuildContext context) {
    final fs = Provider.of<FirestoreService>(context, listen: false);
    return Scaffold(
      appBar: AppBar(title: Text('${widget.politicianName} - Election Results')),
      body: StreamBuilder<List<ElectionResult>>(
        stream: fs.streamElectionResultsByPolitician(widget.politicianName),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        const Text('Firestore Index Required'),
                        const SizedBox(height: 8),
                        Text(
                          'To view election results, create a composite index in Firebase Console:\n\n'
                          '1. Go to Firebase Console > Firestore > Indexes\n'
                          '2. Click "Create Index"\n'
                          '3. Collection: election_results\n'
                          '4. Fields: politicianName (Ascending), electionYear (Descending)\n'
                          '5. Wait for index to build (~1-5 minutes)\n\n'
                          'Error: ${snapshot.error}',
                          style: const TextStyle(fontSize: 11),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final results = snapshot.data ?? [];
          if (results.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.how_to_vote, size: 48, color: Colors.grey),
                  const SizedBox(height: 8),
                  Text('No election results found for ${widget.politicianName}'),
                ],
              ),
            );
          }
          // Sort by electionYear descending
          results.sort((a, b) => b.electionYear.compareTo(a.electionYear));
          return SingleChildScrollView(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              children: [
                ...results.map(
                  (result) => Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${result.position} - ${result.electionYear}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.teal,
                                ),
                              ),
                              Chip(
                                label: Text('${result.votes} votes'),
                                backgroundColor: Colors.cyan[100],
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          _buildResultField('Province', result.province ?? 'N/A'),
                          _buildResultField('Ward No', result.wardNo ?? 'N/A'),
                          if (result.votePercentage != null)
                            _buildResultField(
                              'Vote Percentage',
                              '${result.votePercentage!.toStringAsFixed(2)}%',
                            ),
                          if (result.totalVotesCast != null)
                            _buildResultField(
                              'Total Votes Cast',
                              result.totalVotesCast.toString(),
                            ),
                          if (result.notes != null && result.notes!.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            _buildResultField('Notes', result.notes!),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildResultField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.grey),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}
