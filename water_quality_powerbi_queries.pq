// ============================================================
//  2024 RAINY SEASON WATER QUALITY — POWER BI QUERIES
//  Power Query (M Language) + DAX Measures
//  Connect to your SQL database or paste CSV data directly
// ============================================================


// ─────────────────────────────────────────────────────────────
// PART A: POWER QUERY (M LANGUAGE)
// Home → Transform Data → Advanced Editor → paste each block
// ─────────────────────────────────────────────────────────────

// ── TABLE 1: PhysicalChemical (from SQL or CSV) ──────────────
// Paste in Advanced Editor for the "PhysicalChemical" query:

let
    Source = Sql.Database("YOUR_SERVER", "YOUR_DB"),
    physical_chemical = Source{[Schema="public",Item="physical_chemical"]}[Data],
    JoinSites = Table.NestedJoin(
        physical_chemical, {"site_id"},
        Source{[Schema="public",Item="sites"]}[Data], {"site_id"},
        "Sites", JoinKind.LeftOuter
    ),
    ExpandSites = Table.ExpandTableColumn(
        JoinSites, "Sites", {"site_name"}, {"site_name"}
    ),
    TypedCols = Table.TransformColumnTypes(ExpandSites, {
        {"ph",             type number},
        {"turbidity_ntu",  type number},
        {"salinity",       type number},
        {"tds_mg_l",       type number},
        {"conductivity",   type number},
        {"chloride_mg_l",  type number},
        {"nitrite_mg_l",   type number},
        {"hardness_mg_l",  type number},
        {"sample_no",      Int64.Type},
        {"site_name",      type text}
    }),
    AddWHO_pH = Table.AddColumn(TypedCols, "pH_WHO_Status",
        each if [ph] >= 6.5 and [ph] <= 8.5 then "PASS" else "FAIL",
        type text
    ),
    AddWHO_Turbidity = Table.AddColumn(AddWHO_pH, "Turbidity_WHO_Status",
        each if [turbidity_ntu] <= 5 then "PASS" else "FAIL",
        type text
    ),
    AddWHO_TDS = Table.AddColumn(AddWHO_Turbidity, "TDS_WHO_Status",
        each if [tds_mg_l] = null or [tds_mg_l] <= 1000 then "PASS" else "FAIL",
        type text
    ),
    AddWHO_Nitrite = Table.AddColumn(AddWHO_TDS, "Nitrite_WHO_Status",
        each if [nitrite_mg_l] = null or [nitrite_mg_l] <= 3.0 then "PASS" else "REVIEW",
        type text
    ),
    AddHardnessClass = Table.AddColumn(AddWHO_Nitrite, "Hardness_Class",
        each if [hardness_mg_l] < 75 then "Soft"
             else if [hardness_mg_l] < 150 then "Moderately Hard"
             else if [hardness_mg_l] < 300 then "Hard"
             else "Very Hard",
        type text
    )
in
    AddHardnessClass


// ── TABLE 2: HeavyMetals ─────────────────────────────────────

