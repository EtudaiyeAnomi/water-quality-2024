-- ============================================================
--  2024 RAINY SEASON WATER QUALITY — SQL SCHEMA & QUERIES
--  Sites: Kwali (n=20) | Sheda (n=8) | Bako (n=10)
--  FCT, Abuja, Nigeria
--  Compatible with: PostgreSQL / MySQL / SQLite
-- ============================================================


-- ─────────────────────────────────────────────────────────────
-- SECTION 1: SCHEMA / TABLE CREATION
-- ─────────────────────────────────────────────────────────────

CREATE TABLE sites (
    site_id     SERIAL PRIMARY KEY,
    site_name   VARCHAR(50)  NOT NULL,   -- 'Kwali', 'Sheda', 'Bako'
    latitude    DECIMAL(9,6),
    longitude   DECIMAL(9,6),
    n_samples   INT
);

CREATE TABLE physical_chemical (
    record_id       SERIAL PRIMARY KEY,
    site_id         INT REFERENCES sites(site_id),
    sample_no       INT          NOT NULL,
    ph              DECIMAL(5,3),
    turbidity_ntu   DECIMAL(8,4),
    salinity        DECIMAL(8,4),
    tds_mg_l        DECIMAL(10,4),
    conductivity    DECIMAL(10,4),
    chloride_mg_l   DECIMAL(10,4),
    nitrate_mg_l    DECIMAL(10,4),
    nitrite_mg_l    DECIMAL(10,4),
    acidity_gdm3    DECIMAL(12,8),
    alkalinity_gdm3 DECIMAL(12,8),
    hardness_mg_l   DECIMAL(10,4),
    longitude       DECIMAL(9,6),
    latitude        DECIMAL(9,6),
    collected_year  INT DEFAULT 2024,
    season          VARCHAR(20) DEFAULT 'Raining'
);

CREATE TABLE heavy_metals (
    record_id   SERIAL PRIMARY KEY,
    site_id     INT REFERENCES sites(site_id),
    sample_no   INT         NOT NULL,
    co_mg_l     DECIMAL(8,4),   -- Cobalt
    fe_mg_l     DECIMAL(8,4),   -- Iron
    cu_mg_l     DECIMAL(8,4),   -- Copper
    cd_mg_l     DECIMAL(8,4),   -- Cadmium
    cr_mg_l     DECIMAL(8,4),   -- Chromium
    ni_mg_l     DECIMAL(8,4),   -- Nickel
    pb_mg_l     DECIMAL(8,4),   -- Lead
    mn_mg_l     DECIMAL(8,4),   -- Manganese
    zn_mg_l     DECIMAL(8,4),   -- Zinc
    mg_mg_l     DECIMAL(8,4),   -- Magnesium
    ca_mg_l     DECIMAL(8,4),   -- Calcium
    na_mg_l     DECIMAL(8,4),   -- Sodium
    k_mg_l      DECIMAL(8,4),   -- Potassium
    collected_year INT DEFAULT 2024
);

CREATE TABLE who_guidelines (
    param_name      VARCHAR(50) PRIMARY KEY,
    who_min         DECIMAL(10,4),
    who_max         DECIMAL(10,4),
    unit            VARCHAR(20),
    note            TEXT
);

-- Seed WHO guidelines reference table
INSERT INTO who_guidelines VALUES
    ('ph',              6.5,    8.5,    '—',        'Drinking water pH range'),
    ('turbidity_ntu',   NULL,   5.0,    'NTU',      'Upper limit for drinking water'),
    ('tds_mg_l',        NULL,   1000.0, 'mg/L',     'WHO upper limit'),
    ('chloride_mg_l',   NULL,   250.0,  'mg/L',     'Taste threshold'),
    ('nitrate_mg_l',    NULL,   50.0,   'mg/L',     'Health-based guideline'),
    ('nitrite_mg_l',    NULL,   3.0,    'mg/L',     'Short-term exposure limit'),
    ('hardness_mg_l',   NULL,   500.0,  'mg/L',     'No health-based guideline'),
    ('fe_mg_l',         NULL,   0.3,    'mg/L',     'Aesthetic guideline value'),
    ('pb_mg_l',         NULL,   0.01,   'mg/L',     'Health-based guideline'),
    ('cd_mg_l',         NULL,   0.003,  'mg/L',     'Health-based guideline'),
    ('cr_mg_l',         NULL,   0.05,   'mg/L',     'Health-based guideline'),
    ('mn_mg_l',         NULL,   0.08,   'mg/L',     'Health-based guideline'),
    ('cu_mg_l',         NULL,   2.0,    'mg/L',     'Health-based guideline');


