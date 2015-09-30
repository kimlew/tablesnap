rebuild: bleh
	virtualenv "./env"

bleh:
	virtualenv ./env
	./env/bin/pip install -r ./requirements.txt
	./env/bin/python setup.py install
	virtualenv --relocatable env
