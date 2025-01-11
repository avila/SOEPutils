* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
* Prog: compare_gen
* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
/*
description:
    This little program compares and generate a _chk_ variable for each of the category of the `compare` output

usage:
    compare_gen stib stib_old, prefix("__cmp_")

warning:
    (!) This program will delete and variable that stats with with same prefix (default: "__cmp_") (!)
*/
* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
capture program drop compare_gen
program define compare_gen
    version 15
    syntax varlist(min=2 max=2) [if/], [PREfix(string) IDvar(varname)]
    tokenize `varlist'
    args var_1 var_2

    if "`prefix'" == "" local prefix "__cmp_"
    if "`idvar'" == "" local idvar "pid"

    local var_1_name = substr("`var_1'", strpos("`var_1'", "_")+1, .)
    local var_2_name = substr("`var_2'", strpos("`var_2'", "_")+1, .)

    if !mi("`if'") {
        local ifif     if `if' /* if including if keyword */
        local ifnot    if !(`if') /* if not for replace at the end */
    }

    compare `var_1' `var_2' `ifif'

    cap drop `prefix'`var_1_name'_`var_2_name'
    qui gen byte `prefix'`var_1_name'_`var_2_name' = .z
    qui replace `prefix'`var_1_name'_`var_2_name' = 1 if (`var_1' < `var_2' & !missing(`var_2') & !missing(`var_1'))
    qui replace `prefix'`var_1_name'_`var_2_name' = 2 if (`var_1' == `var_2') & (!missing(`var_2') & !missing(`var_1'))
    qui replace `prefix'`var_1_name'_`var_2_name' = 3 if (`var_1' > `var_2' & !missing(`var_2') & !missing(`var_1'))
    
    //qui replace `prefix'`var_1_name'_`var_2_name' = 4 if (!missing(`var_1') & !missing(`var_2'))
    qui replace `prefix'`var_1_name'_`var_2_name' = 4 if (missing(`var_1') & !missing(`var_2'))
    qui replace `prefix'`var_1_name'_`var_2_name' = 5 if (!missing(`var_1') & missing(`var_2'))
    qui replace `prefix'`var_1_name'_`var_2_name' = 6 if (missing(`var_1') & missing(`var_2'))

    cap label drop `prefix'`var_1'_`var_2' 
    label define `prefix'`var_1'_`var_2' ///
        1 "1: `var_1' < `var_2'" ///
        2 "2: `var_1' = `var_2'" ///
        3 "3: `var_1' > `var_2'" ///
        4 "4: `var_1' missing only" ///
        5 "5: `var_2' missing only" ///
        6 "6: jointly missing", replace //
    label values `prefix'`var_1_name'_`var_2_name' `prefix'`var_1'_`var_2'
    label var `prefix'`var_1_name'_`var_2_name' "Compare `var_1' and `var_2'"

    cap drop `prefix'all_uneqs
    qui gen byte `prefix'all_uneqs = (`var_1' != `var_2')
    cap drop `prefix'by_id
    qui egen byte `prefix'by_id = max(`prefix'all_uneqs), by(`idvar')
    if !mi("`if'") qui replace `prefix'`var_1_name'_`var_2_name' = . `ifnot' /* replaces back to missing based on passed if condition */

    di "New var: `prefix'`var_1_name'_`var_2_name', `prefix'all_uneqs, `prefix'by_id"
    
end
