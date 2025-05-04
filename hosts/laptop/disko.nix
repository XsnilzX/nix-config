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
          size = "915G";
          content = {
            type = "luks";
            name = "cryptroot";
            content = {
              type = "btrfs";
              subvolumes = {
                "@".mountpoint = "/";
                "@".mountOptions = [ "compress=zstd:5" "noatime" "ssd" "discard=async" "space_cache=v2 " ];

                "@home".mountpoint = "/home";
                "@home".mountOptions = [  "compress=zstd:5" "noatime" "ssd" "discard=async" "space_cache=v2 " ];

                "@nix".mountpoint = "/nix";
                "@nix".mountOptions = [  "compress=zstd:5" "noatime" "ssd" "discard=async" "space_cache=v2 " ];

                "@log".mountpoint = "/var/log";
                "@log".mountOptions = [  "compress=zstd:5" "noatime" "ssd" "discard=async" "space_cache=v2 " ];
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
