run:
	cd libwebrtc && cargo build

download:
	mkdir lib_zip && \
	cd lib_zip && \
	curl -L -O https://github.com/crow-misia/libwebrtc-bin/releases/download/96.4664.1.0/libwebrtc-win-x64.7z && \
	7z x libwebrtc-win-x64.7z && \
	cd ../ && \
	rm -rf lib_zip