#!/usr/bin/env python

import fnmatch
import os
import ntpath
import sys
import shutil
import argparse
from subprocess import call

# Add this to your path
protoc_path = "protoc"

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

# Find protofiles and compile
for root, dirnames, filenames in os.walk('pogo'):
    for filename in fnmatch.filter(filenames, '*.proto'):
        proto_file = os.path.join(root, filename)
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
