{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
  nix-update-script,
}:

buildNpmPackage rec {
  pname = "markedjs";
  version = "5.1.1";

  src = fetchFromGitHub {
    owner = "markedjs";
    repo = "marked";
    rev = "v${version}";
    hash = "sha256-Yitu6rl6dCebw7Um7rapbCWRtacN87XGoHkcRJ8vnp0=";
  };

  npmDepsHash = "sha256-eWVLHJCRL1dP4sGtSmTwoaWXHz61wxEwNBPJu3fCo30=";

  passthru.updateScript = nix-update-script { };

  meta = with lib; {
    description = "A markdown parser and compiler. Built for speed";
    homepage = "https://github.com/markedjs/marked";
    license = with licenses; [ ];
    maintainers = with maintainers; [
      camillemndn
      julienmalka
    ];
    platforms = platforms.linux;
  };
}
