#!/bin/bash
source ak.bash
#sqlite_install

get_cache "test"
set_cache "test" "testcontent"
get_cache "test"
