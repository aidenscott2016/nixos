{
  lib,
  pkgs,
  config,
  ...
}:
{
  # mounts the desktop windows computer
  # For mount.cifs, required unless domain name resolution is not needed.
  # environment.systemPackages = [ pkgs.cifs-utils ];
  # fileSystems."/mnt/share" = {
  #   device = "//10.0.4.40/Downloads";
  #   fsType = "cifs";
  #   options =
  #     let
  #       # this line prevents hanging on network split
  #       automount_opts = "x-systemd.automount,noauto,x-systemd.idle-timeout=60,x-systemd.device-timeout=5s,x-systemd.mount-timeout=5s";
  #       auth = "username=aiden,password=a";
  #     in
  #     [ "${automount_opts},${auth} " ];
  # };

  # make shares visible for windows 10 clients
  services.samba-wsdd.enable = true;

  #https://gist.github.com/vy-let/a030c1079f09ecae4135aebf1e121ea6
  services.samba = {
    openFirewall = true;
    enable = true;

    # You will still need to set up the user accounts to begin with:
    # $ sudo smbpasswd -a yourusername

    # This adds to the [global] section:
    extraConfig = ''
      browseable = yes
      smb encrypt = required
    '';

    shares = {
      homes = {
        browseable = "no"; # note: each home will be browseable; the "homes" share will not.
        "read only" = "no";
        "guest ok" = "no";
      };
    };
  };

  networking.firewall.allowedTCPPorts = [
    445
    139
  ];
  networking.firewall.allowedUDPPorts = [
    137
    138
  ];

  # mDNS
  #
  # This part may be optional for your needs, but I find it makes browsing in Dolphin easier,
  # and it makes connecting from a local Mac possible.
  services.avahi = {
    enable = true;
    nssmdns = true;
    publish = {
      enable = true;
      addresses = true;
      domain = true;
      hinfo = true;
      userServices = true;
      workstation = true;
    };
    extraServiceFiles = {
      smb = ''
        <?xml version="1.0" standalone='no'?><!--*-nxml-*-->
        <!DOCTYPE service-group SYSTEM "avahi-service.dtd">
        <service-group>
          <name replace-wildcards="yes">%h</name>
          <service>
            <type>_smb._tcp</type>
            <port>445</port>
          </service>
        </service-group>
      '';
    };
  };
}
