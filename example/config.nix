# usage: nix-instantiate --eval --json --strict example/config.nix | jq .
{
  lvm_vg = {
    pool = {
      type = "lvm_vg";
      lvs = {
        root = {
          type = "lv";
          size = "10G";
          content = {
            type = "filesystem";
            format = "ext4";
            mountpoint = "/";
          };
        };
        home = {
          type = "lv";
          size = "10G";
          content = {
            type = "filesystem";
            format = "ext4";
            mountpoint = "/home";
          };
        };
      };
    };
  };
  disk = {
    sda = {
      device = "/dev/sda";
      content = {
        type = "table";
        format = "gpt";
        partitions = [
          {
            name = "boot";
            type = "partition";
            part-type = "ESP";
            start = "1MiB";
            end = "1024MiB";
            fs-type = "fat32";
            bootable = true;
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot";
            };
          }
          {
            name = "crypt_root";
            type = "partition";
            part-type = "primary";
            start = "1024MiB";
            end = "100%";
            flags = ["bios_grub"];
            content = {
              type = "luks";
              name = "crypted";
              keyFile = "/tmp/secret.key";
              extraArgs = [
                "--hash sha512"
                "--iter-time 5000"
              ];
              content = {
                type = "lvm_pv";
                vg = "pool";
              };
            };
          }
        ];
      };
    };
  };
}
