-- EdTech Scanner Database Initialization
-- PostgreSQL 14+

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Create ENUM types
DO $$ BEGIN
    CREATE TYPE auth_method AS ENUM ('google', 'phone', 'guest');
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

-- Users table
CREATE TABLE IF NOT EXISTS users (
    user_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    auth_method auth_method NOT NULL,
    google_id VARCHAR(255) UNIQUE,
    phone_number VARCHAR(20) UNIQUE,
    email VARCHAR(255) UNIQUE,
    full_name VARCHAR(255),
    profile_picture VARCHAR(512),
    language_preference VARCHAR(5) DEFAULT 'en',
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_login_at TIMESTAMP,
    deleted_at TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_users_google_id ON users(google_id);
CREATE INDEX IF NOT EXISTS idx_users_phone_number ON users(phone_number);
CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);

-- Equipment table
CREATE TABLE IF NOT EXISTS equipment (
    equipment_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    class_name VARCHAR(100) UNIQUE NOT NULL,
    name_en VARCHAR(255) NOT NULL,
    name_km VARCHAR(255),
    category VARCHAR(100) NOT NULL,
    description_en TEXT NOT NULL,
    description_km TEXT,
    usage_en TEXT NOT NULL,
    usage_km TEXT,
    safety_info_en TEXT,
    safety_info_km TEXT,
    image_url VARCHAR(512),
    tags TEXT[],
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_equipment_class_name ON equipment(class_name);
CREATE INDEX IF NOT EXISTS idx_equipment_category ON equipment(category);

-- Scan metadata table
CREATE TABLE IF NOT EXISTS scan_metadata (
    scan_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
    equipment_id UUID NOT NULL REFERENCES equipment(equipment_id) ON DELETE CASCADE,
    confidence_score FLOAT NOT NULL,
    device_info JSONB,
    scanned_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    synced_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_scan_metadata_user_id ON scan_metadata(user_id);
CREATE INDEX IF NOT EXISTS idx_scan_metadata_equipment_id ON scan_metadata(equipment_id);
CREATE INDEX IF NOT EXISTS idx_scan_metadata_scanned_at ON scan_metadata(scanned_at DESC);

-- Insert sample equipment data
INSERT INTO equipment (class_name, name_en, category, description_en, usage_en, safety_info_en, tags) VALUES
('microscope', 'Compound Microscope', 'Microscopy', 'An optical instrument with multiple lenses for magnifying small objects', 'Used to observe cells, microorganisms, and other tiny specimens in detail', 'Handle with care, avoid touching lenses, use proper lighting to prevent eye strain', ARRAY['optical', 'magnification', 'biology']),
('beaker', 'Laboratory Beaker', 'Glassware', 'A cylindrical container with a flat bottom used for mixing and heating liquids', 'Used for holding, mixing, and heating liquids in laboratory experiments', 'Use heat-resistant beakers for heating, handle hot glassware with tongs or heat-resistant gloves', ARRAY['glassware', 'container', 'chemistry']),
('test-tube', 'Test Tube', 'Glassware', 'A thin glass tube closed at one end, used for holding small amounts of liquid or solid samples', 'Used for chemical reactions, heating small amounts of substances, and storing samples', 'Always point away from people when heating, use test tube holders, wear safety goggles', ARRAY['glassware', 'chemistry', 'reactions']),
('flask', 'Erlenmeyer Flask', 'Glassware', 'A conical flask with a narrow neck, ideal for mixing and heating solutions', 'Used for titrations, mixing solutions, culturing microorganisms, and heating liquids', 'Handle with care when hot, use appropriate heating methods, avoid thermal shock', ARRAY['glassware', 'mixing', 'chemistry']),
('bunsen-burner', 'Bunsen Burner', 'Heating', 'A gas burner used for heating, sterilization, and combustion in laboratory', 'Used to heat substances, sterilize equipment, and perform flame tests', 'Keep flammable materials away, tie back long hair, wear safety goggles, ensure proper ventilation', ARRAY['heating', 'flame', 'safety'])
ON CONFLICT (class_name) DO NOTHING;
