#~/bin/bash


# 

if [ ! $1 ];
then 
	echo "usage: $0 [lang]"
	exit 1
fi

lang=$1

directories=$(find pogo/ -type d -print0 | while read -d $'\0' file; do echo -n "-I $file "; done)
protos=$(find pogo/ -type f -name "*.proto" -print0| sed 's/\x00/ /g')

output_dir=$lang"_out/"

mkdir -p $output_dir

protoc $directories --"$lang"_out=$output_dir $protos

echo '[+] Done'