Calculating the mode by groups three solutions

   This is not a trivial problem

   Three Solutions

        1. R  package modeest (best solution?)
        2. proc univariate
        3. proc kde (Pgstats solution)


Good Read ( modeest R package)

Looks like a solid package (just computes modes)
https://cran.r-project.org/web/packages/modeest/modeest.pdf

34 pages and two pages of references.

Calculating the mode is for various densities
and domain widths is not a simple problem.

## Estimate of the mode
mlv(x, method = "lientz", bw = 0.2)
mlv(x, method = "naive", bw = 1/3)
mlv(x, method = "venter", type = "shorth")
mlv(x, method = "grenander", p = 4)
mlv(x, method = "hrm", bw = 0.3)
mlv(x, method = "hsm")
mlv(x, method = "parzen", kernel = "gaussian")
mlv(x, method = "tsybakov", kernel = "gaussian")
mlv(x, method =  "asselin", bw = 2/3)
mlv(x, method = "vieu")

SAS Forum
https://tinyurl.com/ybyubwuo
https://communities.sas.com/t5/SAS-Programming/problem-in-proc-sql-over-a-query/m-p/492403

Pgstats profile
https://communities.sas.com/t5/user/viewprofilepage/user-id/462

githubs

https://github.com/rogerjdeangelis/utl_calculate_mode_for_each_row


INPUT
====

SD1.HAVE total obs=5,203

    SEX      WEIGHT

   Female      140
   Female      194
   Female      132
   Female      158
  ...
   Male        177
   Male        173
   Male        164
   Male        177
...

Visualize the Modes of integer variable weight

Females = 138lbs
Males   = 164lbs

I love the 1980 Classic graphics Editor

                      Top 10 Most Frequent Weights

           FEMALES                           MALES
 --------------------------------==+ ------------------------------
 Weight                Count Mode  | Weight              Count Mode
 -----                 ----  ----  | ------              ----- ----
 138   |**************    69  138  |  164   |*********    46   164
 132   |************      61       |  168   |*********    45
 139   |***********       57       |  175   |*********    44
 137   |***********       57       |  167   |*********    44
 136   |***********       57       |  151   |*********    43
  99   |***********       57       |  179   |********     41
 135   |***********       56       |  159   |********     41
 131   |***********       55       |  162   |********     40
 128   |***********       55       |  171   |********     39
 125   |**********        52       |  182   |********     38

* code to create the above - need to use the excellect 1980 classic graphics editor;
options ls=64 ps=500;
proc chart data=sd1.have;
hbar weight / space=0 descending width=1 midpoints=99 to 276 by 1 group=sex;
run;quit;
options ls=171 ps=32;


PROCESS
=======


1. R  package modeest (best solution?) (I am nor an expert R programmer)
========================================================================

   %utl_submit_r64('
   library(haven);
   library(modeest);
   library(data.table);
   have<-as.data.frame(read_sas("d:/sd1/have.sas7bdat"));
   ckh=
   agef<-as.data.frame(as.integer(have[have$SEX=="Female",][,2]));
   agem<-as.data.frame(as.integer(have[have$SEX=="Male",][,2]));
   wantf<-apply(agef,2,function(x) mlv(x, method = "mfv")[[1]]);
   wantm<-apply(agem,2,function(x) mlv(x, method = "mfv")[[1]]);
   want<-cbind(wantf,wantm);
   want;
   writeClipboard(as.character(paste(want, collapse = " ")))
   ',returnVar=mode);

   %put Female/Male &=mode respectively;

   ---------------------------------------
   Female/Male MODE=138 164 respectively
   --------------------------------------

2. proc univariate
===================

   ods output summary=wantUnv(keep=_name_ mode);
   proc means data=sd1.have stackodsoutput mode;
     class sex;
     var weight;
   run;quit;

                N
   SEX        Obs            Mode
   ------------------------------
   Female    2869      138.000000

   Male      2334      164.000000
   ------------------------------


3. proc kde -- Bandwidth Method  Sheather-Jones Algorithm
=========================================================

    proc kde data=sd1.have;
    by sex;
    univar weight / out=havHis plots=none;
    run;quit;

    proc sql;
      select
         sex
        ,value as wgtMode
      from havHis
    group by sex
    having density=max(density);
    quit;

   SEX        Value
   ----------------
   Female    134.57
   Male    168.4725


*                _               _       _
 _ __ ___   __ _| | _____     __| | __ _| |_ __ _
| '_ ` _ \ / _` | |/ / _ \   / _` |/ _` | __/ _` |
| | | | | | (_| |   <  __/  | (_| | (_| | || (_| |
|_| |_| |_|\__,_|_|\_\___|   \__,_|\__,_|\__\__,_|

;

options validvarname=upcase;
libname sd1 "d:/sd1";
proc sort data=sashelp.heart(where=(weight ne .) keep=sex weight)
          out=sd1.have;
  by sex;
run;quit;



