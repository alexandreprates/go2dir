#!/usr/local/bin/bash

source /go2dir/tests/setup/tesht.sh

# Load source
source /go2dir/go2dir.sh

test go2 -l
assert_success
assert_stdout "Mapped dirs in"

mkdir -p /tmp/go2dir_test_site

test go2 -a /tmp/go2dir_test_site test_site
assert_success
assert_stdout "Mapping test_site to /tmp/go2dir_test_site"

test go2 -a wrong_dir_name ops
assert_fail 1
assert_stderr "Dir does not exist"

test go2 -l
assert_success
assert_stdout "test_site|/tmp/go2dir_test_site"

test go2 unknow_named
assert_fail 1
assert_stderr "Sorry, i didn't find unknow_named"

cd # Change current dir to user home

test go2 test_site
assert_success
assert_stdout "go to test_site at /tmp/go2dir_test_site"
assert_equal "$(pwd)" "/tmp/go2dir_test_site"

test go2 -R test_site
assert_success
assert_stdout "test_site was successfully removed"

test go2 -l
assert_not_stdout "Mapping"
assert_not_stdout "test_site|/tmp/go2dir_test_site"

test go2 -R
assert_fail 2
assert_stderr "You must specify the named directory to remove"

test go2 -R unknow_named
assert_fail 3
assert_stderr "unknow_named is not mapped"

mkdir -p /tmp/projects/foo\ bar
cd /tmp/projects/foo\ bar

test go2 -a .
assert_success
assert_stdout "Mapping foo-bar to /tmp/projects/foo bar"

cd

test go2 foo-bar
assert_success
assert_stdout "go to foo-bar at /tmp/projects/foo bar"
assert_equal "$(pwd)" "/tmp/projects/foo bar"

report
