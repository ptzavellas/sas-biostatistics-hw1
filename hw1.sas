/*===========================================================================================
PURPOSE : Introduction to Biostatistics - Homework 1
Notes   : This program completes all tasks for Homework 1, including data import,
          data manipulation, macro programming, and visualization.
          Tasks 1-3 are completed outside of SAS (folder creation, file upload,
          and SAS file creation) and are therefore not included in this file.
Topics  : Library definition, data import, data manipulation, macro variables,
          proc freq, proc means, proc sgplot, proc sgpanel, ods output
Source  : Willems et al. (1997) and Schorling et al. (1997)
          "Prevalence of coronary heart disease risk factors among rural blacks:
           a community-based study" - Diabetes Care dataset,
           Buckingham County, Virginia
          CDC BMI Guidelines:
          https://www.cdc.gov/bmi/adult-calculator/bmi-categories.html
Authors  :P. Tzavellas, p.tzavellas@med.uoa.gr
Date    : March 2026
===========================================================================================*/

/* --------------------------------------------------------
   Tasks 1-3: Completed outside of SAS
   
   Task 1: Created folder "hw1" inside
           /export/viya/homes/&sysuserid./Biostatistics/
   Task 2: Downloaded diabetes.csv from
           https://hbiostat.org/data/ and uploaded
           to the "hw1" folder
   Task 3: Created this file "hw1.sas" in the "hw1" folder
   -------------------------------------------------------- */

/* --------------------------------------------------------
   Task 4: Define macro variable classpath
   
   Purpose : Sets the base path for all file references
             throughout the homework
   -------------------------------------------------------- */
   
   %let classpath = /export/viya/homes/&sysuserid./Biostatistics;

/* --------------------------------------------------------
   Task 5: Define SAS library hw1
   
   Purpose : Points to the ~/hw1/ directory where all
             homework datasets and outputs are stored
   -------------------------------------------------------- */

libname hw1 "&classpath./hw1";

/* --------------------------------------------------------
   Task 6: Define macro variable name
   
   Purpose : Stores last name in lowercase for use in
             dataset naming convention
   -------------------------------------------------------- */

%let name = tzavellas;

/* --------------------------------------------------------
   Task 7: Import diabetes.csv into hw1.diab_&name
   
   Source  : &classpath./hw1/data/diabetes.csv
   Output  : hw1.diab_tzavellas
   -------------------------------------------------------- */
   
   proc import datafile= "&classpath./hw1/data/diabetes.csv"
				dbms = csv
				out = hw1.diab_&name.
                replace;
			getnames = yes;
run;

/* --------------------------------------------------------
   Task 8: Print first 3 rows and check contents
            of hw1.diab_&name
   -------------------------------------------------------- */
proc print data = hw1.diab_&name. (obs=3);
    title "First 3 Observations of hw1.diab_&name.";
run;

ods select variables;
proc contents data = hw1.diab_&name.;
    title "Contents of hw1.diab_&name.";
run;

/* --------------------------------------------------------
   Task 9: Create hw1.diab2 with labeled variables
   
   Source  : Willems et al. (1997) and 
             Schorling et al. (1997)
             "Prevalence of coronary heart disease risk 
              factors among rural blacks: a community-based 
              study" - Diabetes Care dataset
              Buckingham County, Virginia
   -------------------------------------------------------- */

data hw1.diab2; 
	set hw1.diab_&name.;
	    label
        chol    = "Total Cholesterol (mg/dL)"
        glyhb   = "Glycosolated Hemoglobin (%)"
        age     = "Age of Patient (years)"
        gender  = "Gender (male/female)"
        waist   = "Waist Circumference (inches)"
        hip     = "Hip Circumference (inches)"
        weight  = "Weight of Patient (pounds)"
    ;
run;
ods select variables;
proc contents data = hw1.diab2;
    title "Contents of hw1.diab2 - Labeled Variables";

run;

/* --------------------------------------------------------
   Task 10: Create new variables in diab2
   
   New variables:
     1. BMI       - Body Mass Index (kg/m^2)
     2. BMI_cat   - BMI Category based on CDC guidelines
     3. diabetes  - Diabetes status based on glyhb
   
   Source : CDC BMI Guidelines
            https://www.cdc.gov/bmi/adult-calculator/bmi-categories.html
   
   Unit conversions:
            weight : pounds → kg      (divide by 2.2046)
            height : inches → meters  (divide by 39.3701)
   -------------------------------------------------------- */

