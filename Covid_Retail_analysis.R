# COVID Retail Employment Analysis - IPUMS CPS Data
# Using Official IPUMS Codebook Column Positions

library(tidyverse)
library(fixest)
library(modelsummary)
library(lubridate)

data_path <- "C:/Users/dgaudin/OneDrive - airmethods.com/Desktop/Seattle U/5300 econometrics/Final Challenge/data_local/cps_00003.dat.gz"

cat("=== IPUMS CPS COVID RETAIL EMPLOYMENT ANALYSIS ===\n")

# Define column positions from IPUMS codebook
ipums_positions <- fwf_positions(
  start = c(1,   10,  116, 118, 119, 130, 137, 140, 146, 149, 152, 157, 52,  187, 189, 160, 170, 179),
  end =   c(4,   11,  117, 118, 121, 131, 139, 143, 148, 151, 153, 159, 65,  188, 190, 169, 178, 186),
  col_names = c("YEAR", "MONTH", "AGE", "SEX", "RACE", "EMPSTAT", "IND1990", "IND", 
                "UHRSWORKT", "AHRSWORKT", "WKSTAT", "EDUC", "WTFINL", 
                "COVIDTELEW", "COVIDUNAW", "FTOTVAL", "INCTOT", "INCWAGE")
)

# Load and clean data
cat("Loading IPUMS CPS data...\n")
cps_data <- read_fwf(gzfile(data_path), ipums_positions, show_col_types = FALSE) %>%
  mutate(across(everything(), as.numeric)) %>%
  filter(
    YEAR >= 2020 & YEAR <= 2022,
    MONTH >= 1 & MONTH <= 12,
    AGE >= 16,  # Working age population
    SEX %in% c(1, 2),
    EMPSTAT %in% c(10, 12, 20, 21, 22),  # Employed or unemployed (in labor force)
    !is.na(WTFINL), WTFINL > 0
  )

cat("Sample size after filtering:", nrow(cps_data), "\n")

# Create analysis variables
analysis_data <- cps_data %>%
  mutate(
    # Time variables
    date = as.Date(paste(YEAR, MONTH, "01", sep = "-")),
    post_covid = ifelse(date >= as.Date("2020-04-01"), 1, 0),
    covid_period = case_when(
      date < as.Date("2020-04-01") ~ "Pre-COVID",
      date >= as.Date("2020-04-01") & date < as.Date("2021-01-01") ~ "COVID Peak",
      date >= as.Date("2021-01-01") ~ "COVID Recovery",
      TRUE ~ "Other"
    ),
    
    # Demographics
    female = ifelse(SEX == 2, 1, 0),
    age_group = case_when(
      AGE >= 16 & AGE <= 24 ~ "16-24",
      AGE >= 25 & AGE <= 34 ~ "25-34", 
      AGE >= 35 & AGE <= 44 ~ "35-44",
      AGE >= 45 & AGE <= 54 ~ "45-54",
      AGE >= 55 & AGE <= 64 ~ "55-64",
      AGE >= 65 ~ "65+",
      TRUE ~ "Other"
    ),
    race_group = case_when(
      RACE == 100 ~ "White",
      RACE == 200 ~ "Black", 
      RACE >= 651 & RACE <= 652 ~ "Asian/PI",
      RACE >= 801 ~ "Multiracial",
      TRUE ~ "Other"
    ),
    education = case_when(
      EDUC <= 071 ~ "HS or Less",
      EDUC >= 072 & EDUC <= 092 ~ "Some College/Associates",
      EDUC >= 111 & EDUC <= 111 ~ "Bachelor's",
      EDUC >= 123 ~ "Graduate Degree",
      TRUE ~ "Other"
    ),
    
    # Employment variables
    employed = ifelse(EMPSTAT %in% c(10, 12), 1, 0),
    unemployed = ifelse(EMPSTAT %in% c(20, 21, 22), 1, 0),
    full_time = ifelse(WKSTAT %in% c(10, 11), 1, 0),
    part_time_economic = ifelse(WKSTAT %in% c(20, 21, 22), 1, 0),
    part_time_noneconomic = ifelse(WKSTAT %in% c(40, 41), 1, 0),
    
    # Industry classification (using IND1990 for consistency)
    retail_industry = ifelse(IND1990 >= 580 & IND1990 <= 691, 1, 0),
    industry_group = case_when(
      IND1990 >= 580 & IND1990 <= 691 ~ "Retail Trade",
      IND1990 >= 641 & IND1990 <= 641 ~ "Food Service", # Eating and drinking places
      IND1990 >= 812 & IND1990 <= 893 ~ "Professional Services",
      IND1990 >= 100 & IND1990 <= 392 ~ "Manufacturing",
      IND1990 >= 060 & IND1990 <= 060 ~ "Construction",
      IND1990 >= 831 & IND1990 <= 840 ~ "Healthcare",
      TRUE ~ "Other Industries"
    ),
    
    # COVID-specific work impacts
    covid_remote = ifelse(COVIDTELEW == 2, 1, 0),  # Worked remotely due to COVID
    covid_unable = ifelse(COVIDUNAW == 2, 1, 0),   # Unable to work due to COVID
    covid_work_impact = ifelse(covid_remote == 1 | covid_unable == 1, 1, 0),
    
    # Hours worked
    usual_hours = ifelse(UHRSWORKT <= 996, UHRSWORKT, NA),
    actual_hours = ifelse(AHRSWORKT <= 996, AHRSWORKT, NA),
    hours_reduction = ifelse(!is.na(usual_hours) & !is.na(actual_hours), 
                             usual_hours - actual_hours, NA),
    
    # Income (available for ASEC samples only)
    has_wage_income = ifelse(!is.na(INCWAGE) & INCWAGE > 0, 1, 0),
    log_wage_income = ifelse(INCWAGE > 0, log(INCWAGE), NA)
  )

