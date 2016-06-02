XONOTIC_PATH=$BENCHDIR/Xonotic

function jordanatic() {
	set -- ./xonotic-linux-sdl.sh
	rm -f data/jordanatic.log
	rm -f data/benchmark.log
	rm -f data/engine.log

	# for next version of benchmark: remove +cl_playerdetailreduction 0 and add +showfps 1
	p="+vid_width $RES_X +vid_height $RES_Y +vid_desktopfullscreen 0 \
		+cl_curl_enabled 0 +r_texture_dds_load 1 \
		+cl_playerdetailreduction 0 +developer 1 \
		-nosound -nohome -benchmarkruns 2 \
		-benchmarkruns_skipfirst \
		-benchmark demos/jordanatic.dem"

	for e in ${1}; do
		rm -f data/benchmark.log
		echo + "$@" +exec effects-$e.cfg $p > data/engine.log
		"$@" +exec effects-$e.cfg $p >>data/engine.log 2>&1 || true
		grep "^MED: " data/engine.log | egrep -e "[0-9]+ frames" | awk "{print \$6}" # print results to the terminal
		if grep '\]quit' data/engine.log >/dev/null; then
			break
		fi
		cat data/engine.log >> data/jordanatic.log
		cat data/benchmark.log >> data/jordanatic.log
	done

	rm -f data/benchmark.log
	rm -f data/engine.log
	if ! [ -f data/jordanatic.log ]; then
		echo
		echo "The benchmark has been aborted. No log file has been written."
	fi
}

TESTS[XONOTIC_BIGKEY]='$XONOTIC_PATH/misc/tools/the-big-benchmark/sixonix.sh "normal" 2>/dev/null | \
	egrep -e "[0-9]+ frames" | awk "{print \$6}"'

TESTS[XONOTIC]='cd $XONOTIC_PATH ; jordanatic "normal"'
