import 'package:cloud_firestore/cloud_firestore.dart';

class Problem {
  final String id;
  final String title;
  final String description;
  final String province;
  final String wardNo;
  final String problemType;
  final String citizenId;
  final String? assignedTo;
  final String status; // pending, solving, solved
  final String? solution;
  final String? solutionImage;
  final String? solutionVideo;
  final Timestamp createdAt;

  Problem({
    required this.id,
    required this.title,
    required this.description,
    required this.province,
    required this.wardNo,
    required this.problemType,
    required this.citizenId,
    this.assignedTo,
    required this.status,
    this.solution,
    this.solutionImage,
    this.solutionVideo,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
        'title': title,
        'description': description,
        'province': province,
        'wardNo': wardNo,
        'problemType': problemType,
        'citizenId': citizenId,
        'assignedTo': assignedTo,
        'status': status,
        'solution': solution,
        'solutionImage': solutionImage,
        'solutionVideo': solutionVideo,
        'createdAt': createdAt,
      };

  static Problem fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Problem(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      province: data['province'] ?? '',
      wardNo: data['wardNo'] ?? '',
      problemType: data['problemType'] ?? '',
      citizenId: data['citizenId'] ?? '',
      assignedTo: data['assignedTo'],
      status: data['status'] ?? 'pending',
      solution: data['solution'],
      solutionImage: data['solutionImage'],
      solutionVideo: data['solutionVideo'],
      createdAt: data['createdAt'] ?? Timestamp.now(),
    );
  }
}
