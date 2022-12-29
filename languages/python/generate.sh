#!/bin/bash

set -e

DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &> /dev/null && pwd)

cd $DIR
pipenv install 
pipenv run pytest --cov
mv .coverage .coverage_no_branch
pipenv run pytest --cov --cov-branch
