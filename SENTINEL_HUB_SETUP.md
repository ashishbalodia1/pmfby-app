# Sentinel Hub API Setup Guide

This guide explains how to configure real satellite data from Sentinel Hub for crop monitoring.

## 🛰️ Overview

The PMFBY app now supports real-time satellite data from:
- **Sentinel-2 MSI** (ESA) - NDVI, EVI, True Color, False Color, Moisture Index
- **NASA SMAP** - Soil Moisture Data
- **Cloud Mask** - For image quality assessment

## 🔧 Setup Instructions

### Step 1: Create Sentinel Hub Account

1. Go to [Sentinel Hub](https://www.sentinel-hub.com/)
2. Click "Sign Up" to create a free trial account
3. Verify your email address

### Step 2: Create OAuth Client

1. Log in to [Sentinel Hub Dashboard](https://apps.sentinel-hub.com/dashboard/)
2. Navigate to **User Settings** → **OAuth Clients**
3. Click **Create new OAuth client**
4. Name it: "PMFBY App"
5. Copy the **Client ID** and **Client Secret**

### Step 3: Create Configuration Instance

1. In Dashboard, go to **Configuration Utility**
2. Click **New Configuration**
3. Name it: "PMFBY Satellite"
4. Add the following layers:

#### NDVI Layer
```javascript
//VERSION=3
function setup() {
  return {
    input: [{ bands: ["B04", "B08"] }],
    output: { bands: 1, sampleType: "FLOAT32" }
  };
}
function evaluatePixel(sample) {
  return [(sample.B08 - sample.B04) / (sample.B08 + sample.B04)];
}
```

#### EVI Layer
```javascript
//VERSION=3
function setup() {
  return {
    input: [{ bands: ["B02", "B04", "B08"] }],
    output: { bands: 1, sampleType: "FLOAT32" }
  };
}
function evaluatePixel(sample) {
  let evi = 2.5 * (sample.B08 - sample.B04) / (sample.B08 + 6 * sample.B04 - 7.5 * sample.B02 + 1);
  return [evi];
}
```

#### Moisture Index Layer
```javascript
//VERSION=3
function setup() {
  return {
    input: [{ bands: ["B8A", "B11"] }],
    output: { bands: 1, sampleType: "FLOAT32" }
  };
}
function evaluatePixel(sample) {
  return [(sample.B8A - sample.B11) / (sample.B8A + sample.B11)];
}
```

5. Copy the **Instance ID** from the configuration URL

### Step 4: Configure the App

Edit `lib/src/services/sentinel_hub_service.dart`:

```dart
// Replace these with your actual credentials
static const String _clientId = 'YOUR_CLIENT_ID';
static const String _clientSecret = 'YOUR_CLIENT_SECRET';
static const String _instanceId = 'YOUR_INSTANCE_ID';
```

## 📡 API Endpoints Used

### WMS GetMap Request
```
GET https://services.sentinel-hub.com/ogc/wms/<instance-id>
  ?SERVICE=WMS
  &REQUEST=GetMap
  &LAYERS=NDVI
  &BBOX=<lon1,lat1,lon2,lat2>
  &WIDTH=512
  &HEIGHT=512
  &FORMAT=image/png
  &CRS=EPSG:4326
  &TIME=<start-date>/<end-date>
  &MAXCC=30
```

### Processing API (for Statistics)
```
POST https://services.sentinel-hub.com/api/v1/process
Authorization: Bearer <access_token>
Content-Type: application/json

{
  "input": {
    "bounds": {
      "bbox": [lon1, lat1, lon2, lat2],
      "properties": {"crs": "http://www.opengis.net/def/crs/EPSG/0/4326"}
    },
    "data": [{
      "type": "sentinel-2-l2a",
      "dataFilter": {
        "timeRange": {"from": "2024-01-01", "to": "2024-12-01"},
        "maxCloudCoverage": 30
      }
    }]
  },
  "output": {"width": 256, "height": 256},
  "evalscript": "..."
}
```

### Catalog API (for Scene Search)
```
POST https://services.sentinel-hub.com/api/v1/catalog/search
Authorization: Bearer <access_token>
Content-Type: application/json

{
  "bbox": [lon1, lat1, lon2, lat2],
  "datetime": "2024-01-01/2024-12-01",
  "collections": ["sentinel-2-l2a"],
  "limit": 10,
  "query": {"eo:cloud_cover": {"lt": 30}}
}
```

## 📊 Available Data Layers

| Layer | Source | Resolution | Update Frequency |
|-------|--------|------------|------------------|
| NDVI | Sentinel-2 | 10m | 5 days |
| EVI | Sentinel-2 | 10m | 5 days |
| Moisture Index | Sentinel-2 | 20m | 5 days |
| True Color | Sentinel-2 | 10m | 5 days |
| False Color | Sentinel-2 | 10m | 5 days |
| Cloud Mask | Sentinel-2 | 20m | 5 days |
| Soil Moisture | NASA SMAP | 9km | Daily |

## 🌍 Coverage Area

The app is configured for India:
- **Latitude**: 8°N to 37°N
- **Longitude**: 68°E to 97°E

## 💰 Pricing

Sentinel Hub offers:
- **Free Trial**: 30,000 Processing Units
- **Exploration Plan**: $50/month
- **Basic Plan**: $100/month

For government/research use, contact Sentinel Hub for special pricing.

## 🔒 Demo Mode

When Sentinel Hub credentials are not configured, the app runs in **Demo Mode**:
- Simulates NDVI values based on location and season
- Shows realistic but synthetic data
- Useful for testing and demonstrations

## 🐛 Troubleshooting

### "Auth failed" Error
- Verify Client ID and Secret are correct
- Check if OAuth client is active
- Ensure trial hasn't expired

### "No data" for a region
- Check cloud cover settings (try increasing MAXCC)
- Verify the date range includes recent data
- Ensure bbox coordinates are correct

### Slow loading
- Reduce image resolution (WIDTH/HEIGHT)
- Limit date range
- Use processing units efficiently

## 📚 Resources

- [Sentinel Hub Documentation](https://docs.sentinel-hub.com/)
- [Sentinel-2 User Guide](https://sentinel.esa.int/web/sentinel/user-guides/sentinel-2-msi)
- [NDVI Reference](https://custom-scripts.sentinel-hub.com/sentinel-2/ndvi/)
- [EVI Reference](https://custom-scripts.sentinel-hub.com/sentinel-2/evi/)

## 📞 Support

For Sentinel Hub support:
- Email: info@sentinel-hub.com
- Forum: [forum.sentinel-hub.com](https://forum.sentinel-hub.com/)

For app issues:
- Create an issue on GitHub
- Contact the development team
