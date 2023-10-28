#!/bin/bash

SCHEME='AppContainer'
REPO_NAME='AppContainer'

build_clean() {
  destination="$1"

  xcodebuild clean \
    -destination "generic/platform=$destination" \
    -scheme "$SCHEME"
}

generate_symbol_graphs() {
  destination=$1
  scheme=$2

  mkdir -p .build/symbol-graphs
  mkdir -p symbol-graphs

  xcodebuild clean build -scheme "${scheme}"\
    -destination "generic/platform=${destination}" \
    OTHER_SWIFT_FLAGS="-emit-extension-block-symbols -emit-symbol-graph -emit-symbol-graph-dir $(pwd)/.build/symbol-graphs"

  mv "./.build/symbol-graphs/$scheme.symbols.json" "./symbol-graphs/${scheme}_${destination}.symbols.json"
}

generate_docc() {
  destination="$1"

  mkdir -p docs

  # xcodebuild docbuild \
  #   -scheme "$SCHEME" \
  #   -destination "generic/platform=$destination" \
  #   OTHER_DOCC_FLAGS="--transform-for-static-hosting -additional-symbol-graph-dir symbol-graphs --hosting-base-path ${REPO_NAME} --output-path docs" \
  #   OTHER_SWIFT_FLAGS="-emit-extension-block-symbols"
  # OTHER_SWIFT_FLAGS -symbol-graph-minimum-access-level private

  $(xcrun --find docc) convert \
    "Sources/${SCHEME}/${SCHEME}.docc" \
     --output-path "docs" \
     --hosting-base-path "${REPO_NAME}" \
     --additional-symbol-graph-dir ./symbol-graphs
}

build_clean ios
generate_symbol_graphs ios AppContainer
generate_symbol_graphs ios AppContainerUI
generate_docc ios
