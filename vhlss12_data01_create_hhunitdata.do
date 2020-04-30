version 12
capture log close

/*--------------------------------------------------------------------------------------------------
  VIETNAM: Data preparation of Vietnam Household Living Standard Survey 2012
  CLEAN, SELECT, MERGE/APPEND DATA, GENERATE UNIVARIATES, CREATE MPCE-BASED CENTILE VARIABLES
  --------------------------------------------------------------------------------------------------
  Author: nghia
  Filename: vhlss12_data01_create_hhunitdata.do
  Date created:  28 December 2017
  Last modified: 15 January 2018
  --------------------------------------------------------------------------------------------------
  Raw files used:
	(a) ho11_2_3_4_5.dta - income, expenditure, hhsize
	(b) wt2012.dta - weights
	(b) muc7.dta - access to electricity, utility bills
	(c) muc6b.dta - vehicle & electric appliances ownership
	(d) muc5b1.dta - data on non-electricity based energy expenditure (gas, kerosene, coal, etc.)
  -----------------------------------------------------------------------------------------------------*/
    
* set directory
cd "W:\Stata_work"
global IN "VHLSS_data\VHLSS_2012"
global OUT0 "processed\2012"

set more off

  	use "${IN}\ho11_2_3_4_5", clear
keep tinh- hoso ttnt tsnguoi thunhap  chikhac_1- chikhac_9   
		duplicates report tinh huyen xa diaban hoso
		sort tinh- hoso

		ren tinh 	province
		ren huyen 	district
		ren xa 		commune
		ren diaban 	ea
		ren hoso 	hhcode

		sort province district commune ea hhcode
	save "${OUT0}\vhlss12_hhsizeincexp", replace

/*-----------------------------------------------------------------
  STEP 2. PREPARE WEIGHTS TO USE FOR 9,399 HHs
  -----------------------------------------------------------------*/
  	use "${IN}\wt2012new", clear
		des, s // basic unit is the enumeration area
		
		duplicates report   tinh huyen xa diaban
		keep tinh huyen xa diaban wt9 	
		
		ren tinh province
		ren huyen district
		ren xa commune
		ren diaban ea
		
		sort province district commune ea 

	save "${OUT0}\vhlss12_weight", replace


use "${IN}\Muc7", clear
		des, s // 9,399 HHs

		ren tinh province
		ren huyen district
		ren xa commune
		ren diaban ea
		ren hoso hhcode

	/*-----------------------------------------------------------------
	  STEP 3: PREPARE HOUSING CHARACTERISTICS DATA
		(A) Total living area
		(B) Type of house
		(C) Access to electricity
		(D) Have paid electricity for the past month
		(E) Amount paid for electricity for the past month
		(F) HH has computer
	  ----------------------------------------------------------------*/
		keep province- hhcode m7c2 m7c4b m7c4c m7c22 m7c23 m7c23k m7c24 
		
		ren m7c2 	harea
		ren m7c4b 	rooftype
		ren m7c4c 	walltype
		ren m7c22   lightingsource
		ren m7c23 	elec_paid_mo
		ren m7c23k 	elec_consumed_mo
		ren m7c24 	elec_paid_yr
		
sort province district commune ea hhcode
save "${OUT0}\vhlss12_hhchars", replace	

	/*-----------------------------------------------------------------
	  STEP 4: PREPARE DATA ON NON-ELECTRICITY ENERGY EXPENDITURE
		
	  ----------------------------------------------------------------*/
use "${IN}\Muc5B1", clear
		des, s // 9,399 HHs

		ren tinh province
		ren huyen district
		ren xa commune
		ren diaban ea
		ren hoso hhcode
		
	  des m5b1ma
		*label list  m5b1ma // focus on codes 202, 203, and 204
		
		forval i=203/205 {
			gen _`i'=.
			gen _`i'_mos= m5b1c2 if  m5b1ma==`i'& m5b1c2>0& !missing(m5b1c2)
			gen _`i'_valuepermo=m5b1c3 if  m5b1ma==`i'& m5b1c3>0& !missing(m5b1c3)
			gen _`i'_valuepastyr=m5b1c4 if  m5b1ma==`i'& m5b1c4>0& !missing(m5b1c4)
		}
		
		la var _203 "gas"
		la var _204 "kerosene"
		la var _205 "gasolene"
		
		forval i=203/205 {
			local ilab: variable label _`i'
			ren _`i'_mos 			`ilab'_mos
			ren _`i'_valuepermo 	`ilab'_valuepermo
			ren _`i'_valuepastyr 	`ilab'_valuepastyr	
		}
		
		collapse (mean) gas_* kerosene_* gasolene_*, by( province district commune ea hhcode)
		
		foreach i in "gas" "kerosene" "gasolene" {
			la var `i'_mos 			"No. of months HH bought `ilab'"
			la var `i'_valuepermo 	"Value of `i' bought per month"
			la var `i'_valuepastyr 	"Value of `i' bought for last 12 months"
		}
		
