*! v0.2 sgen // mavila@diw.de
capture program drop sgen
program define sgen
    syntax newvarname =/exp [if] [in] 
    /* local typlist is generated automatically when syntax newvarname is used */
    
    gen `typlist' `varlist'=`exp' 

    cap drop _d_`varlist'
    qui gen _d_`varlist' = ""

    scalar counter_`varlist' = 0
end 
