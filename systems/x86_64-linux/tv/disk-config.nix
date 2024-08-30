{
  disko.devices = {
    disk = {
      vdb = {
        device = "/dev/disk/by-id/ata-LITEON_CV8-8E512-11_SATA_512GB_TW04WFGMLOH0083F00Z5";
        type = "disk";
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              type = "EF00";
              size = "1G";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
              };
            };
            root = {
              size = "100%";
              content = {
                type = "filesystem";
                format = "ext4";
                mountpoint = "/";
              };
            };
          };
        };
      };
    };
  };
}