sort province district commune ea hhcode
save "${OUT0}\vhlss12_fuelexp", replace	
	
/*-----------------------------------------------------------------------
  STEP 5. PREPARE VEHICLE AND ELECTRIC APPLIANCES DATA
	(A) Quantity for each owned appliance
	(B) Ownership of appliance (based on a non-zero quantity)
  -----------------------------------------------------------------------*/

 
	use "${IN}\Muc6B.dta", clear
	des, s // basic unit is purchase of asset and not the HH

	/*----------------------------------
	  Codes for motor vehicles:
		1	Automobile 
		2	Motorbike
		3	Bicycle
		4	Ship(s), boat(s), junk(s), outer part with a motor 
		---------------------------------*/
		foreach i in 1 2 3 4 {
		gen n_`i'= m6c3 if  m6c2==`i'& m6c3>0& !missing(m6c3)
		}

	/*------------------------------------
	Codes for electric appliances
		7	Pumping machine(s)
		8	Electricity generator(s)
		9	Printer(s)
		10	Fax machine(s)
		14	Video player(s), DVD player(s), digital player(s), satellite antenna 
		15	Color TV(s) 
		16	Black and white TV(s) 
		18	Radio/radio-cassette player(s)
		19	Disk player(s) 
		20	Computer(s)
		22	Refrigerator(s)
		23	Air conditioner(s)
		24	Washing machine(s), (clothes-) drying machine(s)
		25	Electric fan(s)
		26	(Bath) water heater(s)
		27	Gas cooker(s), magnetic cooker(s)
		28	Electric cooker(s), electric rice cooker(s), pressure cooker(s) 
		33	Vacuum cleaner(s), dehumidifier(s), water filter(s)
		34	Microwave oven(s), baking oven(s)
	------------------------------------------------------------*/
		forvalues i=7/34 {
		gen n_`i'= m6c3 if  m6c2==`i'& m6c3>0& !missing(m6c3)
		}
		drop n_11-n_13 n_17 n_21 n_29-n_32
	
		keep tinh huyen xa diaban hoso n_1- n_34
		collapse (sum) n_*, by( tinh huyen xa diaban hoso)
		sort tinh huyen xa diaban hoso
		
	* RENAME VARIABLES
		ren n_1 n_car
		ren n_2 n_motorbike
		ren n_3 n_bicycle
		ren n_4 n_motorboat
		ren n_7 n_pump
		ren n_8 n_generator
		ren n_9 n_printer
		ren n_10 n_faxmach
		ren n_14 n_videoplayer
		ren n_15 n_colortv
		ren n_16 n_bwtv
		ren n_18 n_radio
		ren n_19 n_discplayer
		ren n_20 n_computer
		ren n_22 n_ref
		ren n_23 n_aircon
		ren n_24 n_washmach
		ren n_25 n_efan
		ren n_26 n_heater
		ren n_27 n_gcooker
		ren n_28 n_ecooker
		ren n_33 n_vacuum
		ren n_34 n_microwave

	* OWNERSHIP DUMMIES AND VARIABLE LABELING
		
		foreach i in "car" "motorbike" "bicycle" "motorboat" {
		gen `i'=1 if n_`i'>0& ~missing(n_`i')
		recode `i' .=0
		
		label var n_`i' "No. of `i'(s)"
		label var `i' "Has `i'"
		}


		foreach i in "pump" "generator" "printer" "faxmach" "videoplayer" "colortv" "bwtv" "discplayer" "radio" "computer" "ref" "aircon" "washmach" "efan" "heater" "gcooker" "ecooker" "vacuum" "microwave" {
		gen `i'=1 if n_`i'>0& ~missing(n_`i')
		recode `i' .=0
		}
			
		la var pump		 	"pumping machine"
		la var generator 	"electric generator"
		la var printer 		"printer"
		la var faxmach 		"fax machine"
		la var videoplayer 	"video/DVD/digital player/ satellite antenna"
		la var colortv		"colored TV"
		la var bwtv			"black & white TV"
		la var discplayer	"disc player"
		la var radio 		"radios/cassette-player"
		la var computer 	"computer"
		la var ref 			"refrigerator"
		la var aircon		"air conditioner"
		la var washmach 	"washing machine/drier"
		la var efan			"electric fan"
		la var heater 		"(bath) water heater"
		la var gcooker 		"gas/magnetic cooker"
		la var ecooker		"electric/rice/pressure cooker"
		la var vacuum		"vacuum clearner/water filter/dehumidifier"
		la var microwave	"microwave/baking over"
		
		foreach i in "pump" "generator" "printer" "faxmach" "videoplayer" "colortv" "bwtv" "discplayer" "radio" "computer" "ref" "aircon" "washmach" "efan" "heater" "gcooker" "ecooker" "vacuum" "microwave" {
		local ilab: variable label `i'
		la var n_`i' "no. of `ilab'(s)"
		la var `i' 	 "has `ilab'"
		}

		ren tinh 	province
		ren huyen 	district
		ren xa 		commune
		ren diaban 	ea
		ren hoso 	hhcode

	sort province district commune ea hhcode
		
	save "${OUT0}\vhlss12_assets", replace

