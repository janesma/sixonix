SYNMARK_PATH=$BENCHDIR/Synmark2-6.10/
SYNMARK_HOME=~/SynMark2Home/

function init_synmark_cfg() {
	mkdir -p $SYNMARK_HOME
	synmark_cfg="$SYNMARK_HOME/User.cfg"
	echo "TestsToRun = \"$1\";" >> $synmark_cfg
	echo "FullScreen = True;" >> $synmark_cfg
	echo "WindowWidth = ${RES_X};" >> $synmark_cfg
	echo "WindowHeight = ${RES_Y};" >> $synmark_cfg
	echo "FrameWidth = 0;" >> $synmark_cfg
	echo "FrameHeight = 0;" >> $synmark_cfg
	echo "VSyncEnable = False;" >> $synmark_cfg
	echo "DepthFormat = D24;" >> $synmark_cfg
	echo "FrameBufferCount = 2;" >> $synmark_cfg
	echo "WarmUpFrames = 3;" >> $synmark_cfg
	echo "WarmUpTime = 5.0;" >> $synmark_cfg
	echo "MeasureFrames = 10;" >> $synmark_cfg
	echo "MeasureTime = 5.0;" >> $synmark_cfg
	echo "DumpTimestamps = False;" >> $synmark_cfg
	echo "DumpScreenshot = False;" >> $synmark_cfg
	echo "ScreenshotFrameNumber = 0;" >> $synmark_cfg
	echo "ValidateImage = False;" >> $synmark_cfg
	echo "AdaptiveFlipsTargetFps = 0;" >> $synmark_cfg
}

function synmark()
{
	syn_test=$1
	init_synmark_cfg $syn_test
	if [ -z ${DEBUGGER+x} ]; then
		./synmark2 | grep FPS | awk "{print \$2}"
	else
		${DEBUGGER} ./synmark2
	fi
	rm $synmark_cfg
	unset synmark_cfg
}

# Synmark
TESTS[SYNMARK]='cd $SYNMARK_PATH ; synmark $1'
