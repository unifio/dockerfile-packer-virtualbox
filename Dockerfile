# Run Packer w/ Virtualbox in a container
#
# Prerequisites
# - Host machine must have working installation of Virtualbox.
# - Host machine should have same Virtualbox version.
# - Host machine should have same kernel version as container.
#
# xhost +local:docker
#
# Example:
#
# docker run --rm \
# 	-v /tmp/.X11-unix:/tmp/.X11-unix \
#   -v /dev/vboxdrv:/dev/vboxdrv \
#   -v `pwd`:/data \
#	  -e DISPLAY=unix$DISPLAY \
#	  --privileged \
#	unifio/packer-virtualbox
#
FROM debian:jessie
MAINTAINER Unif.io, Inc. <support@unif.io>

ENV VBOX_VERSION 5.0.16-105871

ENV PACKER_VERSION 0.9.0
ENV PACKER_SHA256SUM 4119d711855e8b85edb37f2299311f08c215fca884d3e941433f85081387e17c

RUN apt-get update && apt-get install -y \
	ca-certificates \
	curl \
  unzip \
	software-properties-common \
  ruby \
  ruby-dev \
	--no-install-recommends && \
	curl -sSL https://www.virtualbox.org/download/oracle_vbox.asc | apt-key add - && \
	echo "deb http://download.virtualbox.org/virtualbox/debian jessie contrib" >> /etc/apt/sources.list.d/virtualbox.list && \
	apt-get update && \
	apt-get install -y \
	virtualbox-5.0=${VBOX_VERSION} \
	&& rm -rf /var/lib/apt/lists/*

RUN curl -s -o /packer-post-processor-vagrant-s3 "https://circle-artifacts.com/gh/unifio/packer-post-processor-vagrant-s3/13/artifacts/0/home/ubuntu/.go_workspace/bin/packer-post-processor-vagrant-s3" && \
  gem install bundler --no-ri --no-rdoc && \
  curl -s -o /packer.zip "https://releases.hashicorp.com/packer/${PACKER_VERSION}/packer_${PACKER_VERSION}_linux_amd64.zip" && \
  echo "${PACKER_SHA256SUM}  /packer.zip" | sha256sum -c && \
  unzip /packer.zip -d /bin && \
  chmod +x /packer-post-processor-vagrant-s3 && \
  mv /packer-post-processor-vagrant-s3 /bin && \
  rm -rf /packer.zip

VOLUME ["/data"]
WORKDIR /data

ENTRYPOINT ["/bin/packer"]

CMD ["--help"]
