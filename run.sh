#!/bin/bash

rm -rf /src/pogoprotos/
git clone -b master https://github.com/goedzo/POGOProtos /src/pogoprotos/

rm -rf /src/pgoapi/
git clone -b 0.73.1 https://github.com/goedzo/pgoapi /src/pgoapi/

cp -F /src/pogoprotos/run.sh /src/run.sh
chmod +x /src/run.sh

cd /src/pogoprotos/
python compile.py python
tar -zcvf out.tar.gz out
cp out.tar.gz /tmp/

cd out
cp -Rf pogoprotos ../../pgoapi/pgoapi/protos
cd /src
tar -zcvf pgoapi.tar.gz pgoapi
cp pgoapi.tar.gz /tmp/