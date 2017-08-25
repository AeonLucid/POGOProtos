# To build a docker container for the "master" branch (this is the default) execute:
#
# docker build --build-arg BUILD_BRANCH=master .
# (or)
# docker build .
#
# To build a docker container for the "dev" branch execute:
# 
# docker build --build-arg BUILD_BRANCH=dev .
# 
# You can also build from different fork and specify a particular commit as the branch
# 
# docker build --build-arg BUILD_REPO=YourFork/PokemonGo-Bot --build-arg BUILD_BRANCH=6a4580f .

FROM alpine

ARG BUILD_REPO=goedzo/POGOProtos
ARG BUILD_BRANCH=master
ARG BUILD_REPO2=goedzo/pgoapi



LABEL build_repo=$BUILD_REPO build_branch=$BUILD_BRANCH

WORKDIR /usr/src/app
VOLUME ["/usr/src/app/configs", "/usr/src/app/web"]

RUN apk -U --no-cache add python py-pip tzdata \
    && rm -rf /var/cache/apk/* \
    && find / -name '*.pyc' -o -name '*.pyo' | xargs -rn1 rm -f

ADD https://raw.githubusercontent.com/$BUILD_REPO/$BUILD_BRANCH/requirements.txt .

#Need to load cert for WGET
RUN apk update
RUN apk add ca-certificates wget
RUN update-ca-certificates
RUN wget -P /tmp/ http://pgoapi.com/pgoencrypt.tar.gz

RUN apk -U --no-cache add --virtual .build-dependencies python-dev gcc make musl-dev git
RUN tar xvzf /tmp/pgoencrypt.tar.gz -C /tmp
RUN make -C /tmp/pgoencrypt/src
RUN cp /tmp/pgoencrypt/src/libencrypt.so /usr/src/app/encrypt.so
RUN ln -s locale.h /usr/include/xlocale.h
RUN pip install --no-cache-dir -r requirements.txt
RUN apk del .build-dependencies
RUN rm -rf /var/cache/apk/* /tmp/pgoencrypt* /usr/include/xlocale.h
RUN find / -name '*.pyc' -o -name '*.pyo' | xargs -rn1 rm -f

RUN apk update
RUN apk add bash

RUN apk update
RUN apk add mc

RUN apk update
RUN apk add git


# Install Protoc
################
RUN set -ex \
	&& apk --no-cache add --virtual .pb-build \
  make \
	cmake \
  autoconf \
  automake \
  curl \
  tar \
  libtool \
	g++ \
  \
	&& mkdir -p /tmp/protobufs \
	&& cd /tmp/protobufs \
	&& curl -o protobufs.tar.gz -L https://github.com/google/protobuf/releases/download/v3.3.0/protobuf-cpp-3.3.0.tar.gz \
	&& mkdir -p protobuf \
	&& tar -zxvf protobufs.tar.gz -C /tmp/protobufs/protobuf --strip-components=1 \
	&& cd protobuf \
	&& ./autogen.sh \
	&& ./configure --prefix=/usr \
	&& make \
	&& make install \
  && cd \
	&& rm -rf /tmp/protobufs/ \
  && rm -rf /tmp/protobufs.tar.gz \
	&& apk --no-cache add libstdc++ \ 
	&& apk del .pb-build \
	&& rm -rf /var/cache/apk/* \
	&& mkdir /defs

# Setup directories for the volumes that should be used
WORKDIR /defs


RUN git clone -b dev https://github.com/goedzo/POGOProtos /src/pogoprotos/
RUN git clone https://github.com/goedzo/pgoapi /src/pgoapi/
RUN cp /src/pogoprotos/run.sh /src/run.sh
RUN chmod +x /src/run.sh

CMD ["/bin/bash"]
