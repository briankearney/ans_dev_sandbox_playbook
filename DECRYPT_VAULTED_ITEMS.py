import argparse
import base64
import pygments
import pygments.formatters
import pygments.lexers
import sys
import yaml

from io import StringIO
from subprocess import Popen, PIPE
from textwrap import dedent

parser = argparse.ArgumentParser(
    description=__doc__,
    formatter_class=argparse.RawTextHelpFormatter,
    prog="DECRYPT_VAULTED_ITEMS.py",
    epilog="Sample Command: python DECRYPT_VAULTED_ITEMS.py --color --decode --file foo.yml --id bar"
)

parser.add_argument(
    "-c",
    "--color",
    action="store_true",
    help="colorize the output for more readability",
)

parser.add_argument(
    "-d",
    "--decode",
    action="store_true",
    help="attempt to base64 decode the output",
)

parser.add_argument(
    "-f",
    "--file",
    help="the file used to store the ansible vault",
)

parser.add_argument(
    "-i",
    "--id",
    help="the ansible vault id to read and decrypt",
)

args = parser.parse_args()

results = []

with open(args.file, "r") as fin:
    for line in fin:
        # if line.startswith(args.id):
        if line.startswith(args.id + ': !vault |'):
            break
    else:
        print(f"{args.id} id not found in {args.file} file")
        sys.exit(1)
    for line in fin:
        if dedent(line) == line:
            break
        else:
            results.append(dedent(line))

results = "".join(results)
results = StringIO(results)

proc = Popen('ansible-vault decrypt', shell=True, stdin=PIPE, stdout=PIPE, stderr=PIPE)
out, err = proc.communicate(results.read().encode())

if args.decode:
    try:
        out = base64.b64decode(out).decode()
        decoded = True
        encoding = "base64"
    except:
        out = out.decode()
        decoded = False
        encoding = "none"
else:
    out = out.decode()
    decoded = False
    encoding = "none"

try:
    err = err.decode()
except UnicodeDecodeError:
    pass

lmay = {
    "decrypted_vault": {
        "decoded": decoded,
        "encoding": encoding,
        "error": err,
        "file": args.file,
        "id": args.id,
        "output": out,
    }
}

if args.color:
    fp = StringIO()
    yaml.dump(lmay, fp)
    fp.seek(0)
    s = fp.read()
    lexer = pygments.lexers.get_lexer_by_name('yaml')
    formatter = pygments.formatters.Terminal256Formatter()
    print(pygments.highlight(s, lexer, formatter))
else:
    yaml.dump(lmay, sys.stdout)