/*-----------------------------------------------------------------
  STEP 6: MERGE ALL FILES INTO ONE
  Relevant generated datasets:
	vhlss12_hhsizeincexp.dta
	vhlss12_weight.dta
	vhlss12_hhchars.dta
	vhlss12_assets.dta
  ----------------------------------------------------------------*/
	use "${OUT0}\vhlss12_hhsizeincexp", clear
	
	merge 1:1 province district commune ea hhcode using "${OUT0}\vhlss12_hhchars.dta" // perfect merging
		drop _m
	
	merge n:1 province district commune ea hhcode using "${OUT0}\vhlss12_assets.dta" // only 9,273 households have data on assets
		tab _m, gen(m)
		ren m2 hasasset
		drop m1
		drop _m		
			
	merge n:1 province district commune ea using "${OUT0}\vhlss12_weight.dta" // perfect merging
		drop _m

	* Rename variables
		ren ttnt 	urbanity
		ren tsnguoi hhsize
		ren thunhap income
		
		/* Determine the HH weight to use: Choose the weight that approximate's best the population estimates of the General Statistics Office (GSO) of Vietnam for 2012(Statistical Yearbook):
			All: 86.933 million
			Urban: 26.516 million
			Rural: 60.417 million
			We do this by multiplying the weight variable (wt) with the HH size. */
			
		gen hhsizewt=wt9*hhsize
		la var hhsizewt "HH weight=hhsize*wt9"

		table urbanity, c(sum hhsizewt) row format(%20.0f) // All = 89.267 mn; U=26.427; R=62.840 
		table urbanity if hasasset==1, c(sum hhsizewt) row format(%20.0f) // All = 88.85 mn; U=26.39; R=52.46

		drop hhsizewt

	sort province district commune ea hhcode

/*-----------------------------------------------------
	Step 7: Clean variables and Generate new variables
  -----------------------------------------------------*/
  
* GENERATE EXPENDITURE VARIABLES ==> BASIS FOR CREATING CENTILES
	gen chikhac_4a=chikhac_4*12 
	/*-----chikhac_4 la chi phi hang thang-----*/
	gen chikhac_5a=chikhac_5*12 
	/*------chikhac_5 la chi phi hang thang----*/
	egen exp=rowtotal( chikhac_1-  chikhac_3 chikhac_4a chikhac_5a chikhac_6- chikhac_9)	
	/* ----tong chi phi cho mot nam-----*/
		replace exp=exp/12 
		/*----- tinh chi phi cho 1 thang-----*/
	la var exp 	"Mean monthly household expenditure (MMHE)"
	gen mpce=exp/hhsize 
	la var mpce "Mean per capita household expenditure (MPCE)"
	move exp wt9
	move mpce wt9
	
