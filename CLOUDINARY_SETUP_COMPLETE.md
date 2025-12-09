# Cloudinary Setup Complete ✅

## Configuration

Your Cloudinary credentials have been configured in the app:

### Credentials
- **Cloud Name**: `dxahqsgwv`
- **API Key**: `916295378241238`
- **API Secret**: `X2GoZB5cN3lnPSE4HEuOAby1m80`
- **Upload Preset**: `pmfby_preset` (default)

### Files Updated

1. **`.env`** - Added Cloudinary credentials
2. **`.env.example`** - Updated template with Cloudinary section
3. **`lib/src/services/cloud_image_service.dart`** - Configured with your credentials

## Usage

### Upload Image and Get URL

```dart
final cloudService = CloudImageService();

// Upload an image
final result = await cloudService.uploadImage(
  imageFile,
  farmerId: 'farmer123',
  imageType: 'crop_damage',
  metadata: {
    'crop': 'wheat',
    'location': 'field1',
  },
);

// Get the URL for database storage
final imageUrl = result.url;  // e.g., https://res.cloudinary.com/dxahqsgwv/image/upload/v123/pmfby_crops/farmer123_crop_damage_123.jpg
final thumbnailUrl = result.thumbnailUrl;  // Optimized thumbnail URL

// Store in database
await collection.insertOne({
  'farmerId': 'farmer123',
  'imageUrl': imageUrl,
  'thumbnailUrl': thumbnailUrl,
  'imageMetadata': {
    'width': result.width,
    'height': result.height,
    'format': result.format,
    'bytes': result.bytes,
    'uploadedAt': result.createdAt,
  },
});
```

### Result Object

The `uploadImage()` method returns a `CloudinaryUploadResult` with:

- **`url`**: Full image URL (store this in database)
- **`thumbnailUrl`**: Optimized 300x300 thumbnail
- **`publicId`**: Cloudinary public ID for the image
- **`width`**: Image width in pixels
- **`height`**: Image height in pixels
- **`format`**: Image format (jpg, png, etc.)
- **`bytes`**: File size in bytes
- **`createdAt`**: Upload timestamp

## Features

### 1. Automatic Image Compression
Images are automatically compressed before upload:
- Quality: 85%
- Max dimensions: 1920x1080
- Format: JPEG

### 2. Organized Storage
Images are stored in folders:
- Folder: `pmfby_crops`
- Naming: `{farmerId}_{imageType}_{timestamp}`

### 3. URL Transformations

Get optimized URLs for different use cases:

```dart
// Get optimized URL
final optimizedUrl = cloudService.getOptimizedUrl(
  result.url,
  width: 800,
  height: 600,
  quality: 'auto',
  format: 'auto',
);
```

### 4. Delete Images

```dart
// Delete by public ID
final deleted = await cloudService.deleteImage(result.publicId);
```

## About Upload Preset

The upload preset `pmfby_preset` is currently set as default. Upload presets are optional configurations in Cloudinary that allow you to:

- Set default transformations
- Define upload restrictions
- Configure folder structure
- Set access control

### If You Need to Create an Upload Preset:

1. Go to [Cloudinary Dashboard](https://cloudinary.com/console)
2. Navigate to Settings → Upload
3. Scroll to "Upload presets"
4. Click "Add upload preset"
5. Name it: `pmfby_preset`
6. Set signing mode to "Unsigned" (for easier frontend uploads)
7. Set folder to `pmfby_crops`
8. Save

**Note**: The current implementation works without a custom preset as it specifies the folder directly in the upload request.

## Database Storage

**Store the URL in MongoDB:**

```javascript
{
  farmerId: "farmer123",
  cropImage: {
    url: "https://res.cloudinary.com/dxahqsgwv/image/upload/v123/pmfby_crops/...",
    thumbnail: "https://res.cloudinary.com/dxahqsgwv/image/upload/c_thumb,w_300,h_300,q_auto/v123/...",
    publicId: "pmfby_crops/farmer123_crop_damage_123",
    width: 1920,
    height: 1080,
    uploadedAt: "2025-12-09T10:30:00Z"
  }
}
```

## Benefits

✅ **Permanent URLs**: Images are stored on Cloudinary's CDN  
✅ **Fast Delivery**: Global CDN ensures fast image loading  
✅ **Automatic Optimization**: Images are served in optimal formats  
✅ **Free Tier**: 25 GB storage + 25 GB bandwidth/month  
✅ **Database-Ready**: URLs can be directly stored in MongoDB

## Example Usage in Your App

```dart
// In your claim submission screen
final imageService = CloudImageService();

// Upload crop damage photos
for (var imageFile in cropDamagePhotos) {
  final result = await imageService.uploadImage(
    imageFile,
    farmerId: currentUser.id,
    imageType: 'crop_damage',
    metadata: {
      'claimId': claimId,
      'cropType': selectedCrop,
      'damageType': damageType,
      'location': currentLocation,
    },
  );
  
  // Store URL in database
  imageUrls.add(result.url);
}

// Save to MongoDB
await claimsCollection.insertOne({
  'farmerId': currentUser.id,
  'claimId': claimId,
  'damageImages': imageUrls,
  'createdAt': DateTime.now(),
});
```

## Testing

Test the upload functionality:

```dart
// Test upload
final testImage = File('/path/to/test/image.jpg');
final result = await cloudService.uploadImage(
  testImage,
  farmerId: 'test_farmer',
  imageType: 'test',
);

print('Upload successful!');
print('URL: ${result.url}');
print('Size: ${result.bytes} bytes');
print('Dimensions: ${result.width}x${result.height}');
```

## Environment Variables (Optional)

If you want to override credentials via environment variables during build:

```bash
flutter run --dart-define=CLOUDINARY_CLOUD_NAME=dxahqsgwv \
           --dart-define=CLOUDINARY_API_KEY=916295378241238 \
           --dart-define=CLOUDINARY_API_SECRET=X2GoZB5cN3lnPSE4HEuOAby1m80
```

## Summary

✅ Cloudinary is configured and ready to use  
✅ Credentials are set with proper fallbacks  
✅ `uploadImage()` returns URLs for database storage  
✅ Images are automatically compressed and optimized  
✅ URLs are permanent and CDN-backed  
✅ Ready for production use