data hw1.diab2;
    set hw1.diab2;

    /* Step 1: Calculate BMI 
       weight in dataset is in pounds → convert to kg
       height in dataset is in inches → convert to meters */
    BMI = (weight / 2.2046) / ((height / 39.3701)**2);
    label BMI = "Body Mass Index (kg/m^2)";

    /* Step 2: Create categorical BMI variable (CDC guidelines)
       Underweight  : BMI < 18.5
       Normal Weight: 18.5 <= BMI < 25
       Overweight   : 25   <= BMI < 30
       Obese        : BMI >= 30                */
    length BMI_cat $ 15;
    if      BMI <  18.5 then BMI_cat = "Underweight";
    else if BMI<  25.0 then BMI_cat = "Normal Weight";
    else if BMI <  30.0 then BMI_cat = "Overweight";
    else if BMI >= 30.0 then BMI_cat = "Obese";
    else                          BMI_cat = " ";  /* missing */
    label BMI_cat = "BMI Category (CDC Guidelines)";

    /* Step 3: Create diabetes variable based on glyhb
       1 = diabetic    (glyhb >  6.5)
       0 = non-diabetic(glyhb <= 6.5) */
    if      glyhb >  6.5 then diabetes = 1;
    else if glyhb > 0 then diabetes = 0;
    else                      diabetes = .;  /* missing */
    label diabetes = "Diabetes Status (1=Diabetic, 0=Non-Diabetic)";

run;

/* Verify new variables */
ods select variables;
proc contents data = hw1.diab2;
run;

/* Quick check of new variables */
proc freq data = hw1.diab2;
    tables BMI_cat diabetes;
run;

proc means data = hw1.diab2 n mean min max;
    var BMI;
run;


/* --------------------------------------------------------
   Task 11: Frequency distribution of two categorical 
             variables in diab2
   
   Variables chosen:
     1. gender   - Gender of patient
     2. BMI_cat  - BMI Category (CDC Guidelines)
   
   Output:
     SAS tables : hw1.diab_gender_dist
                  hw1.diab_BMI_cat_dist
     Excel files: ~/hw1/diab_gender_dist.xlsx
                  ~/hw1/diab_BMI_cat_dist.xlsx
   -------------------------------------------------------- */
/* ---- Variable 1: Gender --------------------------------- */
proc freq data = hw1.diab2;
    tables gender / nocum
                    out = hw1.diab_gender_dist;
run;

/* ---- Variable 2: BMI Category -------------------------- */
proc freq data = hw1.diab2;
    tables BMI_cat / nocum
                     out = hw1.diab_BMI_cat_dist;
run;

/* ---- Export Gender to xlsx ----------------------------- */
ods excel file = "&classpath./hw1/diab_gender_dist.xlsx"
          options(sheet_name = "Gender Distribution");

    proc print data = hw1.diab_gender_dist noobs;
        format PERCENT 8.2;   /* ← variable name first */
        title "Frequency Distribution - Gender";
    run;

ods excel close;

/* ---- Export BMI_cat to xlsx ---------------------------- */
ods excel file = "&classpath./hw1/diab_BMI_cat_dist.xlsx"
          options(sheet_name = "BMI Category Distribution");

    proc print data = hw1.diab_BMI_cat_dist noobs;
        format PERCENT 8.2;   /* ← variable name first */
        title "Frequency Distribution - BMI Category";
    run;

ods excel close;
/* ---- Export gender distribution to xlsx ---------------- */
/*proc export data   = hw1.diab_gender_dist
            outfile= "&classpath./hw1/diab_gender_dist.xlsx"
            dbms   = xlsx
            replace;
run;
*/
/* ---- Export BMI_cat distribution to xlsx --------------- */
/*proc export data   = hw1.diab_BMI_cat_dist
            outfile= "&classpath./hw1/diab_BMI_cat_dist.xlsx"
            dbms   = xlsx
            replace;
run; 

*/


