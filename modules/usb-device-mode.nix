{
  config,
  lib,
  ...
}: let
  cfg = config.jetson.usbDeviceMode;
in {
  options.jetson.usbDeviceMode = {
    enable = lib.mkEnableOption "USB device mode over the Type-C port (ACM console + NCM ethernet)";

    address = lib.mkOption {
      type = lib.types.str;
      default = "192.168.55.1";
      description = "Address of the gadget end of the link. Matches the L4T default.";
    };

    interface = lib.mkOption {
      type = lib.types.str;
      default = "usb0";
      description = "Interface name the NCM function registers.";
    };
  };

  config = lib.mkIf cfg.enable {
    # tegra-xudc drives the Type-C port as a peripheral; both are modules in
    # tegra_defconfig, unlike the host-side xhci stack which is built in
    boot.kernelModules = ["tegra-xudc" "libcomposite"];

    systemd.services.usb-gadget = {
      description = "USB device mode gadget";
      wantedBy = ["multi-user.target"];
      requires = ["sys-kernel-config.mount"];
      after = ["sys-kernel-config.mount"];

      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
      };

      script = ''
        g=/sys/kernel/config/usb_gadget/nixos
        mkdir -p "$g"

        # NVIDIA's vendor id keeps the host-side udev rules and drivers that
        # people already have for L4T applying unchanged
        echo 0x0955 >"$g/idVendor"
        echo 0x7020 >"$g/idProduct"

        mkdir -p "$g/strings/0x409"
        echo NVIDIA >"$g/strings/0x409/manufacturer"
        echo "${config.networking.hostName}" >"$g/strings/0x409/product"
        echo "$(cat /etc/machine-id 2>/dev/null || echo 0000000000000000)" >"$g/strings/0x409/serialnumber"

        mkdir -p "$g/functions/acm.usb0"
        mkdir -p "$g/functions/ncm.usb0"
        echo "${cfg.interface}" >"$g/functions/ncm.usb0/ifname" || true

        mkdir -p "$g/configs/c.1/strings/0x409"
        echo "ACM + NCM" >"$g/configs/c.1/strings/0x409/configuration"
        ln -sf "$g/functions/acm.usb0" "$g/configs/c.1/"
        ln -sf "$g/functions/ncm.usb0" "$g/configs/c.1/"

        # binding to a UDC is what makes the port enumerate on the host
        udc=$(ls /sys/class/udc | head -1)
        test -n "$udc"
        echo "$udc" >"$g/UDC"
      '';

      preStop = ''
        g=/sys/kernel/config/usb_gadget/nixos
        echo "" >"$g/UDC" || true
        rm -f "$g/configs/c.1/acm.usb0" "$g/configs/c.1/ncm.usb0"
        rmdir "$g/configs/c.1/strings/0x409" "$g/configs/c.1" \
              "$g/functions/acm.usb0" "$g/functions/ncm.usb0" \
              "$g/strings/0x409" "$g" || true
      '';
    };

    # the acm function exposes ttyGS0 here and /dev/ttyACM0 on the host
    systemd.services."serial-getty@ttyGS0" = {
      enable = true;
      wantedBy = ["multi-user.target"];
      serviceConfig.Restart = "always";
    };

    networking = {
      networkmanager.unmanaged = ["interface-name:${cfg.interface}"];

      interfaces.${cfg.interface}.ipv4.addresses = [
        {
          address = cfg.address;
          prefixLength = 24;
        }
      ];

      firewall.interfaces.${cfg.interface} = {
        allowedTCPPorts = [22 53];
        allowedUDPPorts = [53 67];
      };
    };

    # the host end is a plain dhcp client, so nothing has to be configured there
    services.dnsmasq = {
      enable = true;
      settings = {
        interface = cfg.interface;
        # the gadget interface does not exist when dnsmasq starts
        bind-dynamic = true;
        dhcp-range = "192.168.55.100,192.168.55.200,12h";
      };
    };
  };
}
