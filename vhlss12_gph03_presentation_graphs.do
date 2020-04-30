version 11.2
capture log close

/*--------------------------------------------------------------------------------------------------
  VIETNAM: Graphs exporting
  --------------------------------------------------------------------------------------------------
  Author: nghia
  Filename: vhlss12_gph03_presentation_graphs.do
  Date created:  12 November 2018
  Last modified:  2012
  --------------------------------------------------------------------------------------------------

  --------------------------------------------------------------------------------------------------*/

  
* set directory
cd "W:\Stata_work"
global OUT0 "processed\2012"
global OUT2 "processed\2012\statagraphs\"
global OUT3 "processed\2012\statagraphs\img"

set more off

use "${OUT0}\vhlss12_centile_allhh", clear


* Observed patter of ownership behavior using motorcycle as example
foreach i of var u r {
local ilab: variable label `i'
foreach j of var car motorbike n_car n_motorbike{
local jlab: variable label `j'

	#delimit ;
	  tw (scatter `j' exp if `i'==1),
			ytitle("`jlab' Ownership in `ilab'", si(medium)) ylabel(, angle(0) labsi(medium))
			xtitle("Mean Monthly Household Expenditure (000 VND)", si(medium)) xlabel(, labsi(medium))
			legend(off)
			title("") 
			note("Source: Calculated using Vietnam Household Living Standard Survey (VHLSS) 2012", si(vsmall));
	  #delimit cr
	  graph save "${OUT2}\pattern_`j'_`i'.gph", asis replace
	  graph export "${OUT3}\pattern_`j'_`i'.tif", width(1920) replace
}
}	 
*Motorbike
foreach i of var r {
local ilab: variable label `i'
foreach j of var motorbike{
local jlab: variable label `j'

	#delimit ;
	  tw (scatter `j' exp if `i'==1),
			ytitle("`jlab' Ownership in `ilab'", si(medium)) ylabel(20(10)100, angle(0) labsi(medium))
			xtitle("Mean Monthly Household Expenditure (000 VND)", si(medium)) xlabel(, labsi(medium))
			legend(off)
			title("") 
			note("Source: Calculated using Vietnam Household Living Standard Survey (VHLSS) 2012", si(medium));
	  #delimit cr
	  graph save "${OUT2}\pattern_`j'_`i'.gph", asis replace
	  graph export "${OUT3}\pattern_`j'_`i'.tif", width(1920) replace
}
}	 

foreach i of var u {
local ilab: variable label `i'
foreach j of var motorbike{
local jlab: variable label `j'

	#delimit ;
	  tw (scatter `j' exp if `i'==1),
			ytitle("`jlab' Ownership in `ilab'", si(medium)) ylabel(30(10)100, angle(0) labsi(medium))
			xtitle("Mean Monthly Household Expenditure (000 VND)", si(medium)) xlabel(, labsi(medium))
			legend(off)
			title("") 
			note("Source: Calculated using Vietnam Household Living Standard Survey (VHLSS) 2012", si(vsmall));
	  #delimit cr
	  graph save "${OUT2}\pattern_`j'_`i'.gph", asis replace
	  graph export "${OUT3}\pattern_`j'_`i'.tif", width(1920) replace
}
}	

