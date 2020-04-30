version 11.2
capture log close

/*--------------------------------------------------------------------------------------------------
  VIETNAM: Data preparation of Vietnam Household Living Standard Survey 2012
  CREATE CENTILE-UNIT (MPE- & MPCE-BASED) DATA
  --------------------------------------------------------------------------------------------------
  Author: trnghia.le
  Filename: vhlss12_data02_create_centilesdata.do
  Date created:  04 March 2018
  Last modified: 04 March 2018
  --------------------------------------------------------------------------------------------------
  Data used: vhlss12_hhunit.dta
  Create 4 sets of centile-unit-based datasets: 
	(1) Centiles with the same number of HHs
	(2) Centiles with the same number of electrified HHs
	(3) Centiles with the same number of HHs among HHs with assets data
	(4) Centiles with the same number of electrified HHs  among HHs with assets data
  -------------------------------------------------------------------------------------------------
  --------------------------------------------------------------------------------------------------*/
   
* set directory
cd "W:\Stata_work"
global OUT0 "processed\2012"

set more off


* A. CREATE CENTILE-BASED DATA (ALL HHs)

use "${OUT0}\vhlss12_hhunit_perc", clear
	des, s // 9,399 HH units
						
	foreach var of var  urbanity hhsize exp mpce n_car- n_bicycle car- bicycle vehicle- n_car_bic centile_hh tothhmem numhh wt9{
	local vlab`var': variable label `var'
	}

	collapse (sum) tothhmem numhh (mean) hhsize exp mpce n_car n_motorbike n_bicycle car motorbike bicycle vehicle n_vehicle car_motor n_car_motor motor_bic n_motor_bic car_bic n_car_bic [pw=wt9], by(centile_hh urbanity)

	foreach var of var urbanity hhsize exp mpce n_car- n_bicycle car- bicycle vehicle- n_car_bic centile_hh tothhmem numhh  {
	label var `var' "`vlab`var''"
	}
	
	ren centile_hh centile
	la var tothhmem "Total person per centile"
	la var hhsize 	"Average HH size per centile"
	
	tab urbanity, gen(u)
	ren u1 u
	ren u2 r
	la var u "Urban"
	la var r "Rural"
	
	order urbanity u r centile

save "${OUT0}\vhlss12_centile_allhh", replace


* B. CREATE CENTILE-BASED DATA (Province)

use "${OUT0}\vhlss12_hhunit_perc", clear
	des, s // 9,399 HH units
						
	foreach var of var  urbanity hhsize exp mpce n_car- n_bicycle car- bicycle vehicle- n_car_bic province tothhmem numhh wt9{
	local vlab`var': variable label `var'
	}

	collapse (sum) tothhmem numhh (mean) hhsize exp mpce n_car n_motorbike n_bicycle car motorbike bicycle vehicle n_vehicle car_motor n_car_motor motor_bic n_motor_bic car_bic n_car_bic [pw=wt9], by(province urbanity)

	foreach var of var urbanity hhsize exp mpce n_car- n_bicycle car- bicycle vehicle- n_car_bic province tothhmem numhh  {
	label var `var' "`vlab`var''"
	}
	
	la var tothhmem "Total person per centile"
	la var hhsize 	"Average HH size per centile"
	
	tab urbanity, gen(u)
	ren u1 u
	ren u2 r
	la var u "Urban"
	la var r "Rural"
	
	order urbanity u r province

save "${OUT0}\vhlss12_mpcecentile_province", replace


* C. CREATE CENTILE-BASED DATA (PROVINCE)

use "${OUT0}\vhlss12_hhunit_perc", clear
	des, s // 9,189 HH units

	foreach var of var   hhsize exp mpce n_car- n_bicycle car- bicycle vehicle- n_car_bic province tothhmem numhh wt9{
	local vlab`var': variable label `var'
	}

	collapse (sum) tothhmem numhh (mean) hhsize exp mpce n_car n_motorbike n_bicycle car motorbike bicycle vehicle n_vehicle car_motor n_car_motor motor_bic n_motor_bic car_bic n_car_bic [pw=wt9], by(province)

	foreach var of var  hhsize exp mpce n_car- n_bicycle car- bicycle vehicle- n_car_bic province tothhmem numhh  {
	label var `var' "`vlab`var''"
	}
	
	
	la var tothhmem "Total person per centile"
	la var hhsize 	"Average HH size per centile"
	
	order province

save "${OUT0}\vhlss12_mpcecentile_province_wt_ur", replace

