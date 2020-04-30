version 12
capture log close

/*--------------------------------------------------------------------------------------------------
  VIETNAM: Export graph to image
  --------------------------------------------------------------------------------------------------
  Author: nghia
  Filename: Export graph.do
  Date created:  07 Feb 2018
  Last modified: 07 Feb 2018
  --------------------------------------------------------------------------------------------------

  -----------------------------------------------------------------------------------------------------*/
  
  * set directory
cd "W:\Stata_work"
global OUT1 "processed\2012\statagraphs\"
global OUT2 "processed\2012\statagraphs\img\"

	* ownership (percentage)	
foreach i in "u" "r" {
foreach j in "car" "motorbike" "bicycle" "car_motor"{
	
	graph use "${OUT1}\nlregs_`j'_`i'.gph",
	graph export "${OUT2}\nlregs_`j'_`i'.png", width(1920) replace
}
}
	*hhsize
foreach i in "u" "r" {
foreach j in "hhsize" {
	
	graph use "${OUT1}\nlregs_mpce_`j'_`i'.gph",
	graph export "${OUT2}\nlregs_mpce_`j'_`i'.png", width(1920) replace
}
}


	*number of vehicle
foreach i in "u" "r" {
foreach j in "n_car" "n_motorbike" "n_bicycle" "n_car_motor"{
	
	graph use "${OUT1}\nlregs_`j'_`i'.gph",
	graph export "${OUT2}\nlregs_`j'_`i'.png", width(1920) replace
}
}
