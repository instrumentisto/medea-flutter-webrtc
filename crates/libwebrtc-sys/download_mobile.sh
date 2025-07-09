#!/bin/bash

# Skip if release is used.
if [[ "$WEBRTC_BRANCH" != "" ]] ; then
  # GH_TOKEN can be set from `secrets.GITHUB_TOKEN` in GitHub Actions.
  if [[ "$GH_TOKEN" == "" ]] ; then
    echo "libwebrtc branch was selected but GH_TOKEN wasn't set."
    exit 1
  fi

  # First argument must be {{ matrix.platform }}
  PLATFORM=$1

  if [[ "$PLATFORM" == "" ]] ; then
    echo "{{ matrix.platform }} is not passed as first argument to this script."
    exit 1
  fi

  ARTIFACTS_URL=$(
    curl -A instrumentisto \
         -H "Authorization: Bearer $GH_TOKEN" \
         -s "https://api.github.com/repos/instrumentisto/libwebrtc-bin/actions/runs?branch=$WEBRTC_BRANCH&status=success&per_page=1" |
    jq -r '.workflow_runs.[0].artifacts_url'
  )

  if [[ "$ARTIFACTS_URL" == "null" ]] ; then
    echo "Workflow run wasn't found for libwebrtc-bin branch: '$WEBRTC_BRANCH'"
    exit 1
  fi

  DOWNLOAD_URL=$(
    curl -A instrumentisto \
         -H "Authorization: Bearer $GH_TOKEN" \
         -s "$ARTIFACTS_URL?name=build-$PLATFORM&per_page=1" |
    jq -r '.artifacts.[0].archive_download_url'
  )

  if [[ "$DOWNLOAD_URL" == "null" ]] ; then
    echo "Artifact wasn't found for libwebrtc-bin branch: '$WEBRTC_BRANCH'"
    exit 1
  fi

  mkdir -p ./temp

  curl -A instrumentisto \
       -H "Authorization: Bearer $GH_TOKEN" \
       -Lo ./temp/libwebrtc-bin.zip "$DOWNLOAD_URL"

  unzip ./temp/libwebrtc-bin.zip -d ./temp/libwebrtc-bin

  if [[ "$PLATFORM" == "android" ]] ; then
    IMPLEMENTATION="libwebrtc-bin-$WEBRTC_BRANCH"

    mkdir -p "./temp/$IMPLEMENTATION"
    tar -C "./temp/$IMPLEMENTATION" -xzf ./temp/libwebrtc-bin/libwebrtc-android.tar.gz aar/libwebrtc.aar

    mkdir -p ./example/android/app/libs
    cp "./temp/$IMPLEMENTATION/aar/libwebrtc.aar" "./example/android/app/libs/$IMPLEMENTATION.aar"

    mkdir -p ./android/libs
    cp "./temp/$IMPLEMENTATION/aar/libwebrtc.aar" "./android/libs/$IMPLEMENTATION.aar"
  elif [[ "$PLATFORM" == "ios" ]] ; then
    unzip ./temp/libwebrtc-bin/libwebrtc-ios.zip -d ./temp/libwebrtc-bin
    cp -r ./temp/libwebrtc-bin/WebRTC.xcframework ./ios

    cd ./example/ios || exit
    flutter pub get
    pod update
  fi

  rm -rf ./temp

  echo "Done"
fi
