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




###########
# Aliases #
###########

deps: lib.download flutter.create.windows flutter.deps
build: rust.build flutter.build
run: flutter.run




####################
# Running commands #
####################

# mylibwebrtc?
# add doc for each method
# debug or release
rust.build:
	cd libwebrtc && \
 	cargo build && \
	cp target/debug/jason_flutter_webrtc.dll ../windows/rust/lib/jason_flutter_webrtc.dll && \
	cp target/debug/jason_flutter_webrtc.dll.lib ../windows/rust/lib/jason_flutter_webrtc.dll.lib 

# use tar instead of 7z
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


