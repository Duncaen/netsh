PREFIX ?= /usr
VERSION ?= 0.0
SRCS = $(shell find ./ -type f -name '*.sh.in')
SCRIPTS = $(SRCS:.sh.in=.sh)
SERVICES = ethernet-generic bridge-generic netns-generic

%.sh: %.sh.in
	sed -e "s|@@PREFIX@@|$(PREFIX)|g" \
		-e "s|@@VERSION@@|$(VERSION)|g" \
		$^ > $@
	chmod +x $@

all: $(SCRIPTS) $(SERVICE_DIRS)

install: all
	install -d $(DESTDIR)/$(PREFIX)/bin
	install -m744 src/netsh.sh $(DESTDIR)/$(PREFIX)/bin/netsh
	install -d $(DESTDIR)/$(PREFIX)/lib/netsh/type
	install -m644 src/lib/cli $(DESTDIR)/$(PREFIX)/lib/netsh/
	install -m644 src/lib/common $(DESTDIR)/$(PREFIX)/lib/netsh/
	install -m644 src/lib/interface $(DESTDIR)/$(PREFIX)/lib/netsh/
	install -m644 src/lib/runit $(DESTDIR)/$(PREFIX)/lib/netsh/
	install -m644 src/lib/type/bridge $(DESTDIR)/$(PREFIX)/lib/netsh/type/
	install -m644 src/lib/type/netns $(DESTDIR)/$(PREFIX)/lib/netsh/type/
	install -m644 src/lib/type/veth $(DESTDIR)/$(PREFIX)/lib/netsh/type/

	install -d $(DESTDIR)/etc/sv/bridge-generic
	ln -sf $(PREFIX)/bin/netsh $(DESTDIR)/etc/sv/bridge-generic/run
	ln -sf $(PREFIX)/bin/netsh $(DESTDIR)/etc/sv/bridge-generic/finish

	install -d $(DESTDIR)/etc/sv/netns-generic
	ln -sf $(PREFIX)/bin/netsh $(DESTDIR)/etc/sv/netns-generic/run
	ln -sf $(PREFIX)/bin/netsh $(DESTDIR)/etc/sv/netns-generic/finish

	install -d $(DESTDIR)/etc/sv/veth-generic
	ln -sf $(PREFIX)/bin/netsh $(DESTDIR)/etc/sv/veth-generic/run
	ln -sf $(PREFIX)/bin/netsh $(DESTDIR)/etc/sv/veth-generic/finish

	install -d $(DESTDIR)/etc/sv/bridge-br0-eth0
	ln -sf ../bridge-generic/run $(DESTDIR)/etc/sv/bridge-br0-eth0/run
	ln -sf ../bridge-generic/finish $(DESTDIR)/etc/sv/bridge-br0-eth0/finish

	install -d $(DESTDIR)/etc/sv/veth-veth0-veth1
	ln -sf ../veth-generic/run $(DESTDIR)/etc/sv/veth-veth0-veth1/run
	ln -sf ../veth-generic/finish $(DESTDIR)/etc/sv/veth-veth0-veth1/finish

	install -d $(DESTDIR)/etc/sv/netns-ns0
	ln -sf ../netns-generic/run $(DESTDIR)/etc/sv/netns-ns0/run
	ln -sf ../netns-generic/finish $(DESTDIR)/etc/sv/netns-ns0/finish
	
test: all
	make install DESTDIR=./test
	mkdir -p ./test/var/service
	ln -sf ../../etc/sv/bridge-br0-eth0 ./test/var/service

clean:
	rm -rf $(SCRIPTS) sv/ test/
	# rm -f {ethernet,bridge}{,-generic}-{run,finish}
	# rm -f lib/{common,interface,bridge}
	# rm -rf test

.PHONY: install clean
