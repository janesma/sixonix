import os
import sixonix
import sys

def run_benchmark(args):
    import sixonix

    if args.benchmark not in sixonix.BENCHMARKS:
        print("ERROR: unknown benchmark.  Choose one of:")
        for test in sixonix.BENCHMARKS:
            print("    " + test)
        sys.exit(-1)

    env = os.environ
    if args.mesa_path is not None:
        env = env.copy()
        sixonix.mesa.MesaPrefix(args.mesa_path).update_env(env)

    fps = sixonix.run(args.benchmark, args, env)
    print(fps)

def register_cmd(subparsers):
    parser = subparsers.add_parser('run', help='run a single benchmark',
                                   parents=[sixonix.run_argparse])
    parser.add_argument('benchmark', help="benchmark to run")
    parser.add_argument('--mesa-path', type=str, default=None,
                        help='path to the mesa build to use')
    parser.set_defaults(func=run_benchmark)
