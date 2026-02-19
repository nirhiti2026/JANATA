import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/firestore_service.dart';
import '../services/auth_service.dart';

class AssignedProblems extends StatelessWidget {
  const AssignedProblems({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthService>(context, listen: false);
    final fs = Provider.of<FirestoreService>(context, listen: false);
    final uid = auth.currentUid ?? '';    return Scaffold(
      appBar: AppBar(title: const Text('Assigned Problems')),
      body: StreamBuilder(
        stream: fs.streamProblemsAssignedTo(uid),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.cloud_off, size: 48, color: Colors.grey),
                  SizedBox(height: 8),
                  Text('Firestore unavailable — no assigned problems in demo mode', style: TextStyle(color: Colors.grey)),
                ],
              ),
            );
          }
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final list = snapshot.data as List;
          if (list.isEmpty) return const Center(child: Text('No assigned problems'));
          return ListView.builder(
            itemCount: list.length,
            itemBuilder: (context, index) {
              final p = list[index];
              return ListTile(
                title: Text(p.title),
                subtitle: Text(p.description),
                trailing: p.status == 'solved'
                    ? const Text('Solved')
                    : ElevatedButton(
                        onPressed: () => showDialog(
                          context: context,
                          builder: (ctx) {
                            final ctrl = TextEditingController();
                            return AlertDialog(
                              title: const Text('Submit Solution'),
                              content: TextField(controller: ctrl, decoration: const InputDecoration(hintText: 'Solution')),
                              actions: [
                                TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
                                ElevatedButton(
                                  onPressed: () {
                                    fs.submitSolution(p.id, ctrl.text.trim()).then((_) => Navigator.pop(ctx));
                                  },
                                  child: const Text('Submit'))
                              ],
                            );
                          },
                        ),
                        child: const Text('Add Solution')),
              );
            },
          );
        },
      ),
    );
  }
}
