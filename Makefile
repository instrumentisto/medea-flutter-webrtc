LIBWEBRTC_PATH = https://github.com/logist322/libwebrtc-bin/releases/download/
LIBWEBRTC_VER = asdsa

deps: lib.download flutter.create.windows flutter.deps
build: rust.build flutter.build
run: flutter.run

# mylibwebrtc?
# add doc for each method
# debug or release
rust.build:
	cd libwebrtc && \
 	cargo build && \
	cp target/debug/mylibwebrtc.dll ../windows/rust/lib/mylibwebrtc.dll && \
	cp target/debug/mylibwebrtc.dll.lib ../windows/rust/lib/mylibwebrtc.dll.lib 

# use tar instead of 7z
lib.download:
	rm -rf libwebrtc-sys/include && \
	rm -rf libwebrtc-sys/webrtc && \
	mkdir lib_zip && \
	cd lib_zip && \
	curl -L -O --silent $(LIBWEBRTC_PATH)$(LIBWEBRTC_VER)/libwebrtc-win-x64.7z && \
	7z x libwebrtc-win-x64.7z && \
	echo "Copying files..." && \
	cp -R include ../libwebrtc-sys && \
	mkdir ../libwebrtc-sys/webrtc && \
	cp release/webrtc.lib ../libwebrtc-sys/webrtc/ && \
	cd ../ && \
	rm -rf lib_zip

flutter.build:
	cd example && flutter build windows

flutter.run:
	cd example && flutter run -d windows

flutter.deps:
	flutter pub get

flutter.create.windows:
	cd example/ && flutter create --platforms windows .

# add tests to libwebrtc-sys
# run tests on ci
# add rust related makefile scripts + dockerized
