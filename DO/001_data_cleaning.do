*This code cleans the 50,000 sample & creates 3 datasets: Raw, Fixed and Panel

capture clear
capture clear matrix
set more off

cd "/Users/panos/DATA/GitHub/tax_discount" //change accordingly

cap mkdir "OUT"
cap mkdir "LOG"
cap mkdir "DTA"

cap log close
log using "LOG/001_data_cleaning.txt", replace

import excel "XLS/lottery_sample_ENG.xlsx", firstrow clear //NOTE: see XLS/README_XLS

*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*

*** Raw Dataset ***

*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*

*Renaming the Lotteries
rename (January2017Lottery10 February2017Lottery9 March2017Lottery8 ///
April2017Lottery7 May2017Lottery6 June2017Lottery5 July2017Lottery4 ///
August2017Lotery3 September2017Lottery2 October2017Lottery1 ///
November2017Lottery11 December2017Lottery12 January2018Lottery13 ///
February2018Lottery14 March2018Lottery15 April2018Lottery16 May2018Lottery17 ///
June2018Lottery18 July2018Lottery19)(m1 m2 m3 m4 m5 m6 m7 m8 m9 m10 m11 m12 ///
m13 m14 m15 m16 m17 m18 m19)

*Renaming variables
rename (ΕΝΔΕΙΞΗ ΚΩΔ301 ΚΩΔ302 ΚΩΔ303 ΚΩΔ304 ΚΩΔ321 ΚΩΔ322 ΚΩΔ475 ΚΩΔ476 ///
ΚΩΔ401 ΚΩΔ402 ΚΩΔ049 ΚΩΔ050)(indicator wg_m wg_s pen_m ///
pen_s xpen_m xpen_s agr_m agr_s seb_m seb_s ///
epay_m epay_s)

*Labeling all new variables
label variable m1 "Total Electronic Payments Jan 2017"
label variable m2 "Total Electronic Payments Feb 2017"
label variable m3 "Total Electronic Payments Mar 2017"
label variable m4 "Total Electronic Payments Apr 2017"
label variable m5 "Total Electronic Payments May 2017"
label variable m6 "Total Electronic Payments Jun 2017"
label variable m7 "Total Electronic Payments Jul 2017"
label variable m8 "Total Electronic Payments Aug 2017"
label variable m9 "Total Electronic Payments Sept 2017"
label variable m10 "Total Electronic Payments Oct 2017"
label variable m11 "Total Electronic Payments Nov 2017"
label variable m12 "Total Electronic Payments Dec 2017"
label variable m13 "Total Electronic Payments Jan 2018"
label variable m14 "Total Electronic Payments Feb 2018"
label variable m15 "Total Electronic Payments Mar 2018"
label variable m16 "Total Electronic Payments Apr 2018"
label variable m17 "Total Electronic Payments May 2018"
label variable m18 "Total Electronic Payments Jun 2018"
label variable m19 "Total Electronic Payments Jul 2018"
label variable N "Unique ID number"
label variable indicator "Person who submitted tax declaration"
label variable wg_m "Annual Declared Income from Waged Activity for 2017"
label variable wg_s "Annual Declared Income of Spouse from Waged Activity for 2017"
label variable pen_m "Annual Income from Main Pension for 2017"
label variable pen_s "Annual Income of Spouse from Main Pension for 2017"
label variable xpen_m "Annual Income from Auxilliary Pension for 2017"
label variable xpen_s "Annual Income of Spouse from Auxilliary Pension for 2017"
label variable agr_m "Annual Declared Income from Agricultural Activity for 2017"
label variable agr_s "Annual Declared Income of Spouse from Agricultural Activity for 2017"
label variable seb_m "Annual Declared Net Profit from Business Activities for 2017"
label variable seb_s "Annual Declared Net Profit of Partner from Business Activities for 2017"
label variable epay_m "Total Annual Declared Payments by Electronic Means for 2017"
label variable epay_s "Total Annual Declared Payments by Electronic Means for Partner for 2017"

sort N
save "DTA/SAMPLE_RAW.dta", replace


*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*

*** Fixed Dataset ***

*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*


*Destring and encode remaining variables
destring N, replace

