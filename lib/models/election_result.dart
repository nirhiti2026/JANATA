import 'package:cloud_firestore/cloud_firestore.dart';

class ElectionResult {
  final String id;
  final String politicianName;
  final String? politicianUid;
  final String? province;
  final String? wardNo;
  final int votes;
  final int? totalVotesCast;
  final double? votePercentage;
  final String position; // e.g., 'Mayor', 'Ward Councilor', 'Representative'
  final int electionYear;
  final String? notes;
  final Timestamp? createdAt;

  ElectionResult({
    required this.id,
    required this.politicianName,
    this.politicianUid,
    this.province,
    this.wardNo,
    required this.votes,
    this.totalVotesCast,
    this.votePercentage,
    required this.position,
    required this.electionYear,
    this.notes,
    this.createdAt,
  });

  Map<String, dynamic> toMap() => {
        'politicianName': politicianName,
        'politicianUid': politicianUid,
        'province': province,
        'wardNo': wardNo,
        'votes': votes,
        'totalVotesCast': totalVotesCast,
        'votePercentage': votePercentage,
        'position': position,
        'electionYear': electionYear,
        'notes': notes,
        'createdAt': createdAt ?? Timestamp.now(),
      };

  static ElectionResult fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ElectionResult(
      id: doc.id,
      politicianName: data['politicianName'] ?? '',
      politicianUid: data['politicianUid'],
      province: data['province'],
      wardNo: data['wardNo'],
      votes: data['votes'] ?? 0,
      totalVotesCast: data['totalVotesCast'],
      votePercentage: data['votePercentage'],
      position: data['position'] ?? '',
      electionYear: data['electionYear'] ?? DateTime.now().year,
      notes: data['notes'],
      createdAt: data['createdAt'],
    );
  }
}
