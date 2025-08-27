# COVID-19 Retail Employment Analysis

## Overview
This project analyzes the impact of COVID-19 on retail employment using IPUMS Current Population Survey (CPS) data from 2020-2022. The analysis demonstrates that retail workers experienced disproportionate employment losses compared to other industries, with statistically significant evidence from comprehensive regression modeling and validation testing.

## Key Findings
- **Retail employment declined 3.7 percentage points vs 2.2pp for non-retail workers**
- **Difference-in-differences effect: -1.57pp (p < 0.001)**
- **All findings validated through F-tests, t-tests, ANOVA, and DiD analysis**
- **Sample: 1.44 million observations with proper survey weights**

## Files Structure

### Data Files
- `data/` - Folder containing IPUMS CPS microdata files
- `IPUMS Codebook` - Official IPUMS codebook with variable positions

### Analysis Scripts
- `Covid_Retail_analysis` - Main analysis script (R file)
- `Stat_validation_tests` - Statistical testing and validation (R file)
- `Covid_retail_plots` - Visualization code (R file)
- `data_validation` - Data quality checks (R file)

### Reports
- `complete_covid_analysis` - Complete Quarto analysis document
- `LFS download instructions` - Data acquisition guide

### Development Files
- `previous attempts/` - Folder with earlier analysis versions
- `README.md` - This file

## Quick Start Guide

### Prerequisites
- **R 4.0+** with RStudio recommended
- **Required R packages**:
  ```r
  install.packages(c("tidyverse", "fixest", "modelsummary", "lubridate", 
                     "broom", "knitr", "kableExtra", "ggplot2", "scales", 
                     "viridis", "quarto"))
  ```

### Step 1: Data Setup
1. Ensure the `data/` folder contains your IPUMS CPS data files
2. Verify the `IPUMS Codebook` file is accessible
3. Check that all R files are in the main project directory

### Step 2: Run Analysis
**Option A: Complete Analysis (Recommended)**
```r
# Open complete_covid_analysis.qmd in RStudio
# Click "Render" button to generate full HTML report
```

**Option B: Individual Scripts**
```r
# 1. Run data validation checks
source("data_validation.R")

# 2. Load data and run main analysis
source("Covid_Retail_analysis.R")

# 3. Generate visualizations
source("Covid_retail_plots.R")

# 4. Run statistical validation tests
source("Stat_validation_tests.R")
```

### Step 3: View Results
- **HTML Report**: Complete analysis with integrated results
- **Individual Outputs**: Plots and statistical summaries from each script
- **Data Validation**: Quality checks and data structure verification

## Data Source Details

### IPUMS CPS Variables Used
- **YEAR, MONTH**: Time identifiers
- **EMPSTAT**: Employment status (employed, unemployed, NILF)
- **IND1990**: Industry classification (retail = codes 580-691)
- **COVIDTELEW**: COVID remote work indicator
- **COVIDUNAW**: COVID unable to work indicator
- **Demographics**: SEX, AGE, RACE, EDUC
- **WTFINL**: Final survey weights for national representativeness

### Sample Characteristics
- **Time Period**: January 2020 - December 2022
- **Population**: Working-age adults (16+)
- **Sample Size**: 1,443,532 observations
- **Geographic Coverage**: United States (nationally representative)

## Methodology

### Statistical Models
1. **Employment Probability Model**: Logistic regression with retail×post-COVID interaction
2. **COVID Work Impact Model**: Analysis of remote work and work disruption patterns  
3. **Hours Worked Model**: Linear regression for employed workers

### Key Features
- **Survey weights**: All estimates use CPS final weights (WTFINL)
- **Robust standard errors**: Heteroskedasticity-robust variance estimation
- **Fixed-width data**: Precise column positions from official IPUMS codebook
- **COVID period definition**: Pre-COVID (Jan 2020-Mar 2020), Post-COVID (Apr 2020+)

### Statistical Validation
- F-statistics for overall model significance
- T-tests for individual coefficient significance
- ANOVA for group differences
- Difference-in-differences analysis
- Welch's t-tests for unequal variances
- Joint hypothesis testing for demographic effects

## Results Summary

### Employment Effects
- **Post-COVID employment decline**: 2.19pp overall
- **Retail interaction effect**: Additional 1.53pp decline for retail workers
- **Total retail impact**: 3.72pp employment decline vs 2.19pp non-retail

### COVID Work Disruption
- **Remote work capability**: 5.6% retail vs 19.4% non-retail
- **Unable to work**: Higher rates for retail during peak COVID period
- **Gender differences**: Women more affected by COVID work disruptions

### Recovery Patterns
- **Slower retail recovery**: Persistent employment gaps through 2022
- **Hours worked**: Retail workers average 2.6 fewer hours per week
- **Demographic variations**: Significant effects across age, race, education groups

## Policy Implications

1. **Industry-Specific Support**: Evidence supports targeted retail employment programs
2. **Work Flexibility**: Need for alternative flexibility measures in retail sector
3. **Demographic Targeting**: Focus on women and specific age groups most affected
4. **Recovery Monitoring**: Continued tracking of retail employment recovery

## Technical Notes

### Data Quality Assurance
- Official IPUMS codebook positions ensure accurate variable extraction
- Comprehensive data validation and cleaning procedures
- Proper handling of survey weights and missing data
- Robust statistical methods account for complex survey design

### Reproducibility
- All code documented with clear comments
- Modular script structure for easy modification
- Version-controlled analysis with consistent results
- Comprehensive error checking and validation

## Troubleshooting

### Common Issues
1. **File not found errors**: Ensure data files are in correct directory
2. **Memory issues**: Large dataset may require 8GB+ RAM
3. **Package errors**: Install all required packages before running
4. **Rendering issues**: Use RStudio for best Quarto compatibility

### Data Access
- **IPUMS Registration**: Free account required at ipums.org
- **Variable Selection**: Use provided extract definition for consistency
- **File Format**: Fixed-width .dat format with codebook positions

## Contact & Citation

### Analysis Information
- **Created**: 2024 COVID Retail Employment Study
- **Data Source**: IPUMS CPS 2020-2022
- **Methodology**: Weighted regression with robust standard errors
- **Validation**: Comprehensive statistical testing at α = 0.05

### Citation
```
COVID-19 Retail Employment Analysis (2024). 
Analysis of IPUMS Current Population Survey data, 2020-2022.
Differences study of retail vs non-retail employment impacts.
```

---

**Note**: This analysis provides statistical evidence of COVID-19's disproportionate impact on retail employment. Findings are statistically significant and validated through testing procedures.

