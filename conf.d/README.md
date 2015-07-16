Overview
========
This configuration directory is the way in which users can customize
benchmarking. Anything with a .sh extension will be sourced by the runner.
Similarly, any configuration files you need for your self-contained tests should
be put here.

Usage
=====
To add something to the runner, you must add to the TESTS array. A simple
example is the nop test:
`TESTS[NOP]='echo 10'`

Variables
=========
There are several variables which are defined. The non-exhaustive list:
- RES_X - the width to run your test.
- RES_Y - the height to run your test.
- CONFIGS_PATH - the location of where this script resides, and the location
  where any configuration files for the test should reside.
- TESTS - The test array which should be added to.
