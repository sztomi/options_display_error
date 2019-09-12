#! /usr/bin/bash
set -ex

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

pkgs=(ffmpeg fontconfig harfbuzz zlib)

export CONAN_USER_HOME=$DIR/conan_cache
export CONAN_USERNAME=_
export CONAN_CHANNEL=_

rm -rf $CONAN_USER_HOME

conan config set general.revisions_enabled=1
conan config set general.default_package_id_mode=recipe_revision_mode

for pkg in "${pkgs[@]}"; do
  pushd $pkg
  conan export .
  popd
done

pushd variant
conan export .
conan graph lock .
popd

for pkg in "${pkgs[@]}"; do
  pushd $pkg
  conan create --build missing -tf=None -ne --lockfile ../variant/conan.lock .
  popd
done
