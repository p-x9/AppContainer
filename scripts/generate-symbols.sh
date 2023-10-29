#!/bin/bash

SYMBOL_DIR='./symbol-graphs'

clean_build() {
  rm -rf ./.build
}

clean_xcbuild() {
  destination=$1
  scheme=$2

  xcodebuild -scheme "$scheme" \
    -destination "generic/platform=${destination}" \
    clean
}

clean_symbol() {
  rm -rf SYMBOL_DIR
}

generate_symbol_graphs() {
  destination=$1
  scheme=$2

  mkdir -p .build/symbol-graphs
  mkdir -p symbol-graphs

  xcodebuild clean build -scheme "${scheme}"\
    -destination "generic/platform=${destination}" \
    OTHER_SWIFT_FLAGS="-emit-extension-block-symbols -emit-symbol-graph -emit-symbol-graph-dir $(pwd)/.build/symbol-graphs"

  mv "./.build/symbol-graphs/${scheme}.symbols.json" "${SYMBOL_DIR}/${scheme}_${destination}.symbols.json"
}


clean_build
clean_xcbuild ios AppContainer
clean_xcbuild ios AppContainerUI

clean_symbol

generate_symbol_graphs ios AppContainer
generate_symbol_graphs ios AppContainerUI
