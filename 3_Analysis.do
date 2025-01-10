

*Felix Bittmann, 2025

********************************************************************************
*** Imputation ***
********************************************************************************
quiet do "Dos/Preparation.do"
sum static DYN CWT
fre female

tabstat static DYN CWT, stats(mean N) by(female)
pwcorr DYN DYNB DNF, obs sig
pwcorr CWT CWTB CNF, obs sig


mi set flong
mi register imputed static points DYN CWT maxdepth maxdistance
mi impute chained (pmm, knn(5)) static maxdepth maxdistance DYN CWT ///
	= c.points##c.points##c.points i.land ///
	, add(25) burnin(18) rseed(6629312) dots by(female)	
replace DYN = . if distmiss == 1		//Only impute values where auxils available
replace CWT = . if depthmiss == 1		//Only impute values where auxils available

mi estimate: mean static		//To check case numbers
mi estimate: mean DYN
mi estimate: mean CWT

tabstat static DYN CWT, stats(mean N) by(female)

compress
save "Data/Imputed.dta", replace



********************************************************************************
use "Data/Imputed.dta", clear


*** Testing case numbers ***
foreach VAR of varlist static DYN CWT {
	gen valid_`VAR' = !missing(`VAR') & _mi_m > 0
}
graph bar valid_* if _mi_m > 0, over(female) ///
	legend(position(6) row(1) order(1 "STA" 2 "DYN" 3 "CWT")) ///
	blabel(bar, format(%6.2f)) ytitle("Share with valid results") ///
	title("After imputation")
graph save "Output/count_after", replace
graph export "Output/count_after.png", replace as(png) width(2500)
graph combine "Output/count_before" "Output/count_after", xcommon ycommon fysize(80)
graph save "Output/count_both", replace
graph export "Output/count_both.png", replace as(png) width(2500)
drop valid_*



*** Descriptive graphs ***
twoway (kdensity static if female == 0 & _mi_m > 0, lcolor(gs8%80)) ///
	(kdensity static if female == 1 & _mi_m > 0, lcolor(black%90)) ///
	, legend(position(6) order(1 "Men" 2 "Women") row(1)) ///
	xtitle("Static time [sec]") name(g1, replace) ytitle("")
	
twoway (kdensity DYN if female == 0 & _mi_m > 0, lcolor(gs8%80)) ///
	(kdensity DYN if female == 1 & _mi_m > 0, lcolor(black%90)) ///
	, legend(position(6) order(1 "Men" 2 "Women") row(1)) ///
	xtitle("Distance DYN [m]") name(g2, replace) ytitle("")
	
twoway (kdensity CWT if female == 0 & _mi_m > 0, lcolor(gs8%80)) ///
	(kdensity CWT if female == 1 & _mi_m > 0, lcolor(black%90)) ///
	, legend(position(6) order(1 "Men" 2 "Women") row(1)) ///
	xtitle("Depth CWT [m]") name(g3, replace) ytitle("")
graph combine g1 g2 g3, row(1) fysize(65)
graph save "Output/kdensity", replace
graph export "Output/kdensity.png", replace as(png) width(2500)


*** CDF using distplot ***
distplot static if _mi_m > 0, over(female) midpoint ///
	legend(position(6) row(1)) name(g1, replace) ytitle("")
distplot DYN if _mi_m > 0, over(female) midpoint ///
	legend(position(6) row(1)) name(g2, replace) ytitle("")
distplot CWT if _mi_m > 0, over(female) midpoint ///
	legend(position(6) row(1)) name(g3, replace) ytitle("")
graph combine g1 g2 g3, row(1) fysize(65)
graph save "Output/distplot", replace
graph export "Output/distplot.png", replace as(png) width(2500)


*** Check of linearity ***
binscatter static DYN if _mi_m > 0, by(female) ///
	legend(position(6) order(1 "Men" 2 "Women") row(1)) ///
	xtitle("Distance DYN [m]") ytitle("Static time [sec]") ///
	name(g1, replace)
	
binscatter static CWT if _mi_m > 0, by(female) ///
	legend(position(6) order(1 "Men" 2 "Women") row(1)) ///
	xtitle("Depth CWT [m]") ytitle("Static time [sec]") ///
	name(g2, replace)
	
