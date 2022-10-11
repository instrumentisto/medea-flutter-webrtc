###############################
# Common defaults/definitions #
###############################

comma := ,

# Checks two given strings for equality.
eq = $(if $(or $(1),$(2)),$(and $(findstring $(1),$(2)),\
                                $(findstring $(2),$(1))),1)




######################
# Project parameters #
######################

RUST_VER ?= 1.64
RUST_NIGHTLY_VER ?= nightly-2022-10-05

FLUTTER_RUST_BRIDGE_VER ?= $(strip \
	$(shell grep -A1 'name = "flutter_rust_bridge"' Cargo.lock \
	        | grep -v 'flutter_rust_bridge' \
	        | cut -d'"' -f2))

KTFMT_VER ?= 0.33

ifneq ($(shell command -v swift 2> /dev/null),)
SWIFT_VER ?= $(strip \
	$(shell swiftc --version | grep 'Apple Swift version' | cut -d' ' -f4))
endif

CURRENT_OS ?= $(strip $(or $(os),\
	$(if $(call eq,$(OS),Windows_NT),windows,\
	$(if $(call eq,$(shell uname -s),Darwin),macos,linux))))




###########
# Aliases #
###########

build: cargo.build

clean: cargo.clean flutter.clean

codegen: cargo.gen

deps: flutter.pub

docs: cargo.doc

fmt: cargo.fmt flutter.fmt kt.fmt swift.fmt

lint: cargo.lint flutter.analyze

run: flutter.run

test: cargo.test flutter.test




####################
# Flutter commands #
####################

# Lint Flutter Dart sources with dartanalyzer.
#
# Usage:
#	make flutter.analyze

flutter.analyze:
ifeq ($(wildcard .packages),)
	flutter pub get
endif
	flutter analyze


# Clean built Flutter artifacts and cache.
#
# Usage:
#	make flutter.clean

flutter.clean:
	flutter clean


# Build Flutter example application for Windows.
#
# Usage:
#	make flutter.build [platform=(apk|linux|macos|windows)]

flutter.build:
	cd example/ && \
	flutter build $(platform)


# Format Flutter Dart sources with dartfmt.
#
# Usage:
#	make flutter.fmt [check=(no|yes)]

flutter.fmt:
	flutter format $(if $(call eq,$(check),yes),-n --set-exit-if-changed,) .
ifeq ($(wildcard .packages),)
	flutter pub get
endif
	flutter pub run import_sorter:main --no-comments \
		$(if $(call eq,$(check),yes),--exit-if-changed,)


# Install Flutter Pub dependencies.
#
# Usage:
#	make flutter.pub [cmd=(get|<pub-cmd>)]

flutter.pub:
	flutter pub $(or $(cmd),get)


# Run Flutter example application for the current OS.
#
# Usage:
#	make flutter.run

flutter.run:
	cd example/ && \
	flutter run -d $(CURRENT_OS) --release


# Run Flutter plugin integration tests on an attached device.
#
# Usage:
#	make flutter.test [device=<device-id>]

flutter.test:
	cd example/ && \
	flutter drive --driver=test_driver/integration_driver.dart \
	              --target=integration_test/webrtc_test.dart \
	              --profile \
	              $(if $(call eq,$(device),),,-d $(device))




##################
# Cargo commands #
##################

# Clean built Rust artifacts.
#
# Usage:
#	make cargo.clean

cargo.clean:
	cargo clean


# Build `flutter-webrtc-native` crate and copy final artifacts to appropriate
# platform-specific directories.
#
# Usage:
#	make cargo.build [debug=(yes|no)] [args=<cargo-build-args>]

lib-out-path = target/$(if $(call eq,$(debug),no),release,debug)

cargo.build:
	cargo build -p flutter-webrtc-native \
		$(if $(call eq,$(debug),no),--release,) \
		$(args)
ifeq ($(CURRENT_OS),linux)
	@mkdir -p linux/rust/include/flutter-webrtc-native/include/
	@mkdir -p linux/rust/lib/
	@mkdir -p linux/rust/src/
	cp -f $(lib-out-path)/libflutter_webrtc_native.so \
		linux/rust/lib/libflutter_webrtc_native.so
	cp -f target/cxxbridge/flutter-webrtc-native/src/renderer.rs.h \
		linux/rust/include/flutter_webrtc_native.h
	cp -f crates/native/include/api.h \
		linux/rust/include/flutter-webrtc-native/include/api.h
	cp -f target/cxxbridge/flutter-webrtc-native/src/renderer.rs.cc \
		linux/rust/src/flutter_webrtc_native.cc
endif
ifeq ($(CURRENT_OS),macos)
	@mkdir -p macos/rust/lib/
	cp -f $(lib-out-path)/libflutter_webrtc_native.dylib \
		macos/rust/lib/libflutter_webrtc_native.dylib
endif
ifeq ($(CURRENT_OS),windows)
	@mkdir -p windows/rust/include/
	@mkdir -p windows/rust/lib/
	@mkdir -p windows/rust/src/
	@mkdir -p windows/rust/include/flutter-webrtc-native/include/
	cp -f $(lib-out-path)/flutter_webrtc_native.dll \
		windows/rust/lib/flutter_webrtc_native.dll
	cp -f $(lib-out-path)/flutter_webrtc_native.dll.lib \
		windows/rust/lib/flutter_webrtc_native.dll.lib
	cp -f target/cxxbridge/flutter-webrtc-native/src/renderer.rs.h \
		windows/rust/include/flutter_webrtc_native.h
	cp -f crates/native/include/api.h \
		windows/rust/include/flutter-webrtc-native/include/api.h
	cp -f target/cxxbridge/flutter-webrtc-native/src/renderer.rs.cc \
		windows/rust/src/flutter_webrtc_native.cc