encode indicator, gen(ind)
label drop ind
recode ind (1=2) (2=3)
label define ind 2 "Spouse" 3 "Taxpayer"
drop indicator

*** Linking consumption information with tax returns ***

*Income

gen income_m = wg_m+pen_m+xpen_m+agr_m+seb_m
gen income_s = wg_s+pen_s+xpen_s+agr_s+seb_s

tab ind, gen(indicator) // 1=Tax return Not Submitted, 2=Spouse Information, 3=Main Taxpayer Info
rename (indicator1 indicator2) (indicator2 indicator3) //non-submitted only in winners sample

gen income_ind=income_m if indicator3==1
replace income_ind=income_s if indicator2==1

gen income_ind_s=income_s if indicator3==1
replace income_ind_s=income_m if indicator2==1

*** Generating Thresholds ***

* Main Taxpayer Threshold (Nominal and Percentage of Income)

gen threshold=income_ind*0.1 if income_ind>=0 & income_ind<=10000
replace threshold=(incomde_ind-10000)*0.15+1000 if income_ind>10000 & income_ind<=30000
replace threshold=(income_ind-30000)*0.20+4000 if income_ind>30000
replace threshold=30000 if income_ind>=160000 //maximum electronic payments of 30,000

gen threshold100=100*(threshold/income_ind) //Percentage of threshold that must be reached to avoid tax credit penalty
replace threshold100=0 if income_ind==0 //Avoiding division by 0, in the command above
gen rthreshold100=round(threshold100)

* Partner Threshold (Nominal and Percentage of Income)

gen threshold_sp=income_ind_s*0.1 if income_ind_s>=0 & income_ind_s<=10000
replace threshold_sp=(income_ind_s-10000)*0.15+1000 if income_ind_s>10000 & income_ind_s<=30000
replace threshold_sp=(income_ind_s-30000)*0.20+4000 if income_ind_s>30000
replace threshold_sp=30000 if income_ind_s>=160000

gen threshold_sp100=100*(threshold_sp/income_ind_s)
replace threshold_sp100=0 if income_ind_s==0 //Avoiding division by 0, in the command above
gen rthreshold_sp100=round(threshold_sp100)


*** Electronic Payments Responses ***

gen epay=epay_m if indicator3==1
replace epay=epay_s if indicator2==1

gen epay_sp=epay_s if indicator3==1
replace epay_sp=epay_m if indicator2==1

gen epay_y=epay/income_ind
replace epay_y=0 if income_ind==0 //Avoiding division by 0, in the command above

gen epay_y_sp=epay_sp/income_ind_s
replace epay_y_sp=0 if income_ind_s==0 //Avoiding division by 0, in the command above


gen epay100=epay_y*100 //049 code as a percentage of income - percentage of income declared as paid by electronic means in 2017
replace epay100=0 if income_ind==0 //Avoiding division by 0, in the command above

gen epay_sp100=epay_y_sp*100 //050 code as a percentage of income - percentage of income declared as paid by electronic means in 2017
replace epay_sp100=0 if income_ind_s==0 //Avoiding division by 0, in the command above


*Monthly Evolution to Threshold *

forvalues n=1(1)12{
gen m`n'_100=100*(m`n'/income_ind)
replace m`n'_100=0 if income_ind==0 //some have 0 declared income, but positive consumption. We avoid devision by 0 in the command line above.
}
gen m1_to_thresh=m1_100
gen m2_to_thresh=m1_100+m2_100
gen m3_to_thresh=m1_100+m2_100+m3_100
gen m4_to_thresh=m1_100+m2_100+m3_100+m4_100
gen m5_to_thresh=m1_100+m2_100+m3_100+m4_100+m5_100
gen m6_to_thresh=m1_100+m2_100+m3_100+m4_100+m5_100+m6_100
gen m7_to_thresh=m1_100+m2_100+m3_100+m4_100+m5_100+m6_100+m7_100
gen m8_to_thresh=m1_100+m2_100+m3_100+m4_100+m5_100+m6_100+m7_100+m8_100
gen m9_to_thresh=m1_100+m2_100+m3_100+m4_100+m5_100+m6_100+m7_100+m8_100+m9_100
gen m10_to_thresh=m1_100+m2_100+m3_100+m4_100+m5_100+m6_100+m7_100+m8_100+m9_100+m10_100
gen m11_to_thresh=m1_100+m2_100+m3_100+m4_100+m5_100+m6_100+m7_100+m8_100+m9_100+m10_100+m11_100
gen m12_to_thresh=m1_100+m2_100+m3_100+m4_100+m5_100+m6_100+m7_100+m8_100+m9_100+m10_100+m11_100+m12_100


forvalues n=1(1)12{
gen pthresh_to_m`n'=m`n'_to_thresh-threshold100
}

