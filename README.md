# Census Tract Food Insecurity Index

This project estimates relative food insecurity risk for the census tracts of Elkhart, Marsshall, and St. Joseph counties of Indiana using a scoring model adapted from **Feeding America's Map the Meal Gap 2024** research. Each tract receives a score from **1 (lowest risk) to 10 (highest risk)**.

---

## What This Is

The index is not an official food insecurity rate — it is a **relative ranking** based on socioeconomic factors known to predict food insecurity. It is useful for identifying which tracts may have the greatest need and for prioritizing outreach or resource allocation within the counties. The Index is a snapshot of the food insecurity and is not meant to used to compare to other regions or over time..

---

## File Overview

| Files |
|---|---|
| `ACSDP5Y2024_DP04-DataX.csv` | Homeownership rates by census tract (ACS Table DP04) |
| `ACSDP5Y2024_DP05-DataX.csv` | % Black and % Hispanic population by census tract (ACS Table DP05) |
| `ACSDT5Y2024_B14006-DataX.csv` | Poverty rates by census tract (ACS Table B14006) |
| `ACSDT5Y2024_B19013-DataX.csv` | Median household income by census tract (ACS Table B19013) |
| `ACSST5Y2024_S1810-DataX.csv` | Disability rates by census tract (ACS Table S1810) |
| `ACSST5Y2024_S2301-DataX.csv` | Unemployment rates by census tract (ACS Table S2301) |
| `food_insecurity_index.R` | R script that reads the CSVs above and produces the index |

All data files cover **139 census tracts** of Elkhart, Marshall, and St Joseph counties and were downloaded from the U.S. Census Bureau using 5-year ACS estimates using most recent report for 2024.

---

## Score Calculation

The R script combines the six data files and applies regression coefficients published by Feeding America in their `Map the Meal Gap 2024 Technical Breif` to predict a food insecurity rate for each tract. The seven factors used, and the direction of their effect, are:

| Factor | Effect on Score |
|---|---|
| Poverty rate | Higher → more food insecurity |
| Unemployment rate | Higher → more food insecurity |
| Disability rate | Higher → more food insecurity |
| Homeownership rate | Higher → less food insecurity |
| Median household income | Higher → less food insecurity |
| % Black population | Structural control |
| % Hispanic population | Structural control |

The predicted values are then placed on a 1–10 scale after a log transformation, which accounts for the fact that most tracts cluster at lower risk levels with a smaller number of tracts at the high end (right skewed data).

---

## Set Up and Usage

> You will need **R** installed on your computer. If you don't have it, download it free at [https://www.r-project.org](https://www.r-project.org). RStudio is also recommended as a user-friendly way to work with R: [https://posit.co/download/rstudio-desktop](https://posit.co/download/rstudio-desktop).

1. Place all six CSV files and the R script in the **same folder**.
2. Open the R script in RStudio.
3. Update the file paths at the top of the script if needed to point to your folder.
4. Click **Run** (or press Ctrl+Enter / Cmd+Enter to run line by line).
5. The script will produce a data frame with a `Food Insecurity Index` column (1–10) for each tract, plus three graphs showing data distribution.

**Required R packages:** `dplyr`, `ggplot2`, `fitdistrplus`. If you haven't installed these before, run the following once in R before running the main script:

```r
install.packages(c("dplyr", "ggplot2", "fitdistrplus"))
```

---

## Updating the Data

All six CSV files were downloaded directly from the Census Bureau's data portal at [data.census.gov](https://data.census.gov). To refresh with newer ACS data:

1. Search for the table number (e.g., `S2301`) on data.census.gov.
2. Filter to **census tract** geography for your Elkhart, Marshall, and St Joseph counties.
3. Download as CSV and replace the corresponding file in your folder.
4. Re-run the R script.

## Contact