binscatter DYN CWT if _mi_m > 0, by(female) ///
	legend(position(6) order(1 "Men" 2 "Women") row(1)) ///
	xtitle("Depth CWT [m]") ytitle("Distance DYN [m]") ///
	name(g3, replace)
graph combine g1 g2 g3, row(1)
graph save "Output/linearity", replace
graph export "Output/linearity.png", replace as(png) width(2500)

	

*** Description Tables ***
eststo M1: estpost summarize static DYN CWT if _mi_m > 0, det
eststo M2: estpost summarize static DYN CWT if _mi_m > 0 & female == 0, det
eststo M3: estpost summarize static DYN CWT if _mi_m > 0 & female == 1, det
esttab M1 using "Output/Deskription.rtf", ///
	cells("mean(fmt(a2)) sd p25 p50 p75 min max") rtf replace label ///
	title("Complete sample") nogaps nonumbers
esttab M2 using "Output/Deskription.rtf", ///
	cells("mean(fmt(a2)) sd p25 p50 p75 min max") rtf append label ///
	title("Men") nogaps nonumbers
esttab M3 using "Output/Deskription.rtf", ///
	cells("mean(fmt(a2)) sd p25 p50 p75 min max") rtf append label ///
	title("Women") nogaps nonumbers
sum static DYN CWT if _mi_m == 1			//For case numbers
sum static DYN CWT if female == 0 & _mi_m == 1		
sum static DYN CWT if female == 1 & _mi_m == 1


*** Additional percentile statistics ***
preserve
keep if _mi_m > 0
collapse (p10) static_10 = static DYN_10 = DYN CWT_10 = CWT ///
	(p20) static_20 = static DYN_20 = DYN CWT_20 = CWT ///
	(p30) static_30 = static DYN_30 = DYN CWT_30 = CWT ///
	(p40) static_40 = static DYN_40 = DYN CWT_40 = CWT ///
	(p50) static_50 = static DYN_50 = DYN CWT_50 = CWT ///
	(p60) static_60 = static DYN_60 = DYN CWT_60 = CWT ///
	(p70) static_70 = static DYN_70 = DYN CWT_70 = CWT ///
	(p80) static_80 = static DYN_80 = DYN CWT_80 = CWT ///
	(p90) static_90 = static DYN_90 = DYN CWT_90 = CWT, by(female)
	
preserve
stack static* if female == 0, into(STA_male) clear
tempfile a
save `a', replace
restore

preserve
stack static* if female == 1, into(STA_female) clear
tempfile b
save `b', replace
restore

preserve
stack DYN* if female == 0, into(DYN_male) clear
tempfile c
save `c', replace
restore

preserve
stack DYN* if female == 1, into(DYN_female) clear
tempfile d
save `d', replace
restore

preserve
stack CWT* if female == 0, into(CWT_male) clear
tempfile e
save `e', replace
restore

preserve
stack CWT* if female == 1, into(CWT_female) clear
tempfile f
save `f', replace
restore

clear
use `a'
merge 1:1 _n  using  `b', nogen
merge 1:1 _n  using  `c', nogen
merge 1:1 _n  using  `d', nogen
merge 1:1 _n  using  `e', nogen
merge 1:1 _n  using  `f', nogen
export excel using "Output/descriptives_deciles", firstrow(variables) replace
restore

		
********************************************************************************	
*** Gender Differences ***
********************************************************************************
eststo M1: mi estimate, post: reg static i.female, vce(hc3)
eststo M3: mi estimate, post: reg DYN i.female, vce(hc3)
eststo M5: mi estimate, post: reg CWT i.female, vce(hc3)

eststo M2: mi estimate, post: qreg static i.female, vce(robust)
eststo M4: mi estimate, post: qreg DYN i.female, vce(robust)
eststo M6: mi estimate, post: qreg CWT i.female, vce(robust)

esttab M1 M2 M3 M4 M5 M6 using "Output/regressions.rtf", rtf label nogaps ///
	nobase ci(1) nonumbers replace ///
	mtitles("OLS" "MED" "OLS" "MED" "OLS" "MED") addnotes("Imputed data (M=25)")


mibeta static female
mibeta DYN female
mibeta CWT female	
	

*** Correlations ***
pwcorr static DYN CWT if _mi_m > 0
pwcorr static DYN CWT if _mi_m == 1, obs
bysort female: pwcorr static DYN CWT if _mi_m > 0



