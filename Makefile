PREFIX?=/usr
BIN=$(PREFIX)/bin

PEA=$(BIN)/pea
PEAD=$(BIN)/pead
PEAT=$(BIN)/peat

SERVICE=/usr/lib/systemd/system/pead.service
ALL=$(PEA) $(PEAD) $(PEAT) $(SERVICE)

check:
	@echo PREFIX is $(PREFIX)
	$(if $(value DISK),,$(error \
	You must specify the root device,\
	e.g. sudo DISK=/dev/sda2 make))
	@echo DISK is $(DISK)
	@echo Searching for dependencies...
	@which bash cryptsetup dd
	@echo Checking if DISK is LUKS encrypted...
	DISK=$(DISK) ./peat.sh

install: check
	install peat.sh $(PEAT)
	install pea.sh $(PEA)
	install pead.sh $(PEAD)
	sed -i "1s/^/DISK=$(subst /,\/,$(DISK))\n/" $(PEAT)
	sed "s/ExecStart=.*$$/ExecStart=$(subst /,\/,$(PEAD))/" pead.service > $(SERVICE)
	systemctl daemon-reload
	systemctl enable --now pead.service

uninstall:
	systemctl disable --now pead.service || true
	rm -v $(ALL)

.PHONY: check
