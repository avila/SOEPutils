
* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
* Prog: assert_year_range
* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
/*
description:
    assert_year_range will assert that simple characteristics of a variable such as min and max fall within a given
    range of syear. This is a quick way to check if there is a new version of a given variable. Missing values are not
    considered in the check.

usage:
    assert_year_range plc0275_v1, min(1995) max(2019) levels(-12 -8 -5 -2 1) onlypos

mandatory arguments:
	- minsyear: minimum syear that should contain valid categories
	- maxsyear: maximum syear that should contain valid categories

option arguments:
	- levels(numlist): list of levels (categories) to check against
	- positiveonly: check only positive (soep valid) categories

To suppress output just run it with quietly.
*/
* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
capture program drop assert_year_range
program define assert_year_range
	version 15
    syntax varlist(max=1), MINsyear(integer) MAXsyear(integer) [levels(numlist) POSitiveonly]
    local var    `varlist'
    /* NOTE: improve c_min and c_max. It is working well like this though */
    local c_min 0
    local c_max 999999
    qui sum syear if inrange(`var', `c_min', `c_max')
    cap assert r(min) == `minsyear' & r(max) == `maxsyear'
    if _rc != 0 {
        di as error "Assertion does not hold"
        di as error "Variable range: `r(min)'~`r(max)'"
        di as error "Checked range: `minsyear'~`maxsyear'"
        error 9
    }
    else {
        di as txt "Yearly range assertion holds. Range: `r(min)'~`r(max)'"
        // di as txt "values range `c_min'~`c_max'"
    }
    // di "1"
    if `"`levels'"'!="" {
    	// di "if"
    	if "`positiveonly'"!="" {
    		// di "only"
    		extract_valid_vals, levelstocheck(`levels')
    		local levels `r(valids)'
    		local if_cond "& `var' > 0"
    		// di "`if_cond'"
    		// di "`levels'"
    	}
    	// di "not only" "`levels'"
    	comma_numlist "`levels'"
    	// di "`r(comma_list)'"
    	local comma_levels "`r(comma_list)'"
    	cap assert inlist(`var', `comma_levels') if !mi(`var') `if_cond'
    	if _rc == 9 {
    		di as error "Levels assertion does not hold. Levels `levels' do not match those of `var'"
    		levelsof `var'
    		di as error "Levels of `var': `r(levels)'"
    		di as error "Check levels: `levels'"
    		error 9
    	}
    	foreach val of local levels {
    		qui count if `var'==`val'
    		cap assert r(N)>0
    		if _rc == 9 {
    			di as error "Levels assertion does not hold. Value `val' not found in `var'."
    			error 9
    		}
    		else {
    			di as txt "Levels assertion holds. Nice!"
    			di as txt "Levels checked: `levels'"
    		}

    	}
    }
end
* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


capture program drop comma_numlist
program comma_numlist, rclass
    /* used in assert_year_range */
    version 15
    numlist `0'
    local result "`r(numlist)'"
    local result : subinstr local result " " ",", all
    return local comma_list "`result'"
end
