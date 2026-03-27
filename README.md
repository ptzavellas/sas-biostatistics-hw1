# SAS Biostatistics Homework 1

## Description
Homework 1 for Introduction to Biostatistics using SAS Viya. This project covers
fundamental SAS programming concepts applied to the Diabetes dataset from 
Buckingham County, Virginia (Willems et al., 1997 & Schorling et al., 1997).

## Authors
**P. Tzavellas** | petrostza1997@hotmail.com 
Medical School, University of Athens
**C. Athanasakopoulos** | xristos.athanasa@gmail.com
Medical School, University of Athens

## Dataset
- **Source**: Diabetes dataset from https://hbiostat.org/data/
- **Reference**: Willems et al. (1997) and Schorling et al. (1997)
- **Description**: Community-based study on coronary heart disease risk factors
  among rural Black residents of Buckingham County, Virginia

## Topics Covered
- SAS library definition and macro variables
- Data import using `PROC IMPORT`
- Data manipulation and variable labeling
- BMI calculation and CDC-based categorization
- Diabetes classification based on glycosolated hemoglobin (glyhb)
- Frequency distributions using `PROC FREQ`
- Descriptive statistics using `PROC MEANS`
- Data visualization using `PROC SGPLOT`
  - Grouped boxplots by gender
  - Scatter plots by diabetes status
  - Bar charts of frequency distributions
- Macro programming with error handling
- ODS output to Excel, PNG and PowerPoint

## Repository Structure
```
sas-biostatistics-hw1/
│
├── hw1.sas              # Main SAS program (all tasks)
├── mymacros.sas         # Macro library (%computemetric)
├── data/
│   └── diabetes.csv     # Raw dataset
├── output/
│   ├── diabetes_dist.png
│   ├── Age_BMI.png
│   ├── GroupedBoxplot.pptx
│   ├── GroupedBoxplot2.pptx
│   ├── means.xlsx
│   ├── diab_gender_dist.xlsx
│   └── diab_BMI_cat_dist.xlsx
├── Presentation/
│   └── Presentation_hw1_March26.pdf
└── README.md
```

## Tasks Summary

| Task | Description |
|------|-------------|
| 4    | Define `classpath` macro variable |
| 5    | Define `hw1` SAS library |
| 6    | Define `name` macro variable |
| 7    | Import `diabetes.csv` into `hw1.diab_tzavellas` |
| 8    | Print first 3 rows and check contents |
| 9    | Create `hw1.diab2` with labeled variables |
| 10   | Create BMI, BMI category and diabetes variables |
| 11   | Frequency distributions saved to Excel |
| 12   | Grouped boxplot of height by gender → PowerPoint |
| 13   | Grouped boxplot of height by gender and BMI → PowerPoint |
| 14   | Bar chart of diabetes distribution → PNG |
| 15   | Scatter plot of BMI vs Age by diabetes → PNG |
| 16   | Means of 5 variables by diabetes → Excel |
| 17   | Macro function `%computemetric` |

## Requirements
- SAS Viya for Learners
- SAS Studio 2025.09
- Base SAS, SAS/STAT, SAS/GRAPH

## References
- Willems JP, Saunders JT, Hunt DE, Schorling JB. (1997). Prevalence of coronary
  heart disease risk factors among rural blacks: A community-based study.
  *Southern Medical Journal*, 90(8), 814-820.
- Schorling JB, Roach J, Siegel M, et al. (1997). A trial of church-based smoking
  cessation interventions for rural African Americans.
  *Preventive Medicine*, 26(1), 92-101.
- CDC BMI Categories: https://www.cdc.gov/bmi/adult-calculator/bmi-categories.html
