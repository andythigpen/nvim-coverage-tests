# Set DEV=1 to mount the local ../nvim-coverage path into the container during development

ifeq ($(DEV),1)
	DEV_VOLUME=-v $(shell pwd)/../nvim-coverage:/root/.local/share/nvim/site/pack/packer/start/nvim-coverage/
else
	DEV_VOLUME=
endif

.PHONY: test clean
test: python-test go-test typescript-test ruby-test cpp-test php-test
	@nvim --headless -c "PlenaryBustedDirectory ./unit"

clean: python-clean go-clean typescript-clean ruby-clean php-clean

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
	@(docker run --rm -v $(shell pwd):/test $(DEV_VOLUME) ${NVIM_PYTHON_IMAGE} \
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
	@(docker run --rm -v $(shell pwd):/test $(DEV_VOLUME) ${NVIM_BASE_IMAGE} \
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
	@(docker run --rm -v $(shell pwd):/test $(DEV_VOLUME) ${NVIM_BASE_IMAGE} \
		bash -c "cd /test && nvim --headless -c 'lua require\"coverage\".setup()' -c 'PlenaryBustedFile languages/typescript_spec.lua'")


## Ruby
RUBY_IMAGE:=mcr.microsoft.com/devcontainers/ruby:3
NVIM_RUBY_IMAGE:=nvim-coverage-ruby:3

languages/ruby/coverage/coverage.json:
	@(docker run --rm -v $(shell pwd):/test ${RUBY_IMAGE} \
		bash -c "cd /test/languages/ruby && bundle install && bundle exec rspec")

.PHONY: ruby-coverage ruby-clean ruby-image ruby-test
ruby-coverage: languages/ruby/coverage/coverage.json

ruby-clean:
	@(cd languages/ruby && \
		rm -rf coverage vendor .rspec_status)

ruby-image:
	@(docker build --build-arg BASE_IMAGE=${RUBY_IMAGE} -t ${NVIM_RUBY_IMAGE} .)

ruby-test: ruby-coverage ruby-image
	@(docker run --rm -v $(shell pwd):/test $(DEV_VOLUME) ${NVIM_RUBY_IMAGE} \
		bash -c "cd /test && nvim --headless -c 'lua require\"coverage\".setup()' -c 'PlenaryBustedFile languages/ruby_spec.lua'")


## C++
CPP_IMAGE:=mcr.microsoft.com/devcontainers/cpp:debian-11
NVIM_CPP_IMAGE:=nvim-coverage-cpp:debian-11

languages/cpp/report.info:
	@(docker run --rm -v $(shell pwd):/test ${NVIM_CPP_IMAGE} \
		bash -c "cd /test/languages/cpp && cmake . && make && make test && lcov --base-directory . --directory . -c -o report.info")

.PHONY: cpp-coverage cpp-clean cpp-image cpp-test
cpp-coverage: languages/cpp/report.info

cpp-clean:
	@(docker run --rm -v $(shell pwd):/test ${CPP_IMAGE} \
		bash -c "cd /test/languages/cpp && make clean")
	@(cd languages/cpp && \
		rm -rf report.info)

cpp-image:
	@(docker build --build-arg BASE_IMAGE=${CPP_IMAGE} -t ${NVIM_CPP_IMAGE} .)

cpp-test: cpp-coverage cpp-image
	(docker run --rm -v $(shell pwd):/test $(DEV_VOLUME) ${NVIM_CPP_IMAGE} \
		bash -c "cd /test && nvim --headless -c 'lua require\"coverage\".setup()' -c 'PlenaryBustedFile languages/cpp_spec.lua'")

## PHP
PHP_IMAGE:=mcr.microsoft.com/devcontainers/php:8

languages/php/coverage/cobertura.xml:
	@(docker run --rm -v $(shell pwd)/languages/php:/var/www/html -e XDEBUG_MODE=coverage ${PHP_IMAGE} \
		bash -c "cd /var/www/html && composer install && vendor/bin/phpunit --coverage-cobertura coverage/cobertura.xml --path-coverage tests/")

.PHONY: php-coverage php-clean php-test
php-coverage: languages/php/coverage/cobertura.xml

php-clean:
	@(docker run --rm -v $(shell pwd)/languages/php:/var/www/html ${PHP_IMAGE} \
		bash -c "rm -rf vendor coverage .phpunit.cache")

php-test: php-coverage base-image
	@(docker run --rm -v $(shell pwd):/test $(DEV_VOLUME) ${NVIM_BASE_IMAGE} \
		bash -c "cd /test && nvim --headless -c 'lua require\"coverage\".setup()' -c 'PlenaryBustedFile languages/php_spec.lua'")
