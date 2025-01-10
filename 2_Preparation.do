

********************************************************************************
*** Women ***
********************************************************************************
import excel "Data/database.xlsx", sheet("WOMEN") firstrow clear allstring
destring points FIM CWT CWTB CNF DYN DYNB DNF female, replace force

*** Clean Static ***
replace STA = "" if STA == "00:00:00"
replace STA = substr(STA, 4, 5) if substr(STA, 1, 3) == "00:"		//Teilweise Zahlen vertauscht
gen minutes = real(substr(STA, 1, 2))
gen seconds = real(substr(STA, 4, 2))
gen static = minutes * 60 + seconds
replace static = . if minutes == 0 & seconds == 0
drop if static > 600 & !missing(static)			//Remove error entries
duplicates drop name country static DYN CWT, force		//Doppelungen entfernen
tempfile women
save `women', replace


********************************************************************************
*** Men ***
********************************************************************************
import excel "Data/database.xlsx", sheet("MEN") firstrow clear allstring
destring points FIM CWT CWTB CNF DYN DYNB DNF female, replace force

replace STA = "" if STA == "00:00:00"
replace STA = substr(STA, 4, 5) if substr(STA, 1, 3) == "00:"		//Teilweise Zahlen vertauscht
gen minutes = real(substr(STA, 1, 2))
gen seconds = real(substr(STA, 4, 2))
gen static = minutes * 60 + seconds
replace static = . if minutes == 0 & seconds == 0
drop if static > 700 & !missing(static)			//Remove error entries
duplicates drop name country static DYN CWT, force		//Doppelungen entfernen

append using `women'
count


*** Sanity checks ***
replace static = . if static == 0
replace DYN = . if DYN == 0
replace CWT = . if CWT == 0
drop if missing(static) & missing(DYN) & missing(CWT)

label var DYN "Distance DYN [m]"
label var CWT "Depth CWT [m]"
label var static "Static time [sec]"
label define female 0 "Men" 1 "Women"
label values female female
egen maxdepth = rowmax(FIM CWT CWTB CNF)
egen maxdistance = rowmax(DYN DYNB DNF)
tabstat static FIM CWT CWTB CNF DYN DYNB DNF maxdistance maxdepth ///
	, by(female) stats(mean N)
gen distmiss = missing(maxdistance)
gen depthmiss = missing(maxdepth)


*** Country information for imputation ***
gen c = ""
replace c = country if inlist(country, "KR", "RU", "CN", "FR", "TW", "DE", "JP", "GR")
replace c = country if inlist(country, "GB", "SE", "CA", "MX", "PL", "DK", "UA", "US")
replace c = country if inlist(country, "CH", "CZ", "BR", "NL", "FI", "HR", "BE", "AU")
replace c = "Other" if c == ""
fre c
encode c, gen(land)
label var land "Country"
fre land
drop c



*** Testing case numbers ***
foreach VAR of varlist static DYN CWT {
	gen valid_`VAR' = !missing(`VAR')
}

/*graph bar valid_*, over(female) ///
	legend(position(6) row(1) order(1 "STA" 2 "DYN" 3 "CWT")) ///
	blabel(bar, format(%6.2f)) ytitle("Share with valid results") ///
	title("Before imputation")
graph save "Output/count_before", replace
graph export "Output/count_before.png", replace as(png) width(2500)
drop valid_*
*/

*** Analysis regarding selection missings ***
preserve
drop if missing(static)
xtile terz = static, n(3)
fre terz
egen totalmiss = rowmiss(CWT CWTB CNF DYN DYNB DNF)
label define terz 1 "Low perf." 2 "Average perf." 3 "High perf."
label values terz terz
graph bar totalmiss, over(terz) blabel(bar, format(%6.2f)) ///
	ytitle("Average number of missing disciplines")
restore



compress
save "Data/workfile.dta", replace


