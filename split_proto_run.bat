mode con: cols=200 lines=60
Powershell.exe -File split_proto.ps1 -Sourcefile "%cd%\base\v0.71.0.proto" -OutPath "%cd%\temp_out" -ProtoIndexFile "%cd%\proto_index.txt" -ProtoTypeFile "%cd%\proto_types.txt" -ProtoImportFile "%cd%\proto_import.txt" -SrcFolder "%cd%\src" -MissingFile "%cd%\proto_missing.txt" > output.txt
@rem Powershell.exe -File split_proto.ps1 -Sourcefile "%cd%\base\v0.69.0.proto" -OutPath "%cd%\temp_out" -ProtoIndexFile "%cd%\proto_index.txt" -SrcFolder "%cd%\src"
pause