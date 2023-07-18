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
	syntax varlist(min=2 max=2) [if], [PREfix(string) IDvar(varname)]
	tokenize `varlist'
	args var_1 var_2

	if "`prefix'" == "" local prefix "__cmp_"
	if "`idvar'" == "" local idvar "pid"


    cap drop `prefix'*

    if "`if'" != "" {
        preserve
        keep `if'
    }

	cap drop `prefix'*
	compare `var_1' `var_2'
	local var_1_name = substr("`var_1'", strpos("`var_1'", "_")+1, .)
	local var_2_name = substr("`var_2'", strpos("`var_2'", "_")+1, .)

	qui gen byte `prefix'`var_1_name'_lt_`var_2_name' = (`var_1' < `var_2' & !missing(`var_2') & !missing(`var_1'))
	qui gen byte `prefix'`var_1_name'_eq_`var_2_name' = (`var_1' == `var_2')
	qui gen byte `prefix'`var_1_name'_gt_`var_2_name' = (`var_1' > `var_2' & !missing(`var_2') & !missing(`var_1'))

	qui gen byte `prefix'jointly_def = 1 if (!missing(`var_1') & !missing(`var_2'))
	qui gen byte `prefix'`var_1_name'_misingOnly = 1 if (missing(`var_1') & !missing(`var_2'))
	qui gen byte `prefix'`var_2_name'_misingOnly = 1 if (!missing(`var_1') & missing(`var_2'))

    qui gen byte `prefix'all_uneqs = (`var_1' != `var_2')
	qui egen byte `prefix'by_id = max(`prefix'all_uneqs), by(`idvar')
    qui replace `prefix'by_id = . if `prefix'by_id == 0
	*qui replace `prefix'by_id = 0 if `prefix'by_id != 1

	qui bys `idvar': gen byte `prefix'_n_uneq = _n if  `prefix'all_uneqs==1

	tabstat `prefix'*, stat(n mean) col(stat) varwidth(32)

    * merge back
    if "`if'" != "" {
        qui tempfile temp
        qui save `temp'

        qui restore
        qui merge 1:1 pid syear using `temp', keepus(__*) nogen
    }

end
* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

