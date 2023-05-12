{ rustPlatform
, toolchain
, fetchFromGitHub
, lib
, ...
}:

rustPlatform.buildRustPackage rec {
  pname = "xwin";
  version = "0.2.10";

  nativeBuildInputs = [ toolchain ];

  src = fetchFromGitHub {
    owner = "Jake-Shadle";
    repo = "xwin";
    rev = "0.2.10";
    sha256 = "sha256-5EpXEzEvVRec/DUqHVlnFpuP0DlLt1TdHd5op33sT4E=";
  };

  doCheck = false; # tests require network access

  cargoSha256 = "sha256-rfL+2iwh3wgnCPETQ8lyMyeVnEw24YhKSPeqTHi96eU=";

  meta = with lib; {
    description = "A utility for downloading and packaging the Microsoft CRT headers and libraries, and Windows SDK headers and libraries needed for compiling and linking programs targeting Windows.";
    homepage = "https://github.com/Jake-Shadle/xwin";
    license = licenses.mit;
    maintainers = [ ];
  };
}
