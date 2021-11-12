# Checks two given strings for equality.

comma := ,

# Checks two given strings for equality.
eq = $(if $(or $(1),$(2)),$(and $(findstring $(1),$(2)),\
                                $(findstring $(2),$(1))),1)




######################
# Project parameters #
######################

LIBWEBRTC_URL = https://github.com/instrumentisto/libwebrtc-bin/releases/download/
LIBWEBRTC_VER = 97.4692.0.0-r0

RUST_VER = 1.55
RUST_NIGHTLY_VER = 'nightly-2021-09-08'




###########
# Aliases #
###########

deps: deps.thirdparty cargo flutter

build: cargo.build

run: flutter.run

fmt: cargo.fmt

lint: cargo.lint

test: cargo.test

doc: cargo.doc




# Downloads compiled libwebrtc with headers to libwebrtc-sys crate.
#
# Usage:
#	make deps.thirdparty
deps.thirdparty:
	mkdir -p temp && \
	curl -L --output-dir temp -O $(LIBWEBRTC_URL)$(LIBWEBRTC_VER)/libwebrtc-win-x64.tar.gz && \
	rm -rf crates/libwebrtc-sys/lib/* || true && \
	tar -xf temp/libwebrtc-win-x64.tar.gz -C crates/libwebrtc-sys/lib
	rm -rf temp




####################
# Flutter commands #
####################

# Build flutter application.
#
# Usage:
#	make flutter.build [release=(no|yes)]

flutter.build:
	cd example && flutter build windows


# Run flutter application.
#
# Usage:
#	make flutter.run

flutter.run:
	cd example && flutter run -d windows


# Install flutter dependencies.
#
# Usage:
#	make flutter [cmd=(pub get|<flutter-cmd>)]

flutter:
	flutter $(or $(cmd),pub get)




##################
# Cargo commands #
##################

# Resolve Cargo project dependencies.
#
# Usage:
#	make cargo [cmd=(fetch|<cargo-cmd>)] [dockerized=(no|yes)]

cargo:
ifeq ($(dockerized),yes)
	docker run --rm --network=host -v "$(PWD)":/app -w /app \
		-u $(shell id -u):$(shell id -g) \
		-v "$(HOME)/.cargo/registry":/usr/local/cargo/registry \
		ghcr.io/instrumentisto/rust:$(RUST_VER) \
			make cargo cmd='$(cmd)' dockerized=no
else
	cargo $(or $(cmd),fetch)
endif


# Build flutter_webrtc_native crate and copies final artifacts to platform-specific directories.
#
# Usage:
#	make cargo.build [debug=(yes|no)]

lib-out-path = target/$(if $(call eq,$(debug),no),release,debug)

cargo.build:
	cargo build -p flutter-webrtc-native $(if $(call eq,$(debug),no),--release,) && \
	cp $(lib-out-path)/flutter_webrtc_native.dll windows/rust/lib/flutter_webrtc_native.dll && \
	cp $(lib-out-path)/flutter_webrtc_native.dll.lib windows/rust/lib/flutter_webrtc_native.dll.lib
	cp crates/native/target/flutter_webrtc_native.hpp windows/rust/include/flutter_webrtc_native.hpp


# Run Rust tests of project.
#
# Usage:
#	make cargo.test

cargo.test:
	cargo test


# Create documentation for libwebrtc.
#
# Usage:
#	make cargo.doc [open=(yes|no)] [clean=(no|yes)]
#	               [dev=(no|yes)]

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


# Lint Rust sources with Clippy.
#
# Usage:
#	make cargo.lint

cargo.lint:
	cargo clippy --workspace -- -D clippy::pedantic -D warnings




##################
# .PHONY section #
##################

.PHONY: build deps doc run test fmt lint \
		cargo \
			cargo.build cargo.doc cargo.fmt cargo.lint cargo.test \
		flutter \
			flutter.build flutter.run \
		deps.thirdparty \

