-- Sample Data for Testing PostgreSQL Geographical Hierarchy
-- This file contains representative sample data from various Indian states

-- ============================================
-- SAMPLE STATES
-- ============================================
INSERT INTO states (state_code, state_name, state_name_hi, lgd_code, metadata) VALUES
('MH', 'Maharashtra', 'महाराष्ट्र', 'LGD27', '{"area_sqkm": 307713, "capital": "Mumbai"}'),
('UP', 'Uttar Pradesh', 'उत्तर प्रदेश', 'LGD09', '{"area_sqkm": 240928, "capital": "Lucknow"}'),
('RJ', 'Rajasthan', 'राजस्थान', 'LGD08', '{"area_sqkm": 342239, "capital": "Jaipur"}'),
('PB', 'Punjab', 'पंजाब', 'LGD03', '{"area_sqkm": 50362, "capital": "Chandigarh"}'),
('HR', 'Haryana', 'हरियाणा', 'LGD06', '{"area_sqkm": 44212, "capital": "Chandigarh"}')
ON CONFLICT (state_code) DO NOTHING;

-- ============================================
-- SAMPLE DISTRICTS (Maharashtra)
-- ============================================
INSERT INTO districts (state_id, district_code, district_name, district_name_hi, lgd_code) VALUES
((SELECT id FROM states WHERE state_code = 'MH'), 'MH-PU', 'Pune', 'पुणे', 'LGD27019'),
((SELECT id FROM states WHERE state_code = 'MH'), 'MH-MU', 'Mumbai', 'मुंबई', 'LGD27001'),
((SELECT id FROM states WHERE state_code = 'MH'), 'MH-NG', 'Nagpur', 'नागपुर', 'LGD27028')
ON CONFLICT (district_code) DO NOTHING;

-- ============================================
-- SAMPLE DISTRICTS (Uttar Pradesh)
-- ============================================
INSERT INTO districts (state_id, district_code, district_name, district_name_hi, lgd_code) VALUES
((SELECT id FROM states WHERE state_code = 'UP'), 'UP-LU', 'Lucknow', 'लखनऊ', 'LGD09033'),
((SELECT id FROM states WHERE state_code = 'UP'), 'UP-AG', 'Agra', 'आगरा', 'LGD09001'),
((SELECT id FROM states WHERE state_code = 'UP'), 'UP-KN', 'Kanpur', 'कानपुर', 'LGD09030')
ON CONFLICT (district_code) DO NOTHING;

-- ============================================
-- SAMPLE DISTRICTS (Punjab)
-- ============================================
INSERT INTO districts (state_id, district_code, district_name, district_name_hi, lgd_code) VALUES
((SELECT id FROM states WHERE state_code = 'PB'), 'PB-LD', 'Ludhiana', 'लुधियाना', 'LGD03011'),
((SELECT id FROM states WHERE state_code = 'PB'), 'PB-AM', 'Amritsar', 'अमृतसर', 'LGD03001'),
((SELECT id FROM states WHERE state_code = 'PB'), 'PB-JL', 'Jalandhar', 'जालंधर', 'LGD03009')
ON CONFLICT (district_code) DO NOTHING;

-- ============================================
-- SAMPLE SUBDISTRICTS (Maharashtra - Pune)
-- ============================================
INSERT INTO subdistricts (district_id, state_id, subdistrict_code, subdistrict_name, subdistrict_name_hi, subdistrict_type, lgd_code) VALUES
((SELECT id FROM districts WHERE district_code = 'MH-PU'), (SELECT id FROM states WHERE state_code = 'MH'), 
 'MH-PU-HAV', 'Haveli', 'हवेली', 'taluka', 'LGD27019001'),
((SELECT id FROM districts WHERE district_code = 'MH-PU'), (SELECT id FROM states WHERE state_code = 'MH'), 
 'MH-PU-SHI', 'Shirur', 'शिरूर', 'taluka', 'LGD27019002'),
((SELECT id FROM districts WHERE district_code = 'MH-PU'), (SELECT id FROM states WHERE state_code = 'MH'), 
 'MH-PU-BAR', 'Baramati', 'बारामती', 'taluka', 'LGD27019003')
ON CONFLICT (subdistrict_code) DO NOTHING;

-- ============================================
-- SAMPLE SUBDISTRICTS (Uttar Pradesh - Lucknow)
-- ============================================
INSERT INTO subdistricts (district_id, state_id, subdistrict_code, subdistrict_name, subdistrict_name_hi, subdistrict_type, lgd_code) VALUES
((SELECT id FROM districts WHERE district_code = 'UP-LU'), (SELECT id FROM states WHERE state_code = 'UP'), 
 'UP-LU-SAR', 'Sarojini Nagar', 'सरोजिनी नगर', 'tehsil', 'LGD09033001'),
((SELECT id FROM districts WHERE district_code = 'UP-LU'), (SELECT id FROM states WHERE state_code = 'UP'), 
 'UP-LU-MAL', 'Malihabad', 'मलीहाबाद', 'tehsil', 'LGD09033002'),
