with import <nixpkgs> {};

let
  stdenv8 = overrideCC stdenv gcc8;
in
  stdenv8.mkDerivation rec {
    name = "raytracer-zig";
    env = buildEnv {
      name = name;
      paths = buildInputs;
    };
    buildInputs = [
      pkgconfig
      zig
      SDL2
    ];
  }
