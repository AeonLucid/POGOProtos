#!/usr/bin/env python

import argparse
import fnmatch
import ntpath
import sys
import os
import shutil
from helpers import compile_helper
from subprocess import call

# Add this to your path
protoc_path = "protoc"

# Specify desired language / output
parser = argparse.ArgumentParser()
parser.add_argument("-l", "--lang", help="Language to produce protoc files")
parser.add_argument("-o", "--out_path", help="Output path for protoc files")
args = parser.parse_args()

# Set defaults
lang = args.lang or "csharp"
out_path = args.out_path or "out"
default_out_path = out_path == "out"

# Determine where to store
proj_root = os.path.abspath("../")
proto_path = os.path.abspath("src/")
out_path = os.path.abspath(out_path)
tmp_out_path = out_path

# Output dir is actually different csharp because we modify it before compiling.
if lang == "csharp":
    tmp_out_path = os.path.join(tmp_out_path, "POGOProtos")

if not default_out_path:
    print 'Can we remove "%s"?' % tmp_out_path
    may_remove = compile_helper.query_yes_no("Please answer.", default="no")
else:
    may_remove = True

if may_remove and os.path.exists(tmp_out_path):
    shutil.rmtree(tmp_out_path)

# If any of the protoc builds fail, we continue on but exit with a non-0 exit
# code so that any automation (such as CI testing) can be made aware of the
# failure.
exit_codes = []

# Find protofiles and compile
for root, dirnames, filenames in os.walk(proto_path):
    protos = fnmatch.filter(filenames, '*.proto')
    relative_out_path = None
    for filename in protos:
        relative_out_path = None

        proto_file = os.path.join(root, filename)
        relative_file_path = proto_file.replace(proto_path, "")
        relative_path = relative_file_path.replace(ntpath.basename(proto_file), "")

        if lang == "csharp":
            destination_path = os.path.abspath(out_path + relative_path)
        else:
            destination_path = os.path.abspath(out_path)

        if relative_out_path is None:
            relative_out_path = os.path.abspath(out_path + relative_path)

        if not os.path.exists(destination_path):
            os.makedirs(destination_path)

        print("Compiling " + relative_file_path + "..")

        command = """{0} --proto_path="{1}" --{2}_out="{3}" "{4}\"""".format(
            protoc_path,
            proto_path,
            lang,
            destination_path,
            os.path.abspath(proto_file)
        )

        exit_codes.append(call(command, shell=True))

compile_helper.finish_compile(out_path, lang)

print("Done!")

if any(c != 0 for c in exit_codes):
  sys.exit(1)