((SELECT id FROM districts WHERE district_code = 'UP-LU'), (SELECT id FROM states WHERE state_code = 'UP'), 
 'UP-LU-MOH', 'Mohanlalganj', 'मोहनलालगंज', 'tehsil', 'LGD09033003')
ON CONFLICT (subdistrict_code) DO NOTHING;

-- ============================================
-- SAMPLE SUBDISTRICTS (Punjab - Ludhiana)
-- ============================================
INSERT INTO subdistricts (district_id, state_id, subdistrict_code, subdistrict_name, subdistrict_name_hi, subdistrict_type, lgd_code) VALUES
((SELECT id FROM districts WHERE district_code = 'PB-LD'), (SELECT id FROM states WHERE state_code = 'PB'), 
 'PB-LD-LUD', 'Ludhiana', 'लुधियाना', 'tehsil', 'LGD03011001'),
((SELECT id FROM districts WHERE district_code = 'PB-LD'), (SELECT id FROM states WHERE state_code = 'PB'), 
 'PB-LD-JAG', 'Jagraon', 'जगराओं', 'tehsil', 'LGD03011002'),
((SELECT id FROM districts WHERE district_code = 'PB-LD'), (SELECT id FROM states WHERE state_code = 'PB'), 
 'PB-LD-PAY', 'Payal', 'पयाल', 'tehsil', 'LGD03011003')
ON CONFLICT (subdistrict_code) DO NOTHING;

-- ============================================
-- SAMPLE GRAM PANCHAYATS (Maharashtra - Haveli)
-- ============================================
INSERT INTO gram_panchayats (subdistrict_id, district_id, state_id, panchayat_code, panchayat_name, panchayat_name_hi, lgd_code) VALUES
((SELECT id FROM subdistricts WHERE subdistrict_code = 'MH-PU-HAV'), 
 (SELECT id FROM districts WHERE district_code = 'MH-PU'),
 (SELECT id FROM states WHERE state_code = 'MH'),
 'MH-PU-HAV-GP001', 'Katraj', 'कातरज', 'LGD27019001001'),
((SELECT id FROM subdistricts WHERE subdistrict_code = 'MH-PU-HAV'), 
 (SELECT id FROM districts WHERE district_code = 'MH-PU'),
 (SELECT id FROM states WHERE state_code = 'MH'),
 'MH-PU-HAV-GP002', 'Dhayari', 'धयारी', 'LGD27019001002'),
((SELECT id FROM subdistricts WHERE subdistrict_code = 'MH-PU-HAV'), 
 (SELECT id FROM districts WHERE district_code = 'MH-PU'),
 (SELECT id FROM states WHERE state_code = 'MH'),
 'MH-PU-HAV-GP003', 'Undri', 'उंद्री', 'LGD27019001003')
ON CONFLICT (panchayat_code) DO NOTHING;

-- ============================================
-- SAMPLE GRAM PANCHAYATS (Uttar Pradesh - Malihabad)
-- ============================================
INSERT INTO gram_panchayats (subdistrict_id, district_id, state_id, panchayat_code, panchayat_name, panchayat_name_hi, lgd_code) VALUES
((SELECT id FROM subdistricts WHERE subdistrict_code = 'UP-LU-MAL'), 
 (SELECT id FROM districts WHERE district_code = 'UP-LU'),
 (SELECT id FROM states WHERE state_code = 'UP'),
 'UP-LU-MAL-GP001', 'Malihabad', 'मलीहाबाद', 'LGD09033002001'),
((SELECT id FROM subdistricts WHERE subdistrict_code = 'UP-LU-MAL'), 
 (SELECT id FROM districts WHERE district_code = 'UP-LU'),
 (SELECT id FROM states WHERE state_code = 'UP'),
 'UP-LU-MAL-GP002', 'Kakori', 'काकोरी', 'LGD09033002002'),
((SELECT id FROM subdistricts WHERE subdistrict_code = 'UP-LU-MAL'), 
 (SELECT id FROM districts WHERE district_code = 'UP-LU'),
 (SELECT id FROM states WHERE state_code = 'UP'),
 'UP-LU-MAL-GP003', 'Nagram', 'नग्राम', 'LGD09033002003')
ON CONFLICT (panchayat_code) DO NOTHING;

-- ============================================
-- SAMPLE GRAM PANCHAYATS (Punjab - Ludhiana)
-- ============================================
INSERT INTO gram_panchayats (subdistrict_id, district_id, state_id, panchayat_code, panchayat_name, panchayat_name_hi, lgd_code) VALUES
((SELECT id FROM subdistricts WHERE subdistrict_code = 'PB-LD-LUD'), 
 (SELECT id FROM districts WHERE district_code = 'PB-LD'),
 (SELECT id FROM states WHERE state_code = 'PB'),
 'PB-LD-LUD-GP001', 'Mullanpur', 'मुल्लानपुर', 'LGD03011001001'),
((SELECT id FROM subdistricts WHERE subdistrict_code = 'PB-LD-LUD'), 
 (SELECT id FROM districts WHERE district_code = 'PB-LD'),
 (SELECT id FROM states WHERE state_code = 'PB'),
 'PB-LD-LUD-GP002', 'Dehlon', 'देहलोन', 'LGD03011001002'),
