{

  name = "proxmox-ve";

  nodes.mypve = {
    services.proxmox-ve = {
      enable = true;
      localIP = "192.168.1.1";
    };
  };

  testScript = ''
    machine.start()
    assert "started" in machine.succeed("pveproxy status")
  '';
}
