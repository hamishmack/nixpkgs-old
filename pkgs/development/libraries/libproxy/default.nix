{ stdenv, lib, fetchFromGitHub, fetchpatch, pkgconfig, cmake
, dbus, networkmanager, spidermonkey_38, pcre, python2, python3, zlib }:

stdenv.mkDerivation rec {
  name = "libproxy-${version}";
  version = "0.4.15";

  src = fetchFromGitHub {
    owner = "libproxy";
    repo = "libproxy";
    rev = version;
    sha256 = "10swd3x576pinx33iwsbd4h15fbh2snmfxzcmab4c56nb08qlbrs";
  };

  patches = lib.optionals stdenv.isDarwin [
    (fetchpatch {
      url = https://raw.githubusercontent.com/macports/macports-ports/master/net/libproxy/files/patch-libproxy-cmake.diff;
      sha256 = "15zhg3jdwvbbfp397mihr8z2cj3hz7w8dc9ypn2i78pjhixnii0w";
      addPrefixes = true;
    })
    (fetchpatch {
      url = https://raw.githubusercontent.com/macports/macports-ports/master/net/libproxy/files/patch-libproxy-test-CMakeLists.txt.diff;
      sha256 = "11wiifii05fi92xlmcbiwaba0p9vcpa2218d2jv0zc5ivrffi4c6";
      addPrefixes = true;
    })
    (fetchpatch {
      url = https://raw.githubusercontent.com/macports/macports-ports/master/net/libproxy/files/patch-bindings-perl-src-CMakeLists.txt.diff;
      sha256 = "1arc2zm27vfwgmjrirwqx0ns63krg8jb9lqm434k3zy56hl04x75";
      addPrefixes = true;
    })
  ];

  outputs = [ "out" "dev" ]; # to deal with propagatedBuildInputs

  nativeBuildInputs = [ pkgconfig cmake ];

  buildInputs = [ dbus pcre python2 python3 ]
   ++ lib.optionals stdenv.isLinux [ networkmanager spidermonkey_38 ]
   ++ lib.optional stdenv.isDarwin zlib;

  preConfigure = ''
    cmakeFlagsArray+=(
      "-DWITH_MOZJS=ON"
      "-DPYTHON2_SITEPKG_DIR=$out/${python2.sitePackages}"
      "-DPYTHON3_SITEPKG_DIR=$out/${python3.sitePackages}"
      ${lib.optionalString stdenv.isDarwin ''
        "-DMP_MACOSX=NO"
        "-DWITH_WEBKIT=NO"
        "-DWITH_WEBKIT3=NO"
      ''}
    )
  '';

  meta = with stdenv.lib; {
    platforms = platforms.unix;
    license = licenses.lgpl21;
    homepage = http://libproxy.github.io/libproxy/;
    description = "A library that provides automatic proxy configuration management";
  };
}