endif


# Generate documentation for project crates.
#
# Usage:
#	make cargo.doc [open=(yes|no)] [clean=(no|yes)] [dev=(no|yes)]

cargo.doc:
ifeq ($(clean),yes)
	@rm -rf target/doc/
endif
	cargo doc --workspace --no-deps \
		$(if $(call eq,$(dev),yes),--document-private-items,) \
		$(if $(call eq,$(open),no),,--open)


# Format Rust sources with rustfmt.
#
# Usage:
#	make cargo.fmt [check=(no|yes)] [dockerized=(no|yes)]

cargo.fmt:
ifeq ($(dockerized),yes)
	docker run --rm --network=host -v "$(PWD)":/app -w /app \
		-u $(shell id -u):$(shell id -g) \
		-v "$(HOME)/.cargo/registry":/usr/local/cargo/registry \
		ghcr.io/instrumentisto/rust:$(RUST_NIGHTLY_VER) \
			make cargo.fmt check=$(check) dockerized=no
else
	cargo +nightly fmt --all $(if $(call eq,$(check),yes),-- --check,)
endif


# Generates Rust and Dart side interop bridge.
#
# Usage:
#	make cargo.gen

cargo.gen:
ifeq ($(shell which flutter_rust_bridge_codegen),)
	cargo install flutter_rust_bridge_codegen --vers=$(FLUTTER_RUST_BRIDGE_VER)
else
ifneq ($(strip $(shell flutter_rust_bridge_codegen --version | cut -d ' ' -f2)),$(FLUTTER_RUST_BRIDGE_VER))
	cargo install flutter_rust_bridge_codegen --force \
	                                          --vers=$(FLUTTER_RUST_BRIDGE_VER)
endif
endif
ifeq ($(shell which cbindgen),)
	cargo install cbindgen
endif
ifeq ($(CURRENT_OS),macos)
ifeq ($(shell brew list | grep -Fx llvm),)
	brew install llvm
endif
endif
	flutter_rust_bridge_codegen --rust-input=crates/native/src/api.rs \
		--dart-output=lib/src/api/bridge.g.dart \
		--skip-add-mod-to-lib \
		--no-build-runner \
		--dart-format-line-length=80
	flutter pub run build_runner build --delete-conflicting-outputs


# Lint Rust sources with Clippy.
#
# Usage:
#	make cargo.lint [dockerized=(no|yes)]

cargo.lint:
ifeq ($(dockerized),yes)
	docker run --rm --network=host -v "$(PWD)":/app -w /app \
		-u $(shell id -u):$(shell id -g) \
		-v "$(HOME)/.cargo/registry":/usr/local/cargo/registry \
		ghcr.io/instrumentisto/rust:$(RUST_VER) \
			make cargo.lint dockerized=no
else
	cargo clippy --workspace -- -D warnings
endif


# Run Rust tests of project.
#
# Usage:
#	make cargo.test

cargo.test:
	cargo test --workspace




##################
# Kotin commands #
##################

# Format Kotlin sources with ktfmt.
#
# Usage:
#	make kt.fmt [check=(no|yes)]

kt-fmt-bin = .cache/ktfmt-$(KTFMT_VER).jar

kt.fmt:
ifeq ($(wildcard $(kt-fmt-bin)),)
	@mkdir -p $(dir $(kt-fmt-bin))
	curl -fL -o $(kt-fmt-bin) \
	     https://search.maven.org/remotecontent?filepath=com/facebook/ktfmt/$(KTFMT_VER)/ktfmt-$(KTFMT_VER)-jar-with-dependencies.jar
endif
	java -jar $(kt-fmt-bin) \
	     $(if $(call eq,$(check),yes),--set-exit-if-changed,) \
		android/src/main/kotlin/




##################
# Swift commands #
##################

# Format Swift sources with swift-format.
#
# Usage:
#   make swift.fmt

swift-fmt-bin = .cache/swift-format/.build/release/swift-format
ifeq ($(SWIFT_VER),5.7)
	swift-fmt-branch = release/5.7
else
ifeq ($(SWIFT_VER),5.6)
	swift-fmt-branch = release/5.6
else
	swift-fmt-branch = swift-$(SWIFT_VER)-branch
endif
endif

swift.fmt:
ifeq ($(wildcard $(swift-fmt-bin)),)
	@mkdir -p .cache/
	git clone https://github.com/apple/swift-format.git .cache/swift-format/
	cd .cache/swift-format/ && \
	git checkout $(swift-fmt-branch) && \
	swift build -c release
endif
	$(swift-fmt-bin) -r -p -i ios/Classes




##########################
# Documentation commands #
##########################

docs.rust: cargo.doc




####################
# Testing commands #
####################

test.cargo: cargo.test

test.flutter: flutter.test




##################
# .PHONY section #
##################

.PHONY: build clean codegen deps docs fmt lint run test \
        cargo.clean cargo.build cargo.doc cargo.fmt cargo.gen cargo.lint \
        	cargo.test \
        docs.rust \
        flutter.analyze flutter.clean flutter.build flutter.fmt flutter.pub \
        	flutter.run flutter.test \
        kt.fmt \
        swift.fmt \
        test.cargo test.flutter
