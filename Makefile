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

clean:
	rm -rf '$(VIRTUALENV_DIR)' '$(BUILD_DIR)'

.PHONY: rebuild build clean
