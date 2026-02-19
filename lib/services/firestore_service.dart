import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import '../models/problem.dart';
import '../models/election_result.dart';

/// Service layer for Firestore database operations
/// Handles all CRUD operations for problems, politicians, elections, complaints, and donations
class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ============== POLITICIAN QUERIES ==============

  Stream<List<Map<String, dynamic>>> streamPoliticians() {
    return _db.collection('users').where('role', isEqualTo: 'politician').snapshots().map((snap) =>
        snap.docs.map((d) => {'uid': d.id, ...d.data()}).toList());
  }

  Future<List<Map<String, dynamic>>> getPoliticiansOnce() async {
    final snap = await _db.collection('users').where('role', isEqualTo: 'politician').get();
    return snap.docs.map((d) => {'uid': d.id, ...d.data()}).toList();
  }

  // ============== PROBLEM QUERIES ==============

  Future<void> createProblem(Problem p) async {
    await _db.collection('problems').add(p.toMap());
  }

  Stream<List<Problem>> streamProblemsAssignedTo(String politicianId) {
    return _db
        .collection('problems')
        .where('assignedTo', isEqualTo: politicianId)
        .snapshots()
        .map((snap) {
          final problems = snap.docs.map((d) => Problem.fromDoc(d)).toList();
          problems.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return problems;
        });
  }

  Stream<List<Problem>> streamAllPendingProblems() {
    return _db
        .collection('problems')
        .where('status', isNotEqualTo: 'solved')
        .snapshots()
        .map((snap) {
          final problems = snap.docs.map((d) => Problem.fromDoc(d)).toList();
          problems.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return problems;
        });
  }

  Stream<List<Problem>> streamProblemsByCitizen(String citizenId) {
    return _db
        .collection('problems')
        .where('citizenId', isEqualTo: citizenId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((d) => Problem.fromDoc(d)).toList());
  }

  Stream<List<Problem>> streamAllProblems() {
    return _db.collection('problems').orderBy('createdAt', descending: true).snapshots().map((s) => s.docs.map((d) => Problem.fromDoc(d)).toList());
  }

  Future<void> submitSolution(String problemId, String solutionText) async {
    await _db.collection('problems').doc(problemId).update({'solution': solutionText, 'status': 'solved'});
  }

  // ============== ELECTION RESULTS QUERIES ==============

  Stream<List<ElectionResult>> streamElectionResultsByPolitician(String politicianName) {
    return _db
        .collection('election_results')
        .where('politicianName', isEqualTo: politicianName)
        .snapshots()
        .map((snap) => snap.docs.map((d) => ElectionResult.fromDoc(d)).toList());
  }

  Future<List<ElectionResult>> getElectionResultsByPolitician(String politicianName) async {
    final snap = await _db
        .collection('election_results')
        .where('politicianName', isEqualTo: politicianName)
        .get();
    return snap.docs.map((d) => ElectionResult.fromDoc(d)).toList();
  }

  Stream<List<ElectionResult>> streamAllElectionResults() {
    return _db
        .collection('election_results')
        .orderBy('electionYear', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((d) => ElectionResult.fromDoc(d)).toList());
  }

  Future<void> createElectionResult(ElectionResult result) async {
    await _db.collection('election_results').add(result.toMap());
  }

  Future<void> updateElectionResult(String resultId, ElectionResult result) async {
    await _db.collection('election_results').doc(resultId).update(result.toMap());
  }

  Future<void> deleteElectionResult(String resultId) async {
    await _db.collection('election_results').doc(resultId).delete();
  }

  // ============== MEDIA UPLOADS ==============

  Future<String> uploadSolutionImage(String problemId, File imageFile) async {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final ref = FirebaseStorage.instance
        .ref()
        .child('solutions/$problemId/images/$timestamp.jpg');
    await ref.putFile(imageFile);
    return await ref.getDownloadURL();
  }

  Future<String> uploadSolutionVideo(String problemId, File videoFile) async {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final ref = FirebaseStorage.instance
        .ref()
        .child('solutions/$problemId/videos/$timestamp.mp4');
    await ref.putFile(videoFile);
    return await ref.getDownloadURL();
  }

  Future<String> uploadReportImage(String politicianId, File imageFile) async {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final ref = FirebaseStorage.instance
        .ref()
        .child('reports/$politicianId/images/$timestamp.jpg');
    await ref.putFile(imageFile);
    return await ref.getDownloadURL();
  }

  Future<String> uploadReportVideo(String politicianId, File videoFile) async {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final ref = FirebaseStorage.instance
        .ref()
        .child('reports/$politicianId/videos/$timestamp.mp4');
    await ref.putFile(videoFile);
    return await ref.getDownloadURL();
  }

  Future<void> submitSolutionWithMedia(
    String problemId,
    String solutionText, {
    String? imageUrl,
    String? videoUrl,
  }) async {
    await _db.collection('problems').doc(problemId).update({
      'solution': solutionText,
      'solutionImage': imageUrl,
      'solutionVideo': videoUrl,
      'status': 'solving',
      'solutionSubmittedAt': Timestamp.now(),
    });
  }

  Future<void> updateProblemStatus(String problemId, String status) async {
    await _db.collection('problems').doc(problemId).update({
      'status': status,
      'solvedAt': Timestamp.now(),
    });
  }

  // ============== POLITICIAN COMPLAINTS ==============

  Future<void> submitPoliticianComplaint({
    required String politicianId,
    required String politicianName,
    required String citizenId,
    required String reason,
    required String description,
    required String complaintType,
    String? imageUrl,
    String? videoUrl,
  }) async {
    await _db.collection('politician_complaints').add({
      'politicianId': politicianId,
      'politicianName': politicianName,
      'citizenId': citizenId,
      'complaintReason': reason,
      'description': description,
      'complaintType': complaintType,
      'imageUrl': imageUrl,
      'videoUrl': videoUrl,
      'status': 'pending',
      'createdAt': Timestamp.now(),
      'updatedAt': Timestamp.now(),
    });
  }

  Stream<List<Map<String, dynamic>>> streamPoliticianComplaints(String politicianId) {
    return _db
        .collection('politician_complaints')
        .where('politicianId', isEqualTo: politicianId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => {'id': d.id, ...d.data()}).toList());
  }

  // ============== DONATIONS & CHARITY ==============

  Future<void> submitDonation({
    required double amount,
    required String organizationId,
    required String donorId,
    required String donorName,
    required String donorEmail,
    required String paymentMethod,
    String? message,
  }) async {
    // Save donation record
    await _db.collection('donations').add({
      'amount': amount,
      'organizationId': organizationId,
      'donorId': donorId,
      'donorName': donorName,
      'donorEmail': donorEmail,
      'paymentMethod': paymentMethod,
      'message': message,
      'status': 'completed',
      'createdAt': Timestamp.now(),
    });

    // Update organization's total collected amount
    final orgDoc = await _db.collection('charity_organizations').doc(organizationId).get();
    if (orgDoc.exists) {
      final currentAmount = (orgDoc.data()?['currentAmountCollected'] as num?)?.toDouble() ?? 0;
      await _db
          .collection('charity_organizations')
          .doc(organizationId)
          .update({'currentAmountCollected': currentAmount + amount});
    }
  }

  Stream<List<Map<String, dynamic>>> streamDonations(String organizationId) {
    return _db
        .collection('donations')
        .where('organizationId', isEqualTo: organizationId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => {'id': d.id, ...d.data()}).toList());
  }

  Stream<List<Map<String, dynamic>>> streamDonationsByDonor(String donorId) {
    return _db
        .collection('donations')
        .where('donorId', isEqualTo: donorId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => {'id': d.id, ...d.data()}).toList());
  }
}
