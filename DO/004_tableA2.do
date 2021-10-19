*This code produces main sample statistics as shown in Table A.2 in Appendix A.1

capture clear
capture clear matrix
set more off

cd "/Users/panos/DATA/GitHub/tax_discount" //change accordingly

cap mkdir "OUT"
cap mkdir "LOG"
cap mkdir "DTA"

cap log close
log using "LOG/004_tableA2.txt", replace

use "DTA/SAMPLE_FIXED.dta" // using cleaned dataset with fixed characteristics

global conditions = "income_ind>0 & (main_income_source==1 | main_income_source==2 | main_income_source==3) & joint_file==0"

*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

*** Table A.2 ***

*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

* Breakdown by income category

tab main_income_source

outreg2 main_income_source using "OUT/sums_stats.tex", ///
                    ctitle(Total) sdec(1) noas cross replace

* Breakdown by single- versus joint-filing household

tab main_income_source joint_file, column

outreg2 main_income_source joint_file using "OUT/sums_stats.tex", ///
                    sdec(1) noas cross append

* ECTD Eligible Sample: Single filers, Income more than 0, exluding self-employed

tab main_income_source if $conditions

outreg2 main_income_source if $conditions using "OUT/sums_stats.tex", ///
                    sdec(1) noas cross append

// NOTE that some post editing needed

clear
