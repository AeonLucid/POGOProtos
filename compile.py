import fnmatch
import os
import ntpath
import sys
import shutil
from subprocess import call

# Not my proudest python code but it works.
is_64bits = sys.maxsize > 2**32

if is_64bits:
    protoc_path = os.path.abspath("..\packages\Google.Protobuf.Tools.3.0.0-beta3\\tools\windows_x64\protoc.exe")
else:
    protoc_path = os.path.abspath("..\packages\Google.Protobuf.Tools.3.0.0-beta3\\tools\windows_x86\protoc.exe")
proj_root = os.path.abspath("..\\")
proto_proj_path = os.path.abspath(proj_root + "\POGOLib\Pokemon\Proto")
proto_path = os.path.abspath("pogo\\")

shutil.rmtree(proto_proj_path)

matches = []
for root, dirnames, filenames in os.walk('pogo'):
    for filename in fnmatch.filter(filenames, '*.proto'):
        matches.append(os.path.join(root, filename))

for proto_file in matches:
    relative_path = proto_file.replace("\\" + ntpath.basename(proto_file), "")
    relative_path = relative_path.replace("pogo", "")

    destination_path = os.path.abspath(proto_proj_path + "\\" + relative_path)

    if not os.path.exists(destination_path):
        os.makedirs(destination_path)

    print("Compiling " + proto_file + "..")
    call("\"" + protoc_path + "\"" + " --proto_path=\"" + proto_path + "\" --csharp_out=\"" + os.path.abspath(proto_proj_path + "\\" + relative_path) + "\" \"" + os.path.abspath(proto_file) + "\"")

print("Done!")
