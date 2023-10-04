{
  disko.devices = {
    disk = {
      evo-870 = {
        device = "/dev/disk/by-id/ata-Samsung_SSD_870_EVO_1TB_S626NF0R239518D";
        type = "disk";
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              type = "EF00";
              size = "500M";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
              };
            };
            root = {
              size = "100G";
              content = {
                type = "filesystem";
                format = "ext4";
                mountpoint = "/";
              };
            };
            swap = {
              size = "2G";
              content = { type = "swap"; };
            };
            #   home = {
            #     size = "100%";
            #     content = {
            #       type = "filesystem";
            #       format = "ext4";
            #       mountpoint = "/home";
            #     };
            #   };
          };
        };
      };
    };
  };
}
