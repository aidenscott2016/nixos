{
  aiden.powermanagement.nixos = {
    services.thermald.enable = true;
    powerManagement.enable = true;
    powerManagement.cpuFreqGovernor = "powersave";
  };
}
