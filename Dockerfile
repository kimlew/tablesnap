FROM ubuntu:18.04

RUN set -ex && apt-get update && apt-get install -y \
	python \
	python3 \
	virtualenv

RUN mkdir /tablesnap
WORKDIR /tablesnap
