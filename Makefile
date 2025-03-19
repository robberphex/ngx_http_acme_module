ROOT_DIR := $(strip $(shell dirname $(realpath $(lastword $(MAKEFILE_LIST)))))

SRC_VERSION := nginx-1.26.3
SRC_LINK := "http://nginx.org/download/$(SRC_VERSION).tar.gz"

SRC_PATH := $(ROOT_DIR)/$(SRC_VERSION)
RUN_PATH := $(ROOT_DIR)/run

MODULE_SRC := $(ROOT_DIR)/ngx_http_acme_module.c $(ROOT_DIR)/ngx_http_acme_module.h $(ROOT_DIR)/ngx_http_acme_lib.h
MODULE_CFG := $(ROOT_DIR)/config

EXAMPLE_DIR := $(ROOT_DIR)/example
EXAMPLE_CONFIG := $(EXAMPLE_DIR)/nginx.conf

RUN_CONF_DIR := $(RUN_PATH)/conf
RUN_CONFIG := $(RUN_CONF_DIR)/nginx.conf
RUN_BIN := $(RUN_PATH)/sbin/nginx
PID_FILE := $(RUN_PATH)/logs/nginx.pid

SRC_MKFILE := $(SRC_PATH)/Makefile
SRC_BIN := $(SRC_PATH)/objs/nginx

CONFIGURE_OPTS := --prefix="$(RUN_PATH)" --with-http_ssl_module

# Dev variables
EXAMPLE_CERT := $(EXAMPLE_DIR)/cert.pem
EXAMPLE_CERT_KEY := $(EXAMPLE_DIR)/cert-key.pem
ACME_DIR := $(RUN_CONF_DIR)/acme
ACME_SERVER_NAME := ledev2.kbauer.at
ACME_CERT_DIR := $(ACME_DIR)/live/$(ACME_SERVER_NAME)
ACME_ACC_DIR := $(ACME_DIR)/accounts

.PHONY: default source configure build install run \
	clean kill reinstall clean-install clean-all \
	run reconfigure clean-build clean-source

#
# Phony targets
#

default: build-dynamic

all: source install

source: clean-source
	mkdir -p "$(SRC_PATH)"
	curl $(SRC_LINK) | tar xz

configure: configure-as-dynamic

build:
	$(MAKE) -C "$(SRC_PATH)" -j 4

configure-debug:
	@test -d $(SRC_PATH) || (echo "You have to run 'make source' first to download the Nginx source code"; exit 2)
	cd "$(SRC_PATH)"; ./configure $(CONFIGURE_OPTS) --add-module="$(ROOT_DIR)" --with-debug

configure-as-dynamic:
	@test -d $(SRC_PATH) || (echo "You have to run 'make source' first to download the Nginx source code"; exit 2)
	cd "$(SRC_PATH)"; ./configure $(CONFIGURE_OPTS) --add-dynamic-module="$(ROOT_DIR)"


install: $(RUN_BIN)

run:
	@test -f "$(RUN_BIN)" || (echo "You have to run 'make install' first"; exit 2)
	@test ! -f "$(PID_FILE)" || (echo "Error: NginX is already running"; exit 2)
	"$(RUN_BIN)"

kill:
	test -f "$(PID_FILE)" && kill `cat "$(PID_FILE)"` || echo "Warning: NginX isn't running"

clean-install:
	rm -rf "$(RUN_PATH)"

reinstall: clean-install install

clean-build:
	$(MAKE) -C "$(SRC_PATH)" clean 2>/dev/null || true

reconfigure: clean-build configure

rebuild: clean-build build

clean: clean-install clean-build

clean-source:
	rm -rf $(SRC_PATH)

clean-all: clean clean-source

#
# File targets
#

$(RUN_BIN): build
	$(MAKE) -C "$(SRC_PATH)" install
	# Install example files
	cp "$(EXAMPLE_CONFIG)" "$(RUN_CONFIG)"
	mkdir -p "$(ACME_CERT_DIR)"
	mkdir -p "$(ACME_ACC_DIR)"
