*! v0.1 srep // mavila@diw.de
capture program drop srep
program define srep
	syntax varname =/exp [if], [note(string)] [verbose]
	// qui:recast double `varlist'
	tempvar touse
    mark `touse' `if'
    local iftouse if `touse'
    /* if !mi(`verbose') di "iftouse: `iftouse'" */
    
    **# counter
    *** ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    cap confirm scalar counter_`varlist'
	if _rc != 0 scalar counter_`varlist' = 0 
	scalar counter_`varlist' = 1 + `=counter_`varlist''
	/* if !mi(`verbose') di "varlist: `varlist'" */

	**# replace
	*** ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	cap drop _var_before
	tempvar varbefore
    qui gen `varbefore' = `varlist' `iftouse'
    replace  `varlist'=`exp' `iftouse'
    if !mi("`verbose'") | mi("`verbose'") {
        /* working on this part */
        qui levelsof `varbefore' if `varbefore'!=`varlist' & `touse', local(levels0) missing
        di "'`varlist'' prev.: " as res "`levels0'"
    }

    cap confirm var _d_`varlist'
    if _rc gen str1 _d_`varlist' = ""
    qui replace _d_`varlist' =  _d_`varlist' + ":" + string(`=counter_`varlist'') if `varbefore'!=`varlist' & `touse'

    /* mark _d_`varlist' if `varbefore'!=`varlist' & `touse' */

    if !mi("`note'") local char_note "// (Note: `note')"

    char `varlist'[_`=counter_`varlist''] "`varlist' = `exp'`if' `char_note'"
    
end

if 0 {
    clear
    set obs 10
    cap drop plb00220_h 
    sgen plb00220_h = .z
    srep plb00220_h = _n^2 if inrange(_n, 3, 6), verbose note(xi)
    srep plb00220_h = 2 if _n == 2, verbose
    srep plb00220_h = 3 if _n == 3, verbose
    fre _d_plb00220_h
    char list plb00220_h[]    
}

