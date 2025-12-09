-- Common PostgreSQL Queries for PMFBY Geographical Data
-- Ready-to-use queries for common operations

-- ============================================
-- 1. Get all states with district count
-- ============================================
SELECT 
    s.state_name,
    s.state_code,
    COUNT(DISTINCT d.id) as total_districts,
    COUNT(DISTINCT CASE WHEN d.is_active THEN d.id END) as active_districts
FROM states s
LEFT JOIN districts d ON s.id = d.state_id
WHERE s.is_active = true
GROUP BY s.id, s.state_name, s.state_code
ORDER BY s.state_name;

-- ============================================
-- 2. Get all districts for a specific state
-- ============================================
SELECT 
    d.id,
    d.district_name,
    d.district_code,
    d.lgd_code
FROM districts d
JOIN states s ON d.state_id = s.id
WHERE s.state_code = 'MH' -- Change state code as needed
  AND d.is_active = true
ORDER BY d.district_name;

-- ============================================
-- 3. Get all subdistricts for a specific district
-- ============================================
SELECT 
    sd.id,
    sd.subdistrict_name,
    sd.subdistrict_code,
    sd.subdistrict_type,
    sd.lgd_code
FROM subdistricts sd
JOIN districts d ON sd.district_id = d.id
WHERE d.district_code = 'MH-PU' -- Change district code as needed
  AND sd.is_active = true
ORDER BY sd.subdistrict_name;

-- ============================================
-- 4. Get all gram panchayats for a subdistrict
-- ============================================
SELECT 
    gp.id,
    gp.panchayat_name,
    gp.panchayat_code,
    gp.lgd_code
FROM gram_panchayats gp
JOIN subdistricts sd ON gp.subdistrict_id = sd.id
WHERE sd.subdistrict_code = 'MH-PU-HAV' -- Change subdistrict code as needed
  AND gp.is_active = true
ORDER BY gp.panchayat_name;

-- ============================================
-- 5. Get all villages for a gram panchayat
-- ============================================
SELECT 
    v.id,
    v.village_name,
    v.village_code,
    v.pincode,
    v.latitude,
    v.longitude,
    v.lgd_code
FROM villages v
JOIN gram_panchayats gp ON v.panchayat_id = gp.id
WHERE gp.panchayat_code = 'MH-PU-HAV-GP001' -- Change panchayat code as needed
  AND v.is_active = true
ORDER BY v.village_name;

-- ============================================
-- 6. Get complete hierarchy for a specific village
-- ============================================
SELECT 
    s.state_name,
    s.state_code,
    d.district_name,
    d.district_code,
    sd.subdistrict_name,
    sd.subdistrict_code,
    sd.subdistrict_type,
    gp.panchayat_name,
    gp.panchayat_code,
    v.village_name,
    v.village_code,
    v.pincode,
    v.latitude,
    v.longitude
FROM villages v
LEFT JOIN gram_panchayats gp ON v.panchayat_id = gp.id
JOIN subdistricts sd ON v.subdistrict_id = sd.id
JOIN districts d ON v.district_id = d.id
JOIN states s ON v.state_id = s.id
WHERE v.village_code = 'MH-PU-HAV-GP001-V001'; -- Change village code as needed

-- ============================================
-- 7. Search villages by name (case-insensitive)
-- ============================================
SELECT 
    v.village_name,
    v.village_code,
    gp.panchayat_name,
    sd.subdistrict_name,
    d.district_name,
    s.state_name,
    v.pincode
FROM villages v
LEFT JOIN gram_panchayats gp ON v.panchayat_id = gp.id
JOIN subdistricts sd ON v.subdistrict_id = sd.id
JOIN districts d ON v.district_id = d.id
JOIN states s ON v.state_id = s.id
WHERE LOWER(v.village_name) LIKE LOWER('%mali%') -- Change search term
  AND v.is_active = true
