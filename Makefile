CUR_DIR := $(shell pwd)

all: help

help:
	@echo "help: make sourceslist"
	@echo "      make packages"
	@echo "      make install <--"

sourceslist:
	make -C $(CUR_DIR)/mk/base sourceslist

packages: 
	make -C $(CUR_DIR)/mk/base install

gtm:
	make -C $(CUR_DIR)/mk/gtm install

iks:
	make -C $(CUR_DIR)/mk/iks install

restore:
	make -C $(CUR_DIR)/mk/restore restore

samba:
	make -C $(CUR_DIR)/mk/samba install

install: packages gtm iks samba
