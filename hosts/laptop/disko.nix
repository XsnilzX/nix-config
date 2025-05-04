{ config, lib, ... }:

{
  disko.devices.disk.main = {
    device = "/dev/nvme0n1";
    type = "disk";
    content = {
      type = "gpt";
      partitions = {
        esp = {
          type = "EF00";
          size = "1G";
          content = {
            type = "filesystem";
            format = "vfat";
            mountpoint = "/boot";
            extraArgs = [ "-F32" ];
          };
        };

        luks-root = {
          size = "914.5G";
          content = {
            type = "luks";
            name = "cryptroot";
            content = {
              type = "btrfs";
              subvolumes = {
                "@".mountpoint = "/";
                "@home".mountpoint = "/home";
                "@nix".mountpoint = "/nix";
                "@log".mountpoint = "/var/log";
              };
            };
          };
        };

        luks-swap = {
          size = "remaining";  # nimmt den Rest der Disk
          content = {
            type = "luks";
            name = "cryptswap";
            content = {
              type = "swap";
              randomEncryption = false;
            };
          };
        };
      };
    };
  };
}
