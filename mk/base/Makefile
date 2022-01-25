DEBIAN_VERSION:=$(shell . /etc/os-release && echo $$VERSION_CODENAME)
PACKAGES=$(shell sed '/^\#/d' packages/distr)

.PHONY: sourceslist packages

all: help

help:
	@echo "help: make help"
	@echo "      make install"
	@echo "      make sousrceslist"
	@echo "      make packages"

sourceslist:
	@apt-get update
	@apt-get -y install curl wget apt-transport-https dirmngr || true 
	@[ "x$(DEBIAN_VERSION)" = "xbuster" ] && curl -s https://deb.nodesource.com/gpgkey/nodesource.gpg.key | apt-key add -
	@cp sourceslist/$(DEBIAN_VERSION).sources.list /etc/apt/sources.list
	@dpkg --add-architecture i386
	@apt-get update

packages: sourceslist
	@apt-get -y install $(PACKAGES) || true

install: packages
