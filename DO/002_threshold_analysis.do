/*
- This code investigates individual behaviour at their personal threshold and
within-individual differences of reported and pre-filled electronic consumption.

- The code Produces Figures A.1, 4.1, 4.2 and 4.3.

- Run 001_data_cleaning.do before running this code.

*/

capture clear
capture clear matrix
set more off

cd "/Users/panos/DATA/GitHub/tax_discount" //change accordingly

cap mkdir "OUT"
cap mkdir "LOG"
cap mkdir "DTA"
cap log close

log using "LOG/002_thresholds.txt", replace

use "DTA/SAMPLE_PANEL.dta" // using cleaned panel dataset

merge m:1 N using "DTA/SAMPLE_FIXED.dta" // merging individual characteristics

*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

*** Formating Data for Analysis ***

*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

gen mdate=mofd(mdy(month,1,year)) // setting time
format mdate %tm
xtset N mdate, monthly

gen below=1 if pthresh_to_m12<0 // binarry variable: individuals below threshold
replace below=0 if below==.

* Threshold-Targeting Variables

gen stat_diff=epay100-threshold100 // difference between reported and pre-filled

gen stat_diff_sp=epay_sp100-threshold_sp100

gen cons_diff_abs=consumption2017-threshold

gen stat_diff_abs=epay-threshold

gen difference=epay-consumption2017


*gen Difference=EPay-consumption2017 if winner_type3==1
*replace Difference=EPayPartner-consumption2017 if winner_type2==1

global conditions = "income_ind>0 & (main_income_source==1 | main_income_source==2 | main_income_source==3) & joint_file==0"
// exclude zero income declared, self-employed and those filing jointly


*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

*** Reported Electronic Consumption ***

*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


* Taxpayer Mass Calculation - Broad (+/- 8000)

xtsum N if stat_diff_abs>=-50 & stat_diff_abs<=50 & $conditions
local n = r(n)
xtsum N if stat_diff_abs>50 & $conditions
local m = r(n)
xtsum N if stat_diff_abs<-50 & $conditions
local l = r(n)

