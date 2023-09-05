*! v0.2 sgen // mavila@diw.de
capture program drop sgen
program define sgen

    syntax newvarname =/exp [if] [in] 

    /* extract data type, if used it will be the first argument */
    gettoken left : 0, parse("=")
    if `: word count `left'' == 2 local datatype : word 1 of `left'

    gen `datatype' `varlist'=`exp' 

    cap drop _d_`varlist'
    gen _d_`varlist' = ""

    scalar counter_`varlist' = 0
end 
