# MongoDB Schema Design - PMFBY App

## 📊 Database Architecture Overview

**Database Name:** `pmfby_app`

**Storage Strategy:**
- **MongoDB Atlas** - All structured data (profiles, claims, metadata)
- **Cloudinary CDN** - Image files (URLs stored in MongoDB)

**Design Principles:**
- Document-oriented (NoSQL)
- Embedded documents for related data
- References for relationships between major entities
- Optimized indexes for fast queries
- Support for geospatial queries
- ML-ready data structure

---

## 📁 Collections Overview

| Collection | Purpose | Estimated Size | Growth Rate |
|------------|---------|----------------|-------------|
| `farmers` | Farmer profiles & land parcels | 10K-1M | Medium |
| `crop_images` | Crop images with ML metadata | 100K-10M | High |
| `crop_loss_intimations` | Loss reports from farmers | 10K-500K | Medium |
| `claims` | Insurance claims | 10K-500K | Medium |
| `officials` | Officer accounts & assignments | 100-10K | Low |
| `ai_inferences` | ML model results & logs | 100K-10M | High |
| `satellite_data` | Satellite imagery metadata | 10K-1M | Low |
| `audit_logs` | System activity logs | 1M-100M | Very High |

---

## 🌾 Collection Schemas

### 1. Farmers Collection

**Collection Name:** `farmers`

**Purpose:** Store farmer profiles, land parcels, and verification status

```javascript
{
  _id: ObjectId("507f1f77bcf86cd799439011"),
  farmerId: "F2024001234",              // Unique farmer ID
  
  // Personal Information
  name: {
    first: "Ram",
    last: "Singh"
  },
  phone: "+919876543210",               // Indexed
  email: "ram.singh@example.com",       // Optional
  
  // Identity Verification
  aadhaar: {
    number: "hashed_aadhaar_12345",     // Hashed, Indexed
    displayNumber: "xxxx-xxxx-1234",    // Masked for display
    verified: true
  },
  
  // Address
  address: {
    state: "Punjab",
    district: "Ludhiana",
    taluka: "Ludhiana",
    village: "Khanna",
    pincode: "141401"
  },
  
  // Land Parcels
  landParcels: [
    {
      parcelId: "P2024001234001",       // Unique parcel ID
      area: 2.5,                        // hectares
      
      // Geospatial boundary
      geoBoundary: {
        type: "Polygon",
        coordinates: [
          [
            [75.5671, 30.7046],         // [longitude, latitude]
            [75.5680, 30.7046],
            [75.5680, 30.7055],
            [75.5671, 30.7055],
            [75.5671, 30.7046]          // Closed polygon
          ]
        ]
      },
      
      // Crop History
      cropHistory: [
        {
          season: "Kharif",             // Kharif/Rabi
          year: 2024,
          cropName: "Wheat",
          cropType: "Rabi Crop",
          variety: "HD-2967",
          sowingDate: ISODate("2024-11-15"),
          expectedHarvestDate: ISODate("2025-04-15"),
          actualYield: 4.5,             // tons/hectare (after harvest)
          insuranceCoverage: {
            policyNumber: "PMFBY202400123",
            sumInsured: 50000,
            premium: 1500,
            status: "active"
          }
        }
      ]
    }
  ],
  
  // Metadata
  createdAt: ISODate("2024-01-15T10:30:00Z"),
  updatedAt: ISODate("2024-11-20T14:45:00Z"),
  
  // Account Status
  accountStatus: "active",              // active, suspended, inactive
  verificationStatus: "verified",       // pending, verified, rejected
  kycCompleted: true
}
```

**Indexes:**
```javascript
db.farmers.createIndex({ "farmerId": 1 }, { unique: true })
db.farmers.createIndex({ "phone": 1 })
db.farmers.createIndex({ "aadhaar.number": 1 })
db.farmers.createIndex({ "address.district": 1 })
db.farmers.createIndex({ "address.state": 1, "address.district": 1 })
db.farmers.createIndex({ "landParcels.geoBoundary": "2dsphere" })  // Geospatial
```

---

### 2. Crop Images Collection

**Collection Name:** `crop_images`

**Purpose:** Store crop images with ML verification metadata

