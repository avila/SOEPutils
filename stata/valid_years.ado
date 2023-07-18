* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
* Prog: valid_years
* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
/*
description:
	displays years for which variable has valid info

syntax:
	valid_years varname

usage:
	. valid_years plb0022_v2
	plb0022_v2: 1985,1986,1987,1988,1989,1990; waves: 6
*/
* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
cap program drop valid_years
program valid_years, rclass

    syntax [varlist], [VARyear(varname)] [CURrentyear]

    if "`varlist'"=="" local varlist _all
    if "`varyear'" == "" local varyear syear 
    qui sum `varyear'
    if "`CURrent_year'" == "" local current_year `r(max)'

    clear results
    local vars_with_breaks
    foreach var of varlist `varlist' {
        local lab : variable label `var'
        local lab_80 = substr("`lab'", 1, 80)
        cap confirm numeric variable `var'
        if _rc!=0 {
            di _rc
            di as text "`var': Sorry, I can only deal with numeric variable..."
            continue
        }
        di as text "    `var'" _colum(21) "/// `lab_80'" _colum(`=80+25')  _continue

        qui sum `varyear' if inrange(`var', 0, 9e9)
        if r(N)>0 {
            local min_year = `r(min)'
            local max_year = `r(max)'
        }
        else {
            local min_year = `r(N)'
            local max_year = `r(N)'
            
            local vars_with_breaks "`vars_with_breaks' `var'"
            di "| " as error "Only missing (negative) values"
            continue
        }

        qui fre `varyear' if inrange(`var', 0, 9e9)
        local ndistinct = `r(r_valid)'
        local breaks = (`max_year' - `min_year'+1) - (`ndistinct')

        
        if `min_year' < `max_year' di as text "| Valid from `min_year' to `max_year'" _continue
        else di as text "| Valid in `min_year'" _continue
        if `current_year'-`max_year'==1 {
            local note = 1 
            local var_first_year_missing "`var_first_year_missing' `var'"
            di as result " <-" _continue
        }

        if `breaks' == 0 {
            di as text ""
        }
        else {

            local vars_with_breaks "`vars_with_breaks' `var'"
            local mis_years ""

            forvalues year = `min_year' (1) `max_year' {
                qui count if `varyear'==`year' & inrange(`var', 0, 9e9)
                if r(N)==0 local mis_years "`mis_years' `year'"
            }

            di as error " Breaks:`mis_years'"
        }
    }

    di as text _newline "Vars with breaks:" as result "`vars_with_breaks'"
    di as text "Missing since `current_year':" as result "`var_first_year_missing'" as text ""
    return local vars  `vars_with_breaks'
end
* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~



capture program drop reload
program define reload
    /*reload current variables from current dataset */
    qui ds
    di as text "reloading  `r(varlist)'" _n " from `c(filename)'"
    use `r(varlist)' using `c(filename)', clear
    desc, short
end