*** Predictions ***
mi estimate: reg static DYN, vce(hc3)
mi estimate: reg static CWT, vce(hc3)
mi estimate: reg DYN static, vce(hc3)
mi estimate: reg DYN CWT, vce(hc3)
mi estimate: reg CWT static
mi estimate: reg CWT DYN, vce(hc3)


*** Predictions Graphically ***
cap drop extreme
gen extreme = (static > 600 & !missing(static)) | (DYN > 300 & !missing(DYN)) | (CWT > 110 & !missing(CWT))
fre extreme if _mi_m > 0


scatterfit DYN static if _mi_m > 0 & extreme == 0, by(female) fit(quadratic) binned ///
	opts(aspectratio(1) legend(position(6) row(1)))
graph save "Output/sta_dyn", replace
graph export "Output/sta_dyn.png", replace as(png) width(2500)


scatterfit CWT static if _mi_m > 0 & extreme == 0, by(female) fit(quadratic) binned ///
	opts(aspectratio(1) legend(position(6) row(1)))
graph save "Output/sta_cwt", replace
graph export "Output/sta_cwt.png", replace as(png) width(2500)


scatterfit CWT DYN if _mi_m > 0 & extreme == 0, by(female) fit(quadratic) binned ///
	opts(aspectratio(1) legend(position(6) row(1)))
graph save "Output/dyn_cwt", replace
graph export "Output/dyn_cwt.png", replace as(png) width(2500)




*** Show variability ***
set seed 867231
cap drop rand
gen rand = runiform()
twoway (scatter DYN static if rand < 0.02 & female == 0 & _mi_m > 0, jitter(3) mcolor(red%40)) ///
	(scatter DYN static if rand < 0.02 & female == 1 & _mi_m > 0, jitter(3) mcolor(sea%40)) ///
	, scheme(plotplainblind) legend(position(6) order(1 "Men" 2 "Women") row(1)) ///
	aspect(1) ylabel(0(50)300) xlabel(0(60)600)
graph save "Output/scatterplot", replace
graph export "Output/scatterplot.png", replace as(png) width(2500)
	

	
	
	
	
********************************************************************************
*** Variability II ***
********************************************************************************
***STA-DYN***
use "Data/Imputed.dta", clear
keep if female == 0
keep if _mi_m > 0
keep if !missing(static) & !missing(DYN)
xtile test = static, n(75)
keep static test DYN
collapse (median) time=static (p5) q5=DYN (p25) q25=DYN (p50) q50=DYN ///
	(p75) q75=DYN (p95) q95=DYN, by(test)

twoway (qfit q5 time, lpattern(shortdash)) ///
	(qfit q25 time, lpattern(dash)) ///
	(qfit q50 time, lpattern(solid)) ///
	(qfit q75 time, lpattern(dash)) ///
	(qfit q95 time, lpattern(shortdash)) ///
	, legend(position(6) row(1) order(1 "Q5" 2 "Q25" 3 "Q50" 4 "Q75" 5 "Q95")) ///
	aspect(1) xtitle("Static time [sec]") ytitle("Distance DYN [m]") title("Men") name(g1, replace)

use "Data/Imputed.dta", clear
keep if female == 1
keep if _mi_m > 0
keep if !missing(static) & !missing(DYN)
xtile test = static, n(75)
keep static test DYN
collapse (median) time=static (p5) q5=DYN (p25) q25=DYN (p50) q50=DYN ///
	(p75) q75=DYN (p95) q95=DYN, by(test)

twoway (qfit q5 time, lpattern(shortdash)) ///
	(qfit q25 time, lpattern(dash)) ///
	(qfit q50 time, lpattern(solid)) ///
	(qfit q75 time, lpattern(dash)) ///
	(qfit q95 time, lpattern(shortdash)) ///
	, legend(position(6) row(1) order(1 "Q5" 2 "Q25" 3 "Q50" 4 "Q75" 5 "Q95")) ///
	aspect(1) xtitle("Static time [sec]") ytitle("Distance DYN [m]") title("Women") name(g2, replace)
	
graph combine g1 g2, ycommon
graph save "Output/variabilitySTADYN", replace
graph export "Output/variabilitySTADYN.png", replace as(png) width(2500)

***STA-CWT***

