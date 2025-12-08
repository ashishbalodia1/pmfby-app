-- PostgreSQL Views for PMFBY Geographical Hierarchy
-- Convenient views for querying hierarchical data

-- ============================================
-- VIEW: complete_hierarchy
-- Shows the full geographical hierarchy for each village
-- ============================================
CREATE OR REPLACE VIEW complete_hierarchy AS
SELECT 
    v.id as village_id,
    v.village_name,
    v.village_code,
    v.latitude,
    v.longitude,
    v.pincode,
    gp.id as panchayat_id,
    gp.panchayat_name,
    gp.panchayat_code,
    sd.id as subdistrict_id,
    sd.subdistrict_name,
    sd.subdistrict_code,
    sd.subdistrict_type,
    d.id as district_id,
    d.district_name,
    d.district_code,
    s.id as state_id,
    s.state_name,
    s.state_code,
    v.is_active as village_active,
    gp.is_active as panchayat_active,
    sd.is_active as subdistrict_active,
    d.is_active as district_active,
    s.is_active as state_active
FROM villages v
LEFT JOIN gram_panchayats gp ON v.panchayat_id = gp.id
JOIN subdistricts sd ON v.subdistrict_id = sd.id
JOIN districts d ON v.district_id = d.id
JOIN states s ON v.state_id = s.id;

-- ============================================
-- VIEW: active_locations
-- Shows only active locations in the hierarchy
-- ============================================
CREATE OR REPLACE VIEW active_locations AS
SELECT *
FROM complete_hierarchy
WHERE 
    state_active = true AND
    district_active = true AND
    subdistrict_active = true AND
    panchayat_active = true AND
    village_active = true;

-- ============================================
-- VIEW: state_summary
-- Summary statistics for each state
-- ============================================
CREATE OR REPLACE VIEW state_summary AS
SELECT 
    s.id,
    s.state_name,
    s.state_code,
    COUNT(DISTINCT d.id) as total_districts,
    COUNT(DISTINCT sd.id) as total_subdistricts,
    COUNT(DISTINCT gp.id) as total_panchayats,
    COUNT(DISTINCT v.id) as total_villages,
    COUNT(DISTINCT CASE WHEN d.is_active THEN d.id END) as active_districts,
    COUNT(DISTINCT CASE WHEN sd.is_active THEN sd.id END) as active_subdistricts,
    COUNT(DISTINCT CASE WHEN gp.is_active THEN gp.id END) as active_panchayats,
    COUNT(DISTINCT CASE WHEN v.is_active THEN v.id END) as active_villages
FROM states s
LEFT JOIN districts d ON s.id = d.state_id
LEFT JOIN subdistricts sd ON s.id = sd.state_id
LEFT JOIN gram_panchayats gp ON s.id = gp.state_id
LEFT JOIN villages v ON s.id = v.state_id
WHERE s.is_active = true
GROUP BY s.id, s.state_name, s.state_code;

-- ============================================
-- VIEW: district_summary
-- Summary statistics for each district
-- ============================================
CREATE OR REPLACE VIEW district_summary AS
SELECT 
    d.id,
    d.district_name,
    d.district_code,
    s.state_name,
    s.state_code,
    COUNT(DISTINCT sd.id) as total_subdistricts,
    COUNT(DISTINCT gp.id) as total_panchayats,
    COUNT(DISTINCT v.id) as total_villages,
    COUNT(DISTINCT CASE WHEN sd.is_active THEN sd.id END) as active_subdistricts,
    COUNT(DISTINCT CASE WHEN gp.is_active THEN gp.id END) as active_panchayats,
    COUNT(DISTINCT CASE WHEN v.is_active THEN v.id END) as active_villages
FROM districts d
JOIN states s ON d.state_id = s.id
LEFT JOIN subdistricts sd ON d.id = sd.district_id
LEFT JOIN gram_panchayats gp ON d.id = gp.district_id
LEFT JOIN villages v ON d.id = v.district_id
WHERE d.is_active = true
GROUP BY d.id, d.district_name, d.district_code, s.state_name, s.state_code;

-- ============================================
-- VIEW: subdistrict_summary
-- Summary statistics for each subdistrict
-- ============================================
CREATE OR REPLACE VIEW subdistrict_summary AS
SELECT 
    sd.id,
    sd.subdistrict_name,
    sd.subdistrict_code,
    sd.subdistrict_type,
    d.district_name,
    s.state_name,
    COUNT(DISTINCT gp.id) as total_panchayats,
    COUNT(DISTINCT v.id) as total_villages,
    COUNT(DISTINCT CASE WHEN gp.is_active THEN gp.id END) as active_panchayats,
    COUNT(DISTINCT CASE WHEN v.is_active THEN v.id END) as active_villages
FROM subdistricts sd
JOIN districts d ON sd.district_id = d.id
JOIN states s ON sd.state_id = s.id
LEFT JOIN gram_panchayats gp ON sd.id = gp.subdistrict_id
LEFT JOIN villages v ON sd.id = v.subdistrict_id
WHERE sd.is_active = true
GROUP BY sd.id, sd.subdistrict_name, sd.subdistrict_code, sd.subdistrict_type, d.district_name, s.state_name;

-- ============================================
-- VIEW: panchayat_summary
-- Summary statistics for each gram panchayat
-- ============================================
CREATE OR REPLACE VIEW panchayat_summary AS
SELECT 
    gp.id,
    gp.panchayat_name,
    gp.panchayat_code,
    sd.subdistrict_name,
    d.district_name,
    s.state_name,
    COUNT(v.id) as total_villages,
    COUNT(CASE WHEN v.is_active THEN v.id END) as active_villages
FROM gram_panchayats gp
JOIN subdistricts sd ON gp.subdistrict_id = sd.id
JOIN districts d ON gp.district_id = d.id
JOIN states s ON gp.state_id = s.id
LEFT JOIN villages v ON gp.id = v.panchayat_id
WHERE gp.is_active = true
GROUP BY gp.id, gp.panchayat_name, gp.panchayat_code, sd.subdistrict_name, d.district_name, s.state_name;

COMMENT ON VIEW complete_hierarchy IS 'Complete geographical hierarchy showing all levels from village to state';
COMMENT ON VIEW active_locations IS 'Only active locations across all hierarchy levels';
COMMENT ON VIEW state_summary IS 'Statistical summary for each state';
COMMENT ON VIEW district_summary IS 'Statistical summary for each district';
COMMENT ON VIEW subdistrict_summary IS 'Statistical summary for each subdistrict';
COMMENT ON VIEW panchayat_summary IS 'Statistical summary for each gram panchayat';
