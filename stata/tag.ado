*** ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
**# tag
*** ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
capture program drop tag
program define tag

    syntax [varname] if, 

    if "`varname'"=="" local varname pid
    local id_var `varname'

    cap drop __i 
    qui gen __i = 1 `if'

    cap drop _ck_all 
    qui egen _ck_all = max(__i==1), by(`id_var')

    cap drop __m 
    qui gen __m = __i * "<--"

    qui count if __i==1
    di as text "[var: __i]" _colum(20) "nr of of ids:" _colum(45) as res "`r(N)'"

    qui count if _ck_all==1 
    di as text "[var: _ck_all]" _colum(20) "nr of of ids * years:" _colum(45) as res "`r(N)'"

    di as text _newline "variables created or overwritten: '_ck_all', '__i' and '__m'"

end
