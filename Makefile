PREFIX ?= /usr
INSTALL_DIR ?= $(PREFIX)
SRC = $(wildcard src/**/*.hx)

all: build

app/app.js: $(SRC) app.hxml
	haxe app.hxml

bin/letterserver.js: $(SRC) server.hxml
	haxe server.hxml

build: app/app.js bin/letterserver.js

install:
	mkdir -p $(INSTALL_DIR)/lib/letterserver
	cp bin/package.json $(INSTALL_DIR)/lib/letterserver
	cd $(INSTALL_DIR)/lib/letterserver && npm install
	cp bin/letterserver.js* $(INSTALL_DIR)/lib/letterserver
	cp -r bin/level $(INSTALL_DIR)/lib/letterserver
	chmod +x $(INSTALL_DIR)/lib/letterserver/letterserver.js
	cp bin/letterserver.service /etc/systemd/system/
	#systemctl daemon-reload

uninstall:
	rm -rf $(INSTALL_DIR)/lib/letterserver
	rm -f /etc/systemd/system/letterserver.service

clean:
	rm -f app/app.js
	rm -f app/app.js.map
	rm -f app/app.css
	rm -f bin/letterserver.js
	rm -f bin/letterserver.js.map

.PHONY: all build install uninstall clean