* CLEAN VARIABLES AND GENERATE UNIVARIATES	
	sum // inconsistencies: negative values for living area (harea) and internet use in minutes per month ( internetuse_minspermo ==> recode to missing
	capture assert harea>0 // 
		tab harea if harea<0

	* recode to missing if HH area, electric bill in the past month, and electric consumption in the past month are negative
	recode  harea elec_paid_mo elec_consumed_mo (-1=.)
	
* GENERATE DUMMIES FOR EACH ROOF/WALL TYPE OF THE HOUSE
	tab rooftype, gen(roof)
	tab walltype, gen(wall)
	
* GENERATE DUMMIES FOR LIGHTING SOURCE
	tab lightingsource, gen(lightsource)
	la var lightsource1 	"National grid electricity"
	la var lightsource2 	"Battery lamp/resin torch"
	la var lightsource3		"Gas/oil/kerosene lamp"
	la var lightsource4 	"Others"
	
* CONSISTENCY CHECK FOR ELECTRICAL SUPPLIES AND VEHICLE OWNERSHIP AGAINST QUANTITY
	foreach i of var  car- microwave {
	assert `i'==1 if n_`i'>0& !missing(n_`i')
	}
	// consistent
	sum n_car- n_microwave

* COMBINE VEHICLE OWNERSHIP
	gen vehicle=inlist(1, car, motorbike, bicycle)
		la var vehicle "has any type of land vehicle"
	egen n_vehicle=rowtotal(n_car n_motorbike n_bicycle)
		recode n_vehicle 0=. if vehicle==0
		la var n_vehicle "no. of land vehicles HH owned"		


	gen car_motor=inlist(1, car, motorbike)
		la var car_motor "has car/motorbike"
	egen n_car_motor=rowtotal(n_car n_motorbike)
		recode n_car_motor 0=. if car_motor==0
		la var n_car_motor "no. of car/motorbike HH owned"
	
	gen motor_bic=inlist(1, bicycle, motorbike)
		la var motor_bic "has bicycle/motorbike"
	egen n_motor_bic=rowtotal(n_bicycle n_motorbike)
		recode n_motor_bic 0=. if car_motor==0
		la var n_motor_bic "no. of motorbike/bicycle HH owned"
	
	gen car_bic=inlist(1, car, bicycle)
		la var car_bic "has car/bicycle"
	egen n_car_bic=rowtotal(n_car n_bic)
		recode n_car_bic 0=. if car_bic==0
		la var n_car_bic "no. of car/bicycle HH owned"	
* COMBINE COLORED TV AND B&W TV OWNERSHIP
	gen tv=inlist(1, colortv, bwtv)
		la var tv "has colored/b&w TV set"
	egen n_tv=rowtotal(n_colortv n_bwtv)
		recode n_tv 0=. if colortv==0& bwtv==0
		la var n_tv "no. of colored/b&w TV sets HH owned"

	foreach var of varlist  car- microwave car_motor tv {
	recode n_`var' 0=. if `var'==0
	}
	
* CONSISTENCY CHECK FOR ELECTRIFICATION
	tab lightingsource // source of lighting is electricity if value is "1"
	capture assert  lightingsource==1 if  elec_paid_mo>0& !missing( elec_paid_mo) 
	capture assert  lightingsource==1 if  elec_paid_yr>0& !missing( elec_paid_yr) 
	capture assert lightingsource==1 if (pump==1| printer==1| videoplayer==1| colortv==1| bwtv==1| discplayer==1| computer==1| ref==1|  aircon==1|  washmach==1|  efan==1|  heater==1|  ecooker==1|  microwave==1)& generator==0 

	count if  elec_paid_mo>0& elec_paid_yr==0& !missing( elec_paid_mo) // consistent
	count if  elec_paid_mo>0& elec_consumed_mo==0& !missing( elec_paid_mo) // 1 inconsistency
	count if  elec_consumed_mo>0& elec_paid_mo==0& !missing( elec_consumed_mo) // 3 inconsistencies ==> might be using generators
	
