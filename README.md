SIXONIX
=======
Sixonix is a very barebones set of scripts which enable the user to run various
benchmarks and collate the data.

Running benchmarks and collecting the data are surprisingly difficult to execute
in a reliable manner. The problem sixonix is trying to solve is to enable
benchmarking of different drivers, on the same system, while eliminating as much
user error (ie. using a debug build of mesa) and system noise (using incorrect
resolutions) as possible. It also attempts to do one step better than,
"run ministat" (it will do that too, if you wish).

If one intends to do anything but utilize the default configuration and recipe,
it will likely require a lot of user modification - and therefore that's not
recommended. **Although the project intends to eliminate as much user error as
possible, users of this infrastructure should do some amount of manual
verification for at least the first few times they use this tool, and after any
benchmark updates.**

Dependencies
============

[run_shuffled_benchmarks.sh](run_shuffled_benchmarks.sh):
- none?

[do_stats.sh](do_stats.sh):
- ministat

[new_stats.py](new_stats.py):
- python3
- numpy
- scipy
- ghc - lol, just kidding

Benchmarks
==========
- [Unigine Heaven, Valley](http://unigine.com/)
- [GFXBench 2.7, 3, 3.1](https://gfxbench.com)
- [GPUTest](http://www.geeks3d.com/gputest/)
- [Xonotic](http://www.xonotic.org/)
- [Warsow](https://www.warsow.net/)
- [MegaGlest](http://megaglest.org/)
- Synmark (internal benchmark)

Benchmark Dependencies
======================
Here is a brief list of dependencies that I don't have on a new Arch install.
Other distros probably are missing other things. You're on your own.

- GFXBench3.1: libXi.so.6, libXrandr.so.2
- Warsow 2.1: libpng12

Installation
============
Assuming you know me, it's pretty easy to get started.

1. Clone the sixonix repo.
2. Copy my benchmarks directory

Usage
=====
[The benchmark shuffler](run_shuffled_benchmarks.sh) will run a random mesa
version with and a random benchmark. Obviously you can customize things to your
heart's content, but if you want it to just work, you can follow the recipe below
which will test mesa-slow vs mesa-fast

Once the run is complete, you may use the included script for generating
statistics

### Execution
The runner as it exists today depends on underscore " _ " within the file names to
determine various information about the benchmark name, and which mesa is
running. Let's not argue about the best way to do it - just don't name your mesa
something with an underscore " _ " in it.

1. Configure the mesa build with default prefix and no debug symbols.
(ie, no -g, and don't touch --prefix or --exec_prefix)
  - `./autogen.sh CFLAGS='-O2 -fomit-frame-pointer -march=native' ...`
2. Build mesa
  - `make`

3. Install it to the local test directory
  - `make DESTDIR=~/mesa-test-dir/mesa-slow install`

4. apply really cool patch that improves perf
  - `git apply foo.patch`

5. Build and install the faster mesa
  - `make && make DESTDIR=~/mesa-test-dir/mesa-fast install`

6. Move to a directory you don't mind cluttering
  - `mkdir -p ~/results/perf ; cd $!`

7. Start benchmarking!
  - A quick sanity test:
      -  `~/scripts/sixonix/run_shuffled_benchmarks.sh -Q`
  - Every test 20 times (this should be the gold standard):
      -  `~/scripts/sixonix/run_shuffled_benchmarks.sh -A -i 20`
  - Unigine benchmarks, 5 times:
      -  `~/scripts/sixonix/run_shuffled_benchmarks.sh -u -i 5`

an execution.log file is created so one can quickly see the order in which
things ran.

### Post execution
By default, both statistics scripts will only output the tests which it finds to
be statistically significant. Using the -v option will display all results.
new_stats is what people should be using, but it's still very much a work in
progress.

#### [new_stats](new_stats.py)
This is the default statistics generator. [new_stats.py](new_stats.py) uses
numpy for all the statistical information and tends to be very finicky about the
input data. If you've got enough samples, you should definitely use this,
otherwise, either munge the script, or use do_stats.

- Default statistical comparison (all results) of two GL drivers:
  -  `~/scripts/sixonix/new_stat.py -v`

- Compare two tests:
  -  `~/scricts/sixonix/new_stats.py bench_warsow_mesa-slow bench_warsow_mesa-fast`

#### [do_stats](do_stats.sh)
The original [do_stats](do_stats.sh) script defers to ministat for all the
statistical generation. What's nice about this script is it doesn't care about
sample numbers or distributions, or anything like that. The bash quickly grew
unmaintainable, and so it's abandoned. (ie. use at your own risk).

`~/sripts/sixonix/do_stats.sh`
