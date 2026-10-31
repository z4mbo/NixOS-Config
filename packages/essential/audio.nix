{ ... }:

{
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;

    # Short, clear names in Noctalia's output picker; hide the unused S/PDIF.
    wireplumber.extraConfig."50-output-names" = {
      "monitor.alsa.rules" = [
        {
          matches = [ { "node.name" = "~alsa_output.usb-Generic_USB_Audio-00.HiFi__Headphones__sink"; } ];
          actions.update-props."node.description" = "Headphones";
        }
        {
          matches = [ { "node.name" = "~alsa_output.usb-Generic_USB_Audio-00.HiFi__Speaker__sink"; } ];
          actions.update-props."node.description" = "Speakers";
        }
        {
          matches = [ { "node.name" = "~alsa_output.usb-Generic_USB_Audio-00.HiFi__SPDIF__sink"; } ];
          actions.update-props."node.disabled" = true;
        }
        {
          matches = [ { "node.name" = "~alsa_output.pci-.*hdmi.*"; } ];
          actions.update-props."node.description" = "Monitor (HP)";
        }
      ];
      "monitor.bluez.rules" = [
        {
          matches = [ { "device.name" = "~bluez_card.64_CD_C2_25_2A_70"; } ];
          actions.update-props."device.description" = "Echo Spot";
        }
        {
          matches = [ { "node.name" = "~bluez_output.64_CD_C2_25_2A_70.*"; } ];
          actions.update-props."node.description" = "Echo Spot";
        }
      ];
    };
  };

  security.rtkit.enable = true;
}
