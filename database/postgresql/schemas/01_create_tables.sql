-- PostgreSQL Schema for PMFBY Geographical Hierarchy
-- This schema supports the hierarchical structure of Indian administrative divisions

-- Enable UUID extension for unique identifiers
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ============================================
-- TABLE: states
-- Stores all Indian states and union territories
-- ============================================
CREATE TABLE IF NOT EXISTS states (
    id SERIAL PRIMARY KEY,
    state_code VARCHAR(10) UNIQUE NOT NULL,
    state_name VARCHAR(100) NOT NULL,
    state_name_hi VARCHAR(100), -- Hindi name
    state_name_local VARCHAR(100), -- Local language name
    lgd_code VARCHAR(20) UNIQUE, -- Local Government Directory code
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    metadata JSONB -- Additional metadata (population, area, etc.)
);

-- ============================================
-- TABLE: districts
-- Stores all districts within states
-- ============================================
CREATE TABLE IF NOT EXISTS districts (
    id SERIAL PRIMARY KEY,
    state_id INTEGER NOT NULL REFERENCES states(id) ON DELETE CASCADE,
    district_code VARCHAR(20) UNIQUE NOT NULL,
    district_name VARCHAR(100) NOT NULL,
    district_name_hi VARCHAR(100), -- Hindi name
    district_name_local VARCHAR(100), -- Local language name
    lgd_code VARCHAR(20) UNIQUE, -- Local Government Directory code
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    metadata JSONB -- Additional metadata
);

-- ============================================
-- TABLE: subdistricts
-- Stores tehsil/mandal/block/taluka level divisions
-- ============================================
CREATE TABLE IF NOT EXISTS subdistricts (
    id SERIAL PRIMARY KEY,
    district_id INTEGER NOT NULL REFERENCES districts(id) ON DELETE CASCADE,
    state_id INTEGER NOT NULL REFERENCES states(id) ON DELETE CASCADE,
    subdistrict_code VARCHAR(20) UNIQUE NOT NULL,
    subdistrict_name VARCHAR(100) NOT NULL,
    subdistrict_name_hi VARCHAR(100), -- Hindi name
    subdistrict_name_local VARCHAR(100), -- Local language name
    subdistrict_type VARCHAR(20) DEFAULT 'tehsil', -- tehsil/mandal/block/taluka
    lgd_code VARCHAR(20) UNIQUE, -- Local Government Directory code
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    metadata JSONB -- Additional metadata
);

-- ============================================
-- TABLE: gram_panchayats
-- Stores gram panchayat (village council) information
-- ============================================
CREATE TABLE IF NOT EXISTS gram_panchayats (
    id SERIAL PRIMARY KEY,
    subdistrict_id INTEGER NOT NULL REFERENCES subdistricts(id) ON DELETE CASCADE,
    district_id INTEGER NOT NULL REFERENCES districts(id) ON DELETE CASCADE,
    state_id INTEGER NOT NULL REFERENCES states(id) ON DELETE CASCADE,
    panchayat_code VARCHAR(20) UNIQUE NOT NULL,
    panchayat_name VARCHAR(100) NOT NULL,
    panchayat_name_hi VARCHAR(100), -- Hindi name
    panchayat_name_local VARCHAR(100), -- Local language name
    lgd_code VARCHAR(20) UNIQUE, -- Local Government Directory code
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    metadata JSONB -- Additional metadata (population, total area, etc.)
);

-- ============================================
-- TABLE: villages (Optional but recommended)
-- Stores individual village information
-- ============================================
CREATE TABLE IF NOT EXISTS villages (
    id SERIAL PRIMARY KEY,
    panchayat_id INTEGER REFERENCES gram_panchayats(id) ON DELETE CASCADE,
    subdistrict_id INTEGER NOT NULL REFERENCES subdistricts(id) ON DELETE CASCADE,
    district_id INTEGER NOT NULL REFERENCES districts(id) ON DELETE CASCADE,
    state_id INTEGER NOT NULL REFERENCES states(id) ON DELETE CASCADE,
    village_code VARCHAR(20) UNIQUE NOT NULL,
    village_name VARCHAR(100) NOT NULL,
    village_name_hi VARCHAR(100), -- Hindi name
    village_name_local VARCHAR(100), -- Local language name
    lgd_code VARCHAR(20) UNIQUE, -- Local Government Directory code
    pincode VARCHAR(10),
    latitude DECIMAL(10, 8), -- GPS coordinates
    longitude DECIMAL(11, 8),
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    metadata JSONB -- Additional metadata (population, agricultural area, etc.)
);

-- ============================================
-- INDEXES for Performance Optimization
-- ============================================