/* --------------------------------------------------------
   Task 12: Grouped Boxplot of Height by Gender
   - Female: Gold fill, Diamond mean marker
   - Male  : #41B6B8 fill, Square mean marker
   - Legend: color swatch + mean shape separately
   Source: hw1.diab2
   Saved to: &classpath./hw1/GroupedBoxplot.pptx
   -------------------------------------------------------- */


data attrmap;
    length id $8 value $10 fillcolor $12 linecolor $12
           markercolor $12 markersymbol $14;
    id = "gender";
    value = "female"; fillcolor="Gold";      linecolor="Black";
                      markercolor="Black";   markersymbol="DiamondFilled"; output;
    value = "male";   fillcolor="#41B6B8"; linecolor="Black";
                      markercolor="Black";   markersymbol="SquareFilled";  output;
run;

title "Boxplot of Height by Gender";

ods powerpoint file = "&classpath./hw1/GroupedBoxplot.pptx";
ods graphics / width=20cm height=15cm;

proc sgplot data=hw1.diab2 dattrmap=attrmap;

    vbox height / group        = gender
                  category     = gender
                  attrid       = gender
                  outlierattrs = (color=Black symbol=CircleFilled size=5)
                  lineattrs    = (color=Black thickness=1.5)
                  whiskerattrs = (color=Black thickness=1.5)
                  medianattrs  = (color=Black thickness=2)
                  meanattrs    = (color=Black size=12)
                  name         = "box";

    /* Legend 1: shows color swatches */
    keylegend "box" /
        title      = "Gender"
        titleattrs = (family="Calibri" size=11pt weight=Bold color=Black)
        valueattrs = (family="Calibri" size=11pt color=Black)
        type       = fill
        location   = outside
        position   = right
        border;

    /* Legend 2: shows mean shapes */
    keylegend "box" /
        title      = "Gender (Mean Shape)"
        titleattrs = (family="Calibri" size=11pt weight=Bold color=Black)
        valueattrs = (family="Calibri" size=11pt color=Black)
        type       = marker
        location   = outside
        position   = bottom
        border;

    xaxis display    = (nolabel)
          valueattrs = (family="Calibri" size=12pt weight=Bold color=Black);

    yaxis label      = "Height (inches)"
          labelattrs = (family="Calibri" size=13pt weight=Bold color=Black)
          valueattrs = (family="Calibri" size=11pt color=Black)
          grid
          gridattrs  = (color=GrayCC thickness=0.5);
run;

title;
ods powerpoint close;


/* --------------------------------------------------------
   Task 13: Boxplot of Height by Gender for each BMI category
   - Female: Gold fill, Diamond mean marker
   - Male  : #41B6B8 fill, Square mean marker
   - X-axis: BMI categories in order
   -------------------------------------------------------- */

/* ---- Step 1: Order BMI categories ---------------------- */
data diab_plot;
    set hw1.diab2;
    BMI_order = .;
    if BMI_cat = "Underweight"    then BMI_order = 1;
    if BMI_cat = "Normal Weight"  then BMI_order = 2;
    if BMI_cat = "Overweight"     then BMI_order = 3;
    if BMI_cat = "Obese"          then BMI_order = 4;
run;

proc sort data=diab_plot;
    by BMI_order;
run;

/* ---- Step 2: Attribute map ----------------------------- */
data attrmap;
    length id $8 value $10 fillcolor $12 linecolor $12
           markercolor $12 markersymbol $14;
    id = "gender";
    value = "female"; fillcolor="Gold";      linecolor="Black";
                      markercolor="Black";   markersymbol="DiamondFilled"; output;
    value = "male";   fillcolor="#41B6B8"; linecolor="Black";
                      markercolor="Black";   markersymbol="SquareFilled";  output;
run;

/* ---- Step 3: Plot -------------------------------------- */
title "Boxplot of Height by Gender and BMI Category";

ods powerpoint file = "&classpath./hw1/GroupedBoxplot2.pptx";
ods graphics / width=30cm height=18cm;