-- ─────────────────────────────────────────────────────────────
-- SECTION 2: SEED DATA — KWALI (n=20)
-- ─────────────────────────────────────────────────────────────

INSERT INTO sites (site_name, latitude, longitude, n_samples) VALUES
    ('Kwali', 8.8174,  7.0350, 20),
    ('Sheda', 8.9800,  7.1200,  8),
    ('Bako',  8.8600,  7.2000, 10);

-- Kwali physicochemical (site_id = 1)
INSERT INTO physical_chemical
  (site_id,sample_no,ph,turbidity_ntu,salinity,conductivity,chloride_mg_l,nitrate_mg_l,nitrite_mg_l,hardness_mg_l,longitude,latitude)
VALUES
  (1,1,6.65,0.59,0.289,720.5,10.12,NULL,NULL,200,7.035338,8.817342),
  (1,2,6.76,0.67,0.312,748.2,9.88,NULL,NULL,200,7.035107,8.817097),
  (1,3,6.64,0.79,0.298,711.0,8.94,NULL,NULL,180,7.035186,8.816326),
  (1,4,6.70,0.83,0.341,763.4,10.55,NULL,NULL,200,7.034850,8.815650),
  (1,5,6.71,0.63,0.305,730.1,9.22,NULL,NULL,200,7.035187,8.815490),
  (1,6,6.75,1.27,0.318,745.0,10.84,NULL,NULL,200,7.035290,8.815323),
  (1,7,6.76,0.66,0.356,771.3,11.03,NULL,NULL,220,7.835638,8.815924),
  (1,8,6.79,0.66,0.367,782.5,10.27,NULL,NULL,200,7.035643,8.815928),
  (1,9,6.82,0.77,0.379,795.0,9.78,NULL,NULL,200,7.035580,8.815857),
  (1,10,6.76,0.65,0.401,812.0,12.14,NULL,NULL,200,7.035302,8.817367),
  (1,11,6.75,0.34,0.289,720.5,8.92,NULL,NULL,180,7.034768,8.818035),
  (1,12,6.72,0.50,0.378,785.0,10.44,NULL,NULL,220,7.034772,8.818050),
  (1,13,6.87,0.53,0.391,802.0,11.22,NULL,NULL,200,7.034508,8.817988),
  (1,14,6.87,1.49,0.402,820.5,10.33,NULL,NULL,220,7.034582,8.818079),
  (1,15,6.89,0.61,0.412,840.0,9.67,NULL,NULL,240,7.034825,8.818137),
  (1,16,6.84,0.47,0.388,795.0,10.88,NULL,NULL,240,7.034633,8.818239),
  (1,17,6.90,0.44,0.371,765.0,9.24,NULL,NULL,200,7.033588,8.817410),
  (1,18,6.53,40.10,0.026,36.9,1.25,NULL,NULL,160,7.033600,8.817400),
  (1,19,6.80,1.76,0.399,815.0,10.66,NULL,NULL,200,7.033225,8.816476),
  (1,20,6.80,0.62,0.511,1033.0,16.22,NULL,NULL,260,7.034000,8.816000);

-- Sheda physicochemical (site_id = 2)
INSERT INTO physical_chemical
  (site_id,sample_no,ph,turbidity_ntu,salinity,tds_mg_l,conductivity,chloride_mg_l,nitrate_mg_l,nitrite_mg_l,hardness_mg_l)
VALUES
  (2,1,6.50,1.10,0.512,280.0,595.0,6.49,7.62,15.43,320),
  (2,2,6.38,0.62,0.180,120.0,254.0,2.50,5.89,3.22,280),
  (2,3,6.20,0.95,0.095,18.1,38.2,1.25,7.14,8.98,400),
  (2,4,6.50,0.62,0.274,183.0,389.0,5.62,6.22,7.45,360),
  (2,5,6.50,0.68,0.210,140.0,298.0,3.82,7.01,9.12,320),
  (2,6,6.50,1.10,0.286,195.0,414.0,4.96,5.44,6.33,360),
  (2,7,6.20,0.55,0.142,95.0,202.0,2.75,6.88,11.22,280),
  (2,8,6.38,0.62,0.362,242.0,514.0,6.25,6.29,14.10,400);

