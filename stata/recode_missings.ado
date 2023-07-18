
*** ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
**# prog: recode_missings
*** ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
/* usage: recode_missings varlist, to(stata/soep) */

capture program drop recode_missings
program define recode_missings
    version 17
    
    syntax varlist, to(str) [override]

    if !inlist("`to'", "stata", "soep") {
        Error 198 "to() has to be either stata or soep"
    }
    
    if "`to'" == "stata" {
        local cmd mvdecode
        local miss_values "-1=.a \ -2=.b \ -3=.c \ -4=.d \ -5=.e \ -6=.f \ -7=.g \ -8=.h"
    }
    else {
        local cmd mvencode
        local miss_values ".a=-1 \ .b=-2 \ .c=-3 \ .d=-4 \ .e=-5 \ .f=-6 \ .g=-7 \ .h=-8"

    }
    
    `cmd' `varlist', mv(`miss_values') `override'

end

*** ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
**# subroutines
*** ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

/* Error nr txt
   displays error message txt and exit with nr
*/
cap program drop Error
program define Error
    args nr txt

    dis as err `"{p}Error: `txt'{p_end}"'
    exit `nr'
end
