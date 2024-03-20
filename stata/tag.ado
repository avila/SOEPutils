*! v0.2 Marcelo Avila (mavila@diw.de/mrainhoavila@gmail.com) 20mar2024

*** ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
**# tag
*** ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
capture program drop tag
program define tag
    version 17

    syntax [varlist(min=0 default=none)] if, ///
        [NOLIst]                 /// does not list variables, only tags id variable
        [format(str)]            /// format of non-string variables
        [strformat(str)]         /// format of string variables
        [Header(integer 40)]     /// header option of list (number of rows for repeating variable name)
        [listopts(string asis)]  /// further options to be passed to list
        [NOSUmmarize]             // write a summary of other variables in varlist


    if "`varlist'"=="" {
        cap xtset
        if _rc == 459 {
            di as error "either pass a ID variable or set dataset to panel with -xtset-"
            exit 459
        }
        local id_var `r(panelvar)'
    }
    else {
        gettoken id_var covars : varlist
        
    }
    local numvars = wordcount("`varlist'")    
    
    if 0 {
        /* debug */
        di "id_var: `id_var'"
        di "covars: `covars'"
        di "varlist: `varlist'"
        di "numvars: `numvars'"
    }    
    
    
    *** ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    **# tags
    *** ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    cap drop __i 
    qui gen __i = 1 `if'

    cap drop __all 
    qui egen __all = max(__i==1), by(`id_var')

    cap drop __m 
    qui gen __m = __i * "<--"


    *** ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    **# lists
    *** ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    
    if "`nolist'"=="" & `numvars'>1 {
        /* shorten format to be able to display more variables */
        if `"`format'"'=="" local format "%12.0g"
        if `"`strformat'"'=="" local strformat "%12s"
        ds `varlist' , not(type string)
        if "`r(varlist)'" != "" format `r(varlist)' `format'
        ds `varlist' , has(type string)
        if "`r(varlist)'" != "" format `r(varlist)' `strformat'

        list `id_var' `covars' __m if __all==1, linesize(255) header(`header') noobs comp ab(9) sepby(`id_var') `listopts'
        di as text "Note: This command overwrites the format of the variables in varlist for better display"
    }
    
    *** ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    **# summarizes
    *** ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    
    if "`nosummarize'"=="" {

        qui count if __all==1 
        local n_all = r(N)

        // di 30 * "~ " _newline "Summarizing targeted variables" _newline 30 * "~ "
        qui levelsof `id_var' if __i==1
        di _newline as text "`id_var':" _colum(20) as res "`r(N)' " as text "tagged obs (" as res "`r(r)' " as text "uniquely, " as res "`n_all'" as text " total [pid#year]" ")" 

        foreach var in `covars' {
            qui levelsof `var' if __i==1, local(levels)  missing
            local n_cat = r(r)
            

            tempname matrvalid
            if `n_cat' <= 50 cap qui fre `var' if __i==1
            if `n_cat' <= 50 cap qui tab `var' if __i==1, missing matcell(`matrvalid')

            cap mata : st_numscalar("colsum", colsum(st_matrix("`matrvalid'")))
            if _rc == 3204 scalar colsum = 0 


            if `n_cat' < 50 {

                di as text _newline 60 * "~" " " _continue
                di as text "`var':" as res "%" as text _colum(90) " [total valid: " as res "`=colsum'" as text "]"

                local r = 1 
                foreach lev in `levels' {
                    local pcti = floor((`matrvalid'[`r',1]/colsum)*100/25)
                    
                    di as text "`lev':" as res %-5.1f (`matrvalid'[`r',1]/colsum)*100 `pcti' * "*" as text " " _continue 

                    if mod(`r', 20) == 0 di as res _newline _continue

                    local r = `r' + 1  
                }
            }
            else {
                di as text _newline 60 * "~" " " _continue
                di as text "`var':" as res "%" as text _colum(90) " [total valid: " as res "skipping..." as text "]"
                di as text as res "`n_cat' " as text "categories. Skipping detailed percentages..." _continue
            }

        }
    if `numvars'>1 di as text _newline _newline "(key: category:" as res "pct" as text "; " as res  "*" as text ">.25, "  as res "**" as text ">.50, "   as res"***" as text ">.75)"
    di as text  "(variables created or overwritten: '__all', '__i' and '__m')" 
    }

end
