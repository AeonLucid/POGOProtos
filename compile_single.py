#!/usr/bin/env python

import argparse
import os
import shutil
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
proto_path = os.path.abspath("pogo")
tmp_path = os.path.abspath("tmp")
tmp_file_path = os.path.abspath(tmp_path + "/POGOProtos.proto")
out_path = os.path.abspath(out_path)

# Clean up previous
if os.path.exists(tmp_path):
    shutil.rmtree(tmp_path)

if default_out_path and os.path.exists(out_path):
    shutil.rmtree(out_path)

# Create necessary directory
os.makedirs(tmp_path)
os.makedirs(out_path)


def walk_files(main_file, path):
    for file_name in os.listdir(path):
        file_name_path = os.path.join(path, file_name)
        if os.path.isfile(file_name_path):
            with open(file_name_path, 'r') as proto_file:
                skipping_header = True
                for proto_line in proto_file.readlines():
                    if proto_line.startswith("message") or proto_line.startswith("enum"):
                        skipping_header = False

                    if not skipping_header:
                        main_file.write(proto_line)

                        if proto_line == "}":
                            main_file.write('\n')
                            continue


def walk_directory(main_file, path):
    for dir_name in os.listdir(path):
        dir_name_path = os.path.join(path, dir_name)
        if os.path.isdir(dir_name_path):
            main_file.write("message %s {\n" % dir_name)

            walk_directory(main_file, dir_name_path)
            walk_files(main_file, dir_name_path)

            main_file.write("}\n")


with open(tmp_file_path, 'a') as tmp_file:
    tmp_file.write('syntax = "proto3";\n')
    tmp_file.write('package POGOProtos;\n\n')

    walk_directory(tmp_file, proto_path)
    walk_files(tmp_file, proto_path)

command = """{0} --proto_path="{1}" --{2}_out="{3}" "{4}\"""".format(
    protoc_path,
    tmp_path,
    lang,
    out_path,
    os.path.abspath(tmp_file_path)
)

call(command, shell=True)

print("Done!")
