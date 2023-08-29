*! v0.1 sgen // mavila@diw.de
capture program drop sgen
program define sgen
	syntax newvarname =/exp [if] [in] 
	local typelist double
	gen `typelist' `varlist'=`exp' 

	cap drop _d_`varlist'
    gen _d_`varlist' = ""

    scalar counter_`varlist' = 0
end
