FROM ubuntu:18.04

RUN set -ex && apt-get update && apt-get install -y \
	python \
	python3 \
	virtualenv \
	curl \
	zip

RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
RUN unzip awscliv2.zip
RUN ./aws/install

RUN mkdir /tablesnap
RUN mkdir /tmp/tablesnap-test
WORKDIR /tablesnap