-- Bako physicochemical (site_id = 3)
INSERT INTO physical_chemical
  (site_id,sample_no,ph,turbidity_ntu,salinity,tds_mg_l,conductivity,chloride_mg_l,nitrate_mg_l,nitrite_mg_l,hardness_mg_l)
VALUES
  (3,1,6.69,0.59,0.047,243.7,87.58,2.50,6.75,0.61,160),
  (3,2,6.69,0.68,0.156,312.0,385.0,8.44,7.22,8.22,200),
  (3,3,6.69,0.79,0.286,486.0,712.0,12.88,1.71,12.44,200),
  (3,4,6.69,0.83,0.421,680.0,895.0,15.96,27.30,15.66,240),
  (3,5,6.69,0.63,0.512,820.0,1025.0,18.32,-6.75,18.88,280),
  (3,6,6.69,1.27,0.490,756.0,982.0,16.85,4.22,13.22,240),
  (3,7,6.69,0.66,0.380,586.0,812.0,12.44,2.88,9.44,200),
  (3,8,6.69,0.66,0.693,4292.0,1393.0,19.97,8.12,21.89,320),
  (3,9,6.69,0.77,0.580,920.0,1188.0,14.22,3.45,11.88,240),
  (3,10,6.69,0.65,0.108,338.0,478.0,9.68,5.12,7.66,200);

-- Kwali heavy metals (site_id = 1)
INSERT INTO heavy_metals
  (site_id,sample_no,co_mg_l,fe_mg_l,cu_mg_l,cd_mg_l,cr_mg_l,ni_mg_l,pb_mg_l,mn_mg_l,zn_mg_l,mg_mg_l,ca_mg_l,na_mg_l,k_mg_l)
VALUES
  (1,1,0.4920,0.6668,0.0953,0.1621,0.0290,0.1360,0.6406,0.1349,0.0363,8.0854,31.6279,10.6536,7.1609),
  (1,2,0.3875,0.5817,0.2161,0.2012,-0.0987,0.1730,0.2671,0.0344,0.0508,9.6689,32.6990,10.9533,13.1085),
  (1,3,0.5075,0.7829,0.1749,0.1343,-0.0281,0.1836,0.4219,0.0687,0.0622,9.3663,21.2750,10.3832,6.3150),
  (1,4,0.4332,1.1395,0.2648,0.1394,0.0587,0.1221,0.4471,0.0624,-0.0261,10.1567,50.6231,11.7050,8.2597),
  (1,5,0.2388,0.8105,0.0692,0.1486,0.1735,0.1585,1.1850,0.0748,-0.0250,8.0822,7.3316,10.2724,4.0157),
  (1,6,0.4111,0.4745,0.0444,0.1262,0.1107,0.1755,0.9767,0.0633,-0.0281,8.1754,10.7805,10.3776,4.4276),
  (1,7,0.5091,0.4870,0.1931,0.1716,0.2781,0.2825,0.3677,-0.0041,-0.0465,9.1373,20.9983,10.3259,7.4215),
  (1,8,0.3570,0.8976,0.0917,0.1828,0.0534,0.2767,0.8559,-0.1442,0.0051,9.4534,24.2760,10.3734,7.1331),
  (1,9,0.3396,0.5914,0.2185,0.2056,0.2201,0.1785,1.0102,0.1586,-0.0298,9.7790,19.9459,10.1599,6.0694),
  (1,10,0.3688,0.5365,0.1687,0.1556,0.1718,0.2120,-0.0352,0.0060,-0.0497,10.1691,62.7791,11.8239,7.1882),
  (1,11,0.4019,0.6499,0.0421,0.2248,0.1307,0.1767,0.5729,-0.0307,-0.0377,8.4949,23.0314,10.6739,11.6875),
  (1,12,0.6035,0.9046,0.1477,0.2538,0.0863,0.3123,0.6603,0.0407,-0.0564,10.2012,61.8138,11.8275,7.4512),
  (1,13,0.4209,0.5625,0.1375,0.1768,0.0327,0.2296,0.9983,-0.0544,-0.0350,7.4818,75.4341,11.3359,10.2319),
  (1,14,0.3823,0.1633,0.1330,0.1977,0.1442,0.1455,1.5915,0.0410,-0.0443,8.3048,31.9677,10.5862,6.9622),
  (1,15,0.5567,0.8612,0.2216,0.2652,0.1365,0.2315,0.8938,0.1047,-0.0341,9.9670,66.7359,11.9559,7.2618),
  (1,16,0.3701,0.8757,0.1734,0.2535,0.1642,0.1453,1.0244,0.0678,-0.0278,10.1459,63.5335,11.8889,7.7668),
  (1,17,0.2536,1.1755,0.0590,0.2708,-0.0134,0.1028,0.9050,0.0463,-0.0182,9.0691,11.8640,9.9934,5.9876),
  (1,18,0.4209,0.8463,0.0388,0.1932,0.1630,0.2063,0.7946,0.3843,-0.0318,8.6274,21.1827,9.8381,5.5303),
  (1,19,0.2960,1.1755,0.0635,0.2206,0.0422,0.1835,0.8724,0.0513,-0.0168,0.4268,2.4609,0.4604,0.5277),
  (1,20,0.3421,0.8463,-0.2186,0.1914,0.1586,0.1766,0.8911,0.1339,-0.0454,9.9838,52.0544,8.1521,7.5026);


