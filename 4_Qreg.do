


*Felix Bittmann, 2025

use "Data/Imputed.dta", clear

tempname name
postfile `name' str8 outcome quantile coef lower upper using "Data/qregresults.dta", replace
foreach VAR of varlist static DYN CWT {
	forvalues q = 1/99 {
		mi estimate: qreg `VAR' i.female, quantile(`q')
		post `name' ("`VAR'") (`q') (r(table)[1,2]) (r(table)[5,2]) (r(table)[6,2])
	}
}
postclose `name'

********************************************************************************

use "Data/qregresults.dta", clear
encode outcome, gen(var)
fre var
replace upper = 0.751 if var == 1 & quantile == 1	//Avoid distorted axis scaling

*** Static ***
twoway (rarea lower upper quantile if var == 3, color(%30)) ///
	(line coef quantile if var == 3, lpattern(solid) lcolor(black)) ///
	, yline(0) xtitle("Quantile") title("Static time [sec]") ///
	legend(off) ytitle("") ///
	name(g1, replace)	
	
*** DYN ***
twoway (rarea lower upper quantile if var == 2, color(%30)) ///
	(line coef quantile if var == 2, lpattern(solid) lcolor(black)) ///
	, yline(0) xtitle("Quantile") title("Distance DYN [m]") ///
	legend(off) ytitle("") ///
	name(g2, replace)	
	
*** CWT ***
twoway (rarea lower upper quantile if var == 1, color(%30)) ///
	(line coef quantile if var == 1, lpattern(solid) lcolor(black)) ///
	, yline(0) xtitle("Quantile") title("Depth CWT [m]") ///
	legend(off) ytitle("") ///
	name(g3, replace)
	*ylabel(-15(5)0)
	
graph combine g1 g2 g3, row(1) fysize(60)
graph save "Output/qreg", replace
graph export "Output/qreg.png", replace as(png) width(2500)


********************************************************************************
*** Deskription ***
********************************************************************************

use "Data/Imputed.dta", clear

tempname name
tempfile males
postfile `name' str8 outcome quantile coef lower upper using `males', replace
foreach VAR of varlist static DYN CWT {
	foreach q of numlist 10(10)90 {
		mi estimate: qreg `VAR' if female == 0, quantile(`q') vce(robust)
		post `name' ("`VAR'") (`q') (r(table)[1,1]) (r(table)[5,1]) (r(table)[6,1])
	}
}
postclose `name'


tempname name
tempfile females
postfile `name' str8 outcome quantile coef lower upper using `females', replace
foreach VAR of varlist static DYN CWT {
	foreach q of numlist 10(10)90 {
		mi estimate: qreg `VAR' if female == 1, quantile(`q') vce(robust)
		post `name' ("`VAR'") (`q') (r(table)[1,1]) (r(table)[5,1]) (r(table)[6,1])
	}
}
postclose `name'
	
use `males', clear
append using `females', gen(female)
label define female 0 "Male" 1 "Female", replace
label values female female


graph bar coef if outcome == "static", over(female) over(quantile) ///
	blabel(bar, format(%5.0f)) scheme(plotplainblind) ///
	ytitle("Static time [sec]") ///
	asyvars legend(position(6) row(1))
graph save "Output/quantiles_STA", replace
graph export "Output/quantiles_STA.png", replace as(png) width(2500)

	
graph bar coef if outcome == "DYN", over(female) over(quantile) ///
	blabel(bar, format(%5.0f)) scheme(plotplainblind) ///
	ytitle("Distance DYN [m]") ///
	asyvars legend(position(6) row(1))
graph save "Output/quantiles_DYN", replace
graph export "Output/quantiles_DYN.png", replace as(png) width(2500)
	
	
graph bar coef if outcome == "CWT", over(female) over(quantile) ///
	blabel(bar, format(%5.0f)) scheme(plotplainblind) ///
	ytitle("Depth CWT [m]") ///
	asyvars legend(position(6) row(1))
graph save "Output/quantiles_CWT", replace
graph export "Output/quantiles_CWT.png", replace as(png) width(2500)
	
	
	
	
