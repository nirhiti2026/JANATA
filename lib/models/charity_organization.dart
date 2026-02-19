import 'package:cloud_firestore/cloud_firestore.dart';

class CharityOrganization {
  final String id;
  final String name;
  final String mission;
  final double targetAmount;
  final double currentAmountCollected;
  final String description;
  final String category;
  final String? imageUrl;

  CharityOrganization({
    required this.id,
    required this.name,
    required this.mission,
    required this.targetAmount,
    required this.currentAmountCollected,
    required this.description,
    required this.category,
    this.imageUrl,
  });

  double get progressPercentage => (currentAmountCollected / targetAmount * 100).clamp(0, 100);

  Map<String, dynamic> toMap() => {
        'name': name,
        'mission': mission,
        'targetAmount': targetAmount,
        'currentAmountCollected': currentAmountCollected,
        'description': description,
        'category': category,
        'imageUrl': imageUrl,
      };

  static CharityOrganization fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CharityOrganization(
      id: doc.id,
      name: data['name'] ?? '',
      mission: data['mission'] ?? '',
      targetAmount: (data['targetAmount'] as num?)?.toDouble() ?? 100000,
      currentAmountCollected: (data['currentAmountCollected'] as num?)?.toDouble() ?? 0,
      description: data['description'] ?? '',
      category: data['category'] ?? '',
      imageUrl: data['imageUrl'],
    );
  }
}

class Donation {
  final String id;
  final double amount;
  final String organizationId;
  final String donorId;
  final String donorName;
  final String donorEmail;
  final String paymentMethod;
  final String? message;
  final String status;
  final Timestamp createdAt;

  Donation({
    required this.id,
    required this.amount,
    required this.organizationId,
    required this.donorId,
    required this.donorName,
    required this.donorEmail,
    required this.paymentMethod,
    this.message,
    required this.status,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
        'amount': amount,
        'organizationId': organizationId,
        'donorId': donorId,
        'donorName': donorName,
        'donorEmail': donorEmail,
        'paymentMethod': paymentMethod,
        'message': message,
        'status': status,
        'createdAt': createdAt,
      };

  static Donation fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Donation(
      id: doc.id,
      amount: (data['amount'] as num?)?.toDouble() ?? 0,
      organizationId: data['organizationId'] ?? '',
      donorId: data['donorId'] ?? '',
      donorName: data['donorName'] ?? '',
      donorEmail: data['donorEmail'] ?? '',
      paymentMethod: data['paymentMethod'] ?? '',
      message: data['message'],
      status: data['status'] ?? 'completed',
      createdAt: data['createdAt'] ?? Timestamp.now(),
    );
  }
}
