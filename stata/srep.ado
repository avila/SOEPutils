*! v0.1 srep // mavila@diw.de
capture program drop srep
program define srep
	syntax varname =/exp [if], [note(string)]
	qui:recast double `varlist'
	di "exp: `exp'"
	tempvar touse
    mark `touse' `if'
    /* if !mi("`in'") local iftouse if `touse' */
    local iftouse if `touse'
    di "iftouse: `iftouse'"
    
    **# counter
    *** ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    cap confirm scalar counter_`varlist'
	if _rc != 0 scalar counter_`varlist' = 0 
	scalar counter_`varlist' = 1 + `=counter_`varlist''
	scalar li counter_`varlist'
	di "varlist: `varlist'"

	**# replace
	*** ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	cap drop _var_before
	tempvar varbefore
    gen `varbefore' = `varlist' `iftouse'
    replace  `varlist'=`exp' `iftouse'
    cap confirm var _d_`varlist'
    if _rc gen str1 _d_`varlist' = ""
    di 10 * "  a "
    replace _d_`varlist' =  _d_`varlist' + ":" + string(`=counter_`varlist'') if `varbefore'!=`varlist' & `touse'
    /* mark _d_`varlist' if `varbefore'!=`varlist' & `touse' */
    di 10 * "  a "

    if !mi("note") char `varlist'[_`=counter_`varlist''] ".. = `exp'`if' // note: `note'"
    
end