let
    Source = Sql.Database("YOUR_SERVER", "YOUR_DB"),
    heavy_metals = Source{[Schema="public",Item="heavy_metals"]}[Data],
    JoinSites = Table.NestedJoin(
        heavy_metals, {"site_id"},
        Source{[Schema="public",Item="sites"]}[Data], {"site_id"},
        "Sites", JoinKind.LeftOuter
    ),
    ExpandSites = Table.ExpandTableColumn(
        JoinSites, "Sites", {"site_name"}, {"site_name"}
    ),
    TypedCols = Table.TransformColumnTypes(ExpandSites, {
        {"co_mg_l", type number}, {"fe_mg_l", type number},
        {"cu_mg_l", type number}, {"cd_mg_l", type number},
        {"cr_mg_l", type number}, {"ni_mg_l", type number},
        {"pb_mg_l", type number}, {"mn_mg_l", type number},
        {"zn_mg_l", type number}, {"mg_mg_l", type number},
        {"ca_mg_l", type number}, {"na_mg_l", type number},
        {"k_mg_l",  type number}, {"site_name", type text}
    }),
    AddLeadStatus = Table.AddColumn(TypedCols, "Pb_WHO_Status",
        each if [pb_mg_l] <= 0.01 then "PASS" else "EXCEED", type text
    ),
    AddCdStatus = Table.AddColumn(AddLeadStatus, "Cd_WHO_Status",
        each if [cd_mg_l] <= 0.003 then "PASS" else "EXCEED", type text
    ),
    AddFeStatus = Table.AddColumn(AddCdStatus, "Fe_WHO_Status",
        each if [fe_mg_l] <= 0.3 then "PASS" else "EXCEED", type text
    ),
    AddCrStatus = Table.AddColumn(AddFeStatus, "Cr_WHO_Status",
        each if [cr_mg_l] = null or [cr_mg_l] <= 0.05 then "PASS" else "EXCEED", type text
    )
in
    AddCrStatus


// ── TABLE 3: WHOGuidelines (static reference) ────────────────

let
    Source = #table(
        {"Parameter", "WHO_Min", "WHO_Max", "Unit", "Note"},
        {
            {"pH",            6.5,   8.5,    "—",     "Drinking water range"},
            {"Turbidity",     null,  5.0,    "NTU",   "Upper limit"},
            {"TDS",           null,  1000.0, "mg/L",  "WHO upper limit"},
            {"Chloride",      null,  250.0,  "mg/L",  "Taste threshold"},
            {"Nitrate",       null,  50.0,   "mg/L",  "Health-based"},
            {"Nitrite",       null,  3.0,    "mg/L",  "Short-term limit"},
            {"Hardness",      null,  500.0,  "mg/L",  "No health guideline"},
            {"Iron (Fe)",     null,  0.3,    "mg/L",  "Aesthetic guideline"},
            {"Lead (Pb)",     null,  0.01,   "mg/L",  "Health-based"},
            {"Cadmium (Cd)",  null,  0.003,  "mg/L",  "Health-based"},
            {"Chromium (Cr)", null,  0.05,   "mg/L",  "Health-based"},
            {"Manganese (Mn)",null,  0.08,   "mg/L",  "Health-based"},
            {"Copper (Cu)",   null,  2.0,    "mg/L",  "Health-based"}
        }
    )
in
    Source


// ─────────────────────────────────────────────────────────────
// PART B: DAX MEASURES
// Modeling tab → New Measure → paste each block
// ─────────────────────────────────────────────────────────────

// ── SECTION B1: Core Aggregations ────────────────────────────

// Average pH
Avg pH = 
AVERAGE(PhysicalChemical[ph])

// pH Standard Deviation
SD pH = 
STDEV.P(PhysicalChemical[ph])

// Average Turbidity
Avg Turbidity = 
AVERAGE(PhysicalChemical[turbidity_ntu])

// Average TDS
Avg TDS = 
AVERAGE(PhysicalChemical[tds_mg_l])

// Average Conductivity
Avg Conductivity = 
AVERAGE(PhysicalChemical[conductivity])

// Average Hardness
Avg Hardness = 
AVERAGE(PhysicalChemical[hardness_mg_l])

// Average Chloride
Avg Chloride = 
AVERAGE(PhysicalChemical[chloride_mg_l])

// Average Nitrite
Avg Nitrite = 
AVERAGE(PhysicalChemical[nitrite_mg_l])

// Total Samples
Total Samples = 
COUNTROWS(PhysicalChemical)


// ── SECTION B2: WHO Compliance Measures ──────────────────────

// pH PASS rate (%)
pH WHO Pass % = 
DIVIDE(
    COUNTROWS(
        FILTER(PhysicalChemical,
            PhysicalChemical[ph] >= 6.5 &&
            PhysicalChemical[ph] <= 8.5
        )
    ),
    COUNTROWS(PhysicalChemical),
    0
) * 100

