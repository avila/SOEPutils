*** ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
**# tag
*** ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
capture program drop tag
program define tag
    version 17

    syntax varlist(min=1) if, [NOlist] /// does not list variables, only tags id variable
        [format(str)] /// format of non-string variables
        [strformat(str)] /// format of string variables
        [Header(integer 40)] /// header option of list (number of rows for repeating variable name)
        [listopts(string asis)] /// further options to be passed to list
        [SUMMarize] // write a summary of tagged 'co-variables'


    gettoken id_var covars : varlist


    *** ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    **# tags
    *** ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

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

    *** ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    **# lists
    *** ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    
    if "`nolist'"=="" {
        /* shorten format to be able to display more variables */
        if `"`format'"'=="" local format "%12.0g"
        if `"`strformat'"'=="" local strformat "%12s"
        ds `varlist' , not(type string)
        if "`r(varlist)'" != "" format `r(varlist)' `format'
        ds `varlist' , has(type string)
        if "`r(varlist)'" != "" format `r(varlist)' `strformat'

        list `id_var' `varlist' __m if _ck_all==1, linesize(255) header(`header') noobs sepby(`id_var') `listopts'

    }
    
    *** ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    **# summarizes
    *** ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    
    if "`summarize'"!="" {
        qui levelsof `id_var' if __i==1
        di _newline as text "`id_var':" _colum(20) as res "`r(N)' " as text "tagged obs. " as res "`r(r)' " as text "uniquely" 

        foreach var in `covars' {
            qui levelsof `var' if __i==1, local(levels) 
            local n_cat = r(r)
            qui fre `var' if __i==1
            cap mata : st_numscalar("colsum", colsum(st_matrix("r(valid)")))
            if _rc == 3204 scalar colsum = 0 

            di as text _newline 120 * "~"
            di as text "var: `var':" as res "%" as text " [total: " as res "`=colsum'" as text "]"
            if `n_cat' < 50 {

                local r = 1 
                foreach lev in `levels' {

                    di as text "`lev':" as res %-5.1f (r(valid)[`r',1]/colsum)*100 as text " " _continue 
                    if mod(`r', 20) == 0 di as res _newline _continue

                    local r = `r' + 1  
                }
            }
            else {
                di as text as res "`n_cat' " as text "categories, skipping detailed percentages..." _continue
            }
            
            
        }
    }

end