ORDER BY v.village_name
LIMIT 50;

-- ============================================
-- 8. Get villages within a radius (requires PostGIS)
-- Note: Install PostGIS extension for this query
-- ============================================
-- CREATE EXTENSION IF NOT EXISTS postgis;
-- 
-- SELECT 
--     v.village_name,
--     v.latitude,
--     v.longitude,
--     ST_Distance(
--         ST_MakePoint(v.longitude, v.latitude)::geography,
--         ST_MakePoint(73.8567, 18.5204)::geography -- Center point (Pune)
--     ) / 1000 as distance_km
-- FROM villages v
-- WHERE ST_DWithin(
--     ST_MakePoint(v.longitude, v.latitude)::geography,
--     ST_MakePoint(73.8567, 18.5204)::geography,
--     50000 -- 50km radius
-- )
-- ORDER BY distance_km
-- LIMIT 20;

-- ============================================
-- 9. Get villages by pincode
-- ============================================
SELECT 
    v.village_name,
    v.village_code,
    gp.panchayat_name,
    sd.subdistrict_name,
    d.district_name,
    s.state_name,
    v.latitude,
    v.longitude
FROM villages v
LEFT JOIN gram_panchayats gp ON v.panchayat_id = gp.id
JOIN subdistricts sd ON v.subdistrict_id = sd.id
JOIN districts d ON v.district_id = d.id
JOIN states s ON v.state_id = s.id
WHERE v.pincode = '411046' -- Change pincode as needed
  AND v.is_active = true;

-- ============================================
-- 10. Count statistics for entire hierarchy
-- ============================================
SELECT 
    'States' as level,
    COUNT(*) as total_count,
    COUNT(CASE WHEN is_active THEN 1 END) as active_count
FROM states
UNION ALL
SELECT 
    'Districts' as level,
    COUNT(*) as total_count,
    COUNT(CASE WHEN is_active THEN 1 END) as active_count
FROM districts
UNION ALL
SELECT 
    'Subdistricts' as level,
    COUNT(*) as total_count,
    COUNT(CASE WHEN is_active THEN 1 END) as active_count
FROM subdistricts
UNION ALL
SELECT 
    'Gram Panchayats' as level,
    COUNT(*) as total_count,
    COUNT(CASE WHEN is_active THEN 1 END) as active_count
FROM gram_panchayats
UNION ALL
SELECT 
    'Villages' as level,
    COUNT(*) as total_count,
    COUNT(CASE WHEN is_active THEN 1 END) as active_count
FROM villages;

-- ============================================
-- 11. Get dropdown data for cascading dropdowns
-- ============================================

-- Step 1: Get States
SELECT id, state_name, state_code FROM states WHERE is_active = true ORDER BY state_name;

-- Step 2: Get Districts for selected state
SELECT id, district_name, district_code FROM districts WHERE state_id = $1 AND is_active = true ORDER BY district_name;

-- Step 3: Get Subdistricts for selected district
SELECT id, subdistrict_name, subdistrict_code, subdistrict_type FROM subdistricts WHERE district_id = $1 AND is_active = true ORDER BY subdistrict_name;

-- Step 4: Get Gram Panchayats for selected subdistrict
SELECT id, panchayat_name, panchayat_code FROM gram_panchayats WHERE subdistrict_id = $1 AND is_active = true ORDER BY panchayat_name;

-- Step 5: Get Villages for selected gram panchayat
SELECT id, village_name, village_code, pincode FROM villages WHERE panchayat_id = $1 AND is_active = true ORDER BY village_name;

-- ============================================
-- 12. Bulk update - Deactivate old records
-- ============================================
-- Example: Deactivate all villages in a specific panchayat
-- UPDATE villages SET is_active = false WHERE panchayat_id = 1;

-- Example: Reactivate a village
-- UPDATE villages SET is_active = true WHERE village_code = 'MH-PU-HAV-GP001-V001';