-- ─────────────────────────────────────────────────────────────
-- SECTION 3: ANALYTICAL QUERIES
-- ─────────────────────────────────────────────────────────────

-- ── Q1: Statistical summary per site (physicochemical) ──────
SELECT
    s.site_name,
    COUNT(pc.record_id)                     AS n_samples,
    ROUND(AVG(pc.ph), 3)                    AS mean_ph,
    ROUND(STDDEV(pc.ph), 4)                 AS sd_ph,
    ROUND(AVG(pc.turbidity_ntu), 4)         AS mean_turbidity,
    ROUND(AVG(pc.tds_mg_l), 2)              AS mean_tds,
    ROUND(AVG(pc.conductivity), 2)          AS mean_conductivity,
    ROUND(AVG(pc.chloride_mg_l), 4)         AS mean_chloride,
    ROUND(AVG(pc.nitrite_mg_l), 4)          AS mean_nitrite,
    ROUND(AVG(pc.hardness_mg_l), 2)         AS mean_hardness
FROM physical_chemical pc
JOIN sites s ON s.site_id = pc.site_id
GROUP BY s.site_name
ORDER BY s.site_name;


-- ── Q2: Heavy metals mean per site ──────────────────────────
SELECT
    s.site_name,
    ROUND(AVG(hm.co_mg_l), 4)  AS avg_cobalt,
    ROUND(AVG(hm.fe_mg_l), 4)  AS avg_iron,
    ROUND(AVG(hm.cu_mg_l), 4)  AS avg_copper,
    ROUND(AVG(hm.cd_mg_l), 4)  AS avg_cadmium,
    ROUND(AVG(hm.cr_mg_l), 4)  AS avg_chromium,
    ROUND(AVG(hm.ni_mg_l), 4)  AS avg_nickel,
    ROUND(AVG(hm.pb_mg_l), 4)  AS avg_lead,
    ROUND(AVG(hm.mn_mg_l), 4)  AS avg_manganese,
    ROUND(AVG(hm.ca_mg_l), 4)  AS avg_calcium,
    ROUND(AVG(hm.mg_mg_l), 4)  AS avg_magnesium,
    ROUND(AVG(hm.na_mg_l), 4)  AS avg_sodium,
    ROUND(AVG(hm.k_mg_l),  4)  AS avg_potassium
FROM heavy_metals hm
JOIN sites s ON s.site_id = hm.site_id
GROUP BY s.site_name;


-- ── Q3: WHO compliance check — physical/chemical ────────────
SELECT
    s.site_name,
    pc.sample_no,
    pc.ph,
    CASE WHEN pc.ph BETWEEN 6.5 AND 8.5 THEN 'PASS' ELSE 'FAIL' END      AS ph_who,
    pc.turbidity_ntu,
    CASE WHEN pc.turbidity_ntu <= 5.0 THEN 'PASS' ELSE 'FAIL' END         AS turbidity_who,
    pc.tds_mg_l,
    CASE WHEN pc.tds_mg_l <= 1000 OR pc.tds_mg_l IS NULL
         THEN 'PASS' ELSE 'FAIL' END                                        AS tds_who,
    pc.nitrite_mg_l,
    CASE WHEN pc.nitrite_mg_l <= 3.0 OR pc.nitrite_mg_l IS NULL
         THEN 'PASS' ELSE 'FAIL' END                                        AS nitrite_who,
    pc.hardness_mg_l,
    CASE WHEN pc.hardness_mg_l <= 500 THEN 'PASS' ELSE 'FAIL' END         AS hardness_who