```javascript
{
  _id: ObjectId("507f1f77bcf86cd799439012"),
  imageId: "IMG20241120143045F001",     // Unique image ID
  farmerId: "F2024001234",              // Reference to farmer
  parcelId: "P2024001234001",           // Reference to parcel
  
  // Image Metadata
  metadata: {
    width: 1920,
    height: 1080,
    format: "jpeg",
    sizeBytes: 524288,                  // ~500KB after compression
    deviceModel: "Samsung Galaxy M32",
    appVersion: "1.0.0"
  },
  
  // Location (GPS where photo was taken)
  location: {
    latitude: 30.7046,
    longitude: 75.5671,
    altitude: 250.0,                    // meters (optional)
    accuracy: 5.0,                      // meters
    timestamp: ISODate("2024-11-20T14:30:45Z")
  },
  
  // Cloud Storage URLs
  imageUrl: "https://res.cloudinary.com/demo/image/upload/v1234/pmfby_crops/F2024001234_cropHealth_1234.jpg",
  thumbnailUrl: "https://res.cloudinary.com/demo/image/upload/c_thumb,w_300,h_300/v1234/pmfby_crops/F2024001234_cropHealth_1234.jpg",
  cloudinaryPublicId: "pmfby_crops/F2024001234_cropHealth_1234",
  
  // Image Type & Purpose
  imageType: "cropHealth",              // cropHealth, cropDamage, sowingProof, harvestProof, lossEvidence
  
  // Crop Information
  cropInfo: {
    cropName: "Wheat",
    cropType: "Rabi Crop",
    variety: "HD-2967",
    sowingDate: ISODate("2024-11-15"),
    expectedHarvestDate: ISODate("2025-04-15")
  },
  
  // ML Verification (populated by ML model)
  mlVerification: {
    inferenceId: "INF20241120143100",
    modelVersion: "crop_verifier_v2.1",
    
    predictions: {
      cropType: "wheat",
      cropHealth: "healthy",
      growthStage: "vegetative",
      diseaseDetected: false,
      pestPresence: false
    },
    
    confidenceScore: 0.95,              // 0.0 to 1.0
    
    detectedIssues: [],                 // ["leaf_blight", "pest_damage"]
    
    // Classification scores for different categories
    classificationScores: {
      "healthy": 0.95,
      "diseased": 0.03,
      "pest_damage": 0.02
    },
    
    isAuthentic: true,                  // True if image is genuine
    fraudIndicator: null,               // "duplicate", "stock_photo", "manipulated"
    
    processedAt: ISODate("2024-11-20T14:31:00Z"),
    processingTimeMs: 1500
  },
  
  // Officer Verification (manual review)
  officerVerification: {
    officerId: "OFF001",
    officerName: "Rajesh Kumar",
    decision: "approved",               // approved, rejected, needsReview, fraudulent
    remarks: "Image quality good, crop verified",
    flags: null,                        // ["poor_quality", "location_mismatch"]
    verifiedAt: ISODate("2024-11-20T15:00:00Z")
  },
  
  // Temporal Context
  season: "Rabi",                       // Kharif/Rabi
  year: 2024,
  
  // Status Workflow
  status: "approved",                   // uploaded, pendingMLVerification, mlVerified, pendingOfficerReview, approved, rejected, flagged
  
  // Timestamps
  capturedAt: ISODate("2024-11-20T14:30:45Z"),  // When photo was taken
  uploadedAt: ISODate("2024-11-20T14:30:50Z"),  // When uploaded to cloud
  verifiedAt: ISODate("2024-11-20T15:00:00Z")   // When final verification done
}
```

**Indexes:**
```javascript
db.crop_images.createIndex({ "imageId": 1 }, { unique: true })
db.crop_images.createIndex({ "farmerId": 1 })
db.crop_images.createIndex({ "parcelId": 1 })
db.crop_images.createIndex({ "farmerId": 1, "season": 1, "year": 1 })
db.crop_images.createIndex({ "status": 1 })
db.crop_images.createIndex({ "capturedAt": -1 })
db.crop_images.createIndex({ "location": "2dsphere" })  // Geospatial
db.crop_images.createIndex({ "mlVerification.isAuthentic": 1 })
```

---

