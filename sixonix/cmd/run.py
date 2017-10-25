import sixonix
import sys

def run_benchmark(args):
    import sixonix

    if args.benchmark not in sixonix.BENCHMARKS:
        print("ERROR: unknown benchmark.  Choose one of:")
        for test in sixonix.BENCHMARKS:
            print("    " + test)
        sys.exit(-1)

    fps = sixonix.run(args.benchmark, args)
    print(fps)

def register_cmd(subparsers):
    parser = subparsers.add_parser('run', help='run a single benchmark',
                                   parents=[sixonix.run_argparse])
    parser.add_argument('benchmark', help="benchmark to run")
    parser.set_defaults(func=run_benchmark)
