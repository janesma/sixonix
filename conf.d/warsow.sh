WARSOW_PATH=$BENCHDIR/warsow_15

TESTS[WARSOW]='
sed "s/RES_X/${RES_X}/; s/RES_Y/${RES_Y}/" ${CONFIGS_PATH}/warsow.cfg > $WARSOW_PATH/basewsw/autoexec.cfg;
$WARSOW_PATH/warsow.x86_64 +set fs_basepath "$WARSOW_PATH" +set fs_usehomedir 0 \
	+set timedemo 1 +demo benchsow.wdz20 \
	+next "quit" 2> /dev/null 2>&1 | grep frames | awk "{print \$5}"'