### 3. Crop Loss Intimations Collection

**Collection Name:** `crop_loss_intimations`

**Purpose:** Store crop loss reports with officer assessments

```javascript
{
  _id: ObjectId("507f1f77bcf86cd799439013"),
  lossId: "LOSS20241120001",           // Unique loss ID
  farmerId: "F2024001234",             // Reference to farmer
  parcelId: "P2024001234001",          // Reference to parcel
  
  // Loss Details
  lossDetails: {
    cropName: "Wheat",
    
    lossCause: "drought",              // drought, flood, cyclone, hailstorm, landslide, pestAttack, disease, wildAnimalAttack, fire, other
    
    estimatedLossPercentage: 60.0,     // Farmer's estimate
    affectedArea: 2.5,                 // hectares
    lossOccurredDate: ISODate("2024-11-15"),
    
    farmerDescription: "Severe drought conditions for 3 weeks, crops wilted and dried up",
    
    symptoms: [
      "Wilted crops",
      "Brown leaves",
      "No water availability",
      "Soil cracking"
    ]
  },
  
  // Supporting Evidence
  imageIds: [
    "IMG20241120143045F001",
    "IMG20241120143050F001",
    "IMG20241120143055F001"
  ],
  
  // Location where loss occurred
  location: {
    latitude: 30.7046,
    longitude: 75.5671,
    accuracy: 10.0,
    timestamp: ISODate("2024-11-20T14:30:45Z")
  },
  
  // Weather Conditions (at time of loss)
  weatherCondition: {
    temperature: 42.5,                 // °C
    rainfall: 0.0,                     // mm
    humidity: 15.0,                    // %
    windSpeed: 25.0,                   // km/h
    description: "Hot and dry, no rainfall for 21 days",
    recordedAt: ISODate("2024-11-15T12:00:00Z")
  },
  
  // Officer Assessment (after investigation)
  officerAssessment: {
    officerId: "OFF001",
    officerName: "Rajesh Kumar",
    
    assessedLossPercentage: 55.0,      // Officer's assessment
    isEligibleForClaim: true,
    
    assessmentRemarks: "Field visit conducted. Loss verified through satellite data and ground inspection.",
    
    verifiedImageIds: [
      "IMG20241120143045F001",
      "IMG20241120143050F001"
    ],
    
    assessedAt: ISODate("2024-11-21T10:00:00Z")
  },
  
  // Temporal Context
  season: "Rabi",
  year: 2024,
  
  // Status Workflow
  status: "assessed",                  // reported, underInvestigation, assessed, claimGenerated, rejected
  
  // Timestamps
  reportedAt: ISODate("2024-11-20T14:35:00Z"),
  assessedAt: ISODate("2024-11-21T10:00:00Z"),
  updatedAt: ISODate("2024-11-21T10:00:00Z")
}
```

**Indexes:**
```javascript
db.crop_loss_intimations.createIndex({ "lossId": 1 }, { unique: true })
db.crop_loss_intimations.createIndex({ "farmerId": 1 })
db.crop_loss_intimations.createIndex({ "status": 1 })
db.crop_loss_intimations.createIndex({ "farmerId": 1, "season": 1, "year": 1 })
db.crop_loss_intimations.createIndex({ "reportedAt": -1 })
db.crop_loss_intimations.createIndex({ "lossDetails.lossCause": 1 })
```

---

### 4. Claims Collection

**Collection Name:** `claims`

**Purpose:** Store insurance claims with approval workflow

