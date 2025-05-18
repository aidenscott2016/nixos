let
  diskName = "/dev/disk/by-id/ata-LITEON_CV8-8E512-11_SATA_512GB_TW04WFGMLOH0083F00Z5";
in
{
  disko.devices = {
    disk = {
      disk1 = {
        type = "disk";
        device = diskName;
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              size = "1G";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = [ "umask=0077" ];
              };
            };
            crypt_p1 = {
              size = "100%";
              content = {
                type = "luks";
                name = "crypt"; # device-mapper name when decrypted
                # if you want to use the key for interactive login be sure there is no trailing newline
                # for example use `echo -n "password" > /tmp/secret.key`
                settings = {
                  allowDiscards = true;
                };
                content = {
                  type = "btrfs";
                  extraArgs = [
                    "-d single"
                    "-f"
                  ];
                  subvolumes = {
                    "/root" = {
                      mountpoint = "/";
                      mountOptions = [
                        "compress=zstd"
                        "relatime"
                        "ssd"
                      ];
                    };
                    "/nix" = {
                      mountpoint = "/nix";
                      mountOptions = [
                        "compress=zstd"
                        "relatime"
                        "ssd"
                      ];
                    };
                    "/home" = {
                      mountpoint = "/home";
                      mountOptions = [
                        "compress=zstd"
                        "relatime"
                        "ssd"
                      ];
                    };
                    "/swap" = {
                      mountpoint = "/.swapvol";
                      swap.swapfile.size = "16G";
                    };
                  };
                };
              };
            };
          };
        };
      };
    };
  };
}
