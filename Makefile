APP_NAME = Waridake
BUNDLE = build/$(APP_NAME).app
# Ad-hoc signing by default. Because the code signature changes on every
# rebuild, macOS drops the accessibility permission each time. To keep it,
# create a self-signed code signing certificate in Keychain Access and build
# with:  make SIGN_IDENTITY="Waridake Dev"
SIGN_IDENTITY ?= -

.PHONY: app icon install clean

app:
	swift build -c release
	rm -rf $(BUNDLE)
	mkdir -p $(BUNDLE)/Contents/MacOS $(BUNDLE)/Contents/Resources
	cp .build/release/$(APP_NAME) $(BUNDLE)/Contents/MacOS/
	cp Resources/Info.plist $(BUNDLE)/Contents/Info.plist
	cp Resources/$(APP_NAME).icns $(BUNDLE)/Contents/Resources/
	cp -R Resources/*.lproj $(BUNDLE)/Contents/Resources/
	codesign --force --sign "$(SIGN_IDENTITY)" $(BUNDLE)
	@echo "==> $(BUNDLE)"

# Redraws the app icon. Resources/Waridake.icns is committed, so this is only
# needed after changing the artwork in Tools/MakeIcon.swift.
icon:
	mkdir -p build
	swift Tools/MakeIcon.swift
	iconutil -c icns build/$(APP_NAME).iconset -o Resources/$(APP_NAME).icns
	@echo "==> Resources/$(APP_NAME).icns (preview: build/icon-preview.png)"

install: app
	rm -rf /Applications/$(APP_NAME).app
	cp -R $(BUNDLE) /Applications/
	@echo "==> Installed to /Applications/$(APP_NAME).app — grant accessibility on first launch"

clean:
	rm -rf .build build
