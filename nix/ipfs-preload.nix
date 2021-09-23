{ modulesPath, lib, ... }:
let
    pkgs = import <nixos-20.09> { };
in {
    imports = lib.optional (builtins.pathExists ./do-userdata.nix) ./do-userdata.nix ++ [
        (modulesPath + "/virtualisation/digital-ocean-config.nix")
    ];

    environment.systemPackages = [ pkgs.ipfs_0_8 ];

    networking.hostName = "ipfs-preload";
    networking.firewall.allowedTCPPorts = [ 80 4001 4002 ];
    
    # Users
    users.users.ipfs = {
        isNormalUser = true;
    };

    # Services
    systemd.services = {
        ipfs = {
            description = "IPFS Daemon";
            serviceConfig = {
                Type = "simple";
                User = "ipfs";
                ExecStart = "${pkgs.ipfs_0_8}/bin/ipfs daemon";
                ExecStop = "${pkgs.procps}/bin/pkill ipfs";
                Restart = "on-failure";
                RestartSec = "5s";
            };
            wantedBy = [ "multi-user.target" ];
        };
    };

    services.nginx = {
        enable = true;
        virtualHosts.default = {
            default = true;
            locations."/api/v0/refs" = {
                proxyPass = "http://localhost:5001/api/v0/refs";
            };
        };
    };
}