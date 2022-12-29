# Example mounting local dev into a container:
# -v $(shell pwd)/../nvim-coverage:/root/.local/share/nvim/site/pack/packer/start/nvim-coverage/

.PHONY: test clean
test: python-test go-test typescript-test ruby-test
	@nvim --headless -c "PlenaryBustedDirectory ./unit"

clean: python-clean go-clean typescript-clean ruby-clean

## Base image
NVIM_BASE_IMAGE:=nvim-coverage-base:test

.PHONY: base-image
base-image:
	@(docker build --build-arg BASE_IMAGE=debian:11 -t ${NVIM_BASE_IMAGE} .)


## Python
PYTHON_IMAGE:=mcr.microsoft.com/vscode/devcontainers/python:3.10
NVIM_PYTHON_IMAGE:=nvim-coverage-python:3.10

languages/python/.coverage:
	@(docker run --rm -v $(shell pwd):/test ${PYTHON_IMAGE} \
		bash /test/languages/python/generate.sh)

.PHONY: python-coverage python-clean python-image python-test
python-coverage: languages/python/.coverage

python-clean:
	@(cd languages/python && \
		rm -rf .pytest_cache .coverage .coverage_no_branch)

python-image:
	@(docker build --build-arg BASE_IMAGE=${PYTHON_IMAGE} -t ${NVIM_PYTHON_IMAGE} .)

python-test: python-coverage python-image
	@(docker run --rm -v $(shell pwd):/test ${NVIM_PYTHON_IMAGE} \
		bash -c "cd /test && nvim --headless -c 'PlenaryBustedFile languages/python_spec.lua'")

## Go
GO_IMAGE:=mcr.microsoft.com/devcontainers/go:0-1.19-bullseye

languages/go/coverage.out:
	@(docker run --rm -v $(shell pwd)/languages/go:/go/src/fizzbuzz ${GO_IMAGE} \
		bash -c "cd /go/src/fizzbuzz && go test -race -covermode=atomic -coverprofile=coverage.out ./...")

.PHONY: go-coverage go-clean go-test
go-coverage: languages/go/coverage.out

go-clean:
	@(cd languages/go && \
		rm -f coverage.out)

go-test: go-coverage base-image
	@(docker run --rm -v $(shell pwd):/test ${NVIM_BASE_IMAGE} \
		bash -c "cd /test && nvim --headless -c 'lua require\"coverage\".setup()' -c 'PlenaryBustedFile languages/go_spec.lua'")


## Typescript
TYPESCRIPT_IMAGE:=mcr.microsoft.com/devcontainers/typescript-node:18

languages/typescript/coverage/lcov.info:
	@(docker run --rm -v $(shell pwd)/languages/typescript:/typescript/fizzbuzz ${TYPESCRIPT_IMAGE} \
		bash -c "cd /typescript/fizzbuzz && npm install && npx jest --coverage --testLocationInResults --verbose --testNamePattern='.*'")

.PHONY: typescript-coverage typescript-clean typescript-test
typescript-coverage: languages/typescript/coverage/lcov.info

typescript-clean:
	@(cd languages/typescript && \
		rm -rf node_modules coverage)

typescript-test: typescript-coverage base-image
	@(docker run --rm -v $(shell pwd):/test ${NVIM_BASE_IMAGE} \
		bash -c "cd /test && nvim --headless -c 'lua require\"coverage\".setup()' -c 'PlenaryBustedFile languages/typescript_spec.lua'")


## Ruby
RUBY_IMAGE:=mcr.microsoft.com/devcontainers/ruby:3
NVIM_RUBY_IMAGE:=nvim-coverage-ruby:3

languages/ruby/coverage/coverage.json:
	@(docker run --rm -v $(shell pwd):/test ${RUBY_IMAGE} \
		bash -c "cd /test/languages/ruby && bundle install && bundle exec rspec")

.PHONY: ruby-coverage ruby-clean
ruby-coverage: languages/ruby/coverage/coverage.json

ruby-clean:
	@(cd languages/ruby && \
		rm -rf coverage vendor .rspec_status)

ruby-image:
	@(docker build --build-arg BASE_IMAGE=${RUBY_IMAGE} -t ${NVIM_RUBY_IMAGE} .)

ruby-test: ruby-coverage ruby-image
	@(docker run --rm -v $(shell pwd):/test ${NVIM_RUBY_IMAGE} \
		bash -c "cd /test && nvim --headless -c 'lua require\"coverage\".setup()' -c 'PlenaryBustedFile languages/ruby_spec.lua'")
