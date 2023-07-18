*** ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
**# Prog: is_there_a_new_version ?
*** ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
/*
DESCR:
	- add descr.
	- only proof of concept

Checks if there is a new version in the input dataset of a variable that has been loaded into memory,
so if you are using var_v1 and a new version with the same name is available in the input dataset, it is likely that the
generation scripts will need to be adjusted to account for the new variable.
*/
*** ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

capture program drop is_there_a_new_version
program define is_there_a_new_version
    di as text "Checking loaded variables against `c(filename)'"

	qui cap desc *_h *_v* using `c(filename)', varlist
    if _rc == 111 {
        di as text "no harmonized (_h) or versioned (_v) variables in `c(filename)'. Check not necessary!"
        exit
    }
	sca varlist_using = "`r(varlist)'"

	qui ds
    sca varlist_in_men = "`r(varlist)'"

    unab allvars: _all /*create list with all variables*/
    local except "pid syear hid cid" /*do not check these variables*/
    foreach var in `:list allvars - except' {
        local db = 0
        *local var = "plb0036_h"     /*for debug*/
        *local var = "plb0036_h"      /*for debug*/
        *local var = "plb0036_h10"    /*for debug*/
        *local var = "plb0036"        /*for debug*/
        if regexm("`var'", "(.*)_v([0-9]+)") {
            /* check for _v versioned variables */
            scalar v_base = regexs(1) /*example: plb0036_v3 -> plb0036*/
            scalar v_vers = regexs(2) /*example: plb0036_v3 -> 3 */
            scalar v_type = "v" /*example: plb0036_v3 -> v; plb0036_h1 -> h*/
        }
        else if regexm("`var'", "(.*)_h([0-9]*)") {
             /*check for _h versioned variables */
            scalar v_base = regexs(1)
            scalar v_vers = regexs(2)
            if "`=v_vers'"=="" scalar v_vers = 0
            scalar v_type = "h" /*example: plb0036_v3 -> v; plb0036_h1 -> h*/
        }
        else {
            /* otherwise pick unversionend var and give version "0" */
            scalar v_base = "`var'"
            scalar v_vers = 0
            scalar v_type = "v"
        }
        scalar ck_vers = `=v_vers' + 1

        if `db' di in red "var: `var'. type `=v_type'"
        if `db' di in red "vers: `=v_vers'"
        if `db' di in red "base: `=v_base'"
        if `db' di in red "ck version: `=ck_vers'"

        di as txt "Checking: `var' -> `=v_base'_`=v_type'`=ck_vers'"
        local ck_found = 0
        if `=v_vers'==0 {

            local ck_vname = "`=v_base'_`=v_type'`=ck_vers'"
            if `db' di in red "`ck_vname'"
            if regexm("`=varlist_using'", "`ck_vname'") local ck_found 1
        }
        if `db' di in red  "found : `ck_found'"
        if `=v_vers'>0 {

            local ck_vname = "`=v_base'_`=v_type'`=ck_vers'"
            if `db' di in red "`ck_vname'"
            if regexm("`=varlist_using'", "`ck_vname'")  local ck_found 1

            if `db' di in red "found : `ck_found'"
        }

        if !regexm("`=varlist_in_men'", "`ck_vname'") & `ck_found' {
            di in red "Found in using: `ck_vname'"
            local list_of_vars_found = "`list_of_vars_found' `ck_vname'"
        }
    }
    if "`list_of_vars_found'" != "" {
        di as text "Newly added variables: " _c
        di in red  "`list_of_vars_found' "
        di in red "stopping"
        error 1
    }
    else {
        di as txt "It seems there are no new versions of currently loaded variables..."
    }

    * clean up
    scalar drop varlist_in_men
    scalar drop varlist_using
    scalar drop v_vers v_base v_type ck_vers
end
*** ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*** ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
