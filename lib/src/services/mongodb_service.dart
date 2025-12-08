import 'package:mongo_dart/mongo_dart.dart';
import 'package:flutter/foundation.dart';
import '../config/mongodb_config.dart';

class MongoDBService {
  static MongoDBService? _instance;
  static Db? _db;
  
  MongoDBService._();
  
  static MongoDBService get instance {
    _instance ??= MongoDBService._();
    return _instance!;
  }
  
  // Initialize MongoDB connection
  Future<void> connect() async {
    try {
      if (_db != null && _db!.isConnected) {
        if (kDebugMode) debugPrint('MongoDB already connected');
        return;
      }
      
      final connectionString = MongoDBConfig.connectionString;
      if (kDebugMode) debugPrint('Connecting to MongoDB Atlas...');
      
      _db = await Db.create(connectionString);
      await _db!.open();
      
      if (kDebugMode) debugPrint('✅ MongoDB connected to ${MongoDBConfig.databaseName}');
      
      // Create indexes for better performance
      await _createIndexes();
    } catch (e) {
      if (kDebugMode) debugPrint('⚠️ MongoDB connection failed: $e');
      rethrow;
    }
  }
  
  // Create database indexes
  Future<void> _createIndexes() async {
    try {
      // Farmers collection indexes
      final farmersCollection = _db!.collection(MongoDBConfig.farmersCollection);
      await farmersCollection.createIndex(key: 'farmerId', unique: true);
      await farmersCollection.createIndex(key: 'phone');
      await farmersCollection.createIndex(key: 'aadhaar.number');
      
      // Crop images collection indexes
      final imagesCollection = _db!.collection(MongoDBConfig.cropImagesCollection);
      await imagesCollection.createIndex(key: 'imageId', unique: true);
      await imagesCollection.createIndex(key: 'farmerId');
      await imagesCollection.createIndex(key: 'parcelId');
      await imagesCollection.createIndex(keys: {'farmerId': 1, 'season': 1});
      
      // Claims collection indexes
      final claimsCollection = _db!.collection(MongoDBConfig.claimsCollection);
      await claimsCollection.createIndex(key: 'claimId', unique: true);
      await claimsCollection.createIndex(key: 'farmerId');
      await claimsCollection.createIndex(key: 'status');
      await claimsCollection.createIndex(keys: {'farmerId': 1, 'season': 1});
      
      // Officials collection indexes
      final officialsCollection = _db!.collection(MongoDBConfig.officialsCollection);
      await officialsCollection.createIndex(key: 'userId', unique: true);
      await officialsCollection.createIndex(key: 'phone');
      
      debugPrint('MongoDB indexes created successfully');
    } catch (e) {
      debugPrint('Error creating indexes: $e');
    }
  }
  
  // Disconnect from MongoDB
  Future<void> disconnect() async {
    try {
      if (_db != null && _db!.isConnected) {
        await _db!.close();
        debugPrint('MongoDB disconnected');
      }
    } catch (e) {
      debugPrint('MongoDB disconnection error: $e');
    }
  }
  
  // Get database instance
  Db? get database => _db;
  
  // Check if connected
  bool get isConnected => _db != null && _db!.isConnected;
  
  // Get collection
  DbCollection getCollection(String collectionName) {
    if (_db == null || !_db!.isConnected) {
      throw Exception('MongoDB not connected. Call connect() first.');
    }
    return _db!.collection(collectionName);
  }
  
  // Helper method to handle connection retry
  Future<T> withRetry<T>(
    Future<T> Function() operation, {
    int maxRetries = 3,
    Duration retryDelay = const Duration(seconds: 2),
  }) async {
    int attempts = 0;
    
    while (attempts < maxRetries) {
      try {
        if (!isConnected) {
          await connect();
        }
        return await operation();
      } catch (e) {
        attempts++;
        if (attempts >= maxRetries) {
          rethrow;
        }
        debugPrint('Operation failed, retrying... (attempt $attempts/$maxRetries)');
        await Future.delayed(retryDelay);
      }
    }
    
    throw Exception('Operation failed after $maxRetries attempts');
  }
}
