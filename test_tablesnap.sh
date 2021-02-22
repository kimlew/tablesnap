#! /bin/sh

# Script Name: test_tablesnap.sh

# Purpose: This script is called by Makefile, passes in 2 arguments, DIRECTORY
# (required) and TIMEOUT (optional), runs tablesnap in the background, e.g.,
# ./tablesnap& and tries to generate 1 of 2 events, IN_MOVED_TO or IN_CLOSE_WRITE
# to a directory, i.e., tries to move or write the file into the directory
# tablesnap is watching, /tmp/tablesnap-test.
# Then, the script checks if tablesnap noticed the events, e.g., uploaded the
# file with a command like: aws s3 ls

# TODO: Use Python to run tablesnap.

# Author: Kim Lew

# exit 1 - is Catchall for general errors.
usage() {
	cat <<-EOF
	usage: $(basename "$0") DIRECTORY TIMEOUT AWS_ACC_KEY_ID AWS_SEC_ACC_KEY
	Checks if inotify notices either an IN_MOVED_TO or an IN_CLOSE_WRITE event,
	to the target directory, /tmp/tablesnap-test.
	Required Arguments:
	- DIRECTORY is the target directory. Creates the directory, if it doesn't already exist.
	- TIMEOUT is the 5 second wait time.
	- AWS_ACC_KEY_ID is the ID needed to access AWS.
	- AWS_SEC_ACC_KEY is the secret key needed to access AWS.
EOF
  exit 1
}

SUCCESS=0
# TODO: Env var or passed in. Let's choose to pass them in since we are passing in other args already.
# TODO: Add a check for the 4 required args. If no args given OR args are empty, give help message.
# If condition not met, exit script with a general error - to shows help in HERE doc
# about script usage.
DIRECTORY=$1
TIMEOUT=$2
AWS_ACC_KEY_ID=$3
AWS_SEC_ACC_KEY=$4
BUCKET=$5
HARDLINKS_PATH=$6

# if $# - tells you the number of passed input arguments the script. if $# != 5
echo "# args passed: $#"
if [ $# -eq 0 ]; then
	echo "No parameters. 4 are required."
	usage
fi

if [ -z "$1" ] || [ -z "$2" ] || [ -z "$3" ] || [ -z "$4" ]; then
  echo "Some parameters are empty."
  usage
fi

# The directory, /tmp/tablesnap-test, should already exist since it is created in
# the Makefile. If the directory does not exist, this script creates the directory.
[ -d "$DIRECTORY" ] || mkdir -p "$DIRECTORY"

# Check for directory /tmp/tablesnap-hardlinks. If not there, create it.
# Example: '/tmp/tablesnap-hardlinks/inotify-test-1610413512'
echo "HARDLINKS_PATH is: $HARDLINKS_PATH"
[ -d "$HARDLINKS_PATH" ] || mkdir -p "$HARDLINKS_PATH"

# Check if AWS CLI is in container & if not install it.
if ! aws --version > /dev/null; then
  echo "Error: You are missing the aws cli program."
  echo "Install AWS CLI version 2."
  echo "Then re-run this script."
  exit 1
fi

# Set AWS_ACCESS_KEY_ID & AWS_SECRET_ACCESS_KEY as environment variables.
# Then, check with aws cli command, if moved or written file is in the container.
export AWS_ACCESS_KEY_ID="$AWS_ACC_KEY_ID"
export AWS_SECRET_ACCESS_KEY="$AWS_SEC_ACC_KEY"

aws s3 ls

echo "My hostname is: $(hostname)"

export TDEBUG=True

# For this tablesnap process running in the background, save the PID  & store
# as variable, to be used to kill process at script end.
echo "Waiting ${TIMEOUT} seconds to see IN_MOVED_TO or IN_CLOSE_WRITE event on ${DIRECTORY}"
./py36env/bin/python ./tablesnap -k "$AWS_ACC_KEY_ID" -s "$AWS_SEC_ACC_KEY" "$BUCKET" "$DIRECTORY" "$HARDLINKS_PATH" &
TABLESNAP_PID=$!
sleep "$TIMEOUT"

THE_FILE=inotify-test-$(date +%s)

touch /tmp/"${THE_FILE}" > /dev/null
mv /tmp/"${THE_FILE}" "${DIRECTORY}/${THE_FILE}" > /dev/null
sleep "$TIMEOUT"

# Check if the file is IN the /tmp/tablesnap-test.
# Need in form: s3://klew-tablesnap-pymigration
# aws s3 ls s3://klew-tablesnap-pymigration/831df189daac:/tmp/tablesnap-test/
if aws s3 ls "${BUCKET}/$(hostname):${DIRECTORY}/" | grep "$THE_FILE"; then
	echo "SUCCESS: The file is in S3."
else
	echo "FAILURE: The files is not in S3."
	SUCCESS=1
fi

kill $TABLESNAP_PID

exit $SUCCESS
