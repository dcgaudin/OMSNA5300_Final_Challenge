# COVID RETAIL EMPLOYMENT ANALYSIS - FIXED VISUALIZATION CODE
# ===========================================================

library(tidyverse)
library(ggplot2)
library(scales)
library(patchwork)
library(viridis)

# Load analysis data first
source("C:/Users/dgaudin/CascadeProjects/covid_retail_analysis/ipums_covid_analysis.R")

# VISUALIZATION 1: Employment Rate Trends (Model 1 - Employment Regression)
# =========================================================================
employment_trends <- analysis_data %>%
  group_by(date, retail_industry) %>%
  summarise(
    employment_rate = weighted.mean(employed, WTFINL, na.rm = TRUE) * 100,
    unemployment_rate = weighted.mean(unemployed, WTFINL, na.rm = TRUE) * 100,
    .groups = "drop"
  ) %>%
  mutate(
    industry_type = ifelse(retail_industry == 1, "Retail", "Non-Retail")
  )

plot1_employment <- ggplot(employment_trends, aes(x = date, y = employment_rate, 
                                                  color = industry_type, linetype = industry_type)) +
  geom_line(linewidth = 1.2) +
  geom_vline(xintercept = as.Date("2020-04-01"), linetype = "dashed", alpha = 0.7, color = "red") +
  annotate("text", x = as.Date("2020-04-01"), y = 98, label = "COVID Start", 
           hjust = -0.1, color = "red", size = 3) +
  scale_x_date(date_labels = "%b %Y", date_breaks = "3 months") +
  scale_y_continuous(limits = c(80, 100), labels = percent_format(scale = 1)) +
  scale_color_manual(values = c("Retail" = "#d62728", "Non-Retail" = "#1f77b4")) +
  labs(
    title = "Employment Rate Trends: Retail vs Non-Retail Industries",
    subtitle = "Retail workers experienced steeper employment declines during COVID-19",
    x = "Date",
    y = "Employment Rate (%)",
    color = "Industry",
    linetype = "Industry",
    caption = "Source: IPUMS CPS 2020-2022, weighted estimates"
  ) +
  theme_minimal() +
  theme(
    axis.text.x = element_text(angle = 45, hjust = 1),
    legend.position = "bottom",
    plot.title = element_text(size = 14, face = "bold"),
    plot.subtitle = element_text(size = 11, color = "gray40")
  )

# VISUALIZATION 2: COVID Work Impact by Industry (Model 2 - COVID Impact Regression)
# ==================================================================================
covid_impact_data <- analysis_data %>%
  filter(!is.na(covid_work_impact)) %>%
  group_by(retail_industry) %>%
  summarise(
    remote_work = weighted.mean(covid_remote, WTFINL, na.rm = TRUE) * 100,
    unable_work = weighted.mean(covid_unable, WTFINL, na.rm = TRUE) * 100,
    total_impact = weighted.mean(covid_work_impact, WTFINL, na.rm = TRUE) * 100,
    .groups = "drop"
  ) %>%
  mutate(
    industry_type = ifelse(retail_industry == 1, "Retail", "Non-Retail")
  ) %>%
  pivot_longer(cols = c(remote_work, unable_work), 
               names_to = "impact_type", values_to = "percentage") %>%
  mutate(
    impact_type = case_when(
      impact_type == "remote_work" ~ "Worked Remotely",
      impact_type == "unable_work" ~ "Unable to Work"
    )
  )

plot2_covid_impact <- ggplot(covid_impact_data, aes(x = industry_type, y = percentage, 
                                                    fill = impact_type)) +
  geom_col(position = "dodge", width = 0.7, alpha = 0.8) +
  geom_text(aes(label = paste0(round(percentage, 1), "%")), 
            position = position_dodge(width = 0.7), vjust = -0.3, size = 3.5) +
  scale_fill_manual(values = c("Worked Remotely" = "#2ca02c", "Unable to Work" = "#ff7f0e")) +
  scale_y_continuous(limits = c(0, 25), labels = percent_format(scale = 1)) +
  labs(
    title = "COVID-19 Work Impact Patterns by Industry",
    subtitle = "Retail workers less likely to work remotely, more likely unable to work",
    x = "Industry Type",
    y = "Percentage of Workers Affected (%)",
    fill = "COVID Impact Type",
    caption = "Source: IPUMS CPS 2020-2022, weighted estimates"
  ) +
  theme_minimal() +
  theme(
    legend.position = "bottom",
    plot.title = element_text(size = 14, face = "bold"),
    plot.subtitle = element_text(size = 11, color = "gray40")
  )

# VISUALIZATION 4: Industry Recovery Timeline
# ===========================================
recovery_timeline <- analysis_data %>%
  filter(industry_group %in% c("Retail Trade", "Professional Services", "Manufacturing", "Construction")) %>%
  group_by(industry_group, date) %>%
  summarise(
    employment_rate = weighted.mean(employed, WTFINL, na.rm = TRUE) * 100,
    .groups = "drop"
  )

plot4_recovery <- ggplot(recovery_timeline, aes(x = date, y = employment_rate, 
                                                color = industry_group)) +
  geom_line(linewidth = 1.1, alpha = 0.8) +
  geom_vline(xintercept = as.Date("2020-04-01"), linetype = "dashed", alpha = 0.7, color = "red") +
  scale_x_date(date_labels = "%b %Y", date_breaks = "4 months") +
  scale_y_continuous(limits = c(80, 100), labels = percent_format(scale = 1)) +
  scale_color_viridis_d(option = "plasma", end = 0.8) +
  labs(
    title = "Employment Recovery by Major Industry",
    subtitle = "Retail Trade showed the slowest employment recovery",
    x = "Date",
    y = "Employment Rate (%)",
    color = "Industry",
    caption = "Source: IPUMS CPS 2020-2022, weighted estimates"
  ) +
  theme_minimal() +
  theme(
    axis.text.x = element_text(angle = 45, hjust = 1),
    legend.position = "bottom",
    plot.title = element_text(size = 14, face = "bold"),
    plot.subtitle = element_text(size = 11, color = "gray40")
  )

# Save individual plots
ggsave("employment_trends.png", plot1_employment, width = 10, height = 6, dpi = 300)
ggsave("covid_impact_patterns.png", plot2_covid_impact, width = 8, height = 6, dpi = 300)
ggsave("recovery_timeline.png", plot4_recovery, width = 10, height = 6, dpi = 300)

# Print plots
cat("=== DISPLAYING COVID RETAIL EMPLOYMENT VISUALIZATIONS ===\n\n")

cat("Plot 1: Employment Rate Trends\n")
print(plot1_employment)

cat("\nPlot 2: COVID Work Impact Patterns\n")
print(plot2_covid_impact)

cat("\nPlot 4: Industry Recovery Timeline\n")
print(plot4_recovery)

cat("\n=== VISUALIZATION COMPLETE ===\n")
cat("Individual plots saved as PNG files in working directory\n")