FROM physical_chemical pc
JOIN sites s ON s.site_id = pc.site_id
ORDER BY s.site_name, pc.sample_no;


-- ── Q4: WHO compliance check — heavy metals (Kwali) ─────────
SELECT
    hm.sample_no,
    hm.fe_mg_l,
    CASE WHEN hm.fe_mg_l <= 0.3 THEN 'PASS' ELSE 'EXCEED' END     AS fe_who,
    hm.pb_mg_l,
    CASE WHEN hm.pb_mg_l <= 0.01 THEN 'PASS' ELSE 'EXCEED' END    AS pb_who,
    hm.cd_mg_l,
    CASE WHEN hm.cd_mg_l <= 0.003 THEN 'PASS' ELSE 'EXCEED' END   AS cd_who,
    hm.cr_mg_l,
    CASE WHEN hm.cr_mg_l <= 0.05 THEN 'PASS' ELSE 'EXCEED' END    AS cr_who,
    hm.mn_mg_l,
    CASE WHEN hm.mn_mg_l <= 0.08 THEN 'PASS' ELSE 'EXCEED' END    AS mn_who
FROM heavy_metals hm
WHERE hm.site_id = 1
ORDER BY hm.sample_no;


-- ── Q5: Cross-site pH range & outlier flag ──────────────────
SELECT
    s.site_name,
    pc.sample_no,
    pc.ph,
    MIN(pc.ph) OVER (PARTITION BY s.site_name)  AS site_min_ph,
    MAX(pc.ph) OVER (PARTITION BY s.site_name)  AS site_max_ph,
    AVG(pc.ph) OVER (PARTITION BY s.site_name)  AS site_avg_ph,
    CASE
        WHEN pc.ph < 6.5 THEN 'BELOW WHO MIN'
        WHEN pc.ph > 8.5 THEN 'ABOVE WHO MAX'
        ELSE 'WITHIN RANGE'
    END AS who_status
FROM physical_chemical pc
JOIN sites s ON s.site_id = pc.site_id
ORDER BY s.site_name, pc.sample_no;


-- ── Q6: Turbidity outlier detection (Kwali sample 18) ───────
SELECT
    s.site_name,
    pc.sample_no,
    pc.turbidity_ntu,
    AVG(pc.turbidity_ntu) OVER (PARTITION BY s.site_name)    AS site_mean,
    STDDEV(pc.turbidity_ntu) OVER (PARTITION BY s.site_name) AS site_sd,
    CASE
        WHEN pc.turbidity_ntu > (
            AVG(pc.turbidity_ntu) OVER (PARTITION BY s.site_name)
            + 2 * STDDEV(pc.turbidity_ntu) OVER (PARTITION BY s.site_name)
        ) THEN 'OUTLIER'
        ELSE 'NORMAL'
    END AS outlier_flag
FROM physical_chemical pc
JOIN sites s ON s.site_id = pc.site_id
ORDER BY turbidity_ntu DESC;


-- ── Q7: Correlation-ready flat export (Power BI input) ──────
SELECT
    s.site_name,
    pc.sample_no,
    pc.ph,
    pc.turbidity_ntu,
    pc.salinity,
    pc.tds_mg_l,
    pc.conductivity,
    pc.chloride_mg_l,
    pc.nitrate_mg_l,
    pc.nitrite_mg_l,
    pc.hardness_mg_l,
    pc.longitude,
    pc.latitude,
    hm.co_mg_l,
    hm.fe_mg_l,
    hm.cu_mg_l,
    hm.cd_mg_l,
    hm.cr_mg_l,
    hm.ni_mg_l,
    hm.pb_mg_l,
    hm.mn_mg_l,
    hm.zn_mg_l,
    hm.mg_mg_l,
    hm.ca_mg_l,
    hm.na_mg_l,
    hm.k_mg_l
