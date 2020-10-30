SHELL := /bin/bash

VIRTUALENV := virtualenv
PYTHON     := /usr/bin/python2.7

VIRTUALENV_DIR := ./virtualenv
BUILD_DIR      := ./build

rebuild:
	$(VIRTUALENV) -p '$(PYTHON)' '$(VIRTUALENV_DIR)'

build:
	$(VIRTUALENV) -p '$(PYTHON)' '$(VIRTUALENV_DIR)'
	'$(VIRTUALENV_DIR)/bin/pip' install -r ./requirements.txt
	'$(VIRTUALENV_DIR)/bin/python' setup.py install

# Create a image with docker build & docker run.
docker-build:
	# e.g., docker build -t  <image_name> /path/to/Dockerfile/
	# -t flag - to tag the image with a name so Docker recognizes this name.
	docker build -t migrate2to3:v1 .

docker-run: docker-build
	# Runs docker-build part before docker-run part, i.e., docker-run DEPENDS on docker-build.
	docker run -it --mount type=bind,source=$(PWD),target=/tablesnap migrate2to3:v1 bash

# Create 2 virtualenvs & test if each virtualenv with each python is running correctly.
docker-py27env:
	docker run -it --mount type=bind,source=$(PWD),target=/tablesnap migrate2to3:v1 virtualenv py27env -p /usr/bin/python
	docker run -it --mount type=bind,source=$(PWD),target=/tablesnap migrate2to3:v1 py27env/bin/pip2 install -r requirements.txt

docker-py36env:
	docker run -it --mount type=bind,source=$(PWD),target=/tablesnap migrate2to3:v1 virtualenv py36env -p /usr/bin/python3
	docker run -it --mount type=bind,source=$(PWD),target=/tablesnap migrate2to3:v1 py36env/bin/pip3 install -r requirements.txt

test_py2.7: docker-py27env
	docker run -it --mount type=bind,source=$(PWD),target=/tablesnap migrate2to3:v1 ./py27env/bin/python ./tablesnap --help

test_py3.6: docker-py36env # Note: Expect this to FAIL until Python migration changes done when syntax errors corrected.
	docker run -it --mount type=bind,source=$(PWD),target=/tablesnap migrate2to3:v1 ./py36env/bin/python ./tablesnap --help

clean:
	rm -rf py27env
	rm -rf py36env
	rm -rf '$(VIRTUALENV_DIR)' '$(BUILD_DIR)'

default: build

.PHONY: rebuild build clean