```javascript
{
  _id: ObjectId("507f1f77bcf86cd799439014"),
  claimId: "CLM2024001234",            // Unique claim ID
  farmerId: "F2024001234",             // Reference to farmer
  parcelId: "P2024001234001",          // Reference to parcel
  lossId: "LOSS20241120001",           // Reference to loss intimation
  
  // Policy Details
  policyDetails: {
    policyNumber: "PMFBY202400123",
    sumInsured: 50000,
    premium: 1500,
    season: "Rabi",
    year: 2024,
    cropName: "Wheat"
  },
  
  // Claim Details
  claimDetails: {
    lossPercentage: 55.0,              // Assessed loss
    claimAmount: 27500,                // 55% of sum insured
    claimReason: "Drought damage verified through field assessment",
    
    supportingDocuments: [
      {
        type: "lossIntimation",
        documentId: "LOSS20241120001"
      },
      {
        type: "officerReport",
        documentId: "RPT20241121001"
      },
      {
        type: "satelliteData",
        documentId: "SAT20241115001"
      }
    ]
  },
  
  // Approval Workflow
  approvalWorkflow: [
    {
      level: "district",
      officerId: "OFF001",
      officerName: "Rajesh Kumar",
      decision: "approved",
      remarks: "Loss verified, claim justified",
      processedAt: ISODate("2024-11-21T10:30:00Z")
    },
    {
      level: "state",
      officerId: "OFF025",
      officerName: "Priya Sharma",
      decision: "approved",
      remarks: "Reviewed and approved",
      processedAt: ISODate("2024-11-22T14:00:00Z")
    }
  ],
  
  // Payment Details
  paymentDetails: {
    bankAccountNumber: "1234567890",   // Encrypted
    ifscCode: "SBIN0001234",
    accountHolderName: "Ram Singh",
    paymentStatus: "processed",        // pending, processed, failed, completed
    transactionId: "TXN20241125001",
    paidAmount: 27500,
    paidAt: ISODate("2024-11-25T10:00:00Z")
  },
  
  // Status
  status: "approved",                  // submitted, underReview, approved, rejected, paid
  
  // Timestamps
  submittedAt: ISODate("2024-11-21T10:00:00Z"),
  approvedAt: ISODate("2024-11-22T14:00:00Z"),
  updatedAt: ISODate("2024-11-25T10:00:00Z")
}
```

**Indexes:**
```javascript
db.claims.createIndex({ "claimId": 1 }, { unique: true })
db.claims.createIndex({ "farmerId": 1 })
db.claims.createIndex({ "status": 1 })
db.claims.createIndex({ "farmerId": 1, "season": 1, "year": 1 })
db.claims.createIndex({ "submittedAt": -1 })
db.claims.createIndex({ "policyDetails.policyNumber": 1 })
```

---

### 5. Officials Collection

**Collection Name:** `officials`

**Purpose:** Store officer accounts and assignments

```javascript
{
  _id: ObjectId("507f1f77bcf86cd799439015"),
  officerId: "OFF001",                 // Unique officer ID
  userId: "firebase_uid_12345",        // Firebase Auth UID
  
  // Personal Information
  name: {
    first: "Rajesh",
    last: "Kumar"
  },
  phone: "+919876543210",
  email: "rajesh.kumar@pmfby.gov.in",
  
  // Role & Permissions
  role: "district_officer",            // district_officer, state_officer, surveyor, auditor
  level: "district",                   // district, state, national
  
  permissions: [
    "view_claims",
    "approve_claims",
    "verify_images",
    "generate_reports"
  ],
  
  // Assignment
  assignment: {
    state: "Punjab",
    district: "Ludhiana",
    talukas: ["Ludhiana", "Khanna"],   // Optional
    effectiveFrom: ISODate("2024-01-01")
  },
  
  // Performance Metrics
  metrics: {
    totalClaimsReviewed: 245,
    averageProcessingTimeDays: 2.5,
    approvalRate: 0.82,                // 82%
    lastActiveAt: ISODate("2024-11-25T10:00:00Z")
  },
  
  // Metadata
  createdAt: ISODate("2024-01-01T09:00:00Z"),
  updatedAt: ISODate("2024-11-25T10:00:00Z"),
  accountStatus: "active"              // active, suspended, inactive
}
```

**Indexes:**
```javascript
db.officials.createIndex({ "officerId": 1 }, { unique: true })
db.officials.createIndex({ "userId": 1 }, { unique: true })
db.officials.createIndex({ "phone": 1 })
db.officials.createIndex({ "assignment.district": 1 })
db.officials.createIndex({ "role": 1 })
```

---

### 6. AI Inferences Collection

**Collection Name:** `ai_inferences`

**Purpose:** Store ML model inference logs and results

