PREFIX ?= $(HOME)/.local
BUILD_DIR ?= build
APP := com.github.svandragt.hello-browser
URL ?= https://www.example.com

.PHONY: all build setup install run clean wipe link

all: build

$(BUILD_DIR)/build.ninja:
	meson setup $(BUILD_DIR) --prefix=$(PREFIX)

setup: $(BUILD_DIR)/build.ninja

build: setup
	ninja -C $(BUILD_DIR)

install: build
	ninja -C $(BUILD_DIR) install

run: install
	XDG_DATA_DIRS="$(PREFIX)/share:$$XDG_DATA_DIRS" \
		$(BUILD_DIR)/src/$(APP) --url $(URL)

link: install
	mkdir -p $(HOME)/bin
	ln -sf $(PREFIX)/bin/$(APP) $(HOME)/bin/hello-browser

wipe:
	meson setup --wipe $(BUILD_DIR) --prefix=$(PREFIX)

clean:
	rm -rf $(BUILD_DIR)
