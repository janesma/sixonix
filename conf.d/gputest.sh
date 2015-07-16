GPUTEST_PATH=$BENCHDIR/GpuTest_Linux_x64_0.7.0

function gputest() {
	./GpuTest /fullscreen /width=$RES_X /height=$RES_Y \
		/benchmark /benchmark_duration_ms=10000 \
		/print_score /no_scorebox \
		/test=${1} | \
		grep Score | awk "{print \$2}"
}

TESTS[FUR]='cd $GPUTEST_PATH; gputest fur'
TESTS[TRIANGLE]=' cd $GPUTEST_PATH; gputest triangle'
TESTS[PLOT3D]='cd $GPUTEST_PATH; gputest plot3d'