* GENERATE ELECTRIFIED DUMMY
	gen electrified=1 if lightingsource==1
	recode electrified .=1 if elec_paid_mo>0& !missing(elec_paid_mo)	
	recode electrified .=1 if elec_paid_yr>0& !missing(elec_paid_yr)
	recode electrified .=1 if elec_consumed>0& !missing(elec_consumed)
	recode electrified .=1 if (printer==1| videoplayer==1| colortv==1| bwtv==1| discplayer==1| computer==1| ref==1|  aircon==1|  washmach==1|  efan==1|  heater==1|  ecooker==1|  microwave==1)& generator==0
	recode electrified .=0
	la var electrified 	"Electrified household"
	
* GENERATE GRID-CONNECTED AND NON-GRID CONNECTED UNIVARIATES
	gen pg1_elec0=1 if generator==1& electrified==0
		la var pg1_elec0 "HH has power generator but not grid-connected"
	gen pg1_elec1=1 if generator==1& electrified==1
		la var pg1_elec1 "HH has power generator but grid-connected"
	gen pg0_elec1=1 if generator==0& electrified==1
		la var pg0_elec1 "HH has no power generator but grid-connected"
	recode pg1_elec0 pg1_elec1 pg0_elec1 (.=0)

/*-----------------------------------------------------
	Step 8: Generate Centiles
  -----------------------------------------------------*/
  
* GENERATE MPE & MPCE-BASED CENTILES BY URBANITY
	tab urbanity, gen(u)
		ren u1 u
		ren u2 r
		la var u "urban"
		la var r "rural"
		
	* for all HHs
	foreach i of var u r {
	local ilab: variable label `i'
	foreach j of var mpce {
	local jlab: variable label `j'
		xtile q`j'_`i'=`j' [pw=wt9] if `i'==1, nq(100)
		la var q`j'_`i' "Centiles based on `jlab' among `ilab' HHs"
	}
	}

	* for all HHs with assets data
	foreach i of var u r {
	local ilab: variable label `i'
	foreach j of var mpce {
	local jlab: variable label `j'
		xtile q`j'_`i'a=`j' [pw=wt9] if `i'==1& hasasset==1, nq(100)
		la var q`j'_`i'a "Centiles based on `jlab' among `ilab' HHs"
	}
	}
	
	* for electrified HHs
	foreach i of var u r {
	local ilab: variable label `i'
	foreach j of var mpce {
	local jlab: variable label `j'
		xtile q`j'_e_`i'=`j' [pw=wt9] if `i'==1& electrified==1, nq(100)
		la var q`j'_e_`i' "Centiles based on `jlab' among `ilab' electrified HHs"
	}
	}

	* for electrified HHs with assets data
	foreach i of var u r {
	local ilab: variable label `i'
	foreach j of var mpce {
	local jlab: variable label `j'
		xtile q`j'_e_`i'a=`j' [pw=wt9] if `i'==1& electrified==1& hasasset==1, nq(100)
		la var q`j'_e_`i'a "Centiles based on `jlab' among `ilab' electrified HHs"
	}
	}

	
	gen centile_hh=qmpce_u if u==1
		replace centile_hh=qmpce_r if r==1
		la var centile_hh "Centiles based on MPCE among all HHs"

	gen centile_hha=qmpce_ua if u==1
		replace centile_hha=qmpce_ra if r==1
		la var centile_hha "Centiles based on MPCE among all HHs"
		
	gen centile_ehh=qmpce_e_u if u==1
		replace centile_ehh=qmpce_r if r==1
		la var centile_ehh "Centiles based on MPCE among electrified HHs"
		
	gen centile_ehha=qmpce_e_ua if u==1
		replace centile_ehha=qmpce_ra if r==1
		la var centile_ehha "Centiles based on MPCE among electrified HHs"
		
		
* GENERATE VARIABLE TO INDICATE NUMBER OF PERSONS & NUMBER OF HHs PER CENTILE
	clonevar tothhmem=hhsize
	gen numhh=1
		la var numhh "Number of HHs per centile"

save "${OUT0}\vhlss12_hhunit", replace

* PERCENTAGES 
	recode car-microwave  roof1- vehicle car_motor motor_bic car_bic tv electrified- pg0_elec1  (1=100)

save "${OUT0}\vhlss12_hhunit_perc", replace

	
	clear
	
	
	

