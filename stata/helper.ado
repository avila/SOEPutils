capture program drop comma_numlist
program comma_numlist, rclass
	/* used in assert_year_range */
	version 15
	numlist `0'
	local result "`r(numlist)'"
	local result : subinstr local result " " ",", all
	return local comma_list "`result'"
end
