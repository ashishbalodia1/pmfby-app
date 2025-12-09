import 'package:mongo_dart/mongo_dart.dart';
import '../models/mongodb/claim_model.dart';
import '../services/mongodb_service.dart';
import '../config/mongodb_config.dart';

/// Repository for managing claims in MongoDB
class ClaimRepository {
  final MongoDBService _mongoService = MongoDBService.instance;

  DbCollection get _collection =>
      _mongoService.getCollection(MongoDBConfig.claimsCollection);

  /// Create a new claim
  Future<String> createClaim(ClaimModel claim) async {
    try {
      final result = await _collection.insertOne(claim.toMap());
      return result.id.toString();
    } catch (e) {
      print('Error creating claim: $e');
      rethrow;
    }
  }

  /// Get claim by ID
  Future<ClaimModel?> getClaimById(String claimId) async {
    try {
      final result = await _collection.findOne(where.eq('claimId', claimId));
      return result != null ? ClaimModel.fromMap(result) : null;
    } catch (e) {
      print('Error getting claim: $e');
      return null;
    }
  }

  /// Get all claims for a farmer
  Future<List<ClaimModel>> getClaimsByFarmer(String farmerId) async {
    try {
      final results = await _collection
          .find(where.eq('farmerId', farmerId).sortBy('createdAt', descending: true))
          .toList();
      return results.map((doc) => ClaimModel.fromMap(doc)).toList();
    } catch (e) {
      print('Error getting farmer claims: $e');
      return [];
    }
  }

  /// Get claims by status
  Future<List<ClaimModel>> getClaimsByStatus(String status) async {
    try {
      final results = await _collection
          .find(where.eq('status', status).sortBy('createdAt', descending: true))
          .toList();
      return results.map((doc) => ClaimModel.fromMap(doc)).toList();
    } catch (e) {
      print('Error getting claims by status: $e');
      return [];
    }
  }

  /// Get all claims (for officers)
  Future<List<ClaimModel>> getAllClaims({int? limit}) async {
    try {
      var query = _collection.find(where.sortBy('createdAt', descending: true));
      
      if (limit != null) {
        query = query.take(limit);
      }
      
      final results = await query.toList();
      return results.map((doc) => ClaimModel.fromMap(doc)).toList();
    } catch (e) {
      print('Error getting all claims: $e');
      return [];
    }
  }

  /// Get claims by district (for district officers)
  Future<List<ClaimModel>> getClaimsByDistrict(String district, {String? status}) async {
    try {
      var query = where.sortBy('createdAt', descending: true);
      
      if (status != null) {
        query = query.eq('status', status);
      }
      
      final results = await _collection.find(query).toList();
      
      // Filter by district (would need district field in claim model or join with farmer data)
      // For now, returning all claims - you can enhance this with proper district filtering
      return results.map((doc) => ClaimModel.fromMap(doc)).toList();
    } catch (e) {
      print('Error getting district claims: $e');
      return [];
    }
  }

  /// Update claim status
  Future<bool> updateClaimStatus({
    required String claimId,
    required String status,
    String? reviewerId,
    String? notes,
  }) async {
    try {
      final updateMap = {
        'status': status,
        'updatedAt': DateTime.now(),
      };
      
      if (reviewerId != null || notes != null) {
        updateMap['humanReview.reviewedAt'] = DateTime.now();
        if (reviewerId != null) updateMap['humanReview.reviewerId'] = reviewerId;
        if (notes != null) updateMap['humanReview.notes'] = notes;
      }
      
      final result = await _collection.updateOne(
        where.eq('claimId', claimId),
        modify.set('status', status)
            .set('updatedAt', DateTime.now())
            .set('humanReview.reviewedAt', DateTime.now())
            .set('humanReview.reviewerId', reviewerId ?? '')
            .set('humanReview.notes', notes ?? ''),
      );
      
      return result.isSuccess && result.nModified > 0;
    } catch (e) {
      print('Error updating claim status: $e');
      return false;
    }
  }

  /// Update claim with payout information
  Future<bool> updateClaimPayout({
    required String claimId,
    required Payout payout,
  }) async {
    try {
      final result = await _collection.updateOne(
        where.eq('claimId', claimId),
        modify
            .set('payout', payout.toMap())
            .set('status', 'APPROVED')
            .set('updatedAt', DateTime.now()),
      );
      
      return result.isSuccess && result.nModified > 0;
    } catch (e) {
      print('Error updating claim payout: $e');
      return false;
    }
  }

  /// Get claim statistics
  Future<Map<String, int>> getClaimStats() async {
    try {
      final allClaims = await getAllClaims();
      
      return {
        'total': allClaims.length,
        'pending': allClaims.where((c) => c.status == 'PENDING').length,
        'approved': allClaims.where((c) => c.status == 'APPROVED').length,
        'rejected': allClaims.where((c) => c.status == 'REJECTED').length,
        'review': allClaims.where((c) => c.status == 'REVIEW').length,
      };
    } catch (e) {
      print('Error getting claim stats: $e');
      return {'total': 0, 'pending': 0, 'approved': 0, 'rejected': 0, 'review': 0};
    }
  }

  /// Delete claim (for testing purposes)
  Future<bool> deleteClaim(String claimId) async {
    try {
      final result = await _collection.deleteOne(where.eq('claimId', claimId));
      return result.isSuccess && result.nRemoved > 0;
    } catch (e) {
      print('Error deleting claim: $e');
      return false;
    }
  }
}
