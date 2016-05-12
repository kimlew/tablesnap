rebuild:
	virtualenv "./virtualenv"

build:
	virtualenv ./virtualenv
	./virtualenv/bin/pip install -r ./requirements.txt
	./virtualenv/bin/python setup.py install
	virtualenv --relocatable virtualenv