forvalues n=1(1)12{
gen thresh_to_m`n'=threshold-((m`n'_to_thresh/100)*income_ind)
}

*Other time-invariant variables

gen consumption2017 = m1+m2+m3+m4+m5+m6+m7+m8+m9+m10+m11+m12 //Consumption in 2017
gen cons100 = (consumption2017/income_ind)*100 //Consumption in 2017, percentage of income
gen total_pen_m = pen_m+xpen_m //Main and Auxilliary Pension, main taxpayer
gen total_pen_s = pen_s+xpen_s //Main and Auxilliary Pension, spouse of taxpayer
gen income_house = income_m+income_s //Total Household Income

* Household binary variables

gen joint_file=1 if income_m>0 & income_s>0 //Dummy for filing jointly (narrow)
replace joint_file=1 if joint_file==. & income_s>0 & income_m==0
replace joint_file=0 if joint_file==.

/*We can use some additional information to distinguish people leaving together
this is the percentage of electronic transactions in the tax returns (Epay and epay partner)
and if both spouses income is 0, but we have information on consumption from the spouse
the same is not true for the main taxpayer as we don't know if he is single. The following
variable is a bit broader than the joint filing above*/

gen house=1 if income_m>0 & (income_ind_s>0 | epay_s>0)
replace house=1 if house==. & income_ind_s>0 & (income_m==0 | epay_m>0)
replace house=1 if house==. & indicator2==1
replace house=0 if house==.

*Generating Income Categories for main taxpayer

gen y_source_m=1 if wg_m>0 & total_pen_m==0 & agr_m==0 & seb_m==0 //Income from Wages only
replace y_source_m=2 if total_pen_m>0 & wg_m==0 & seb_m==0 & agr_m==0 // Pension only
replace y_source_m=3 if seb_m>0 & wg_m==0 & total_pen_m==0 & agr_m==0 // Business income only
replace y_source_m=4 if agr_m>0 & wg_m==0 & total_pen_m==0 & seb_m==0 // Agricultural Income only
replace y_source_m=5 if wg_m>0 & total_pen_m>0 & agr_m==0 & seb_m==0 // Wages and Pension
replace y_source_m=6 if wg_m>0 & seb_m>0 & total_pen_m==0 & agr_m==0 //Wages and Business
replace y_source_m=7 if wg_m>0 & agr_m>0 & total_pen_m==0 & seb_m==0 // Wages and Agriculture
replace y_source_m=8 if total_pen_m>0 & seb_m>0 & wg_m==0 & agr_m==0 // Pension and Business
replace y_source_m=9 if total_pen_m>0 & agr_m>0 & wg_m==0 & seb_m==0 // Pension and Agriculture
replace y_source_m=10 if total_pen_m==0 & agr_m>0 & wg_m==0 & seb_m>0 // Business and Agriculture
replace y_source_m=11 if total_pen_m>0 & agr_m==0 & wg_m>0 & seb_m>0 // Wages, Pension and Business
replace y_source_m=12 if total_pen_m>0 & agr_m>0 & wg_m>0 & seb_m==0 // Wages, Pension and Agriculture
replace y_source_m=13 if total_pen_m==0 & agr_m>0 & wg_m>0 & seb_m>0 // Wages, Business and Agriculture
replace y_source_m=14 if total_pen_m>0 & agr_m>0 & wg_m==0 & seb_m>0 //Pension, Business and Agriculture
replace y_source_m=15 if total_pen_m>0 & agr_m>0 & wg_m>0 & seb_m>0 // All sources
replace y_source_m=16 if total_pen_m==0 & agr_m==0 & wg_m==0 & seb_m==0 //Zero declared income

