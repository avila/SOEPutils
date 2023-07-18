* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
* Programs for interactive use (mostly to save some typing)
* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
/* define helper programs for interactive use */

capture program drop helper
program define helper

    /* short for tab syear VARNAME */
    cap program drop t // tab
    program t
        syntax [varlist], [*]
        tab syear `1', `options'
    end

    /* short for tab syear VARNAME, row nofreq */
    cap program drop rt // row tab
    program rt 
        tab syear `1', row nofreq
    end

    /* short for lookfor VARNAME */
    cap program drop lf
    program lf
    	lookfor `1'
    end

    /* short to check for valid obs by syear */
    cap program drop ll
    program ll
        syntax varlist
        valid_years `varlist'
    end

    /* short to check for valid obs by syear */
    cap program drop lluse
    program lluse
        syntax varlist
        clear results
        foreach var of varlist `varlist' {
            local lab : variable label `var'
            local lab_80 = substr("`lab'", 1, 60)
            qui levelsof syear if inrange(`var', 0, 9e9), sep(,)
            di "`var'" _colum(16) " /// `lab_80'" _colum(81) " | `r(levels)'"
        }
    end

end
