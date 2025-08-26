DROP TABLE IF EXISTS profile_fund;
DROP TABLE IF EXISTS fund;
DROP TABLE IF EXISTS sold;
DROP TABLE IF EXISTS asset;
DROP TABLE IF EXISTS profile_char;
DROP TABLE IF EXISTS region_country;
DROP TABLE IF EXISTS r_primary_property_type;
DROP TABLE IF EXISTS profile_source;
DROP TABLE IF EXISTS management_co;
DROP TABLE IF EXISTS lifecycle_stage;
DROP TABLE IF EXISTS city_state_province;
    
CREATE TABLE city_state_province (
	city_state_province_id SMALLINT NOT NULL,
    city VARCHAR(50),
    state_province VARCHAR(50),
    PRIMARY KEY (city_state_province_id)
    );
    
CREATE TABLE lifecycle_stage (
	lifecycle_stage_id TINYINT NOT NULL,
    lifecycle_stage VARCHAR(26) NOT NULL,
    PRIMARY KEY (lifecycle_stage_id)
    );
    
CREATE TABLE management_co (
	management_co_id SMALLINT NOT NULL,
    management_co VARCHAR(50) NOT NULL,
    PRIMARY KEY (management_co_id)
    );
    
CREATE TABLE profile_source (
	profile_source_id TINYINT NOT NULL,
    profile_source VARCHAR(20) NOT NULL,
    PRIMARY KEY (profile_source_id)
    );
    
CREATE TABLE r_primary_property_type (
	r_primary_property_type_id TINYINT NOT NULL,
    r_primary_property_type VARCHAR(60) NOT NULL,
    PRIMARY KEY (r_primary_property_type_id)
    );

CREATE TABLE region_country (
	region_country_id SMALLINT NOT NULL,
    global_region VARCHAR(13) NOT NULL,
    country VARCHAR(50) NOT NULL,
    PRIMARY KEY (region_country_id)
    );

CREATE TABLE profile_char (
	r_profile_id INT NOT NULL,
    r_profile_name VARCHAR(100) NOT NULL,
    bought_date DATE,
    year_built SMALLINT,
    gfa_sqft INT,
    gla_sqft INT,
    profile_active BOOL,
    wbtc BOOL,
    lifecycle_stage_id TINYINT NOT NULL,
    management_co_id SMALLINT,
    r_primary_property_type_id TINYINT NOT NULL,
    profile_source_id TINYINT NOT NULL,
    region_country_id SMALLINT NOT NULL,
    city_state_province_id SMALLINT,
    PRIMARY KEY (r_profile_id),
    FOREIGN KEY (lifecycle_stage_id) REFERENCES lifecycle_stage(lifecycle_stage_id) ON DELETE CASCADE,
    FOREIGN KEY (management_co_id) REFERENCES management_co(management_co_id) ON DELETE CASCADE,
    FOREIGN KEY (r_primary_property_type_id) REFERENCES r_primary_property_type(r_primary_property_type_id) ON DELETE CASCADE,
    FOREIGN KEY (profile_source_id) REFERENCES profile_source(profile_source_id) ON DELETE CASCADE,
    FOREIGN KEY (region_country_id) REFERENCES region_country(region_country_id) ON DELETE CASCADE,
    FOREIGN KEY (city_state_province_id) REFERENCES city_state_province(city_state_province_id) ON DELETE CASCADE
    );
    
    CREATE TABLE asset (
	r_profile_id INT NOT NULL,
    asset_name VARCHAR(100) NOT NULL,
    asset_id VARCHAR(20) NOT NULL,
    FOREIGN KEY (r_profile_id) REFERENCES profile_char(r_profile_id) ON DELETE CASCADE
    );
    
    CREATE TABLE sold (
	r_profile_id INT NOT NULL,
    sold_date DATE NOT NULL,
    PRIMARY KEY (r_profile_id),
	FOREIGN KEY (r_profile_id) REFERENCES profile_char(r_profile_id) ON DELETE CASCADE
    );
    
	CREATE TABLE fund (
	fund_id TINYINT NOT NULL,
    fund_name VARCHAR(100) NOT NULL,
    PRIMARY KEY (fund_id)
    );
    
    CREATE TABLE profile_fund (
	r_profile_id INT NOT NULL,
    fund_id TINYINT NOT NULL,
    FOREIGN KEY (r_profile_id) REFERENCES profile_char(r_profile_id) ON DELETE CASCADE,
    FOREIGN KEY (fund_id) REFERENCES fund(fund_id) ON DELETE CASCADE
    );