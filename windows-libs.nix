{ requireFile
, xwin
, stdenvNoCC
}:

# Licence: https://go.microsoft.com/fwlink/?LinkId=2086102
stdenvNoCC.mkDerivation {
  src = requireFile {
    name = "xwin-dl.tar.xz";
    sha256 = "sha256-ipPSsmQnlwrTb4Ca5mvVdz9sJmKicmPqkd3hawyxbRI=";
    url = "https://example.com/Redacted";
    message = ''
      To compile rust packages for windows, you need to download the
      MSVC libraries. You can find them at the following URL:

        [REDACTED]

      Please download the file, then run the following command:

        nix-prefetch-url file://\$PWD/xwin-dl.tar.xz

      By doing so, you agree to the terms of the Microsoft Software
      License Terms for Microsoft Visual C++ Libraries for Windows:

        https://go.microsoft.com/fwlink/?LinkId=2086102
    '';
  };

  name = "windows-libs";
  version = "1.0.0";
  phases = [ "unpackPhase" "installPhase" ];

  buildInputs = [ xwin ];

  unpackPhase = ''
    # Set HOME to the current directory so that xwin can use the cache
    export HOME=$out/
    # Create cache directory
    mkdir -p $out/.xwin-cache
    # Unpack the archive
    tar xf $src -C $out/.xwin-cache
    # Unpack the .msi files using xwin
    xwin --cache-dir $out/.xwin-cache --accept-license unpack 
  '';

  installPhase = ''
    # Ask xwin to splat the files into the right place
    mkdir -p $out/lib/
    xwin --cache-dir $out/.xwin-cache --accept-license splat --output $out/lib/
  '';
}
