import 'package:cloud_firestore/cloud_firestore.dart';

class PoliticianComplaint {
  final String id;
  final String politicianId;
  final String politicianName;
  final String citizenId;
  final String complaintReason;
  final String description;
  final String complaintType; // 'Urgent', 'Normal'
  final String status; // 'pending', 'reviewed', 'resolved'
  final Timestamp createdAt;

  PoliticianComplaint({
    required this.id,
    required this.politicianId,
    required this.politicianName,
    required this.citizenId,
    required this.complaintReason,
    required this.description,
    required this.complaintType,
    required this.status,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
        'politicianId': politicianId,
        'politicianName': politicianName,
        'citizenId': citizenId,
        'complaintReason': complaintReason,
        'description': description,
        'complaintType': complaintType,
        'status': status,
        'createdAt': createdAt,
      };

  static PoliticianComplaint fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PoliticianComplaint(
      id: doc.id,
      politicianId: data['politicianId'] ?? '',
      politicianName: data['politicianName'] ?? '',
      citizenId: data['citizenId'] ?? '',
      complaintReason: data['complaintReason'] ?? '',
      description: data['description'] ?? '',
      complaintType: data['complaintType'] ?? 'Normal',
      status: data['status'] ?? 'pending',
      createdAt: data['createdAt'] ?? Timestamp.now(),
    );
  }
}
