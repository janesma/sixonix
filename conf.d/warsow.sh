WARSOW_PATH=$BENCHDIR/warsow_21

function do_warsow() {
	sed "s/RES_X/${RES_X}/; s/RES_Y/${RES_Y}/" ${CONFIGS_PATH}/warsow.cfg > $WARSOW_PATH/basewsw/autoexec.cfg;
	sed "s/RES_X/${RES_X}/; s/RES_Y/${RES_Y}/" ${CONFIGS_PATH}/warsow.cfg > $WARSOW_PATH/benchsow/config.cfg;
	cd $WARSOW_PATH ;
	rm basewsw/sixonix.log
	./warsow.x86_64 +set fs_basepath "$WARSOW_PATH" +set fs_usehomedir 0 \
		+set timedemo 1 +demo basewsw/benchsow.wdz20 \
		+next "quit" 2> /dev/null 2>&1 ;
	grep frames basewsw/sixonix.log | awk '{print $5}'
}

TESTS[WARSOW]=do_warsow