*Generating Income Categories for spouses

gen y_source_s=1 if wg_s>0 & total_pen_s==0 & agr_s==0 & seb_s==0 //Income from Wages only
replace y_source_s=2 if total_pen_s>0 & wg_s==0 & seb_s==0 & agr_s==0 // Pension only
replace y_source_s=3 if seb_s>0 & wg_s==0 & total_pen_s==0 & agr_s==0 // Business income only
replace y_source_s=4 if agr_s>0 & wg_s==0 & total_pen_s==0 & seb_s==0 // Agricultural Income only
replace y_source_s=5 if wg_s>0 & total_pen_s>0 & agr_s==0 & seb_s==0 // Wages and Pension
replace y_source_s=6 if wg_s>0 & seb_s>0 & total_pen_s==0 & agr_s==0 //Wages and Business
replace y_source_s=7 if wg_s>0 & agr_s>0 & total_pen_s==0 & seb_s==0 // Wages and Agriculture
replace y_source_s=8 if total_pen_s>0 & seb_s>0 & wg_s==0 & agr_s==0 // Pension and Business
replace y_source_s=9 if total_pen_s>0 & agr_s>0 & wg_s==0 & seb_s==0 // Pension and Agriculture
replace y_source_s=10 if total_pen_s==0 & agr_s>0 & wg_s==0 & seb_s>0 // Business and Agriculture
replace y_source_s=11 if total_pen_s>0 & agr_s==0 & wg_s>0 & seb_s>0 // Wages, Pension and Business
replace y_source_s=12 if total_pen_s>0 & agr_s>0 & wg_s>0 & seb_s==0 // Wages, Pension and Agriculture
replace y_source_s=13 if total_pen_s==0 & agr_s>0 & wg_s>0 & seb_s>0 // Wages, Business and Agriculture
replace y_source_s=14 if total_pen_s>0 & agr_s>0 & wg_s==0 & seb_s>0 //Pension, Business and Agriculture
replace y_source_s=15 if total_pen_s>0 & agr_s>0 & wg_s>0 & seb_s>0 // All sources
replace y_source_s=16 if total_pen_s==0 & agr_s==0 & wg_s==0 & seb_s==0 //Zero declared income OR no spouse

*Generating Income Categories for individuals (both main taxpayer and spouse) not receiving any business income

gen y_SEB=1 if y_source_m==3 | y_source_m==6 | y_source_m==8 | y_source_m==11 | y_source_m==13 | y_source_m==14 ///
| y_source_m==15 | y_source_s==3 | y_source_s==6 | y_source_s==8 | y_source_s==11 | y_source_s==13 ///
| y_source_s==14 | y_source_s==15
replace y_SEB=0 if y_SEB==.

tab y_SEB

*Generating Primary Income Categories for main taxpayer

gen y_primary_m=max(wg_m,total_pen_m,seb_m,agr_m) if y_source_m!=16
replace y_primary_m=1 if y_primary_m==wg_m
replace y_primary_m=2 if y_primary_m==total_pen_m
replace y_primary_m=3 if y_primary_m==seb_m
replace y_primary_m=4 if y_primary_m==agr_m

*Generating Primary Income Categories for spouse

gen y_primary_s=max(wg_s,total_pen_s,seb_s,agr_s) if y_source_s!=16
replace y_primary_s=1 if y_primary_s==wg_s
replace y_primary_s=2 if y_primary_s==total_pen_s
replace y_primary_s=3 if y_primary_s==seb_s
replace y_primary_s=4 if y_primary_s==agr_s


/*Generating combined income category. This correspond to the information we
have on e-transactions. 0 is SEB, 1 WG, 2 PEN, 3 AGR and 4 0-income declared*/

