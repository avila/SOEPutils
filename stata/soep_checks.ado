capture program drop soep_checks
program define soep_checks
    version 17
    
    syntax, [NOVersions] [NOLevels] [VARyear(varname)]
    desc, short

    if "`noversions'"=="" {
        di 120 * "~"
        di as input "Checking if there is a new version of loaded variables"
        is_there_a_new_version

        di 120 * "~"
    }
    if "`varyear'"=="" {
        // is no custom varyear, use syear
        local varyear syear
    }
    capture confirm variable `varname'
    if _rc==111 {
        di "variable '`varyear'' not loaded, so not checking for valid years"
    }
    else if "`nolevels'"=="" {
        di as input _n"Checking valid years of loaded variables"
        valid_years, varyear(`varyear')
        di 120 * "~"
    }
end
