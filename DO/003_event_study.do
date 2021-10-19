*** Event Study - Around Deadline ***

capture clear
capture clear matrix
set more off


cd "/Users/panos/DATA/GitHub/tax_discount" //change accordingly


cap mkdir "OUT"
cap mkdir "LOG"
cap mkdir "DTA"

cap log close
log using "LOG/003_event.txt", replace

*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

*** Data Loading and Additional Packages ***

*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

* Packages - NOTE: Run once
//ssc install eventdd
//ssc install estout
//ssc install reghdfe
//ssc install ftools
//ssc install matsort

use "DTA/SAMPLE_PANEL.dta" // using cleaned panel dataset
merge m:1 N using "DTA/SAMPLE_FIXED.dta" // merging individual characteristics

*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

*** Data Preparation ***

*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

*Setting date dimension
gen mdate=mofd(mdy(month,1,year))
format mdate %tm
xtset N mdate, monthly

*Binary variable if threshold reached (1 if below threshold at end of year)
gen below=1 if pthresh_to_m12<0
replace below=0 if below==.

*Consumption Parameter (percentage of e-consumption per declared income)
gen cons_y=(consumption/income_ind)*100 if income_ind>0
//income limited to >0 as 0 do not abide to a threshold.

*First Differencing to detrend
gen dcons_y=D.cons_y

* Global variables

global conditions = "if income_ind>0 & joint_file==0 & (main_income_source==1 | main_income_source==2 | main_income_source==3)"
// Exclude: winners, declaring 0 income, filing jointly, being business onwner
global options = "method(hdfe, absorb(N) cluster(N))"
// Using reghdfe, absorbing individual fixed effects, clustering st.err at i-level
global dv1 = "cons_y"
// Dependent variable 1: Parameterised monthly consumption over annual income
global dv2 = "dcons_y"
// Dependent variable 2: Monthly difference of parameterised consumption
global time = "timevar(dif)"
// time variable


*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

*** Setting up Estimation ***

*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

* Time variables

tab mdate, gen(date)

sort N mdate
by N: gen month_num=_n // enumerates dates
by N: gen event=month_num if month==12 & year==2017 // indicator of event date
egen event_date=min(event), by(N)
gen dif=month_num-event_date // timevar for eventdd regression


*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

*** Event Study - Estimation around End-of-Year Deadline ***

*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

*Individuals reaching threshold per month

xtsum N $conditions & below==1
local n = r(n)

eventdd $dv1 $conditions & below==1, ///
        leads(11) lags(6) keepbal(N) $time $options baseline(-11) noline ///
        graph_op(msize(vsmall) mcolor(black) msymbol(circle) scheme(plotplain) ///
        title("Threshold Not Reached") name(m12,replace) ///
        xlabel(#19, angle(45)) xtitle("Month Before/After Deadline", size(small) margin(zero)) ///
        text( 20 8 "Sample: " , place(nw) just(left) margin(l+4 t+1 b+1) width(30)) ///
        text( 20 12 "`n'", place(nw) just(left) margin(l+4 t+1 b+1) width(30)) ///
        graphregion(color(white)) bgcolor(white) ///
        ytitle("Consumption (% of Income)", size(medsmall) margin(zero)) ///
        legend(off) nodraw)

outreg2 using "OUT/event.tex", tex(frag) se sdec(3) bdec(3) ///
        ctitle(Not Reached) addstat(N, `n') replace

forvalues a=2(1)7 {
local b=`a'-1

xtsum N $conditions & pthresh_to_m`a'>=0 & pthresh_to_m`b'<0
local n = r(n)

eventdd $dv1 $conditions & pthresh_to_m`a'>=0 & pthresh_to_m`b'<0, ///
        leads(11) lags(6) keepbal(N) $time $options baseline(-11) noline ///
        graph_op(msize(vsmall) mcolor(black) msymbol(circle) scheme(plotplain) ///
        title("Month `a'") name(m`b',replace) ///
        xlabel(#19, angle(45)) xtitle("Month Before/After Deadline", size(small) margin(zero)) ///
        text( 17 8 "Sample: " , place(nw) just(left) margin(l+4 t+1 b+1) width(30)) ///
        text( 17 12 "`n'", place(nw) just(left) margin(l+4 t+1 b+1) width(30)) ///
        graphregion(color(white)) bgcolor(white) ///
        ytitle("Consumption (% of Income)", size(small) margin(zero)) ///
        legend(off) nodraw)

outreg2 using "OUT/event.tex", tex(frag) se sdec(3) bdec(3) ///
        ctitle(Month `a') addstat(N, `n') append

}

forvalues a=8(1)12 {
local b=`a'-1

xtsum N $conditions & pthresh_to_m`a'>=0 & pthresh_to_m`b'<0
local n = r(n)

eventdd $dv1 $conditions & pthresh_to_m`a'>=0 & pthresh_to_m`b'<0, ///
        leads(11) lags(6) keepbal(N) $time $options baseline(-11) noline ///
        graph_op(msize(vsmall) mcolor(black) msymbol(circle) scheme(plotplain) ///
        title("Month `a'") name(m`b',replace) ///
        xlabel(#19, angle(45)) xtitle("Month Before/After Deadline", size(small) margin(zero)) ///
        text( 20 8 "Sample: " , place(nw) just(left) margin(l+4 t+1 b+1) width(30)) ///
        text( 20 12 "`n'", place(nw) just(left) margin(l+4 t+1 b+1) width(30)) ///
        graphregion(color(white)) bgcolor(white) ///
        ytitle("Consumption (% of Income)", size(small) margin(zero)) ///
        legend(off) nodraw)

outreg2 using "OUT/event.tex", tex(frag) se sdec(3) bdec(3) ///
        ctitle(Month `a') addstat(N, `n') append

}

*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

*** Output: Table A.3 and Figure 4.5 ***

*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

* NOTE: event.tex outputs table A.3 - some post editing needed

*Figure 4.5

graph combine m1 m2 m3 m4 m5 m6, cols(2) ycommon ysize(8) graphregion(margin(zero))
graph save "OUT/fig4_5a", replace

graph combine m7 m8 m9 m10 m11 m12, cols(2) ycommon ysize(8) graphregion(margin(zero))
graph save "OUT/fig4_5b", replace

clear
