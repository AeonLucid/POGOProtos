#!/usr/bin/env python

import fnmatch
import os
import ntpath
import sys
import shutil
import argparse
from subprocess import call

# Determine operating system
op = "*nix"
if sys.platform.startswith('win'):
    op = "win" + ["64","32"][sys.maxsize > 2**32]

# Where does protoc live?
protoc_path = {
    "*nix": "protoc",
    "win64": "../packages/Google.Protobuf.Tools.3.0.0-beta3/tools/windows_x64/protoc.exe",
    "win": "../packages/Google.Protobuf.Tools.3.0.0-beta3/tools/windows_x86/protoc.exe"
}[op]

# Specify desired language
parser = argparse.ArgumentParser()
parser.add_argument("-l", "--lang", help="Language to produce protoc files")
args = parser.parse_args()
lang = args.lang or "csharp"

# Determine where to store
proj_root = os.path.abspath("../")
proto_proj_path = os.path.abspath(proj_root + "/POGOLib/Pokemon/Proto")
proto_path = os.path.abspath("pogo/")
shutil.rmtree(proto_proj_path)
matches = []
for root, dirnames, filenames in os.walk('pogo'):
    for filename in fnmatch.filter(filenames, '*.proto'):
        matches.append(os.path.join(root, filename))

for proto_file in matches:
    relative_path = proto_file.replace("/" + ntpath.basename(proto_file), "")
    relative_path = relative_path.replace("pogo", "")

    destination_path = os.path.abspath(proto_proj_path + "/" + relative_path)

    if not os.path.exists(destination_path):
        os.makedirs(destination_path)

    print("Compiling " + proto_file + "..")

    command = """{0} --proto_path='{1}' --{2}_out='{3}' '{4}'""".format(
        protoc_path,
        proto_path,
        lang,
        destination_path,
        os.path.abspath(proto_file)
    )

    call(command,shell=True)

print("Done!")