proc sgplot data=diab_plot dattrmap=attrmap;

    vbox height / group        = gender
                  category     = BMI_cat
                  attrid       = gender
                  outlierattrs = (color=Black symbol=CircleFilled size=5)
                  lineattrs    = (color=Black thickness=1.5)
                  whiskerattrs = (color=Black thickness=1.5)
                  medianattrs  = (color=Black thickness=2)
                  meanattrs    = (color=Black size=12)
                  name         = "box";

    /* Legend 1: colors */
    keylegend "box" /
        title      = "Gender"
        titleattrs = (family="Calibri" size=11pt weight=Bold color=Black)
        valueattrs = (family="Calibri" size=11pt color=Black)
        type       = fill
        location   = outside
        position   = right
        border;

    /* Legend 2: mean shapes */
    keylegend "box" /
        title      = "Gender (Mean Shape)"
        titleattrs = (family="Calibri" size=11pt weight=Bold color=Black)
        valueattrs = (family="Calibri" size=11pt color=Black)
        type       = marker
        location   = outside
        position   = bottom
        border;

    /* Force correct order on x-axis */
    xaxis display      = (nolabel)
          valueattrs   = (family="Calibri" size=12pt weight=Bold color=Black)
          discreteorder = data;   /* ← keeps BMI_order sort order */

    yaxis label      = "Height (inches)"
          labelattrs = (family="Calibri" size=13pt weight=Bold color=Black)
          valueattrs = (family="Calibri" size=11pt color=Black)
          grid
          gridattrs  = (color=GrayCC thickness=0.5);
run;

title;
ods powerpoint close;





/* --------------------------------------------------------
   Task 14: Bar chart of % frequency distribution
             of diabetes variable
   Saved to: ~/hw1/diabetes_dist.png
   Size    : 6in width x 4in height
   -------------------------------------------------------- */
/* ---- Define format ------------------------------------ */
proc format;
    value diabfmt
        0 = "No"
        1 = "Yes";
run;

/* ---- Step 1: Compute % frequency ---------------------- */
proc freq data=hw1.diab2 noprint;
    tables diabetes / out=diab_dist;
run;

/* ---- Step 2: Format percent with % symbol ------------- */
data diab_dist;
    set diab_dist;
    pct_label = cats(put(PERCENT, 8.1), "%");
    format diabetes diabfmt.;   /* ← apply format here */
run;

/* ---- Step 3: Save as PNG ------------------------------ */
ods listing gpath="&classpath./hw1/";
ods graphics / reset
               imagename = "diabetes_dist"
               outputfmt = png
               width     = 6in
               height    = 4in;

/* ---- Step 4: Plot ------------------------------------- */
title "% Frequency Distribution of Diabetes";

proc sgplot data=diab_dist;

    format diabetes diabfmt.;   /* ← also apply in proc sgplot */

    vbar diabetes / response     = PERCENT
                    group        = diabetes
                    groupdisplay = cluster
                    outlineattrs = (color=Black)
                    datalabel    = pct_label
                    datalabelattrs = (family="Calibri" size=10pt weight=Bold);

    styleattrs datacolors = (SteelBlue Tomato);

    xaxis label      = "Diabetic (No/Yes)"
          labelattrs = (family="Calibri" size=11pt weight=Bold color=Black)
          valueattrs = (family="Calibri" size=11pt color=Black);

    yaxis label      = "Percentage (%)"
          labelattrs = (family="Calibri" size=11pt weight=Bold color=Black)
          valueattrs = (family="Calibri" size=10pt color=Black)
          max        = 100
          grid
          gridattrs  = (color=GrayCC thickness=0.5);
run;

title;
ods graphics off;
ods listing close;


/* --------------------------------------------------------
   Task 15: Scatter plot of BMI vs Age by Diabetes status
   Saved to: ~/Biostatistics/hw1/Age_BMI.png
   Size    : 6in width x 4in height
   -------------------------------------------------------- */
/* We create a character variable of diabetes to allow us change the 
shape of diabetes and missing valus in the scatter*/

data hw1.diab2;
    set hw1.diab2;
    length diab_char $8;
    if      diabetes = 1 then diab_char = "Yes";
    else if diabetes = 0 then diab_char = "No";
    else                      diab_char = "Missing";
run;