-- States indexes
CREATE INDEX IF NOT EXISTS idx_states_code ON states(state_code);
CREATE INDEX IF NOT EXISTS idx_states_active ON states(is_active);
CREATE INDEX IF NOT EXISTS idx_states_lgd ON states(lgd_code);

-- Districts indexes
CREATE INDEX IF NOT EXISTS idx_districts_state ON districts(state_id);
CREATE INDEX IF NOT EXISTS idx_districts_code ON districts(district_code);
CREATE INDEX IF NOT EXISTS idx_districts_active ON districts(is_active);
CREATE INDEX IF NOT EXISTS idx_districts_lgd ON districts(lgd_code);

-- Subdistricts indexes
CREATE INDEX IF NOT EXISTS idx_subdistricts_district ON subdistricts(district_id);
CREATE INDEX IF NOT EXISTS idx_subdistricts_state ON subdistricts(state_id);
CREATE INDEX IF NOT EXISTS idx_subdistricts_code ON subdistricts(subdistrict_code);
CREATE INDEX IF NOT EXISTS idx_subdistricts_type ON subdistricts(subdistrict_type);
CREATE INDEX IF NOT EXISTS idx_subdistricts_active ON subdistricts(is_active);
CREATE INDEX IF NOT EXISTS idx_subdistricts_lgd ON subdistricts(lgd_code);

-- Gram Panchayats indexes
CREATE INDEX IF NOT EXISTS idx_panchayats_subdistrict ON gram_panchayats(subdistrict_id);
CREATE INDEX IF NOT EXISTS idx_panchayats_district ON gram_panchayats(district_id);
CREATE INDEX IF NOT EXISTS idx_panchayats_state ON gram_panchayats(state_id);
CREATE INDEX IF NOT EXISTS idx_panchayats_code ON gram_panchayats(panchayat_code);
CREATE INDEX IF NOT EXISTS idx_panchayats_active ON gram_panchayats(is_active);
CREATE INDEX IF NOT EXISTS idx_panchayats_lgd ON gram_panchayats(lgd_code);

-- Villages indexes
CREATE INDEX IF NOT EXISTS idx_villages_panchayat ON villages(panchayat_id);
CREATE INDEX IF NOT EXISTS idx_villages_subdistrict ON villages(subdistrict_id);
CREATE INDEX IF NOT EXISTS idx_villages_district ON villages(district_id);
CREATE INDEX IF NOT EXISTS idx_villages_state ON villages(state_id);
CREATE INDEX IF NOT EXISTS idx_villages_code ON villages(village_code);
CREATE INDEX IF NOT EXISTS idx_villages_pincode ON villages(pincode);
CREATE INDEX IF NOT EXISTS idx_villages_location ON villages(latitude, longitude);
CREATE INDEX IF NOT EXISTS idx_villages_active ON villages(is_active);
CREATE INDEX IF NOT EXISTS idx_villages_lgd ON villages(lgd_code);

-- Composite indexes for common queries
CREATE INDEX IF NOT EXISTS idx_districts_state_active ON districts(state_id, is_active);
CREATE INDEX IF NOT EXISTS idx_subdistricts_district_active ON subdistricts(district_id, is_active);
CREATE INDEX IF NOT EXISTS idx_panchayats_subdistrict_active ON gram_panchayats(subdistrict_id, is_active);
CREATE INDEX IF NOT EXISTS idx_villages_panchayat_active ON villages(panchayat_id, is_active);

-- ============================================
-- TRIGGERS for auto-updating timestamps
-- ============================================

-- Function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Apply trigger to all tables
CREATE TRIGGER update_states_updated_at BEFORE UPDATE ON states
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_districts_updated_at BEFORE UPDATE ON districts
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_subdistricts_updated_at BEFORE UPDATE ON subdistricts
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_gram_panchayats_updated_at BEFORE UPDATE ON gram_panchayats
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_villages_updated_at BEFORE UPDATE ON villages
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- ============================================
-- COMMENTS for documentation
-- ============================================

COMMENT ON TABLE states IS 'Stores all Indian states and union territories';
COMMENT ON TABLE districts IS 'Stores all districts within states';
COMMENT ON TABLE subdistricts IS 'Stores tehsil/mandal/block level administrative divisions';
COMMENT ON TABLE gram_panchayats IS 'Stores gram panchayat (village council) information';
COMMENT ON TABLE villages IS 'Stores individual village information with GPS coordinates';

COMMENT ON COLUMN subdistricts.subdistrict_type IS 'Type of subdivision: tehsil (North), mandal (South), block (East), taluka (West)';
COMMENT ON COLUMN villages.metadata IS 'JSON field for additional data like population, agricultural area, crop patterns, etc.';