// Turbidity PASS rate (%)
Turbidity WHO Pass % = 
DIVIDE(
    COUNTROWS(
        FILTER(PhysicalChemical,
            PhysicalChemical[turbidity_ntu] <= 5
        )
    ),
    COUNTROWS(PhysicalChemical),
    0
) * 100

// Nitrite REVIEW count (samples above WHO 3.0 mg/L)
Nitrite WHO Exceedance Count = 
CALCULATE(
    COUNTROWS(PhysicalChemical),
    FILTER(
        PhysicalChemical,
        NOT ISBLANK(PhysicalChemical[nitrite_mg_l]) &&
        PhysicalChemical[nitrite_mg_l] > 3.0
    )
)

// TDS Compliance %
TDS WHO Pass % = 
DIVIDE(
    COUNTROWS(
        FILTER(PhysicalChemical,
            ISBLANK(PhysicalChemical[tds_mg_l]) ||
            PhysicalChemical[tds_mg_l] <= 1000
        )
    ),
    COUNTROWS(PhysicalChemical),
    0
) * 100

// Overall WHO compliance score (physical/chem params)
Overall Compliance Score = 
VAR pH_pass    = [pH WHO Pass %]
VAR Turb_pass  = [Turbidity WHO Pass %]
VAR TDS_pass   = [TDS WHO Pass %]
RETURN
DIVIDE(pH_pass + Turb_pass + TDS_pass, 3, 0)


// ── SECTION B3: Heavy Metals DAX ─────────────────────────────

// Average Lead
Avg Lead (Pb) = 
AVERAGE(HeavyMetals[pb_mg_l])

// Lead exceedance % vs WHO 0.01 mg/L
Lead WHO Exceedance % = 
DIVIDE(
    COUNTROWS(FILTER(HeavyMetals, HeavyMetals[pb_mg_l] > 0.01)),
    COUNTROWS(HeavyMetals),
    0
) * 100

// Average Iron
Avg Iron (Fe) = 
AVERAGE(HeavyMetals[fe_mg_l])

// Iron exceedance % vs WHO 0.3 mg/L
Iron WHO Exceedance % = 
DIVIDE(
    COUNTROWS(FILTER(HeavyMetals, HeavyMetals[fe_mg_l] > 0.3)),
    COUNTROWS(HeavyMetals),
    0
) * 100

// Average Cadmium
Avg Cadmium (Cd) = 
AVERAGE(HeavyMetals[cd_mg_l])

// Cadmium exceedance %
Cadmium WHO Exceedance % = 
DIVIDE(
    COUNTROWS(FILTER(HeavyMetals, HeavyMetals[cd_mg_l] > 0.003)),
    COUNTROWS(HeavyMetals),
    0
) * 100

// Average Calcium (Ca)
Avg Calcium = 
AVERAGE(HeavyMetals[ca_mg_l])

// Ca + Mg (hardness proxy)
Ca Mg Sum = 
AVERAGE(HeavyMetals[ca_mg_l]) + AVERAGE(HeavyMetals[mg_mg_l])


// ── SECTION B4: Ranked & Comparative Measures ────────────────

// Site with highest avg pH
Top Site by pH = 
CALCULATE(
    VALUES(PhysicalChemical[site_name]),
    TOPN(1,
        SUMMARIZE(PhysicalChemical,
            PhysicalChemical[site_name],
            "AvgpH", AVERAGE(PhysicalChemical[ph])
        ),
        [AvgpH], DESC
    )
)

// Max turbidity recorded (to flag outlier)
Max Turbidity = 
MAX(PhysicalChemical[turbidity_ntu])

// Count turbidity outliers (>2 NTU)
Turbidity Outliers = 
COUNTROWS(
    FILTER(PhysicalChemical, PhysicalChemical[turbidity_ntu] > 2.0)
)