/* Attribute map - coral/teal για consistency με Task 14 but with diab_char */
data attrmap_diab;
    length id $10 value $8 fillcolor $12 linecolor $12 
           markercolor $12 markersymbol $15;
    id = "diab_char";
    value = "No";      fillcolor = "#2ABFBF"; linecolor = "#2ABFBF"; 
                       markercolor = "#2ABFBF"; markersymbol = "trianglefilled"; output;
    value = "Yes";     fillcolor = "#F4796B"; linecolor = "#F4796B"; 
                       markercolor = "#F4796B"; markersymbol = "squarefilled";   output;
    value = "Missing"; fillcolor = "#440154"; linecolor = "#440154"; 
                       markercolor = "#440154"; markersymbol = "circlefilled";   output;
run;
title color = black height = 14pt bold
      "BMI vs Age by Diabetes Status";

ods listing gpath = "&classpath./hw1";
ods graphics / reset = all;
ods graphics / attrpriority = none /*so the symbols can change*/
               imagename = "Age_BMI"
               imagefmt  = png
               width     = 6in
               height    = 4in;

proc sgplot data = hw1.diab2 dattrmap = attrmap_diab;
    format diabetes diabfmt.;
    scatter x = age y = BMI / group        = diab_char
                               attrid      = diab_char
                               markerattrs = (size = 5); 
    xaxis label      = "Age (years)"
          labelattrs = (size = 12 weight = bold color = black)
          valueattrs = (size = 11 color = black);
    yaxis label      = "BMI (kg/m^2)"
          labelattrs = (size = 12 weight = bold color = black)
          valueattrs = (size = 11 color = black);
    keylegend / title      = "Diabetes"
                titleattrs = (size = 12 weight = bold color = black)
                valueattrs = (size = 11 color = black)
                position   = right location = outside;
run;

title;
ods listing close;



/* --------------------------------------------------------
   Task 16: Means of 5 numerical variables by diabetes
   Variables: age, bmi, chol, weight, glyhb
   Saved to : hw1.Means (SAS table)
              &classpath./hw1/means.xlsx (Excel)
   -------------------------------------------------------- */

/* ---- Step 1: Compute means by diabetes status ---------- */
proc means data=hw1.diab2 noprint;
    class diabetes;
    var age bmi chol weight glyhb;
    output out=hw1.Means mean=mean_age mean_bmi mean_chol mean_weight mean_glyhb;
run;

/* ---- Step 2: Clean up table ---------------------------- */
data hw1.Means;
    set hw1.Means;
    where diabetes in (0, 1);   /* remove overall mean row */
    drop _TYPE_ _FREQ_;
    label diabetes    = "Diabetes"
          mean_age    = "Age"
          mean_bmi    = "BMI"
          mean_chol   = "Cholesterol"
          mean_weight = "Weight"
          mean_glyhb  = "Glycosolated Hemoglobin";
run;

/* ---- Step 3: Print to results tab ---------------------- */
ods excel file="&classpath./hw1/means.xlsx"
          options(sheet_name="Means");

proc print data=hw1.Means noobs label;
    format mean_age    8.3
           mean_bmi    8.3
           mean_chol   8.3
           mean_weight 8.3
           mean_glyhb  8.3;
    title "Mean Values of Numerical Variables by Diabetes Status";
run;

ods excel close;

/* ---- Step 4: Also print to results tab ----------------- */
proc print data=hw1.Means label;
    format mean_age    8.3
           mean_bmi    8.3
           mean_chol   8.3
           mean_weight 8.3
           mean_glyhb  8.3;
    title "Mean Values of Numerical Variables by Diabetes Status";
run;

/* --------------------------------------------------------
   Task 17: Macro function to compute a metric for a 
             specified variable in a specified SAS table
   
   Macro    : %computemetric
   Arguments: table    = SAS table (library.dataset)
              variable = Variable name in the table
              metric   = mean, median or sum
   
   Saved to : &classpath./hw1/mymacros.sas
   Loaded via %include statement
   
   Calls    :
     1. Mean   of height in hw1.diab2
     2. Median of weight in hw1.diab2
     3. Sum    of chol   in hw1.diab2
     4. Mean   of MSRP   in sashelp.cars
   -------------------------------------------------------- */

%include "&classpath./hw1/mymacros.sas";

%computemetric(table=hw1.diab2,    variable=height, metric=mean);
%computemetric(table=hw1.diab2,    variable=weight, metric=median);
%computemetric(table=hw1.diab2,    variable=chol,   metric=sum);
%computemetric(table=sashelp.cars, variable=MSRP,   metric=mean);