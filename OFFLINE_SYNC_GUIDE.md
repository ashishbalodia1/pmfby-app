# Offline Storage & Sync System Guide

## 📦 **How Images are Stored Locally**

### **Storage Architecture**

```
📱 Device Storage
├── Application Documents Directory
│   └── /captures/                    # AR Camera captures
│       ├── capture_full_plant_1234567890.jpg
│       ├── capture_leaf_photo_1234567891.jpg
│       └── capture_field_view_1234567892.jpg
│   └── /crop_images/                 # Regular captures
│       ├── upload_abc123.jpg
│       └── upload_def456.jpg
└── SharedPreferences (SQLite)
    └── pending_uploads                # Upload queue metadata
        ├── id, imagePath, cropType
        ├── capturedAt, status, retryCount
        └── latitude, longitude, description
```

---

## 🗂️ **Storage Locations**

### **1. Image Files**
**Location**: `/data/user/0/com.example.myapp/app_flutter/`
- **AR Camera**: `captures/` folder
- **Regular Capture**: `crop_images/` folder

**Path Example**:
```
/data/data/com.example.myapp/app_flutter/captures/capture_full_plant_1733742725123.jpg
```

### **2. Metadata**
**Location**: `SharedPreferences` (persisted SQLite database)
- Stores upload queue information
- Survives app restarts
- Lightweight JSON format

---

## 🔄 **Offline Workflow**

### **When User is Offline:**

```
User Takes Photo
      ↓
Save to Local Storage (/captures/)
      ↓
Create PendingUpload Entry
      ↓
Save Metadata to SharedPreferences
      ↓
Show "Saved Locally" Message
      ↓
Continue Working Offline ✅
```

### **When User Comes Online:**

```
Connectivity Detected
      ↓
Auto Sync Service Starts
      ↓
Get Pending Uploads from Storage
      ↓
For Each Upload:
  ├─ Compress Image (quality: 85%)
  ├─ Upload to Cloudinary
  ├─ Update Status → "synced"
  └─ Optional: Delete local copy
      ↓
Update Last Sync Time
      ↓
Show Notification: "X photos synced"
```

---

## 📊 **Upload States**

### **Status Flow:**

```
pending → uploading → synced
   ↓
 failed (retry count++)
   ↓
 retry (max 3 attempts)
   ↓
 permanently failed
```

| Status | Description | Color | Action |
|--------|-------------|-------|--------|
| **pending** | Waiting for upload | 🟡 Orange | Will sync when online |
| **uploading** | Currently uploading | 🔵 Blue | In progress |
| **synced** | Successfully uploaded | 🟢 Green | Can be deleted |
| **failed** | Upload error | 🔴 Red | Will retry (max 3x) |

---

## ⚙️ **Auto Sync Configuration**

### **Foreground Sync (App Open)**
```dart
// Runs every 30 seconds when:
✅ App is in foreground
✅ Device is online
✅ Has pending uploads
```

### **Background Sync (App Closed)**
```dart
// Runs every 15 minutes when:
✅ Device is online (WiFi/Mobile)
✅ Has pending uploads
✅ Battery not low
```

---

## 🌐 **Cloudinary Integration**

### **Upload Process:**

1. **Compression**
   ```
   Original: 3-5 MB
   Compressed: 200-500 KB (85% quality)
   Format: JPEG optimized
   ```

2. **Upload to Cloudinary**
   ```
   URL: https://api.cloudinary.com/v1_1/{cloud_name}/image/upload
   Folder: pmfby_crops/
   Public ID: farmerId_imageType_timestamp
   ```

3. **Metadata Attached**
   ```json
   {
     "description": "Crop damage assessment",
     "latitude": "28.6139",
     "longitude": "77.2090",
     "capturedAt": "2025-12-09T10:30:45.123Z",
     "uploadId": "capture_full_plant_1234567890"
   }
   ```

4. **Result**
   ```
   URL: https://res.cloudinary.com/.../pmfby_crops/farmer123_wheat_1733742725.jpg
   Thumbnail: https://res.cloudinary.com/.../c_thumb,w_200/.../farmer123_wheat_1733742725.jpg
   ```

---

## 💾 **Storage Management**

### **Get Storage Statistics:**

```dart
final stats = await LocalStorageService().getStorageStats();

// Returns:
{
  'totalUploads': 25,
  'pendingUploads': 8,
  'failedUploads': 2,
  'syncedUploads': 15,
  'totalSizeMB': '45.23'
}
```

### **Clean Up Synced Images:**

```dart
// Remove synced uploads from queue
await LocalStorageService().clearSyncedUploads();

// Delete local image files (optional)
for (var upload in syncedUploads) {
  await LocalStorageService().deleteLocalImage(upload.imagePath);
}
```

---

## 🔧 **Code Implementation**

### **1. Save Image Locally (AR Camera)**

```dart
// In ar_camera_screen.dart
final directory = await getApplicationDocumentsDirectory();
final capturesDir = Directory(path.join(directory.path, 'captures'));
await capturesDir.create(recursive: true);

final timestamp = DateTime.now().millisecondsSinceEpoch;
final imagePath = path.join(capturesDir.path, 'capture_${taskId}_$timestamp.jpg');

final XFile image = await _controller!.takePicture();
await File(image.path).copy(imagePath);
```

