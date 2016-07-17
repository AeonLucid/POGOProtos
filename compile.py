#!/usr/bin/env python

import argparse
import fnmatch
import ntpath
import os
import shutil
from subprocess import call

# Add this to your path
protoc_path = "protoc"

# Specify desired language
parser = argparse.ArgumentParser()
parser.add_argument("-l", "--lang", help="Language to produce protoc files")
parser.add_argument("-o", "--out_path", help="Output path for protoc files")
args = parser.parse_args()
lang = args.lang or "csharp"
out_path = args.out_path or "out"

# Determine where to store
proj_root = os.path.abspath("../")
proto_path = os.path.abspath("pogo/")
out_path = os.path.abspath(out_path)

# Clean up previous
if os.path.exists(out_path):
    shutil.rmtree(out_path)

# Find protofiles and compile
for root, dirnames, filenames in os.walk(proto_path):
    for filename in fnmatch.filter(filenames, '*.proto'):
        proto_file = os.path.join(root, filename)
        relative_file_path = proto_file.replace(proto_path, "")
        relative_path = relative_file_path.replace(ntpath.basename(proto_file), "")

        destination_path = os.path.abspath(out_path + relative_path)

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

        call(command, shell=True)

print("Done!")