local all_per=`n'+`m'+`l'
local n_per=round((`n'/`all_per')*100)
local m_per=round((`m'/`all_per')*100)
local l_per=round((`l'/`all_per')*100)


* Histogram - Broad (+/- 8000)

twoway histogram stat_diff_abs if stat_diff_abs>-8000 & stat_diff_abs<8000 & $conditions, ///
								width(100) frac xlabel(#20, angle(45)) ///
								xtitle("Reported") scheme(plotplain) ///
								text( 0.0715 6800 "Taxpayer Mass" , place(nw) just(left) ///
								margin(l+4 t+1 b+1) width(30)) ///
								text( 0.0638 10000 "   0 : `n' (`n_per'%) " "< 0 : `l' (`l_per'%)" " ///
								> 0 : `m' (`m_per'%)", place(nw) just(left) margin(l+4 t+1 b+1) width(30)) ///
								name(hist_declared_broad, replace) nodraw

* Taxpayer Mass Calculation - Narrow (+/- 2000)

xtsum N if stat_diff_abs>=-50 & stat_diff_abs<=50 & $conditions
local n = r(n)
xtsum N if stat_diff_abs>50 & $conditions
local m = r(n)
xtsum N if stat_diff_abs<-50 & $conditions
local l = r(n)

local all_per=`n'+`m'+`l'
local n_per=round((`n'/`all_per')*100)
local m_per=round((`m'/`all_per')*100)
local l_per=round((`l'/`all_per')*100)


*Histogram - Narrow (+/- 2000)

twoway histogram stat_diff_abs if stat_diff_abs>-2000 & stat_diff_abs<2000 & $conditions, ///
 									width(20) frac xlabel(#20, angle(45)) ///
									xtitle("Reported") scheme(plotplain) ///
									text( 0.01515 1500 "Taxpayer Mass" , place(nw) just(left) ///
									margin(l+4 t+1 b+1) width(30)) ///
									text( 0.01378 2300 "   0 : `n' (`n_per'%) " "< 0 : `l' (`l_per'%)" " ///
									> 0 : `m' (`m_per'%)", place(nw) just(left) margin(l+4 t+1 b+1) width(30)) ///
									name(hist_declared_narrow, replace) nodraw

*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

*** Pre-filled Electronic Consumption ***

*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


* Taxpayer Mass Calculation - Broad (+/- 8000)

xtsum N if cons_diff_abs>=-50 & cons_diff_abs<=50 & $conditions
local n = r(n)
xtsum N if cons_diff_abs>50 & $conditions
local m = r(n)
xtsum N if cons_diff_abs<-50 & $conditions
local l = r(n)

local all_per=`n'+`m'+`l'
local n_per=round((`n'/`all_per')*100)
local m_per=round((`m'/`all_per')*100)
local l_per=round((`l'/`all_per')*100)


* Histogram - Broad (+/- 8000)

twoway histogram cons_diff_abs if cons_diff_abs>-8000 & cons_diff_abs<8000 ///
										& $conditions, width(100) frac xlabel(#20, angle(45)) ///
										xtitle("Pre-filled") scheme(plotplain) ///
										text( 0.0715 6800 "Taxpayer Mass" , place(nw) just(left) ///
										margin(l+4 t+1 b+1) width(30)) ///
										text( 0.0638 10000 "   0 : `n' (`n_per'%) " "< 0 : `l' (`l_per'%)" " ///
										> 0 : `m' (`m_per'%)", place(nw) just(left) margin(l+4 t+1 b+1) width(30)) ///
										name(hist_actual_broad, replace) nodraw

* Taxpayer Mass Calculation - Broad (+/- 2000)

xtsum N if cons_diff_abs>=-50 & cons_diff_abs<=50 & $conditions
local n = r(n)
xtsum N if cons_diff_abs>50 & $conditions
local m = r(n)
xtsum N if cons_diff_abs<-50 & $conditions
local l = r(n)

local all_per=`n'+`m'+`l'
local n_per=round((`n'/`all_per')*100)
local m_per=round((`m'/`all_per')*100)
local l_per=round((`l'/`all_per')*100)

* Histogram - Narrow (+/- 2000)

twoway histogram cons_diff_abs if cons_diff_abs>-2000 & cons_diff_abs<2000 & ///
													$conditions, width(20) frac xlabel(#20, angle(45)) ///
													xtitle("Pre-filled") scheme(plotplain) ///
													text( 0.01515 1500 "Taxpayer Mass" , place(nw) just(left) ///
													margin(l+4 t+1 b+1) width(30)) ///
													text( 0.01378 2300 "   0 : `n' (`n_per'%) " "< 0 : `l' (`l_per'%)" " ///
													> 0 : `m' (`m_per'%)", place(nw) just(left) margin(l+4 t+1 b+1) width(30)) ///
													name(hist_actual_narrow, replace) nodraw


*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

*** Output: Figures A.1 and 4.1 ***

*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

*Figure A.1
graph combine hist_declared_broad hist_actual_broad, ///
			cols(1) ycommon iscale(0.7273) ysize(8) graphregion(margin(zero))

graph save "OUT/figA_1", replace


*Figure 4.1
graph combine hist_declared_narrow hist_actual_narrow, ///
			cols(1) ycommon iscale(0.7273) ysize(8) graphregion(margin(zero))

graph save "OUT/fig4_1", replace

// NOTE that both graphs need some editing



*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

*** Responses in the Reporting Margin ***

*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

*** Within Taxpayer Consumption Difference ***

xtsum N if difference>=-50 & difference<=50 & $conditions
local n = r(n)
xtsum N if difference>50 & $conditions
local m = r(n)
xtsum N if difference<-50 & $conditions
local l = r(n)

local all_per=`n'+`m'+`l'
local n_per=round((`n'/`all_per')*100)
local m_per=round((`m'/`all_per')*100)
local l_per=round((`l'/`all_per')*100)


histogram difference if difference<=1000 & difference>=-1000 & $conditions, ///
			width(10) frac xlabel(#30, angle(45)) xtitle("Euros") scheme(plotplain) ///
			text( 0.15 700 "Taxpayer Mass" , place(nw) just(left) margin(l+4 t+1 b+1) ///
			width(30)) text( 0.135 1100 "   0 : `n' (`n_per'%) " "< 0 : `l' (`l_per'%)" "> 0 : ///
			`m' (`m_per'%)", place(nw) just(left) margin(l+4 t+1 b+1) width(30)) ///
			name(difference, replace) nodraw

*** Within-Taxpayer Difference - Below/Above Threshold ***

*Histogram of Individuals Below Threshold

xtsum N if difference>=-50 & difference<=50 & below==1 & $conditions
local n = r(n)
xtsum N if difference>50 & below==1 & $conditions
local m = r(n)
xtsum N if difference<-50 & below==1 & $conditions
local l = r(n)

local all_per=`n'+`m'+`l'
local n_per=round((`n'/`all_per')*100)
local m_per=round((`m'/`all_per')*100)
local l_per=round((`l'/`all_per')*100)


histogram difference if difference<=2000 & difference>=-500 & below==1 & $conditions, ///
					width(10) frac xlabel(#30, angle(45)) scheme(plotplain) xtitle("Euros") ///
					text( 0.08 1500 "Taxpayer Mass" , place(nw) just(left) margin(l+4 t+1 b+1) width(30)) ///
					text( 0.071 2000 "   0 : `n' (`n_per'%) " "< 0 : `l' (`l_per'%)" " ///
					> 0 : `m' (`m_per'%)", place(nw) just(left) margin(l+4 t+1 b+1) width(30)) ///
					name(hist_below, replace) nodraw

*Histogram of Individuals Above Threshold

xtsum N if difference>=-50 & difference<=50 & below==0 & $conditions
local n = r(n)
xtsum N if difference>50 & below==0 & $conditions
local m = r(n)
xtsum N if difference<-50 & below==0 & $conditions
local l = r(n)

local all_per=`n'+`m'+`l'
local n_per=round((`n'/`all_per')*100)
local m_per=round((`m'/`all_per')*100)
local l_per=round((`l'/`all_per')*100)


histogram difference if difference<=2000 & difference>=-500 & below==0 & $conditions, ///
						width(10) frac xlabel(#30, angle(45)) scheme(plotplain) xtitle("Euros") ///
						text( 0.08 1500 "Taxpayer Mass" , place(nw) just(left) margin(l+4 t+1 b+1) width(30)) ///
						text( 0.071 2000 "   0 : `n' (`n_per'%) " "< 0 : `l' (`l_per'%)" " ///
						> 0 : `m' (`m_per'%)", place(nw) just(left) margin(l+4 t+1 b+1) width(30)) ///
						name(hist_above, replace) nodraw


*** Within-Taxpayer Difference - Income Decomposition ***

* Income Group: 1-2500 EUR

histogram difference if income_ind<=2500 & difference<=2000 & difference>-500 & ///
						below==1 & $conditions, width(10) frac xlabel(#30, angle(45)) xtitle("Euros") ///
						title("1 - 2500") scheme(plotplain) name(hist_below_0_25, replace) nodraw


* Income Group: 2501-5000 EUR

histogram difference if income_ind>2500 & income_ind<=5000 & ///
						difference<=2000 & difference>-500 & below==1 & $conditions, ///
						width(10) frac xlabel(#30, angle(45)) xtitle("Euros") title("2501 - 5000") ///
						scheme(plotplain) name(hist_below_25_50, replace) nodraw

* Income Group: 5001-7500 EUR

histogram difference if income_ind>5000 & income_ind<=7500 & ///
						difference<=2000 & difference>-500 & below==1 & $conditions, ///
						width(10) frac xlabel(#30, angle(45)) xtitle("Euros") title("5001 - 7500") ///
						scheme(plotplain) name(hist_below_50_75, replace) nodraw

* Income Group: 10001-20000 EUR

histogram difference if income_ind>7500 & income_ind<=10000 ///
 						& below==1 & difference<=2000 & difference>-500 & $conditions, ///
						width(10) frac xlabel(#30, angle(45)) xtitle("Euros") title("7501 - 10000") ///
						scheme(plotplain) name(hist_below_75_100, replace) nodraw

*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

*** Output: Figures 4.2, 4.3, 4.4 ***

*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

*Figure 4.2
graph display difference
graph save "OUT/fig4_2", replace

*Figure 4.3
graph combine hist_below hist_above, ///
 			cols(1) ycommon iscale(0.7273) ysize(8) graphregion(margin(zero))
graph save "OUT/fig4_3", replace

*Figure 4.4
graph combine hist_below_0_25 hist_below_25_50 hist_below_50_75 hist_below_75_100, ///
			cols(2) row(2) iscale(0.5) ycommon xcommon graphregion(margin(zero))

graph save "OUT/fig4_4", replace

clear