# Data quality check
cat("\n=== DATA QUALITY CHECK ===\n")
cat("Years:", paste(sort(unique(analysis_data$YEAR)), collapse = ", "), "\n")
cat("Months:", paste(sort(unique(analysis_data$MONTH)), collapse = ", "), "\n")
cat("Gender distribution:", round(prop.table(table(analysis_data$female)) * 100, 1), "\n")
cat("Employment status:", round(prop.table(table(analysis_data$employed)) * 100, 1), "\n")
cat("Retail workers:", sum(analysis_data$retail_industry), 
    "(", round(mean(analysis_data$retail_industry) * 100, 1), "%)\n")

# Summary statistics by industry and COVID period
cat("\n=== EMPLOYMENT SUMMARY BY INDUSTRY AND COVID PERIOD ===\n")
employment_summary <- analysis_data %>%
  group_by(industry_group, covid_period) %>%
  summarise(
    n_workers = n(),
    employment_rate = weighted.mean(employed, WTFINL, na.rm = TRUE) * 100,
    unemployment_rate = weighted.mean(unemployed, WTFINL, na.rm = TRUE) * 100,
    pct_female = weighted.mean(female, WTFINL, na.rm = TRUE) * 100,
    pct_fulltime = weighted.mean(full_time, WTFINL, na.rm = TRUE) * 100,
    covid_remote_pct = weighted.mean(covid_remote, WTFINL, na.rm = TRUE) * 100,
    covid_unable_pct = weighted.mean(covid_unable, WTFINL, na.rm = TRUE) * 100,
    avg_usual_hours = weighted.mean(usual_hours, WTFINL, na.rm = TRUE),
    avg_actual_hours = weighted.mean(actual_hours, WTFINL, na.rm = TRUE),
    .groups = "drop"
  )

print(employment_summary)

