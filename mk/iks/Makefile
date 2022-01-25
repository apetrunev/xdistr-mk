CUR_DIR := $(shell pwd)
XM := $(CUR_DIR)/xm.tar.gz

include ../common/gtm.vars

all: help

help:
	@echo "help: make install"

# $(1) -- file
define setCorrectPermissions
	chown -v gtm:gtm $(1) && chmod -v 664 $(1)
endef

install:
ifeq ($(GTM_DATA_PARTITION),mounted)
ifeq ($(GTM_DATA_MJL_PARTITION),mounted)
	@if ! test -d $(GTM_DIR); then false; fi
	@echo "Copy environment files"
	@cp -v $(CUR_DIR)/pattable_N $(GTM_DIR)/pattable_N
	@cp -v $(CUR_DIR)/iks_environment $(GTM_DIR)/.iks_environment
	@cp -v $(CUR_DIR)/iks_profile $(GTM_DIR)/.profile
	@if ! test -d $(PFS_DIR); then false; fi
	@cp -v $(CUR_DIR)/Server.ver $(PFS_DIR)/
	$(call setCorrectPermissions,$(GTM_DIR)/pattable_N)
	$(call setCorrectPermissions,$(GTM_DIR)/.iks_environment)
	$(call setCorrectPermissions,$(GTM_DIR)/.profile)
	$(call setCorrectPermissions,$(PFS_DIR)/Server.ver)
	@$(CUR_DIR)/setGtmUsersEnvironment
	@tar -C $(GTM_DIR)/ --xattrs -xvzpf $(XM) 
	@echo "Create database"
	if ! test -d $(GTM_DIR)/data; then false; fi
	runuser -u $(GTM_SUSER) -g $(GTM_SGROUP) -m -- /bin/sh -c "umask 002 && $(CUR_DIR)/db_create database" || true
	@if ! test -d $(GTM_DIR)/data/mjl; then false; fi
	runuser -u $(GTM_SUSER) -g $(GTM_SGROUP) -m -- /bin/sh -c "umask 002 && $(CUR_DIR)/db_journal enable $(GTM_DIR)/data/mjl/iks.mjl IKS" || true
	@$(CUR_DIR)/enableEmptyPasswords || true
	@cp -vr adm $(GTM_DIR)/
	# Copy services
	@find adm/services -mindepth 1 -maxdepth 1 -type f -name "*.service" -exec cp -v "{}" /etc/systemd/system/ \;
	@systemctl daemon-reload
	@systemctl enable gtm.service && systemctl start gtm.service
	@systemctl enable xvfb.service && systemctl start xvfb.service 
	@systemctl enable x11vnc.service && systemctl start x11vnc.service
	@systemctl enable xterm.service && systemctl start xterm.service
	@systemctl enable lab.service && systemctl start lab.service
	@systemctl restart ssh.service
	@echo "#########################################"
	@echo "# GT.M database installation completed. #"
	@echo "#########################################"
endif
endif
