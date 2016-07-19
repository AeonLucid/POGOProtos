POGOProtos
===================

This repository contains the [ProtoBuf](https://github.com/google/protobuf) `.proto` files needed to decode the PokémonGo RPC.

If you want to know which messages are implemented right now, click [here](https://github.com/AeonLucid/POGOProtos/blob/master/pogo/Networking/Requests/RequestType.proto).

# Usage

## Preparation

### Windows
Be sure to add te newest version of `protoc` to your environmental path.

### *nix
Ensure that you have the newest version of `protoc` installed.

### OS X
Use `homebrew` to install `protobuf ` with `brew install --devel protobuf`.

## Compilation
There are two ways to compile **POGOProtos**.

### Single file compilation (Recommended)
Run `python compile_single.py` to compile everything to a single file.

#### Flags

 - Add the `-l` or `--language` flag to compile to whatever language you need, the default is C#.
 - Add the `-o` or `--output` flag to set an output directory, the default is `out`.
 - Add the `-d` or `--desc_file` flag to only generate a descriptor file, `POGOProtos.desc` will be written to the specified output directory.

### Recursive compilation
Run `python compile.py` to recursively compile everything.

#### Flags

 - Add the `-l` or `--language` flag to compile to whatever language you need, the default is C#.
 - Add the `-o` or `--output` flag to set an output directory, the default is `out`.

### Extra information
You can find all available languages here [https://github.com/google/protobuf](https://github.com/google/protobuf).

# Libraries

If you don't want to compile POGOProtos but instead use it directly, check out the following repository.

*More will be added later when most proto files are added.*

| Language     | Source                                                |
|--------------|-------------------------------------------------------|
| NodeJS       | https://github.com/rastapasta/node-pokemongo-protobuf |