FROM physical_chemical pc
JOIN sites s  ON s.site_id  = pc.site_id
LEFT JOIN heavy_metals hm
    ON hm.site_id  = pc.site_id
    AND hm.sample_no = pc.sample_no
ORDER BY s.site_name, pc.sample_no;


-- ── Q8: Hardness classification per sample ──────────────────
SELECT
    s.site_name,
    pc.sample_no,
    pc.hardness_mg_l,
    CASE
        WHEN pc.hardness_mg_l < 75   THEN 'Soft'
        WHEN pc.hardness_mg_l < 150  THEN 'Moderately Hard'
        WHEN pc.hardness_mg_l < 300  THEN 'Hard'
        ELSE 'Very Hard'
    END AS hardness_class
FROM physical_chemical pc
JOIN sites s ON s.site_id = pc.site_id
ORDER BY pc.hardness_mg_l DESC;


-- ── Q9: Site-level KPI summary (Power BI card visuals) ──────
SELECT
    s.site_name,
    COUNT(pc.record_id)                                 AS total_samples,
    ROUND(AVG(pc.ph),3)                                 AS avg_ph,
    ROUND(MIN(pc.ph),3)                                 AS min_ph,
    ROUND(MAX(pc.ph),3)                                 AS max_ph,
    ROUND(AVG(pc.hardness_mg_l),1)                      AS avg_hardness,
    ROUND(AVG(pc.conductivity),1)                       AS avg_conductivity,
    ROUND(AVG(pc.tds_mg_l),1)                           AS avg_tds,
    ROUND(AVG(pc.turbidity_ntu),3)                      AS avg_turbidity,
    SUM(CASE WHEN pc.ph BETWEEN 6.5 AND 8.5
        THEN 1 ELSE 0 END)                              AS ph_pass_count,
    SUM(CASE WHEN pc.turbidity_ntu > 5
        THEN 1 ELSE 0 END)                              AS turbidity_fail_count
FROM physical_chemical pc
JOIN sites s ON s.site_id = pc.site_id
GROUP BY s.site_name
ORDER BY s.site_name;


-- ── Q10: Heavy metals exceedance summary vs WHO ─────────────
SELECT
    'Lead (Pb)'      AS metal, 0.01  AS who_limit_mg_l,
    COUNT(*)         AS n_tested,
    SUM(CASE WHEN pb_mg_l > 0.01  THEN 1 ELSE 0 END) AS n_exceeded,
    ROUND(100.0 * SUM(CASE WHEN pb_mg_l > 0.01  THEN 1 ELSE 0 END) / COUNT(*), 1) AS pct_exceeded
FROM heavy_metals WHERE site_id = 1
UNION ALL
SELECT 'Cadmium (Cd)', 0.003, COUNT(*),
    SUM(CASE WHEN cd_mg_l > 0.003 THEN 1 ELSE 0 END),
    ROUND(100.0 * SUM(CASE WHEN cd_mg_l > 0.003 THEN 1 ELSE 0 END)/COUNT(*),1)
FROM heavy_metals WHERE site_id = 1
UNION ALL
SELECT 'Iron (Fe)', 0.3, COUNT(*),
    SUM(CASE WHEN fe_mg_l > 0.3 THEN 1 ELSE 0 END),
    ROUND(100.0 * SUM(CASE WHEN fe_mg_l > 0.3 THEN 1 ELSE 0 END)/COUNT(*),1)
FROM heavy_metals WHERE site_id = 1
UNION ALL
SELECT 'Chromium (Cr)', 0.05, COUNT(*),
    SUM(CASE WHEN cr_mg_l > 0.05 THEN 1 ELSE 0 END),
    ROUND(100.0 * SUM(CASE WHEN cr_mg_l > 0.05 THEN 1 ELSE 0 END)/COUNT(*),1)
FROM heavy_metals WHERE site_id = 1
UNION ALL
SELECT 'Manganese (Mn)', 0.08, COUNT(*),
    SUM(CASE WHEN mn_mg_l > 0.08 THEN 1 ELSE 0 END),
    ROUND(100.0 * SUM(CASE WHEN mn_mg_l > 0.08 THEN 1 ELSE 0 END)/COUNT(*),1)
FROM heavy_metals WHERE site_id = 1;
