#!/bin/bash
declare VERBOSE
declare STRING

# The following regex describes the uniqueness in the file names. In this case,
# group0 is the name of the test, ie. eqypt, and group2 is the name representing
# mesa, ie. master
regex="(.+)_(.+$)"

# Returns true if there is a statistical difference in the two input files $1,
# and $2
function stat_diff() {
	# Run ministat on two files and see if they're statistically different.
	# IMPROVEME: Use something other than ministat
        if ministat ${1} ${2} 2>/dev/null | grep -q "No difference" ; then
		return 0
        else
		return 1
        fi
}

function print_header() {
	declare -A test_names
	max=()
	TEMP_STRING=""
	local skip=$1 # Number of columns to skip before printing the first

	# First find the largest set of mesas. If some version of mesa doesn't
	# run because of a crash, we may end up with different amounts (for
	# example if egypt crashes on test branch, but not master).
	for file in *;  do
		[[ $file =~ $regex ]]
		test_name="${BASH_REMATCH[1]}"
		mesa_name="${BASH_REMATCH[2]}"

		[[ -z $test_name ]] && continue
		[[ -z $mesa_name ]] && continue

		[[ -v test_names[$mesa_name] && test_names[$mesa_name] -eq 1 ]] && continue
		test_names[$mesa_name]=1

		mesa_versions=(${test_name}_*)

		if [[ ${#mesa_versions[*]} -gt ${#max[*]} ]] ; then
			# This fanciness just copies the array to max by
			# converting it to a string and then parsing back to an
			# array.
			stringed_array=$(declare -p mesa_versions)
			eval "declare -A max="${stringed_array#*=}
		fi
	done

	columns=${#max[*]}

	# If the caller asked for a skip > number of columns, it's a bug and if
	# we don't nastily inform the user, they may misinterpret the data
	# (speaking from experience)
	[[ $skip -gt $columns-1 ]] && echo "Specified skip is too large" && exit -1

	# Next begin building the header string taking into account the possible
	# number "skip" for which column to print first.
	# FIXME: Is Bash guaranteed to make this alphabetical? If not, it won't
	# match how we process this in the data function
	# The following prints our the headers according to skip - it's a dumb
	# stack kinda thing
	for m in ${max[*]} ; do
		[[ $m =~ $regex ]]
		mesa_name="${BASH_REMATCH[2]}"
		if [[ $skip -eq 0 ]] ; then
			TEMP_STRING="$mesa_name $TEMP_STRING"
		else
			TEMP_STRING="$TEMP_STRING $mesa_name"
		fi
		((--skip))
	done

	# Finally, print the string with the special diff column for the common
	# case of 2 data sets.
	STRING+="Test $TEMP_STRING"
	if [[ $columns -eq 2 ]] ; then
		STRING+=$(printf " diff%s" '\n')
	else
		STRING+=$(printf "%s" '\n')
	fi
	return $columns
}

# Print the results of statistics run all all files. If verbose mode isn't
# specified, it will only print tests which show a statistical difference.
function print_results() {
	declare -A result_files
	declare -A statistically_significant
	local columns=$1
	local first_column=$2

	# First create a unique list of tests
	# FIXME: There is probably a better way to do this...
	for file in *;  do
		[[ $file =~ $regex ]]
		test_name="${BASH_REMATCH[1]}"
		mesa_name="${BASH_REMATCH[2]}"

		[[ -z $test_name ]] && continue # Skip empty
		result_files[$test_name]=$test_name
	done

	# Next find all the tests of statistical significance
 	# FIXME: If the user asked for verbose output, we're going to print them all,
	# so just skip this the loop.
	for test_name in ${result_files[*]} ; do
		# Put all the versions in an array
		mesa_versions=(${test_name}_*)

		# If columns doesn't match expected it means we don't have input
		# data for both files. Just skip it.
		# FIXME: show a 0 avg?
		[[ $columns -eq ${#mesa_versions[*]} ]] || continue

		# Optimization: if we've already marked the test significant, move on
		[[ -n ${statistically_significant[$test_name]} ]] && continue

		# Verbose always adds everything.
		# If we're reporting 1 column, there's no point in the loop, ie.
		# it's the same as verbose mode.
		if [[ -n $VERBOSE ]] || [[ $columns -eq 1 ]] ; then
		       	statistically_significant[$test_name]=$test_name
			continue
		fi

		# Look for any statistical significance across all mesa versions
		# FIXME: Could be optimized
		for ((i=$columns-1; i>=1; i--)) ; do
			for ((j=$i-1; j>=0; j--)); do
				[[ $i -eq $j ]] && continue
				stat_diff "${mesa_versions[$i]}" "${mesa_versions[$j]}"
				local significant=$?
				# Mark it significant, and move to the next test
				if [[ $significant -eq 1 ]] ; then
					statistically_significant[$test_name]=$test_name
				       	break
				fi
			done

			# Already matched above, move on
			[[ -n ${statistically_significant[$test_name]} ]] && break
		done
	done

	# Finally print all tests. In order to get alphabetical order, we loop
	# over the tests per bash and compare to the statistically significant
	# array.
	for file in * ; do
		[[ $file =~ $regex ]]
		test_name="${BASH_REMATCH[1]}"
		[[ -z $test_name ]] && continue # Skip empty

		# Ignore tests which we didn't find with statistical
		# significance
		if ! egrep -q "\b${test_name}\b" <<<${statistically_significant[*]}; then
			continue
		fi

		# The caller gave us a column to start with, use that
		# and wraparound if needed
		mesa_versions=(${test_name}_*)
		if [[ ${columns} -eq 2 ]] ; then
			avg1=$(awk '{x+=$1;next}END{print x/NR}' ${mesa_versions[0]})
			avg2=$(awk '{x+=$1;next}END{print x/NR}' ${mesa_versions[1]})
			if [[ $first_column -eq 1 ]] ; then
				tmp=$avg1
				avg1=$avg2
				avg2=$tmp
			fi
			diff=`echo "scale=3; ${avg2}-${avg1}" | bc`
			STRING+=$(printf "%s %.3f %.3f %.3f%s" "$test_name" "$avg1" "$avg2" "$diff" '\n')
		else
			STRING+="$test_name"
			for ((i=$first_column; i<$columns+$first_column; i++)) ; do
				ndx=$(($i % $columns))
				avg=$(awk '{s+=$1}END{print s/NR}' RS=" " ${mesa_versions[$ndx]})
				STRING+=" $avg"
			done
			STRING+=$(printf "%s" '\n')
		fi
		# And remove it from the list
		unset statistically_significant[$test_name]
	done
}

function usage() {
	echo "[-vcrh] [-s skip count]"
	echo -e '\tv: Verbose output, print all data (default if not enough statistical data)'
	echo -e '\tc: CSV output (implies verbose)'
	echo -e '\tr: Reverse column order (shortcut for -s 1)'
	echo -e '\ts: "skip" count. Number of columsn to skip before first printed'
	echo -e '\th: This help'
}

SKIP=0
DELIMETER="     "
while getopts “vcs:rh” OPT; do
	case $OPT in
		v) VERBOSE=1 ;;
		c) DELIMETER="," ;;
		s) SKIP=$OPTARG ;;
		r) SKIP=1 ;;
		h) usage && exit 0 ;;
	esac
done

# The main calls a function to print the header, ie. explanation of which column
# is what. That returns the number of columns which we can use in the result
# printing
print_header $SKIP
COLUMN=$?
print_results $COLUMN $SKIP

echo -e $STRING | COLUMNS=72 column -t -s ' ' -o "${DELIMETER}"