```javascript
{
  _id: ObjectId("507f1f77bcf86cd799439016"),
  inferenceId: "INF20241120143100",    // Unique inference ID
  imageId: "IMG20241120143045F001",    // Reference to image
  
  // Model Information
  modelInfo: {
    modelName: "crop_verifier",
    modelVersion: "v2.1",
    framework: "TensorFlow",
    deploymentEnvironment: "cloud"
  },
  
  // Input
  input: {
    imageUrl: "https://res.cloudinary.com/...",
    imageSize: 524288,
    preprocessingApplied: ["resize", "normalize", "augment"]
  },
  
  // Output
  output: {
    predictions: {
      cropType: "wheat",
      cropHealth: "healthy",
      growthStage: "vegetative",
      diseaseDetected: false,
      pestPresence: false
    },
    
    confidenceScores: {
      "wheat": 0.95,
      "rice": 0.03,
      "corn": 0.02
    },
    
    boundingBoxes: [                   // For object detection
      {
        class: "wheat_plant",
        confidence: 0.95,
        bbox: [100, 100, 300, 400]     // [x, y, width, height]
      }
    ],
    
    isAuthentic: true,
    fraudIndicators: {
      duplicateImage: false,
      stockPhoto: false,
      imageManipulation: false,
      locationMismatch: false
    }
  },
  
  // Performance
  performance: {
    inferenceTimeMs: 1500,
    gpuUtilization: 0.75,
    memoryUsageMB: 512
  },
  
  // Validation
  humanValidation: {
    validated: true,
    validatedBy: "OFF001",
    matchesMLPrediction: true,
    validatedAt: ISODate("2024-11-20T15:00:00Z")
  },
  
  // Timestamps
  requestedAt: ISODate("2024-11-20T14:30:50Z"),
  processedAt: ISODate("2024-11-20T14:31:00Z")
}
```

**Indexes:**
```javascript
db.ai_inferences.createIndex({ "inferenceId": 1 }, { unique: true })
db.ai_inferences.createIndex({ "imageId": 1 })
db.ai_inferences.createIndex({ "processedAt": -1 })
db.ai_inferences.createIndex({ "output.isAuthentic": 1 })
```

---

### 7. Satellite Data Collection

**Collection Name:** `satellite_data`

**Purpose:** Store satellite imagery metadata and analysis

```javascript
{
  _id: ObjectId("507f1f77bcf86cd799439017"),
  satelliteDataId: "SAT20241115001",
  
  // Coverage Area
  coverage: {
    type: "Polygon",
    coordinates: [/* GeoJSON polygon */]
  },
  
  // Satellite Info
  satelliteInfo: {
    source: "Sentinel-2",              // Sentinel-2, Landsat-8, etc.
    resolution: 10,                    // meters per pixel
    captureDate: ISODate("2024-11-15"),
    cloudCoverage: 5.0                 // percentage
  },
  
  // Indices (Vegetation health)
  indices: {
    ndvi: 0.65,                        // Normalized Difference Vegetation Index
    ndmi: 0.45,                        // Normalized Difference Moisture Index
    evi: 0.55                          // Enhanced Vegetation Index
  },
  
  // Analysis
  analysis: {
    cropHealth: "moderate",
    stressLevel: "medium",
    irrigationRecommended: true,
    anomalyDetected: false
  },
  
  // Storage
  imageUrl: "https://storage.googleapis.com/...",
  thumbnailUrl: "https://storage.googleapis.com/...",
  
  processedAt: ISODate("2024-11-15T12:00:00Z")
}
```

**Indexes:**
```javascript
db.satellite_data.createIndex({ "satelliteDataId": 1 }, { unique: true })
db.satellite_data.createIndex({ "coverage": "2dsphere" })
db.satellite_data.createIndex({ "satelliteInfo.captureDate": -1 })
```

---

### 8. Audit Logs Collection

**Collection Name:** `audit_logs`

**Purpose:** Track all system actions for compliance and debugging

