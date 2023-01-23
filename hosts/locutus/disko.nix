# nix build  .#nixosConfigurations.locutus.config.system.build.disko
# nix build  .#nixosConfigurations.locutus.config.system.build.mountScript
# nix build  .#nixosConfigurations.locutus.config.system.build.createScript
# sudo cryptsetup open /dev/nvme0n1p2
# sudo ./result


inputs@{ ... }: {
  disko = {
    enableConfig = false;
    devices = {
      disk = {
        vdb = {
          type = "disk";
          device = "/dev/nvme0n1";
          content = {
            type = "table";
            format = "gpt";
            partitions = [
              {
                type = "partition";
                name = "ESP";
                start = "1MiB";
                end = "100MiB";
                bootable = true;
                content = {
                  type = "filesystem";
                  format = "vfat";
                  mountpoint = "/boot";
                  mountOptions = [
                    "defaults"
                  ];
                };
              }
              {
                type = "partition";
                name = "luks";
                start = "100MiB";
                end = "100%";
                content = {
                  type = "luks";
                  name = "crypted";
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
      lvm_vg = {
        pool = {
          type = "lvm_vg";
          lvs = {
            swap = {
              type = "lvm_lv";
              size = "8G";
              content = {
                type = "swap";
                randomEncryption = true;
              };
            };
            root = {
              type = "lvm_lv";
              size = "50G";
              content = {
                type = "filesystem";
                format = "ext4";
                mountpoint = "/";
                mountOptions = [
                  "defaults"
                ];
              };
            };
            # Disko seem to create pvs in alphabetical order. For +100%free to work, home must be the last thing created
            zhome = {
              type = "lvm_lv";
              size = "+100%FREE";
              content = {
                type = "filesystem";
                format = "ext4";
                mountpoint = "/home";
              };
            };

          };
        };
      };
    };
  };
}