// Hardness classification breakdown (use with slicer)
Hard Sample Count = 
SWITCH(
    TRUE(),
    SELECTEDVALUE(PhysicalChemical[Hardness_Class]) = "Soft",
        CALCULATE(COUNTROWS(PhysicalChemical), PhysicalChemical[Hardness_Class] = "Soft"),
    SELECTEDVALUE(PhysicalChemical[Hardness_Class]) = "Moderately Hard",
        CALCULATE(COUNTROWS(PhysicalChemical), PhysicalChemical[Hardness_Class] = "Moderately Hard"),
    SELECTEDVALUE(PhysicalChemical[Hardness_Class]) = "Hard",
        CALCULATE(COUNTROWS(PhysicalChemical), PhysicalChemical[Hardness_Class] = "Hard"),
    SELECTEDVALUE(PhysicalChemical[Hardness_Class]) = "Very Hard",
        CALCULATE(COUNTROWS(PhysicalChemical), PhysicalChemical[Hardness_Class] = "Very Hard"),
    COUNTROWS(PhysicalChemical)
)


// ── SECTION B5: Tooltip / Info Measures ──────────────────────

// Dynamic site summary text (use in card visual)
Site Summary Label = 
VAR site = SELECTEDVALUE(PhysicalChemical[site_name], "All Sites")
VAR n    = [Total Samples]
VAR avgpH = FORMAT([Avg pH], "0.00")
RETURN
"Site: " & site & " | Samples: " & n & " | Avg pH: " & avgpH

// WHO limit reference for pH (use with gauge)
WHO pH Max = 8.5
WHO pH Min = 6.5
WHO Turbidity Max = 5.0
WHO TDS Max = 1000
WHO Nitrite Max = 3.0
WHO Hardness Max = 500


// ─────────────────────────────────────────────────────────────
// PART C: RECOMMENDED POWER BI VISUALS LAYOUT
// ─────────────────────────────────────────────────────────────
//
//  PAGE 1 — OVERVIEW
//  ┌──────────┬──────────┬──────────┬──────────┐
//  │ Card:    │ Card:    │ Card:    │ Card:    │
//  │ Avg pH   │ Avg TDS  │ Total n  │ Compliance│
//  └──────────┴──────────┴──────────┴──────────┘
//  ┌─────────────────────┬────────────────────┐
//  │ Clustered Bar:      │ Donut:             │
//  │ Site × pH/Turbidity │ Hardness Class %   │
//  └─────────────────────┴────────────────────┘
//  ┌─────────────────────────────────────────┐
//  │ Matrix Table: Site × All Params (means) │
//  └─────────────────────────────────────────┘
//
//  PAGE 2 — WHO COMPLIANCE
//  ┌──────────────────────────────────────┐
//  │ Stacked Bar: Pass/Fail per Parameter │
//  └──────────────────────────────────────┘
//  ┌──────────────────────────────────────┐
//  │ Table: WHO Compliance Detail         │
//  │ Columns: Site, Sample, pH✓, Turb✓   │
//  └──────────────────────────────────────┘
//
//  PAGE 3 — HEAVY METALS
//  ┌──────────────────┬───────────────────┐
//  │ Line Chart:      │ Bar: WHO Exceed % │
//  │ Pb/Fe/Cd/Co      │ per metal         │
//  │ by Sample No.    │                   │
//  └──────────────────┴───────────────────┘
//  ┌──────────────────────────────────────┐
//  │ Scatter: Ca vs Mg (coloured by site) │
//  └──────────────────────────────────────┘
//
//  PAGE 4 — MAP
//  ┌──────────────────────────────────────┐
//  │ ArcGIS / Bing Map:                   │
//  │ Latitude + Longitude fields          │
//  │ Bubble size = conductivity           │
//  │ Colour = site_name                   │
//  └──────────────────────────────────────┘
//
// ─────────────────────────────────────────────────────────────