```javascript
{
  _id: ObjectId("507f1f77bcf86cd799439018"),
  
  // Who
  actor: {
    type: "farmer",                    // farmer, officer, system, admin
    id: "F2024001234",
    name: "Ram Singh"
  },
  
  // What
  action: "image_uploaded",            // image_uploaded, claim_submitted, claim_approved, etc.
  resource: {
    type: "crop_image",
    id: "IMG20241120143045F001"
  },
  
  // When
  timestamp: ISODate("2024-11-20T14:30:50Z"),
  
  // Where
  ipAddress: "192.168.1.100",
  deviceInfo: "Samsung Galaxy M32, Android 12",
  location: {
    latitude: 30.7046,
    longitude: 75.5671
  },
  
  // Details
  details: {
    oldValue: null,
    newValue: { status: "uploaded" },
    metadata: {
      fileSize: 524288,
      uploadDuration: 5000              // ms
    }
  },
  
  // Result
  result: "success",                   // success, failure, partial
  errorMessage: null
}
```

**Indexes:**
```javascript
db.audit_logs.createIndex({ "timestamp": -1 })
db.audit_logs.createIndex({ "actor.id": 1 })
db.audit_logs.createIndex({ "action": 1 })
db.audit_logs.createIndex({ "resource.type": 1, "resource.id": 1 })
```

---

## 🔗 Relationships Between Collections

### Document References (Foreign Keys)

```
farmers (farmerId)
  ├─→ crop_images (farmerId)
  ├─→ crop_loss_intimations (farmerId)
  ├─→ claims (farmerId)
  └─→ land_parcels (embedded)
      └─→ crop_images (parcelId)

crop_loss_intimations (lossId)
  ├─→ crop_images (imageIds array)
  └─→ claims (lossId)

crop_images (imageId)
  ├─→ ai_inferences (imageId)
  └─→ crop_loss_intimations (imageIds)

officials (officerId)
  ├─→ crop_images (officerVerification.officerId)
  ├─→ crop_loss_intimations (officerAssessment.officerId)
  └─→ claims (approvalWorkflow.officerId)
```

### Embedded vs Referenced

**Embedded Documents (Nested):**
- Land parcels in farmers (one farmer owns multiple parcels)
- Crop history in land parcels (historical data)
- ML verification in crop images (belongs to image)
- Officer verification in crop images (belongs to image)
- Weather condition in crop loss (captured at time of loss)

**Referenced Documents (Separate Collections):**
- Farmer → Crop Images (one-to-many, images grow large)
- Farmer → Claims (one-to-many, claims grow large)
- Loss → Images (many-to-many via array of IDs)
- Officer → Various entities (many-to-many)

---

## 🎯 Query Patterns & Optimization

### Common Queries

**1. Get farmer with all crop images:**
```javascript
// Step 1: Get farmer
db.farmers.findOne({ farmerId: "F2024001234" })

// Step 2: Get images
db.crop_images.find({ 
  farmerId: "F2024001234" 
}).sort({ capturedAt: -1 })
```

**2. Get pending images for officer review:**
```javascript
db.crop_images.find({
  status: "pendingOfficerReview",
  "mlVerification.confidenceScore": { $lt: 0.9 }  // Low confidence
}).sort({ uploadedAt: 1 }).limit(50)
```

**3. Get claims by district:**
```javascript
// Join with farmers to get district
db.claims.aggregate([
  {
    $lookup: {
      from: "farmers",
      localField: "farmerId",
      foreignField: "farmerId",
      as: "farmer"
    }
  },
  {
    $match: { "farmer.address.district": "Ludhiana" }
  }
])
```

**4. Get geospatial query (images near a location):**
```javascript
db.crop_images.find({
  location: {
    $near: {
      $geometry: {
        type: "Point",
        coordinates: [75.5671, 30.7046]  // [longitude, latitude]
      },
      $maxDistance: 5000  // 5km
    }
  }
})
```

**5. Aggregate statistics:**
```javascript
// Claims by status
db.claims.aggregate([
  {
    $group: {
      _id: "$status",
      count: { $sum: 1 },
      totalAmount: { $sum: "$claimDetails.claimAmount" }
    }
  }
])
```

---

## 🔒 Security & Privacy

### Data Encryption
- **At Rest:** MongoDB Atlas encryption enabled
- **In Transit:** TLS/SSL for all connections
- **Field-Level:** Aadhaar numbers hashed using bcrypt
- **Bank Details:** Encrypted before storage

