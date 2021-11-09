# Checks two given strings for equality.

comma := ,

# Checks two given strings for equality.
eq = $(if $(or $(1),$(2)),$(and $(findstring $(1),$(2)),\
                                $(findstring $(2),$(1))),1)




######################
# Project parameters #
######################

LIBWEBRTC_PATH = https://github.com/logist322/libwebrtc-bin/releases/download/
LIBWEBRTC_VER = nadlast

RUST_VER = 1.55
RUST_NIGHTLY_VER = 'nightly-2021-09-08'




###########
# Aliases #
###########

deps: lib.download cargo flutter
build: 
	lib.build release=$(if $(call eq,$(release),yes),yes,)
	flutter.build release=$(if $(call eq,$(release),yes),yes,)

run: flutter.run




####################
# Running commands #
####################

# Build libwebrtc and deliver all necessity files to flutter windows directory.
#
# Usage:
#	make lib.build [release=(no|yes)]
lib.build:
	make cargo.build $(if $(call eq,$(release),yes),dev=no,) && \
	cp libwebrtc/target/$(if $(call eq,$(release),yes),release,debug)/jason_flutter_webrtc.dll windows/rust/lib/jason_flutter_webrtc.dll && \
	cp libwebrtc/target/$(if $(call eq,$(release),yes),release,debug)/jason_flutter_webrtc.dll.lib windows/rust/lib/jason_flutter_webrtc.dll.lib 


# Downloead libwebrtc source and deliver all necessity files to libwebrtc-sys.
#
# Usage:
#	make lib.download
lib.download:
	rm -rf lib_zip && \
	rm -rf libwebrtc-sys/include && \
	rm -rf libwebrtc-sys/webrtc && \
	mkdir lib_zip && \
	cd lib_zip && \
	curl -L -O --silent $(LIBWEBRTC_PATH)$(LIBWEBRTC_VER)/libwebrtc-win-x64.tar && \
	tar -x -f libwebrtc-win-x64.tar && \
	echo "Copying headers..." && \
	cp -R include ../libwebrtc-sys && \
	mkdir ../libwebrtc-sys/webrtc && \
	echo "Copying libwebrtc..." && \
	cp release/webrtc.lib ../libwebrtc-sys/webrtc/ && \
	cd ../ && \
	rm -rf lib_zip




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
	flutter $(if $(call eq,$(cmd),pub),pub get,$(cmd))




##################
# Cargo commands #
##################

# Resolve Cargo project dependencies.
#
# Usage:
#	make cargo [cmd=(fetch|<cargo-cmd>)] [dockerized=(no|yes)]

cargo:
ifeq ($(dockerized),yes)
	MSYS_NO_PATHCONV=1 docker run --rm --network=host -v "$(PWD)":/app -w /app \
		-u $(shell id -u):$(shell id -g) \
		-v "$(HOME)/.cargo/registry":/usr/local/cargo/registry \
		ghcr.io/instrumentisto/rust:$(RUST_VER) \
			make cargo cmd='$(cmd)' dockerized=no
else
	cargo $(or $(cmd),fetch) --manifest-path libwebrtc/Cargo.toml
endif


# Build libwebrtc.
#
# Usage:
#	make cargo.build [debug=(no|yes)]

cargo.build:
	cargo build $(if $(call eq,$(debug),no),--release,) --manifest-path libwebrtc/Cargo.toml


# Test libwebrtc-sys.
#
# Usage:
#	make cargo.test

cargo.test:
	cargo test --manifest-path libwebrtc-sys/Cargo.toml --test integration_test


# Create documentation for libwebrtc.
#
# Usage:
#	make cargo.doc

cargo.doc:
	cargo doc --manifest-path libwebrtc-sys/Cargo.toml


# Format Rust sources with rustfmt.
#
# Usage:
#	make cargo.fmt [check=(no|yes)] [dockerized=(no|yes)]

cargo.fmt:
ifeq ($(dockerized),yes)
	MSYS_NO_PATHCONV=1 docker run --rm --network=host -v "$(PWD)":/app -w /app \
		-u $(shell id -u):$(shell id -g) \
		-v "$(HOME)/.cargo/registry":/usr/local/cargo/registry \
		ghcr.io/instrumentisto/rust:$(RUST_NIGHTLY_VER) \
			make cargo.fmt check=$(check) dockerized=no
else
	cargo fmt --manifest-path libwebrtc/Cargo.toml --all $(if $(call eq,$(check),yes),-- --check,)
endif


# Lint Rust sources with Clippy.
#
# Usage:
#	make cargo.lint [dockerized=(no|yes)]

cargo.lint:
ifeq ($(dockerized),yes)
	MSYS_NO_PATHCONV=1  docker run --rm --network=host -v "$(PWD)":/app -w /app \
		-u $(shell id -u):$(shell id -g) \
		-v "$(HOME)/.cargo/registry":/usr/local/cargo/registry \
		ghcr.io/instrumentisto/rust:$(RUST_VER) \
			make cargo.lint dockerized=no
else
	cargo clippy --manifest-path libwebrtc/Cargo.toml --workspace -- -D clippy::pedantic -D warnings
endif


# Show version of project's Cargo crate.
#
# Usage:
#	make cargo.version [crate=(medea|<crate-name>)]

cargo.version:
	@printf "$(crate-ver)"


