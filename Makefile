PREFIX?=/usr
BIN=$(PREFIX)/bin

PEA=$(BIN)/pea
PEAD=$(BIN)/pead
PEAT=$(BIN)/peat
CONF=/etc/pea.conf
CHICKPEA=/etc/profile.d/01-chickpea

SERVICE=/usr/lib/systemd/system/pead.service
ALL=$(PEA) $(PEAD) $(PEAT) $(SERVICE)

check:
	$(info Checking for dependencies...)
	systemctl is-system-running
	@which bash cryptsetup dd


install: check
	install peat.sh $(PEAT)
	install pea.sh $(PEA)
	install pead.sh $(PEAD)
	install chickpea.sh $(CHICKPEA)
	cp pea.conf $(shell [ -f "$(CONF)" ] && echo $(CONF).pacnew || echo $(CONF))
	sed "s/ExecStart=.*$$/ExecStart=$(subst /,\/,$(PEAD))/" pead.service > $(SERVICE)
	systemctl daemon-reload

uninstall:
	systemctl disable --now pead.service || true
	rm -v $(ALL)
	mv $(CONF) $(CONF).pacsave

.PHONY: check
