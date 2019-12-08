NAME := $(shell cargo read-manifest | jq -r ".name")
VERSION := $(shell cargo read-manifest | jq -r ".version")
DESCRIPTION := $(shell cargo read-manifest | jq ".description")
AUTHOR := $(shell cargo read-manifest | jq ".authors[]")

DIST=dist
BIN := $(shell echo "$(DIST)/bin/$(NAME)")
DEB := $(shell echo "$(DIST)/$(NAME)_$(VERSION)_amd64.deb")
RPM := $(shell echo "$(DIST)/$(NAME)-$(VERSION)-1.x86_64.rpm")

.PHONY: all
all: $(BIN) $(DEB) $(RPM)

.PHONY: $(BIN)
$(BIN):
	mkdir -p $(DIST)/bin
	cargo build --release
	cp target/release/$(NAME) $(BIN)
	strip $(BIN)

$(DEB): $(BIN)
	cd $(DIST) && fpm -s dir -t deb --prefix /usr -n $(NAME) -v $(VERSION) --description $(DESCRIPTION) --maintainer $(AUTHOR) --vendor $(AUTHOR) -d libncurses6 -d libc6 --license MIT -f --deb-priority optional --deb-no-default-config-files bin/$(NAME)

$(RPM): $(BIN)
	cd $(DIST) && fpm -s dir -t rpm --prefix /usr -n $(NAME) -v $(VERSION) --description $(DESCRIPTION) --maintainer $(AUTHOR) --vendor $(AUTHOR) -d "ncurses >= 6" --license MIT -f bin/$(NAME)

.PHONY: distclean
distclean:
	rm -rf $(DIST)

.PHONY: clean
clean: distclean
	cargo clean

.PHONY: dev-clippy
clippy:
	cargo watch -c -x clippy

.PHONY: dev-install
dev-install:
	cargo watch -c -x "install --path . --force"

.PHONY: install
install:
	cargo install --path . --force