((SELECT id FROM subdistricts WHERE subdistrict_code = 'PB-LD-LUD'), 
 (SELECT id FROM districts WHERE district_code = 'PB-LD'),
 (SELECT id FROM states WHERE state_code = 'PB'),
 'PB-LD-LUD-GP003', 'Khanna', 'खन्ना', 'LGD03011001003')
ON CONFLICT (panchayat_code) DO NOTHING;

-- ============================================
-- SAMPLE VILLAGES (Maharashtra - Katraj GP)
-- ============================================
INSERT INTO villages (panchayat_id, subdistrict_id, district_id, state_id, village_code, village_name, village_name_hi, lgd_code, pincode, latitude, longitude, metadata) VALUES
((SELECT id FROM gram_panchayats WHERE panchayat_code = 'MH-PU-HAV-GP001'),
 (SELECT id FROM subdistricts WHERE subdistrict_code = 'MH-PU-HAV'),
 (SELECT id FROM districts WHERE district_code = 'MH-PU'),
 (SELECT id FROM states WHERE state_code = 'MH'),
 'MH-PU-HAV-GP001-V001', 'Katraj', 'कातरज', 'LGD27019001001001', '411046', 18.4474, 73.8633, '{"population": 5000, "agricultural_area_acres": 120}'),
((SELECT id FROM gram_panchayats WHERE panchayat_code = 'MH-PU-HAV-GP001'),
 (SELECT id FROM subdistricts WHERE subdistrict_code = 'MH-PU-HAV'),
 (SELECT id FROM districts WHERE district_code = 'MH-PU'),
 (SELECT id FROM states WHERE state_code = 'MH'),
 'MH-PU-HAV-GP001-V002', 'Kondhwa', 'कोंढवा', 'LGD27019001001002', '411048', 18.4577, 73.8831, '{"population": 7500, "agricultural_area_acres": 200}')
ON CONFLICT (village_code) DO NOTHING;

-- ============================================
-- SAMPLE VILLAGES (Uttar Pradesh - Malihabad GP)
-- ============================================
INSERT INTO villages (panchayat_id, subdistrict_id, district_id, state_id, village_code, village_name, village_name_hi, lgd_code, pincode, latitude, longitude, metadata) VALUES
((SELECT id FROM gram_panchayats WHERE panchayat_code = 'UP-LU-MAL-GP001'),
 (SELECT id FROM subdistricts WHERE subdistrict_code = 'UP-LU-MAL'),
 (SELECT id FROM districts WHERE district_code = 'UP-LU'),
 (SELECT id FROM states WHERE state_code = 'UP'),
 'UP-LU-MAL-GP001-V001', 'Malihabad', 'मलीहाबाद', 'LGD09033002001001', '226102', 26.9237, 80.7139, '{"population": 12000, "agricultural_area_acres": 350, "main_crop": "mango"}'),
((SELECT id FROM gram_panchayats WHERE panchayat_code = 'UP-LU-MAL-GP001'),
 (SELECT id FROM subdistricts WHERE subdistrict_code = 'UP-LU-MAL'),
 (SELECT id FROM districts WHERE district_code = 'UP-LU'),
 (SELECT id FROM states WHERE state_code = 'UP'),
 'UP-LU-MAL-GP001-V002', 'Behtamujawar', 'बेहटामुजावर', 'LGD09033002001002', '226203', 26.9387, 80.7289, '{"population": 8500, "agricultural_area_acres": 280}')
ON CONFLICT (village_code) DO NOTHING;

-- ============================================
-- SAMPLE VILLAGES (Punjab - Mullanpur GP)
-- ============================================
INSERT INTO villages (panchayat_id, subdistrict_id, district_id, state_id, village_code, village_name, village_name_hi, lgd_code, pincode, latitude, longitude, metadata) VALUES
((SELECT id FROM gram_panchayats WHERE panchayat_code = 'PB-LD-LUD-GP001'),
 (SELECT id FROM subdistricts WHERE subdistrict_code = 'PB-LD-LUD'),
 (SELECT id FROM districts WHERE district_code = 'PB-LD'),
 (SELECT id FROM states WHERE state_code = 'PB'),
 'PB-LD-LUD-GP001-V001', 'Mullanpur Dakha', 'मुल्लानपुर दख', 'LGD03011001001001', '141101', 30.8927, 75.8573, '{"population": 15000, "agricultural_area_acres": 450, "main_crop": "wheat"}'),
((SELECT id FROM gram_panchayats WHERE panchayat_code = 'PB-LD-LUD-GP001'),
 (SELECT id FROM subdistricts WHERE subdistrict_code = 'PB-LD-LUD'),
 (SELECT id FROM districts WHERE district_code = 'PB-LD'),
 (SELECT id FROM states WHERE state_code = 'PB'),
 'PB-LD-LUD-GP001-V002', 'Galib Kalan', 'गालिब कलां', 'LGD03011001001002', '141116', 30.9027, 75.8673, '{"population": 6500, "agricultural_area_acres": 180, "main_crop": "rice"}')
ON CONFLICT (village_code) DO NOTHING;
