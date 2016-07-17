POGOProtos
===================

This repository contains the [ProtoBuf](https://github.com/google/protobuf) `.proto` files needed to decode the PokemonGo RPC.

# Use
If on Windows, be sure to add te newest version of `protoc` to your environemntal path. If on *nix ensure that you have the newest version of `protoc` installed. To compile, run `compile.py` to recursively compile everything.

# Flags

 - Add the `-l` or `--language` flag to compile to whatever language you need, the default is C#.
 - Add the `-o` or `--output` flag to set an output directory, the deafult is `out`.