### Access Control
```javascript
// MongoDB Users & Roles
{
  role: "farmerAppRole",
  privileges: [
    { resource: { db: "pmfby_app", collection: "farmers" }, actions: ["find", "update"] },
    { resource: { db: "pmfby_app", collection: "crop_images" }, actions: ["find", "insert"] }
  ]
}

{
  role: "officerAppRole",
  privileges: [
    { resource: { db: "pmfby_app", collection: "" }, actions: ["find"] },
    { resource: { db: "pmfby_app", collection: "crop_images" }, actions: ["update"] },
    { resource: { db: "pmfby_app", collection: "claims" }, actions: ["update"] }
  ]
}
```

### Data Masking
- Aadhaar: Show only last 4 digits
- Bank Account: Show only last 4 digits
- Phone: Mask middle digits

---

## 📈 Scalability Considerations

### Sharding Strategy
```javascript
// Shard key for crop_images (high volume)
sh.shardCollection("pmfby_app.crop_images", { farmerId: 1, capturedAt: 1 })

// Shard key for audit_logs (very high volume)
sh.shardCollection("pmfby_app.audit_logs", { timestamp: 1 })
```

### Archiving Strategy
- Archive old audit logs (>1 year) to cold storage
- Archive completed claims (>2 years) to separate collection
- Keep active season data in hot storage

### Caching
- Cache farmer profiles (rarely change)
- Cache officer assignments
- Cache frequently accessed images

---

## 🧪 Sample Data

### Complete Workflow Example

**1. Farmer registers:**
```javascript
db.farmers.insertOne({ /* farmer document */ })
```

**2. Farmer uploads crop image:**
```javascript
db.crop_images.insertOne({
  imageId: "IMG001",
  farmerId: "F001",
  status: "pendingMLVerification"
})
```

**3. ML model processes:**
```javascript
db.ai_inferences.insertOne({ /* inference results */ })
db.crop_images.updateOne(
  { imageId: "IMG001" },
  { $set: { mlVerification: { /* ML results */ }, status: "mlVerified" } }
)
```

**4. Officer reviews (if flagged):**
```javascript
db.crop_images.updateOne(
  { imageId: "IMG001" },
  { $set: { officerVerification: { /* officer review */ }, status: "approved" } }
)
```

**5. Farmer reports loss:**
```javascript
db.crop_loss_intimations.insertOne({
  lossId: "LOSS001",
  farmerId: "F001",
  imageIds: ["IMG001", "IMG002"],
  status: "reported"
})
```

**6. Officer assesses:**
```javascript
db.crop_loss_intimations.updateOne(
  { lossId: "LOSS001" },
  { $set: { officerAssessment: { /* assessment */ }, status: "assessed" } }
)
```

**7. Claim generated:**
```javascript
db.claims.insertOne({
  claimId: "CLM001",
  farmerId: "F001",
  lossId: "LOSS001",
  status: "submitted"
})
```

**8. Claim approved:**
```javascript
db.claims.updateOne(
  { claimId: "CLM001" },
  { $set: { status: "approved", approvedAt: new Date() } }
)
```

---

## 📊 Performance Benchmarks

| Operation | Target Time | Index Used |
|-----------|-------------|------------|
| Farmer lookup by ID | <10ms | farmerId (unique) |
| Get farmer's images | <50ms | farmerId + capturedAt |
| Pending officer reviews | <100ms | status + uploadedAt |
| Geospatial query (5km) | <200ms | 2dsphere index |
| Aggregate statistics | <500ms | Multiple indexes |
| Full-text search | <100ms | Text index |

---

## 🔄 Migration & Versioning

### Schema Versioning
```javascript
{
  schemaVersion: "2.0",  // Track schema version
  // ... document fields
}
```

### Migration Script Example
```javascript
// Migrate old documents to new schema
db.crop_images.updateMany(
  { schemaVersion: { $exists: false } },
  { $set: { schemaVersion: "2.0", status: "uploaded" } }
)
```

---

## 📚 References

- MongoDB Best Practices: https://docs.mongodb.com/manual/administration/production-notes/
- GeoJSON Specification: https://geojson.org/
- MongoDB Indexes: https://docs.mongodb.com/manual/indexes/
- MongoDB Aggregation: https://docs.mongodb.com/manual/aggregation/

---

**Last Updated:** December 4, 2025
**Schema Version:** 2.0
**Database:** pmfby_app (MongoDB Atlas)
