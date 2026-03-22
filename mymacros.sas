/* --------------------------------------------------------
   File    : mymacros.sas
   Purpose : Macro library
   Contains: %computemetric macro
   -------------------------------------------------------- */

%macro computemetric(table=, variable=, metric=);

    /* ---- Validate metric input ------------------------- */
    %if %upcase(&metric) ne MEAN and
        %upcase(&metric) ne MEDIAN and
        %upcase(&metric) ne SUM %then %do;
        %put ERROR: Invalid metric "&metric". Must be mean, median or sum.;
        %return;
    %end;

    /* ---- Validate table exists ------------------------- */
    %let dsid = %sysfunc(open(&table));
    %if &dsid = 0 %then %do;
        %put ERROR: Table "&table" does not exist.;
        %return;
    %end;

    /* ---- Validate variable exists ---------------------- */
    %let varnum = %sysfunc(varnum(&dsid, &variable));
    %let rc     = %sysfunc(close(&dsid));
    %if &varnum = 0 %then %do;
        %put ERROR: Variable "&variable" does not exist in table "&table".;
        %return;
    %end;

    /* ---- Compute and print metric ---------------------- */
    proc means data=&table &metric noprint;
        var &variable;
        output out=_metric_ &metric=result;
    run;

    data _null_;
        set _metric_;
        put "NOTE: The %upcase(&metric) of %upcase(&variable) in &table is: " result;
    run;

    proc print data=_metric_ noobs label;
        var result;
        format result 12.3;
        label result = "%upcase(&metric) of %upcase(&variable)";
        title "%upcase(&metric) of %upcase(&variable) in &table";
    run;

%mend computemetric;