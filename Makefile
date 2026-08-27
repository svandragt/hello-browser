PREFIX ?= $(HOME)/.local
BUILD_DIR ?= build
APP := com.github.svandragt.hello-browser
URL ?= https://www.example.com

DESKTOP_DIR ?= $(HOME)/.local/share/applications
ICON ?= web-browser

.PHONY: all build setup install run clean wipe link desktop

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

desktop:
	@if [ -z "$(NAME)" ] || [ -z "$(URL)" ]; then \
		echo "usage: make desktop NAME=\"My App\" URL=https://example.org [ICON=icon-name]"; \
		exit 2; \
	fi
	@slug=$$(echo "$(NAME)" | tr '[:upper:] ' '[:lower:]-' | tr -cd 'a-z0-9-'); \
	file="$(DESKTOP_DIR)/hello-browser-$$slug.desktop"; \
	mkdir -p "$(DESKTOP_DIR)"; \
	{ \
		echo "[Desktop Entry]"; \
		echo "Type=Application"; \
		echo "Name=$(NAME)"; \
		echo "Exec=$(PREFIX)/bin/$(APP) --class $(APP).$$slug $(URL)"; \
		echo "Icon=$(ICON)"; \
		echo "Categories=Network;WebBrowser;"; \
		echo "Terminal=false"; \
		echo "StartupNotify=true"; \
		echo "StartupWMClass=$(APP).$$slug"; \
	} > "$$file"; \
	echo "Wrote $$file"; \
	command -v update-desktop-database >/dev/null && \
		update-desktop-database "$(DESKTOP_DIR)" || true
