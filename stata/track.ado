*! v0.5 track // mavila@diw.de
*! date: 19.03.2024
*! update (v0.5): fix typlist when passed data type as in 'track: gen (type) varname'
*! update (v0.4): max number of categores to be printed (500)
*! update (v0.3): change format (due to bad format of some decimal numbers)


/* 
TODO: 
- include syntax checks and break early if non-compliant. 

Notes: 
- program im testing, syntax might change considerably

Usage: 
    clear 
    set obs 10 
    track : gen x = 1
    track : replace x = 2 if _n==5
    track : replace x = 3 if inrange(_n,3,6)
    track : replace x = 1
    list 
    char list x[]
*/


**# Main program
*** ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

capture program drop track
program define track, properties(prefix) 

    gettoken part 0 : 0, parse(" :") quotes
    while `"`part'"' != ":" & `"`part'"' != "" {
        local left `"`left' `part'"'
        gettoken part 0 : 0, parse(" :") quotes
    }
    local call_subcomm   : word 1 of `0'
    local track_varname  : word 2 of `0'
    gettoken junk subcmd_rest: 0

    
    if !1 { /* debug */
        di "subcmd_rest: `subcmd_rest'"
        di "call_subcomm: `call_subcomm'"
        di "track_varname: `track_varname'"
        di as text "left: " as res "`left'"
        di as text "part: " as res "`part'"
        di as text "0: " as res "`0'"   
    }
    

    if regexm("`call_subcomm'", "gen") {
        /* generate */
        _track_generate `subcmd_rest'
    }
    if regexm("`call_subcomm'", "replace") {
        /* replace */
        _track_replace `subcmd_rest'
    }


end


if 0 {
    clear 
    set obs 10 
    track a,b   :  gen x = 1
    track a,b   :  gen y = _n^2

    capture drop x 
    track : gene x = 1 
    track : replace x = 2 if inrange(y,5,30)
    track : replace x = 3 if inrange(y,20,50), note(xi)

    list 
    char list x[]

    track : replace x = 1
    list 
    track : replace x = 1
    list
}


**# _track_generate
*** ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

*! v0.4 _track_generate // mavila@diw.de
capture program drop _track_generate
program define _track_generate
    syntax newvarname =/exp [if] [in] 
    /* local typlist is generated automatically when syntax newvarname is used */
    di as text "Tracking changes in `varlist' with '__`varlist''"
    gen `typlist' `varlist'=`exp' 

    cap drop __`varlist'
    qui gen __`varlist' = ""

    scalar _trk_counter_`varlist' = 0
end 



**# _track_replace
*** ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

*! v0.4 _track_replace // mavila@diw.de
capture program drop _track_replace
program define _track_replace
    syntax varname =/exp [if], [note(string)] [verbose]
    // qui:recast double `varlist'
    tempvar touse
    mark `touse' `if'
    local iftouse if `touse'
    /* if !mi(`verbose') di "iftouse: `iftouse'" */
    
    **# counter
    *** ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    cap confirm scalar _trk_counter_`varlist'
    if _rc != 0 scalar _trk_counter_`varlist' = 0 
    scalar _trk_counter_`varlist' = 1 + `=_trk_counter_`varlist''
    /* if !mi(`verbose') di "varlist: `varlist'" */

    **# replace
    *** ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    cap drop _var_before
    tempvar varbefore
    qui gen `varbefore' = `varlist' `iftouse'
    qui replace  `varlist'=`exp' `iftouse'
    if !mi("`verbose'") | mi("`verbose'") {
        /* working on this part */
        qui levelsof `varbefore' if `varbefore'!=`varlist' & `touse', local(levels0) missing

        if !mi("`levels0'") {
            if wordcount("`levels0'")<=500 {
                foreach lev in `levels0' {
                    /* change format of levels*/
                    local levels_display : di "`levels_display'" %7.3g `lev'
                }
                di as text "'`varlist'': " as res "`levels_display'" as text " -> " as res "`exp'" as text " [total changes: " as res "`r(N)'" as text "]"    
            }
            else {
                qui sum `varbefore' if `varbefore'!=`varlist' & `touse'
                di as text "'`varlist'': " as res "Several categories (ranging from " %7.3g `r(min)' " to " %7.3g `r(max)' ")" as text " -> " as res "`exp'" as text " [total changes: " as res "`r(N)'" as text "]"    
            }
        }
        else di as text "("  as res "0"  as text " real changes made, won't affect tracking variable)"
    }

    cap confirm var __`varlist'
    if _rc gen str1 __`varlist' = ""
    qui replace __`varlist' =  __`varlist' + ":" + string(`=_trk_counter_`varlist'') if `varbefore'!=`varlist' & `touse'

    /* mark __`varlist' if `varbefore'!=`varlist' & `touse' */

    if !mi("`note'") local char_note "// (Note: `note')"

    char `varlist'[_`=_trk_counter_`varlist''] "`varlist' = `exp'`if' `char_note'"
    
end
