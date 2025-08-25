# OMSNA5300 Final Challenge

This repository contains data and analysis for a retail employment study using IPUMS CPS data from Jan 2020 to Apr 2022.

## Data File
- **File**: `data/cps_00002.dat.gz`
- **Source**: IPUMS Current Population Survey (CPS)
- **Size**: ~89.3 MB (compressed)
- **Access**: Stored using Git LFS; download with `git lfs pull` after cloning.

## Data Elements
- **EMP** (Employment Status): Whether employed, unemployed, or not in labor force.
- **IND** (Industry): Current industry (e.g., retail).
- **AGE** (Age): Age of individuals.
- **SEX** (Sex): Gender of individuals.
- **RACE** (Race): Racial category.
- **HISPAN** (Hispanic Origin): Hispanic ethnicity.
- **EDUC** (Education): Education level.
- **COVIDTELEW** (COVID Telework): Telework due to COVID-19.
- **COVIDUNAW** (COVID Unable to Work): Unable to work due to COVID-19.
- **WTSUPP** (Weight): Survey weight for Basic Monthly samples.
- **STATEFIP** (State): State identifier for regional analysis.
- **LABFORCE** (Labor Force): In labor force or not.
- **WRKLYR** (Worked Last Year): Worked in the past year.
- **UHRSWORKT** (Hours Worked): Usual hours worked per week.
- **CLASSWKR** (Class of Worker): Employment class (e.g., wage/salary).
- **OCC** (Occupation): Occupation details.
- **INCTOT** (Income): Total personal income (from ASEC).
- **MARST** (Marital Status): Marital status.
- **FAMSIZE** (Family Size): Household size.

## Notes
- Data covers Jan 2020 to Apr 2022, focusing on retail employment during COVID-19.
- See IPUMS CPS site for full variable details.

The report analyzes IPUMS CPS data (Jan 2020-Apr 2022) for retail employment during COVID-19.

## Data File
- **File**: `data/cps_00002.dat.gz`
- **Size**: ~89.3 MB
- **Access**: Use Git LFS (`git lfs pull` after cloning)

## Key Findings
- **Employment Rates**: Comprehensive measure (84%) far exceeds EMP-only (0.9%), showing a more realistic view.
- **Trade/Retail Trends**: EMP rate rose from 1.89% (Pre-COVID) to 13.0% (Recovery), a significant increase.
- **Industry Recovery**: All IND groups (Trade, Services, Manufacturing, Other) show clear COVID recovery patterns.
- **Age Impact**: Age differences are statistically significant but small (50+ vs. younger, p=0.59).
- **Wage Stability**: Avg wage (~$23.4K) stable across COVID periods for all age groups.

## Analysis Details
- **Data**: 3.58M rows, 50 columns (EMP, IND, AGE, SEX, etc.).
- **Methods**: T-tests, F-tests, regressions, ANOVA, visualizations.
- **Focus**: Trade/Retail (62,260 workers) vs. other IND, age group trends.

## How to Use
1. Clone: `git clone https://github.com/dcgaudin/OMSNA5300_Final_Challenge.git`
2. Install LFS: `git lfs install`
3. Pull data: `git lfs pull`
4. Load in R: `library(ipumsr); data <- read_ipums_micro("data/cps_00002.ddi")`
