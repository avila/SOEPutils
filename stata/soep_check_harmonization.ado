*** ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
**# soep_check_harmonization: check harmonization
*** ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
/*  Version: 0.1
    Date: 10.02.2023
    Author: Marcelo Avila

    Syntax: soep_check_harmonization TARGET_VARIABLE INPUT_VARIABLE(S), 

    arguments and options:
        - verbose: include syear information, other than just displaying the variable labels
        - debug: only for debugging purposes

    Description: display every category of a harmonized (consolidate) and a target variable to check for consistency 
    during the harmonization process. 

    During a harmonization most categories are going to be uniquely identifiable in the input as well as in the output
    variable, but it can be the case that multiple, similar categories are merged into one. By carefuly looking at the
    variable labels and the years that they are valid one can more easily spot some harmonization issues. 

    to be improved: 
        - allow of [if] conditional
        - better support when using soep (-1, ..., -8) instead of stata missings (.a, ..., .h), sofar it 
        just checks for valid categories (between 0 and 9e9). Works fine as is, though.
        - trim very long labels
        - trim levels of syear if verbose
*/


capture program drop soep_check_harmonization
program define soep_check_harmonization
    
    syntax varlist(min=2),  [verbose] [debug]
    
    gettoken var_out varlist: varlist
    *gettoken var_ins : varlist

    if "`debug'"!="" local db "1"
    if "`db'"=="1" di as error "in: `var_ins', out: `var_out', list: `varlist'"

    foreach var_ins of local varlist {
        di as text _n "`var_ins' -> `var_out'" _n _n 
    

        qui levelsof `var_ins' if inrange(`var_ins', 0, 9e9), local(range_in) 
        foreach cati in `range_in' {
            
            qui levelsof `var_out' if `var_ins'==`cati' & inrange(`var_ins', 0, 9e9), local(range_out)
            local vallab_in_`cati': label (`var_ins') `cati' // #2 from above
            if "`db'"=="1" di as error "vallab_in_`cati': `vallab_in_`cati''"
            if "`db'"=="1" di as error "range_out `range_out'"

            local len_range_out : list sizeof local(range_out)
            if `len_range_out'>=1 {
                if `len_range_out'>=2 di as error "Warning: " as res "`var_ins'==`cati' splits in (`range_out')"

                foreach cato of numlist `range_out' { 
                    if "`db'"=="1" di as error "cati: `cati'"
                    if "`db'"=="1" di as error "cato: `cato'"
                    local vallab_out_`cati': label (`var_out') `cato' // #2 from above
                    di as resu  "(`cati'=`cato'):" _colum(10) _continue
                    di as resu "`var_ins': " "`vallab_in_`cati''"  _continue
                    di as text  _colum(85) "->" _continue
                    di as resu _colum(90) "`var_out': " "`vallab_out_`cati''" _skip(15)

                    qui levelsof syear if `var_ins'==`cati', sep(",") local(syeari)
                    if "verbose"=="`verbose'" di as text _colum(4) "syear in `var_ins'==`cati':" _colum(45)  "`syeari'"
                    qui levelsof syear if `var_out'==`cato', sep(",") local(syearo)
                    if "verbose"=="`verbose'" di as text  _colum(4) "syear in `var_out'==`cato':"  _colum(45)  "`syearo'" 
    
                }
    
            }
    
            else {
                di as error "Warning: " as res "`vallab_in_`cati'' -> No corresponding category in `var_out'"
    
            }
            di as text 40 * "~ ~ " 
    
        }
        if "`db'"=="1" di as error "`var_ins', `var_out'"
    }

end 
