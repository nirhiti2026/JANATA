import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/problem.dart';
import '../services/firestore_service.dart';

class ProblemList extends StatefulWidget {
  final bool viewSolvedOnly;
  const ProblemList({super.key, this.viewSolvedOnly = false});

  @override
  State<ProblemList> createState() => _ProblemListState();
}

class _ProblemListState extends State<ProblemList> {
  final _searchCtrl = TextEditingController();
  String _searchBy = 'Date';
  Map<String, String> _politicianNames = {};

  @override
  void initState() {
    super.initState();
    _loadPoliticians();
  }

  Future<void> _loadPoliticians() async {
    final fs = Provider.of<FirestoreService>(context, listen: false);
    try {
      final list = await fs.getPoliticiansOnce();
      final map = <String, String>{};
      for (var p in list) {
        final uid = p['uid'] as String;
        final name = (p['name'] ?? '') as String;
        map[uid] = name;
      }
      setState(() => _politicianNames = map);
    } catch (_) {
      // demo mode or unavailable - ignore
    }
  }

  List<Problem> _applyFilter(List<Problem> all) {
    var filtered = all.where((p) => !widget.viewSolvedOnly || p.status == 'solved').toList();
    final q = _searchCtrl.text.trim();
    if (q.isEmpty) return filtered;
    final ql = q.toLowerCase();
    switch (_searchBy) {
      case 'Date':
        return filtered.where((p) => p.createdAt.toDate().toString().toLowerCase().contains(ql)).toList();
      case 'Province':
        return filtered.where((p) => p.province.toLowerCase().contains(ql)).toList();
      case 'Ward No':
        return filtered.where((p) => p.wardNo.toLowerCase().contains(ql)).toList();
      case 'Politician name':
        return filtered.where((p) {
          final name = _politicianNames[p.assignedTo] ?? '';
          return name.toLowerCase().contains(ql);
        }).toList();
      case 'Name':
        return filtered.where((p) => p.title.toLowerCase().contains(ql)).toList();
      case 'Problem Type':
        return filtered.where((p) => p.problemType.toLowerCase().contains(ql)).toList();
      default:
        return filtered;
    }
  }

  @override
  Widget build(BuildContext context) {
    final fs = Provider.of<FirestoreService>(context, listen: false);
    final stream = fs.streamAllProblems();
    return Scaffold(
      appBar: AppBar(title: Text(widget.viewSolvedOnly ? 'View Solved Problems' : 'All Problems')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 12.0),
                    child: SizedBox(
                      width: 200,
                      child: TextField(
                        controller: _searchCtrl,
                        decoration: const InputDecoration(
                          hintText: 'Search...',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        onChanged: (_) => setState(() {}),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 12.0),
                    child: SizedBox(
                      width: 180,
                      child: DropdownButtonFormField<String>(
                        value: _searchBy,
                        items: const [
                          DropdownMenuItem(value: 'Date', child: Text('Date')),
                          DropdownMenuItem(value: 'Province', child: Text('Province')),
                          DropdownMenuItem(value: 'Ward No', child: Text('Ward No')),
                          DropdownMenuItem(value: 'Politician name', child: Text('Politician')),
                          DropdownMenuItem(value: 'Name', child: Text('Name')),
                          DropdownMenuItem(value: 'Problem Type', child: Text('Type')),
                        ],
                        onChanged: (v) => setState(() => _searchBy = v ?? 'Date'),
                        decoration: const InputDecoration(
                          labelText: 'Search By',
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => setState(() {}),
                    icon: const Icon(Icons.search),
                    label: const Text('Search'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: () => setState(() {
                      _searchCtrl.clear();
                      _searchBy = 'Date';
                    }),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Reset'),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<List<Problem>>(
              stream: stream,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.cloud_off, size: 48, color: Colors.grey),
                        SizedBox(height: 8),
                        Text('Firestore unavailable', style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  );
                }
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                final allProblems = snapshot.data ?? <Problem>[];
                final problems = _applyFilter(allProblems);
                return problems.isEmpty
                    ? const Center(child: Text('No problems found.'))
                    : ListView.builder(
                        itemCount: problems.length,
                        itemBuilder: (context, index) {
                          final p = problems[index];
                          final politicianName = _politicianNames[p.assignedTo] ?? 'Unassigned';
                          return Card(
                            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            child: ListTile(
                              title: Text(p.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 4),
                                  Text('${p.province} - Ward ${p.wardNo}', style: const TextStyle(fontSize: 12)),
                                  Text('Type: ${p.problemType}', style: const TextStyle(fontSize: 12)),
                                  Text('Politician: $politicianName', style: const TextStyle(fontSize: 12)),
                                  const SizedBox(height: 4),
                                  Text(p.description, style: const TextStyle(fontSize: 11, color: Colors.grey), maxLines: 2, overflow: TextOverflow.ellipsis),
                                ],
                              ),
                              trailing: Chip(
                                label: Text(p.status, style: const TextStyle(color: Colors.white, fontSize: 12)),
                                backgroundColor: p.status == 'solved' ? Colors.green : Colors.orange,
                              ),
                            ),
                          );
                        },
                      );
              },
            ),
          ),
        ],
      ),
    );
  }
}