use "Data/Imputed.dta", clear
keep if female == 0
keep if _mi_m > 0
keep if !missing(static) & !missing(CWT)
xtile test = static, n(75)
keep static test CWT
collapse (median) time=static (p5) q5=CWT (p25) q25=CWT (p50) q50=CWT ///
	(p75) q75=CWT (p95) q95=CWT, by(test)

twoway (qfit q5 time, lpattern(shortdash)) ///
	(qfit q25 time, lpattern(dash)) ///
	(qfit q50 time, lpattern(solid)) ///
	(qfit q75 time, lpattern(dash)) ///
	(qfit q95 time, lpattern(shortdash)) ///
	, legend(position(6) row(1) order(1 "Q5" 2 "Q25" 3 "Q50" 4 "Q75" 5 "Q95")) ///
	aspect(1) xtitle("Static time [sec]") ytitle("Depth CWT [m]") title("Men") name(g1, replace) ///
	ylabel(0(25)125)

use "Data/Imputed.dta", clear
keep if female == 1
keep if _mi_m > 0
keep if !missing(static) & !missing(CWT)
xtile test = static, n(75)
keep static test CWT
collapse (median) time=static (p5) q5=CWT (p25) q25=CWT (p50) q50=CWT ///
	(p75) q75=CWT (p95) q95=CWT, by(test)

twoway (qfit q5 time, lpattern(shortdash)) ///
	(qfit q25 time, lpattern(dash)) ///
	(qfit q50 time, lpattern(solid)) ///
	(qfit q75 time, lpattern(dash)) ///
	(qfit q95 time, lpattern(shortdash)) ///
	, legend(position(6) row(1) order(1 "Q5" 2 "Q25" 3 "Q50" 4 "Q75" 5 "Q95")) ///
	aspect(1) xtitle("Static time [sec]") ytitle("Depth CWT [m]") title("Women") name(g2, replace) ///
	ylabel(0(25)125)
	
graph combine g1 g2, ycommon
graph save "Output/variabilitySTACWT", replace
graph export "Output/variabilitySTACWT.png", replace as(png) width(2500)


***DYN-CWT***

use "Data/Imputed.dta", clear
keep if female == 0
keep if _mi_m > 0
keep if !missing(DYN) & !missing(CWT)
xtile test = DYN, n(75)
keep DYN test CWT
collapse (median) time=DYN (p5) q5=CWT (p25) q25=CWT (p50) q50=CWT ///
	(p75) q75=CWT (p95) q95=CWT, by(test)

twoway (qfit q5 time, lpattern(shortdash)) ///
	(qfit q25 time, lpattern(dash)) ///
	(qfit q50 time, lpattern(solid)) ///
	(qfit q75 time, lpattern(dash)) ///
	(qfit q95 time, lpattern(shortdash)) ///
	, legend(position(6) row(1) order(1 "Q5" 2 "Q25" 3 "Q50" 4 "Q75" 5 "Q95")) ///
	aspect(1) xtitle("Distance DYN [m]") ytitle("Depth CWT [m]") title("Men") name(g1, replace) ///
	ylabel(0(25)125)

use "Data/Imputed.dta", clear
keep if female == 1
keep if _mi_m > 0
keep if !missing(DYN) & !missing(CWT)
xtile test = DYN, n(75)
keep DYN test CWT
collapse (median) time=DYN (p5) q5=CWT (p25) q25=CWT (p50) q50=CWT ///
	(p75) q75=CWT (p95) q95=CWT, by(test)

twoway (qfit q5 time, lpattern(shortdash)) ///
	(qfit q25 time, lpattern(dash)) ///
	(qfit q50 time, lpattern(solid)) ///
	(qfit q75 time, lpattern(dash)) ///
	(qfit q95 time, lpattern(shortdash)) ///
	, legend(position(6) row(1) order(1 "Q5" 2 "Q25" 3 "Q50" 4 "Q75" 5 "Q95")) ///
	aspect(1) xtitle("Distance DYN [m]") ytitle("Depth CWT [m]") title("Women") name(g2, replace) ///
	ylabel(0(25)125)
	
graph combine g1 g2, ycommon
graph save "Output/variabilityDYNCWT", replace
graph export "Output/variabilityDYNCWT.png", replace as(png) width(2500)
	
	
	
	
	
