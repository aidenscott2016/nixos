{
  disko.devices = {
    disk = {
      # Devices will be mounted and formatted in alphabetical order, and btrfs can only mount raids
      # when all devices are present. So we define an "empty" luks device on the first disk,
      # and the actual btrfs raid on the second disk, and the name of these entries matters!
      disk1 = {
        type = "disk";
        device = "/dev/nvme0n1";
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              size = "512M";
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
                name = "p1"; # device-mapper name when decrypted
                # if you want to use the key for interactive login be sure there is no trailing newline
                # for example use `echo -n "password" > /tmp/secret.key`
                passwordFile = "/tmp/secret.key"; # Same key for both devices
                settings = { allowDiscards = true; };
              };
            };
          };
        };
      };
      disk2 = {
        type = "disk";
        device = "/dev/nvme1n1";
        content = {
          type = "gpt";
          partitions = {
            crypt_p2 = {
              size = "100%";
              content = {
                type = "luks";
                name = "p2";
                passwordFile = "/tmp/secret.key"; # Same key for both devices
                settings = { allowDiscards = true; };
                content = {
                  type = "btrfs";
                  extraArgs = [
                    "-d single"
                    "/dev/mapper/p1" # Use decrypted mapped device, same name as defined in disk1
                  ];
                  subvolumes = {
                    "/root" = {
                      mountpoint = "/";
                      mountOptions = [ "rw" "relatime" "ssd" ];
                    };
                    "/home" = {
                      mountpoint = "/home";
                      mountOptions = [ "rw" "relatime" "ssd" ];
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
