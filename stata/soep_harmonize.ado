*** ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
**# soep_harmonize: harmonize variables into one
*** ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

capture program drop soep_harmonize 
program define soep_harmonize 

    syntax varlist, GENerate(name) MISsings(str) [NOASSERT_multiple_valid] [replace]

    
    **# error handling 
    *** ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    
    if !inlist("`missings'", "stata", "soep") {
        Error 198 "missings() has to be either stata or soep"
    }

    if "`replace'"=="replace" cap drop `generate' /*drop gen variable if they already exist (and option replace called)*/
    confirm new var `generate'

    **# missing handling (to be able to use rowfirst)
    *** ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    if "`missings'" == "soep" {
        di as text "mvdecode `varlist'"
        di as text "this might a take a short while"
        mvdecode `varlist', mv(-1=.a \ -2=.b \ -3=.c \ -4=.d \ -5=.e \ -6=.f \ -7=.g \ -8=.h)
    }
    
    **# a) get the first non-missing value from varlist
    *** ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    
    //make sure only one non-missing per row in `varlist'
    tempvar check
    qui egen `check' = rownonmiss(`varlist') 
    qui sum `check'
    cap assert r(max)==1

    if _rc!=0{
        if "`noassert_multiple_valid'"=="" {
            Error 198 "More than one valid obs in `varlist'. Use 'noassert_multiple_valid' to bypass this assertion"
        }
        else {
            di as err  "Warning: More than one valid obs in 'varlist'. " _continue
            di as err  "The first non-missing from 'varlist' will be passed onto '`generate''."
            di as err  "Warning: The 'varlist' is: `varlist'."
            
            tempvar inter
            qui egen `inter' = rowfirst(`varlist')
            gen `generate' = `inter' if !mi(`inter') /* somehow necessary because if all missing takes last missing ¯\_(ツ)_/¯ */
        }
    }
    else {
        /* if there is only one, then mean is same as first/last, but sets to . if all missing (other than rowfirst) */
        qui egen `generate' = rowmean(`varlist')
    }


    **# b) populate final variable with missing, whereas a. have precedence over .b, and .b over .c, and so on.
    *** ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    qui ds `varlist'
    local var_list_comma = subinstr("`r(varlist)'", " ", ", ", .)
    foreach miss in .a .b .c .d .e .f .g .h {
        qui replace `generate' = `miss' if `generate'==. & inlist(`miss', `var_list_comma')
    }

    **# missing handling, back to previous state
    *** ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    if "`missings'" == "soep" {
        di as text "mvencode `varlist' `generate'"
        mvencode `varlist' `generate', mv(.a=-1 \ .b=-2 \ .c=-3 \ .d=-4 \ .e=-5 \ .f=-6 \ .g=-7 \ .h=-8)
        /* note that missings from `generate' is also encoded to soep missings */
    }
 
end

*** ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
