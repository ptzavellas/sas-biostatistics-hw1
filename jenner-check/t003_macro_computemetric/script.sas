/* --------------------------------------------------------
   Task 17 (hw1.sas + mymacros.sas): the %computemetric macro
   function computes a mean, median or sum for a named variable
   in a named table, after validating the metric, the table
   (via the OPEN function) and the variable (via VARNUM). This
   bundle carries the author's %computemetric definition from
   mymacros.sas verbatim, and drives it with the same four
   calls Task 17 makes.

   Adapted for a self-contained run: the diab2 table is
   reconstructed inline from a 45-row sample of the author's
   real diabetes.csv (Willems et al., 1997) instead of being
   read from the Viya library; the sashelp.cars call is the
   author's, unchanged. The macro itself is not modified.
   -------------------------------------------------------- */

data diab2;
    length gender $6;
    input id chol glyhb age gender $ height weight;
    datalines;
    1000 203 4.3099999428 46 female 62 121
    1001 165 4.4400000572 29 female 64 218
    1002 228 4.6399998665 58 female 61 256
    1003 78 4.6300001144 67 male 67 119
    1005 249 7.7199997902 64 male 68 183
    1008 248 4.8099999428 34 male 71 190
    1011 195 4.8400001526 30 male 69 191
    1015 227 3.9400000572 37 male 59 170
    1016 177 4.8400001526 45 male 69 166
    1022 263 5.7800002098 55 female 63 202
    1024 242 4.7699999809 60 female 65 156
    1029 215 4.9699997902 38 female 58 195
    1030 238 4.4699997902 27 female 60 170
    1031 183 4.5900001526 40 female 59 165
    1035 191 4.6700000763 36 male 69 183
    1036 213 3.4100000858 33 female 65 157
    1037 255 4.3299999237 50 female 65 183
    1041 230 4.5300002098 20 male 67 159
    1045 194 5.2800002098 36 male 64 126
    1250 196 11.2399997711 62 female 65 196
    1252 186 6.4899997711 70 male 67 178
    1253 234 4.6700000763 47 male 67 230
    1254 203 12.7399997711 38 female 69 288
    1256 281 5.5599999428 66 female 62 185
    1271 228 4.6100001335 24 female 61 113
    1277 179 4.1799998283 41 female 72 118
    1280 232 5.0999999046 37 male 68 252
    1281 . 4.2800002098 48 male 68 100
    1282 254 4.5199999809 43 female 62 145
    1285 215 4.3699998856 40 male 70 189
    1301 177 5.1100001335 42 female 65 174
    1303 182 4.4699997902 52 male 68 139
    1304 265 15.5200004578 61 male 74 191
    1305 182 5.6599998474 61 female 69 174
    1309 199 3.6700000763 25 male 66 118
    1312 183 4.0300002098 47 female 66 186
    1313 194 2.6800000668 35 male 66 159
    1314 190 3.5599999428 46 male 72 205
    1315 173 6.2100000381 57 male 71 145
    1316 182 7.9099998474 70 male 69 214
    1317 136 4.5799999237 22 female 66 160
    1321 218 3.8900001049 52 female 62 170
    1323 225 4.3800001144 36 male 67 192
    1326 262 . 43 male 75 253
    1500 213 5.9600000381 72 female 59 137
    ;
run;

/* ---- Author's macro, verbatim from mymacros.sas ---------- */
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
        format result 12.1;
        label result = "%upcase(&metric) of %upcase(&variable)";
        title "%upcase(&metric) of %upcase(&variable) in &table";
    run;

%mend computemetric;

/* ---- Task 17 calls -------------------------------------- */
%computemetric(table=diab2,        variable=height, metric=mean);
%computemetric(table=diab2,        variable=weight, metric=median);
%computemetric(table=diab2,        variable=chol,   metric=sum);
%computemetric(table=sashelp.cars, variable=MSRP,   metric=mean);