### **2. Save Upload Metadata**

```dart
final upload = PendingUpload(
  id: 'capture_${taskId}_$timestamp',
  imagePath: imagePath,
  cropType: taskId,
  description: 'Multi-angle crop capture',
  latitude: _currentPosition?.latitude,
  longitude: _currentPosition?.longitude,
  capturedAt: DateTime.now(),
  status: SyncStatus.pending,
);

await LocalStorageService().savePendingUpload(upload);
```

### **3. Start Auto Sync**

```dart
// In main.dart or dashboard
final autoSyncService = AutoSyncService();
await autoSyncService.initializeNotifications();
await autoSyncService.initializeBackgroundSync();

// Start foreground sync
autoSyncService.startPeriodicSync(connectivityService);
```

### **4. Manual Sync Trigger**

```dart
// Trigger immediate sync
await AutoSyncService().syncPendingUploads();
```

---

## 📱 **User Interface Indicators**

### **Pending Upload Badge:**

```dart
// In dashboard
FutureBuilder<int>(
  future: LocalStorageService().getPendingUploadsCount(),
  builder: (context, snapshot) {
    final count = snapshot.data ?? 0;
    return Badge(
      count: count,
      child: Icon(Icons.cloud_upload),
    );
  },
)
```

### **Sync Status Screen:**

Navigate to: `Upload Status Screen` to see:
- ✅ Synced uploads
- ⏳ Pending uploads  
- 🔄 Currently uploading
- ❌ Failed uploads (with retry button)

---

## 🔍 **Debugging**

### **Check Local Storage:**

```dart
// Get all pending uploads
final uploads = await LocalStorageService().getPendingUploads();
for (var upload in uploads) {
  print('ID: ${upload.id}');
  print('Path: ${upload.imagePath}');
  print('Status: ${upload.status}');
  print('Retry Count: ${upload.retryCount}');
}
```

### **Check Image Files:**

```dart
final directory = await getApplicationDocumentsDirectory();
final capturesDir = Directory('${directory.path}/captures');
final files = await capturesDir.list().toList();
print('Total images: ${files.length}');
```

### **Manual Upload Test:**

```dart
final cloudService = CloudImageService();
final result = await cloudService.uploadImage(
  File('/path/to/image.jpg'),
  farmerId: 'test_farmer',
  imageType: 'wheat_damage',
);
print('Uploaded: ${result.url}');
```

---

## ⚠️ **Important Notes**

### **1. Cloudinary Setup Required**

Set environment variables in `cloud_image_service.dart`:
```dart
static const String cloudName = 'your-cloud-name';
static const String uploadPreset = 'pmfby_preset';
```

Or use `.env` file:
```
CLOUDINARY_CLOUD_NAME=your-cloud-name
CLOUDINARY_UPLOAD_PRESET=pmfby_preset
```

### **2. Storage Limits**

- **App Storage**: Limited by device (typically 100MB+)
- **Cloudinary Free Tier**: 25 GB storage, 25 GB bandwidth/month
- **Recommendation**: Delete local images after successful upload

### **3. Network Optimization**

- Images compressed before upload (85% quality)
- Upload only on WiFi? (optional configuration)
- Batch uploads to reduce requests
- Retry failed uploads with exponential backoff

---

## 🎯 **Best Practices**

### **For Offline Support:**
1. ✅ Always save images locally first
2. ✅ Queue uploads for later
3. ✅ Show clear offline/online status
4. ✅ Retry failed uploads automatically
5. ✅ Allow manual sync trigger

### **For Storage Management:**
1. ✅ Clean up synced images periodically
2. ✅ Show storage usage to users
3. ✅ Warn when storage is full
4. ✅ Compress images before storage
5. ✅ Provide manual cleanup option

### **For User Experience:**
1. ✅ Show sync progress notifications
2. ✅ Display pending upload count
3. ✅ Allow users to view upload queue
4. ✅ Provide manual sync button
5. ✅ Show sync status in UI

---

## 🚀 **Testing Checklist**

- [ ] Take photo offline → Check saved locally
- [ ] Go online → Verify auto sync starts
- [ ] Check Cloudinary dashboard for uploads
- [ ] Test app restart with pending uploads
- [ ] Test network interruption during upload
- [ ] Test failed upload retry mechanism
- [ ] Test storage cleanup
- [ ] Test background sync (15 min intervals)
- [ ] Test batch upload (multiple images)
- [ ] Test storage limit warnings

---

## 📞 **Troubleshooting**

### **Images not uploading?**
1. Check internet connectivity
2. Verify Cloudinary credentials
3. Check pending uploads queue
4. Look for error messages in logs
5. Try manual sync

### **Storage filling up?**
1. Clear synced uploads
2. Delete local images after sync
3. Reduce image quality in settings
4. Implement auto-cleanup policy

### **Sync not working?**
1. Check permissions (storage, network)
2. Verify WorkManager configuration
3. Test foreground sync first
4. Check background restrictions on device

---

This system ensures **100% offline capability** while automatically syncing when online! 🎉
