{ lib
, stdenv
, fetchgit
, callPackage
, makeWrapper
, perl
, pve-container ? callPackage ./container.nix { }
, pve-firewall ? callPackage ./firewall.nix { }
, pve-guest-common ? callPackage ./guest-common.nix { }
, pve-qemu-server
, pve-storage
, pve-qemu
}:

let
  perlDeps = [
    pve-container
    pve-firewall
    pve-guest-common
    pve-qemu-server
    pve-storage
  ];
  perlEnv = perl.withPackages (_: perlDeps);
in

perl.pkgs.toPerlModule (stdenv.mkDerivation rec {
  pname = "pve-ha-manager";
  version = "4.0.5";

  src = fetchgit {
    url = "https://git.proxmox.com/git/${pname}.git";
    rev = "800a0c3e485f175d914fb7b59dfcd0cd375998de";
    hash = "sha256-zY0tB4Uby3uFlPHNy75weYioSln/Bt4wzf+u7ba4nSE=";
  };

  sourceRoot = "source/src";

  postPatch = ''
    sed -i Makefile \
      -e "s/ha-manager.1 pve-ha-crm.8 pve-ha-lrm.8 ha-manager.bash-completion pve-ha-lrm.bash-completion //" \
      -e "s/pve-ha-crm.bash-completion ha-manager.zsh-completion pve-ha-lrm.zsh-completion pve-ha-crm.zsh-completion //" \
      -e "/install -m 0644 -D pve-ha-crm.bash-completion/,+5d" \
      -e "/install -m 0644 pve-ha-crm.8/,+6d" \
      -e "s/Werror/Wno-error/" \
      -e "/PVE_GENERATING_DOCS/d" \
      -e "/shell /d"
  '';

  makeFlags = [
    "DESTDIR=$(out)"
    "PREFIX="
    "SBINDIR=/bin"
    "PERLDIR=/${perl.libPrefix}/${perl.version}"
  ];

  buildInputs = [ perlEnv makeWrapper ];
  propagatedBuildInputs = perlDeps;

  postInstall = ''
    cp ${pve-container}/.bin/pct $out/bin
    cp ${pve-qemu-server}/.bin/* $out/bin
    rm $out/bin/pve-ha-simulator
  '';

  postFixup = ''
    for bin in $out/bin/*; do
      wrapProgram $bin \
        --prefix PATH : ${lib.makeBinPath [ pve-qemu ]} \
        --prefix PERL5LIB : $out/${perl.libPrefix}/${perl.version}
    done      
  '';

  meta = with lib; {
    description = "Proxmox VE High Availabillity Manager - read-only source mirror";
    homepage = "https://github.com/proxmox/pve-ha-manager";
    license = with licenses; [ ];
    maintainers = with maintainers; [ camillemndn julienmalka ];
    platforms = platforms.linux;
  };
})