gen main_income_source=0 if y_primary_m==3 & indicator3==1
replace main_income_source=0 if y_primary_s==3 & indicator2==1
replace main_income_source=1 if y_primary_m==1 & indicator3==1
replace main_income_source=1 if y_primary_s==1 & indicator2==1
replace main_income_source=2 if y_primary_m==2 & indicator3==1
replace main_income_source=2 if y_primary_s==2 & indicator2==1
replace main_income_source=3 if y_primary_m==4 & indicator3==1
replace main_income_source=3 if y_primary_s==4 & indicator2==1
replace main_income_source=4 if y_primary_m==. & indicator3==1
replace main_income_source=4 if y_primary_s==. & indicator2==1
replace main_income_source=5 if main_income_source==. // winners who have not submitted tax returns



gen y_SEB_primary_m=1 if main_income_source==0
replace y_SEB_primary_m=0 if y_SEB_primary==.

gen y_SEB_primary_s=1 if y_primary_s==3 & indicator3==1 & joint_file==1
replace y_SEB_primary_s=1 if y_primary_m==3 & indicator2==1 & joint_file==1
replace y_SEB_primary_s=0 if y_SEB_primary_s==.

gen y_SEB_primary_joint=1 if y_primary_m==3 & y_primary_s==3
replace y_SEB_primary_joint=0 if y_SEB_primary_joint==.

gen y_WG_primary_m=1 if main_income_source==1
replace y_WG_primary_m=0 if y_WG_primary_m==.

gen y_WG_primary_s=1 if y_primary_s==1 & indicator3==1 & joint_file==1
replace y_WG_primary_s=1 if y_primary_m==1 & indicator2==1 & joint_file==1
replace y_WG_primary_s=0 if y_WG_primary_s==.

gen y_PEN_primary_m=1 if main_income_source==2
replace y_PEN_primary_m=0 if y_PEN_primary_m==.

gen y_PEN_primary_s=1 if y_primary_s==2 & indicator3==1 & joint_file==1
replace y_PEN_primary_s=1 if y_primary_m==2 & indicator2==1 & joint_file==1
replace y_PEN_primary_s=0 if y_PEN_primary_s==.

gen y_AGR_primary_m=1 if main_income_source==3
replace y_AGR_primary_m=0 if y_AGR_primary_m==.

gen y_AGR_primary_s=1 if y_primary_s==4 & indicator3==1 & joint_file==1
replace y_AGR_primary_s=1 if y_primary_m==4 & indicator2==1 & joint_file==1
replace y_AGR_primary_s=0 if y_AGR_primary_s==.

compress
sort N
save "DTA/SAMPLE_FIXED.dta", replace


*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*

*** Creating Panel Dataset ***

*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*


*Stripping for year 2017

forvalues m=1(1)12{
use "DTA/SAMPLE_FIXED.dta"
keep N m`m' m`m'_to_thresh thresh_to_m`m' pthresh_to_m`m'
rename m`m' consumption
rename m`m'_to_thresh cons_evo
rename thresh_to_m`m' thresh_evo
rename pthresh_to_m`m' pthresh_evo
gen year = 2017
gen month = `m'
compress
save "DTA/SAMPLE_2017_`m'.dta",replace
clear
}

*Stripping for year 2018

forvalues m=13(1)19{
use "DTA/SAMPLE_FIXED.dta"
keep N m`m'
local n=(-12+`m')
rename m`m' consumption
gen year = 2018
gen month = `n'
compress
save "DTA/SAMPLE_2018_`n'.dta",replace
clear
}

use "DTA/SAMPLE_2017_1.dta"
erase "DTA/SAMPLE_2017_1.dta"
forvalues m=2(1)12{
append using "DTA/SAMPLE_2017_`m'.dta"
erase "DTA/SAMPLE_2017_`m'.dta"
}

forvalues m=1(1)7{
append using "DTA/SAMPLE_2018_`m'.dta"
erase "DTA/SAMPLE_2018_`m'.dta"
}

compress
sort N year month
order N year month
save "DTA/SAMPLE_PANEL.dta",replace

*Final Output three datasets for the Random Sample: Raw, Panel, and Fixed.
/*Merging and check for consistency
use "DTA/SAMPLE_PANEL.dta", clear
merge m:1 N using "DTA/SAMPLE_FIXED.dta"
bysort N: egen consumption_2017=sum(consumption) if year==2017
*su consumption_2017
*su consumption2017 if year==2017
gen diff= consumption_2017 - consumption2017 if year==2017
su diff
drop diff consumption_2017
*/

clear
