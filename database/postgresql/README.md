# PostgreSQL Database Schema for PMFBY Geographical Data

## Overview
This directory contains PostgreSQL database schemas for managing Indian geographical hierarchy data for the PMFBY (Pradhan Mantri Fasal Bima Yojana) application.

## Directory Structure

```
database/postgresql/
├── schemas/
│   ├── 01_create_tables.sql    # Main table definitions
│   ├── 02_create_views.sql     # Useful views for queries
│   └── 03_sample_data.sql      # Sample test data
├── queries/
│   └── common_queries.sql      # Ready-to-use queries
└── README.md                   # This file
```

## Database Tables

### 1. **states**
Stores all Indian states and union territories
- Primary Key: `id`
- Unique: `state_code`, `lgd_code`
- Fields: state_name, state_name_hi, state_name_local, metadata (JSONB)

### 2. **districts**
Stores all districts within states
- Primary Key: `id`
- Foreign Key: `state_id` → states(id)
- Unique: `district_code`, `lgd_code`
- Fields: district_name, district_name_hi, district_name_local, metadata

### 3. **subdistricts**
Stores tehsil/mandal/block level divisions
- Primary Key: `id`
- Foreign Keys: `district_id`, `state_id`
- Unique: `subdistrict_code`, `lgd_code`
- Fields: subdistrict_name, subdistrict_type (tehsil/mandal/block/taluka), metadata

### 4. **gram_panchayats**
Stores gram panchayat (village council) information
- Primary Key: `id`
- Foreign Keys: `subdistrict_id`, `district_id`, `state_id`
- Unique: `panchayat_code`, `lgd_code`
- Fields: panchayat_name, panchayat_name_hi, panchayat_name_local, metadata

### 5. **villages** (Optional)
Stores individual village information with GPS coordinates
- Primary Key: `id`
- Foreign Keys: `panchayat_id`, `subdistrict_id`, `district_id`, `state_id`
- Unique: `village_code`, `lgd_code`
- Fields: village_name, pincode, latitude, longitude, metadata

## Setup Instructions

### Prerequisites
- PostgreSQL 12 or higher
- Database user with CREATE TABLE permissions

### Environment Variables
Add these to your `.env` file:
```env
POSTGRES_HOST=your_postgres_host
POSTGRES_PORT=5432
POSTGRES_DB=pmfby_geo_db
POSTGRES_USER=your_postgres_user
POSTGRES_PASSWORD=your_postgres_password
POSTGRES_SSL_MODE=require
```

### Installation Steps

1. **Create Database**
```bash
psql -U postgres -c "CREATE DATABASE pmfby_geo_db;"
```

2. **Run Schema Scripts** (in order)
```bash
# Create tables and indexes
psql -U your_user -d pmfby_geo_db -f database/postgresql/schemas/01_create_tables.sql

# Create views
psql -U your_user -d pmfby_geo_db -f database/postgresql/schemas/02_create_views.sql

# Load sample data (optional)
psql -U your_user -d pmfby_geo_db -f database/postgresql/schemas/03_sample_data.sql
```

Or run all at once:
```bash
cd database/postgresql/schemas
cat 01_create_tables.sql 02_create_views.sql 03_sample_data.sql | psql -U your_user -d pmfby_geo_db
```

## Key Features

### 1. **Hierarchical Structure**
- Full support for Indian administrative hierarchy
- Maintains referential integrity via foreign keys
- Cascading deletes for data consistency

### 2. **Multi-language Support**
- English (primary)
- Hindi (state_name_hi)
- Local language (state_name_local)

### 3. **LGD Code Support**
- Stores Local Government Directory (LGD) codes
- Unique constraint ensures data integrity

### 4. **Metadata Storage**
- JSONB fields for flexible additional data
- Can store: population, area, crop patterns, etc.

### 5. **Performance Optimized**
- Comprehensive indexing strategy
- Composite indexes for common queries
- Optimized for cascading dropdowns

### 6. **Audit Trail**
- created_at timestamp
- updated_at timestamp (auto-updated via trigger)
- is_active flag for soft deletes

## Common Use Cases

### 1. Cascading Dropdowns
Use the provided queries in `common_queries.sql` section 11 for implementing cascading dropdowns in Flutter.

### 2. Location Search
- Search by village name (case-insensitive)
- Search by pincode
- Search by GPS coordinates (requires PostGIS)

### 3. Statistics & Reports
Use the summary views:
- `state_summary`
- `district_summary`
- `subdistrict_summary`
- `panchayat_summary`

### 4. Complete Hierarchy
Use `complete_hierarchy` view to get full location details in one query.

## Database Views

### Available Views
1. **complete_hierarchy** - Full hierarchy from village to state
2. **active_locations** - Only active locations
3. **state_summary** - Statistics per state
4. **district_summary** - Statistics per district
5. **subdistrict_summary** - Statistics per subdistrict
6. **panchayat_summary** - Statistics per panchayat

## Flutter Integration

### Package Requirements
```yaml
dependencies:
  postgres: ^2.6.0  # PostgreSQL client
```

### Example Connection
```dart
import 'package:postgres/postgres.dart';

final connection = PostgreSQLConnection(
  'your_host',
  5432,
  'pmfby_geo_db',
  username: 'your_user',
  password: 'your_password',
  useSSL: true,
);

await connection.open();
```

### Example Query
```dart
final results = await connection.query(
  'SELECT id, district_name FROM districts WHERE state_id = @stateId AND is_active = true',
  substitutionValues: {'stateId': selectedStateId},
);
```

## Data Import

### Bulk Import from CSV
```bash
# Import states
psql -d pmfby_geo_db -c "\COPY states(state_code, state_name, state_name_hi, lgd_code) FROM 'states.csv' CSV HEADER"

# Import districts
psql -d pmfby_geo_db -c "\COPY districts(state_id, district_code, district_name, lgd_code) FROM 'districts.csv' CSV HEADER"
```

## Maintenance

### Regular Tasks
1. **Backup Database**
```bash
pg_dump -U your_user pmfby_geo_db > backup_$(date +%Y%m%d).sql
```

2. **Vacuum & Analyze**
```sql
VACUUM ANALYZE states;
VACUUM ANALYZE districts;
VACUUM ANALYZE subdistricts;
VACUUM ANALYZE gram_panchayats;
VACUUM ANALYZE villages;
```

3. **Check Index Usage**
```sql
SELECT schemaname, tablename, indexname, idx_scan 
FROM pg_stat_user_indexes 
WHERE schemaname = 'public'
ORDER BY idx_scan DESC;
```

## Performance Tips

1. **Use Prepared Statements** - Reduces query parsing time
2. **Limit Results** - Use LIMIT clause for large datasets
3. **Use Views** - Pre-defined views are optimized
4. **Connection Pooling** - Reuse database connections
5. **Index Monitoring** - Regularly check unused indexes

## Security Considerations

1. **Never commit credentials** to version control
2. **Use SSL connections** in production
3. **Implement row-level security** if needed
4. **Regular security updates** for PostgreSQL
5. **Principle of least privilege** for database users

## Support & References

- PostgreSQL Documentation: https://www.postgresql.org/docs/
- LGD Portal: https://lgdirectory.gov.in/
- India Census Data: https://censusindia.gov.in/

## License
This schema is part of the PMFBY application project.
