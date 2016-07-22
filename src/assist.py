#!/usr/bin/env python

import os
import argparse

parser = argparse.ArgumentParser()
parser.add_argument("-m", "--message", help="Message to prodecure files for.")
args = parser.parse_args()


def underscore_to_camelcase(value):
    def camelcase():
        while True:
            yield str.capitalize

    c = camelcase()
    return "".join(c.next()(x) if x else '_' for x in value.split("_"))


if not args.message:
    print "Specify a message."


def initialize_file(package, message, path):
    with open(path, 'a') as opened_file:
        opened_file.write('syntax = "proto3";\n')
        opened_file.write('package %s;\n\n' % package)
        opened_file.write('message %s {\n' % message)
        opened_file.write('\t// Initialized by assist.py\n')
        opened_file.write('}\n')

    print "Created %s" % path


message = underscore_to_camelcase(args.message)
request_path = os.path.join("POGOProtos\Networking\Requests\Messages", "%sMessage.proto" % message)
response_path = os.path.join("POGOProtos\Networking\Responses", "%sResponse.proto" % message)

initialize_file("POGOProtos.Networking.Requests.Messages", "%sMessage" % message, request_path)
initialize_file("POGOProtos.Networking.Responses", "%sResponse" % message, response_path)
