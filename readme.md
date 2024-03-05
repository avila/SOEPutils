SOEPutils: Helper Stata programs for wrangling SOEP data
========================================================

The Stata programs included in this repository were developed to assist the
generation of the SOEP data. Most commands rely heavily on SOEP conventions
(such as missing numbers and names of key variables).

For now, most of the meager documentation and some usage examples can be found
in the actual do file of each command. Hopefully some basic help files will be
added in the near future.

Feel free to write an issue if bugs found or for feature request.

Installation 
============

You can check it and install this package using Stata's `net` command. 

net install SOEPutils,

```stata
net describe SOEPutils, from("https://raw.githubusercontent.com/avila/SOEPutils/main") 
net install  SOEPutils, from("https://raw.githubusercontent.com/avila/SOEPutils/main") replace
```


## list of programs:

```
- assert_year_range.ado
- compare_gen.ado
- is_there_a_new_version.ado
- recode_missings.ado
- rename_relabel.ado
- sgen.ado (will be replaced with -track-)
- srep.ado (will be replaced with -track-)
- soep_check_harmonization.ado
- soep_checks.ado
- soep_harmonize.ado
- tag.ado
- track.ado (testing)
- valid_years.ado

Author:  Marcelo Avila (Student Assistent at DIW Berlin)
```