# Focus on retail vs other industries
cat("\n=== RETAIL VS NON-RETAIL COMPARISON ===\n")
retail_comparison <- analysis_data %>%
  group_by(retail_industry, post_covid) %>%
  summarise(
    n_workers = n(),
    employment_rate = weighted.mean(employed, WTFINL, na.rm = TRUE) * 100,
    unemployment_rate = weighted.mean(unemployed, WTFINL, na.rm = TRUE) * 100,
    covid_impact_rate = weighted.mean(covid_work_impact, WTFINL, na.rm = TRUE) * 100,
    pct_female = weighted.mean(female, WTFINL, na.rm = TRUE) * 100,
    avg_hours = weighted.mean(actual_hours, WTFINL, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  mutate(
    industry_type = ifelse(retail_industry == 1, "Retail", "Non-Retail"),
    period = ifelse(post_covid == 1, "Post-COVID", "Pre-COVID")
  )

print(retail_comparison)

# Calculate COVID impact
covid_impact_analysis <- retail_comparison %>%
  select(industry_type, period, employment_rate, unemployment_rate, covid_impact_rate) %>%
  pivot_longer(cols = c(employment_rate, unemployment_rate, covid_impact_rate), 
               names_to = "metric", values_to = "rate") %>%
  pivot_wider(names_from = period, values_from = rate) %>%
  mutate(
    covid_change = `Post-COVID` - `Pre-COVID`,
    pct_change = (covid_change / `Pre-COVID`) * 100
  )

cat("\n=== COVID IMPACT ANALYSIS ===\n")
print(covid_impact_analysis)

# Regression Analysis
cat("\n=== REGRESSION ANALYSIS ===\n")

# Model 1: Employment probability
model1 <- feols(
  employed ~ retail_industry * post_covid + female + age_group + race_group + education,
  data = analysis_data,
  weights = ~WTFINL,
  vcov = "hetero"
)

# Model 2: COVID work impact
covid_data <- analysis_data %>% filter(!is.na(covid_work_impact))
if(nrow(covid_data) > 1000) {
  model2 <- feols(
    covid_work_impact ~ retail_industry + female + age_group + race_group + education,
    data = covid_data,
    weights = ~WTFINL,
    vcov = "hetero"
  )
} else {
  model2 <- NULL
  cat("Insufficient COVID impact data for regression\n")
}

# Model 3: Hours worked (for employed workers)
hours_data <- analysis_data %>% filter(employed == 1, !is.na(actual_hours))
if(nrow(hours_data) > 1000) {
  model3 <- feols(
    actual_hours ~ retail_industry * post_covid + female + age_group + race_group + education,
    data = hours_data,
    weights = ~WTFINL,
    vcov = "hetero"
  )
} else {
  model3 <- NULL
  cat("Insufficient hours data for regression\n")
}

# Display regression results
models_list <- list("Employment" = model1)
if(!is.null(model2)) models_list[["COVID Impact"]] <- model2
if(!is.null(model3)) models_list[["Hours Worked"]] <- model3

modelsummary(
  models_list,
  title = "COVID Impact on Retail Employment (IPUMS CPS Analysis)",
  notes = c(
    "Standard errors are heteroskedasticity-robust.",
    "All models use CPS final weights (WTFINL).",
    "Sample: 2020-2022 CPS data, working-age population (16+)."
  ),
  stars = TRUE
)

# Individual model summaries
cat("\n=== MODEL 1: EMPLOYMENT PROBABILITY ===\n")
summary(model1)

if(!is.null(model2)) {
  cat("\n=== MODEL 2: COVID WORK IMPACT ===\n")
  summary(model2)
}

if(!is.null(model3)) {
  cat("\n=== MODEL 3: HOURS WORKED ===\n")
  summary(model3)
}

# Key findings
cat("\n=== KEY FINDINGS ===\n")
retail_pre <- retail_comparison %>% filter(industry_type == "Retail", period == "Pre-COVID")
retail_post <- retail_comparison %>% filter(industry_type == "Retail", period == "Post-COVID")
nonretail_pre <- retail_comparison %>% filter(industry_type == "Non-Retail", period == "Pre-COVID")
nonretail_post <- retail_comparison %>% filter(industry_type == "Non-Retail", period == "Post-COVID")

if(nrow(retail_pre) > 0 && nrow(retail_post) > 0) {
  retail_emp_change <- retail_post$employment_rate - retail_pre$employment_rate
  retail_unemp_change <- retail_post$unemployment_rate - retail_pre$unemployment_rate
  
  cat("1. Retail employment rate change:", round(retail_emp_change, 1), "percentage points\n")
  cat("2. Retail unemployment rate change:", round(retail_unemp_change, 1), "percentage points\n")
}

if(nrow(nonretail_pre) > 0 && nrow(nonretail_post) > 0) {
  nonretail_emp_change <- nonretail_post$employment_rate - nonretail_pre$employment_rate
  nonretail_unemp_change <- nonretail_post$unemployment_rate - nonretail_pre$unemployment_rate
  
  cat("3. Non-retail employment rate change:", round(nonretail_emp_change, 1), "percentage points\n")
  cat("4. Non-retail unemployment rate change:", round(nonretail_unemp_change, 1), "percentage points\n")
}

# COVID-specific impacts
covid_summary <- analysis_data %>%
  filter(!is.na(covid_work_impact)) %>%
  group_by(retail_industry) %>%
  summarise(
    covid_remote_pct = weighted.mean(covid_remote, WTFINL, na.rm = TRUE) * 100,
    covid_unable_pct = weighted.mean(covid_unable, WTFINL, na.rm = TRUE) * 100,
    total_covid_impact = weighted.mean(covid_work_impact, WTFINL, na.rm = TRUE) * 100,
    .groups = "drop"
  ) %>%
  mutate(industry_type = ifelse(retail_industry == 1, "Retail", "Non-Retail"))

if(nrow(covid_summary) > 0) {
  cat("\n=== COVID WORK IMPACT BY INDUSTRY ===\n")
  print(covid_summary)
}

cat("\n=== ANALYSIS COMPLETE ===\n")
cat("Data source: IPUMS CPS 2020-2022 with official codebook positions\n")
cat("Key variables: Employment, Industry, COVID work impacts, Demographics\n")
cat("Analysis covers three research questions with proper survey weights\n")