foreach i of var r {
local ilab: variable label `i'
foreach j of var n_motorbike{
local jlab: variable label `j'

	#delimit ;
	  tw (scatter `j' exp if `i'==1),
			ytitle("`jlab' Ownership in `ilab'", si(medium)) ylabel(1(0.5)2, angle(0) labsi(medium))
			xtitle("Mean Monthly Household Expenditure (000 VND)", si(medium)) xlabel(, labsi(medium))
			legend(off)
			title("") 
			note("Source: Calculated using Vietnam Household Living Standard Survey (VHLSS) 2012", si(vsmall));
	  #delimit cr
	  graph save "${OUT2}\pattern_`j'_`i'.gph", asis replace
	  graph export "${OUT3}\pattern_`j'_`i'.tif", width(1920) replace
}
}	 
foreach i of var u {
local ilab: variable label `i'
foreach j of var n_motorbike{
local jlab: variable label `j'

	#delimit ;
	  tw (scatter `j' exp if `i'==1),
			ytitle("`jlab' Ownership in `ilab'", si(medium)) ylabel(1(0.5)2.5, angle(0) labsi(medium))
			xtitle("Mean Monthly Household Expenditure (000 VND)", si(medium)) xlabel(, labsi(medium))
			legend(off)
			title("") 
			note("Source: Calculated using Vietnam Household Living Standard Survey (VHLSS) 2012", si(vsmall));
	  #delimit cr
	  graph save "${OUT2}\pattern_`j'_`i'.gph", asis replace
	  graph export "${OUT3}\pattern_`j'_`i'.tif", width(1920) replace
}
}	 

* Car

foreach i of var r {
local ilab: variable label `i'
foreach j of var car{
local jlab: variable label `j'

	#delimit ;
	  tw (scatter `j' exp if `i'==1),
			ytitle("`jlab' Ownership in `ilab'", si(medium)) ylabel(0(10)30, angle(0) labsi(medium))
			xtitle("Mean Monthly Household Expenditure (000 VND)", si(medium)) xlabel(, labsi(medium))
			legend(off)
			title("") 
			note("Source: Calculated using Vietnam Household Living Standard Survey (VHLSS) 2012", si(vsmall));
	  #delimit cr
	  graph save "${OUT2}\pattern_`j'_`i'.gph", asis replace
	  graph export "${OUT3}\pattern_`j'_`i'.tif", width(1920) replace
}
}	 

foreach i of var u {
local ilab: variable label `i'
foreach j of var car{
local jlab: variable label `j'

	#delimit ;
	  tw (scatter `j' exp if `i'==1),
			ytitle("`jlab' Ownership in `ilab'", si(medium)) ylabel(30(10)60, angle(0) labsi(medium))
			xtitle("Mean Monthly Household Expenditure (000 VND)", si(medium)) xlabel(, labsi(medium))
			legend(off)
			title("") 
			note("Source: Calculated using Vietnam Household Living Standard Survey (VHLSS) 2012", si(vsmall));
	  #delimit cr
	  graph save "${OUT2}\pattern_`j'_`i'.gph", asis replace
	  graph export "${OUT3}\pattern_`j'_`i'.tif", width(1920) replace
}
}	

foreach i of var r {
local ilab: variable label `i'
foreach j of var n_car {
local jlab: variable label `j'

	#delimit ;
	  tw (scatter `j' exp if `i'==1),
			ytitle("`jlab' Ownership in `ilab'", si(medium)) ylabel(1(0.2)1.8, angle(0) labsi(medium))
			xtitle("Mean Monthly Household Expenditure (000 VND)", si(medium)) xlabel(, labsi(medium))
			legend(off)
			title("") 
			note("Source: Calculated using Vietnam Household Living Standard Survey (VHLSS) 2012", si(vsmall));
	  #delimit cr
	  graph save "${OUT2}\pattern_`j'_`i'.gph", asis replace
	  graph export "${OUT3}\pattern_`j'_`i'.tif", width(1920) replace
}
}	 
foreach i of var u {
local ilab: variable label `i'
foreach j of var n_car {
local jlab: variable label `j'

	#delimit ;
	  tw (scatter `j' exp if `i'==1),
			ytitle("`jlab' Ownership in `ilab'", si(medium)) ylabel(1(0.5)2.5, angle(0) labsi(medium))
			xtitle("Mean Monthly Household Expenditure (000 VND)", si(medium)) xlabel(, labsi(medium))
			legend(off)
			title("") 
			note("Source: Calculated using Vietnam Household Living Standard Survey (VHLSS) 2012", si(vsmall));
	  #delimit cr
	  graph save "${OUT2}\pattern_`j'_`i'.gph", asis replace
	  graph export "${OUT3}\pattern_`j'_`i'.tif", width(1920) replace
}
}	 