{
  pkgs,
  lib,
  ...
}: let
  # We just import from the repository for testing here:
  diskoNixos = import ../../. {
    inherit lib;
  };
  disko = import ../../. {
    inherit lib;
    inherit pkgs;
  };
  # In your own system use something like this:
  #import (builtins.fetchGit {
  #  url = "https://github.com/nix-community/disko";
  #  ref = "master";
  #}) {
  #  inherit lib;
  #};
  cfg = {
    disk = {
      sda = {
        device = "/dev/sda";
        type = "device";
        content = {
          type = "table";
          format = "msdos";
          partitions = [
            {
              name = "root";
              type = "partition";
              part-type = "primary";
              start = "1M";
              end = "100%";
              bootable = true;
              content = {
                type = "filesystem";
                format = "ext4";
                mountpoint = "/";
              };
            }
          ];
        };
      };
    };
  };
in {
  imports = [
    (diskoNixos.config cfg)
  ];
  boot.loader.grub.devices = [ "/dev/sda" ];
  system.stateVersion = "22.05";
  environment.systemPackages = with pkgs; [
    (pkgs.writeScriptBin "tsp-create" (disko.create cfg))
    (pkgs.writeScriptBin "tsp-mount" (disko.mount cfg))
  ];
}
