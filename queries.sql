-- 1. How many properties are under initial construction in the United States, by fund?
SELECT fund_name AS "Fund", COUNT(r_profile_name) AS "Properties Under Initial Construction"
FROM profile_char AS pc
INNER JOIN lifecycle_stage AS ls ON pc.lifecycle_stage_id = ls.lifecycle_stage_id
INNER JOIN region_country AS rc ON pc.region_country_id = rc.region_country_id
INNER JOIN profile_fund AS pf ON pc.r_profile_id = pf.r_profile_id
INNER JOIN fund AS f ON f.fund_id = pf.fund_id
WHERE lifecycle_stage = "Under Initial Construction" AND country = "United States" AND profile_active = true
GROUP BY fund_name;

-- 2. What are the asset names of the 5 properties that were sold most recently, and when were they sold?
SELECT DISTINCT asset_name, sold_date
FROM profile_char as pc
INNER JOIN asset AS a ON a.r_profile_id = pc.r_profile_id
INNER JOIN sold AS s ON s.r_profile_id = pc.r_profile_id
ORDER BY sold_date DESC
LIMIT 5;

-- 3. Which management companies manage the most properties, and how many, by region?
WITH count_properties_managed AS (
	SELECT global_region, management_co, COUNT(r_profile_id) AS properties_managed
	FROM profile_char AS pc
	INNER JOIN management_co AS mc ON pc.management_co_id = mc.management_co_id
	INNER JOIN region_country AS rc ON pc.region_country_id = rc.region_country_id
    WHERE profile_active = true
	GROUP BY management_co, global_region
	ORDER BY properties_managed DESC
	),
part AS (
	SELECT *, ROW_NUMBER() OVER (PARTITION BY global_region ORDER BY properties_managed DESC) AS num_row
    FROM count_properties_managed
	)
SELECT global_region, management_co, properties_managed
FROM part
WHERE num_row <= 1
ORDER BY global_region DESC, properties_managed DESC;

-- 4. What percentage of GFA (gross floor area) was sold in 2022, by fund?
WITH gather AS (
	SELECT fund_name, gfa_sqft, sold_date
	FROM profile_char AS pc
	INNER JOIN lifecycle_stage AS ls ON pc.lifecycle_stage_id = ls.lifecycle_stage_id
	LEFT JOIN sold AS s ON pc.r_profile_id = s.r_profile_id
	INNER JOIN profile_fund AS pf ON pc.r_profile_id = pf.r_profile_id
	INNER JOIN fund AS f ON pf.fund_id = f.fund_id
	WHERE profile_active = true
    ORDER BY gfa_sqft DESC
	),
total AS (
    SELECT fund_name, SUM(gfa_sqft) AS total_gfa
    FROM gather
    GROUP BY fund_name
    ),
sold_2022 AS (
    SELECT fund_name, SUM(gfa_sqft) AS sold_gfa
    FROM gather
    WHERE YEAR(sold_date) = 2022 OR sold_date = null
    GROUP BY fund_name
    )
SELECT t.fund_name AS fund_name, IFNULL(sold_gfa,0) AS sold_gfa, total_gfa, ROUND(IFNULL((sold_gfa/total_gfa*100),0),1) AS percent_gfa_sold_2022
FROM total AS t
LEFT JOIN sold_2022 AS s2022 ON s2022.fund_name = t.fund_name
ORDER BY percent_gfa_sold_2022 DESC, total_gfa DESC;

-- 5. Create a view that looks like the original spreadsheet.
DROP VIEW IF EXISTS spreadsheet;

CREATE VIEW spreadsheet AS
SELECT asset_name AS "Asset Name", asset_id AS "Asset ID", r_profile_name AS "R Profile Name", pc.r_profile_id AS "R Profile ID", profile_source AS "Profile Source", IF(profile_active = 1, "Active", "Inactive") AS "Profile Active", lifecycle_stage AS "Lifecycle Stage", management_co AS "Management Company", bought_date AS "Acquisition Date", sold_date AS "Disposition Date", fund_name AS "Fund", global_region AS "Global Region", country AS "Country", city AS "City", state_province AS "State/Province", r_primary_property_type AS "R Primary Property Type", year_built AS "Year Built", gfa_sqft AS "GFA (sqft)", gla_sqft AS "GLA (sqft)", IF(wbtc = 1, "TRUE", "FALSE") AS "WBTC"
FROM profile_char AS pc
RIGHT JOIN asset AS a ON pc.r_profile_id = a.r_profile_id
LEFT JOIN profile_source AS ps ON pc.profile_source_id = ps.profile_source_id
LEFT JOIN lifecycle_stage AS ls ON pc.lifecycle_stage_id = ls.lifecycle_stage_id
LEFT JOIN management_co AS mc ON pc.management_co_id = mc.management_co_id
LEFT JOIN sold AS s ON pc.r_profile_id = s.r_profile_id
RIGHT JOIN profile_fund AS pf ON pc.r_profile_id = pf.r_profile_id
LEFT JOIN fund AS f ON pf.fund_id = f.fund_id
LEFT JOIN region_country AS rc ON pc.region_country_id = rc.region_country_id
LEFT JOIN city_state_province AS csp ON pc.city_state_province_id = csp.city_state_province_id
LEFT JOIN r_primary_property_type AS rppt ON pc.r_primary_property_type_id = rppt.r_primary_property_type_id;

SELECT *
FROM spreadsheet
LIMIT 2000;