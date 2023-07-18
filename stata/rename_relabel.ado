* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
* Prog: rename_relabel
* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
/*
description:
    renames the variable as built-in rename command but also applies the label of the old_name to the
    new_name in order to keep track which input variable the renamed variable is based upon.

syntax:
     rename_relabel old_name new_name

example:
. desc plb0022_h
plb0022_h: Erwerbsstatus [harmonisiert]

. rename_relabel plb0022_h erwstatus_h

. desc erwstatus_h
erwstatus_h: Erwerbsstatus [harmonisiert] | plb0022_h
*/
* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
cap program drop rename_relabel
program rename_relabel
	args var newvar
	local lab : variable label `var'
	local newlab "`var':`lab'"
	label variable `var' "`newlab'"

	rename `var' `newvar'
	//if `verbose' di "relabeling `var' to `newlab'"
end
* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

