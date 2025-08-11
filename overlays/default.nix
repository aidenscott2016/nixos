# Snowfall Lib provides access to additional information via a primary argument of
# your overlay.
{
  # Channels are named after NixPkgs instances in your flake inputs. For example,
  # with the input `nixpkgs` there will be a channel available at `channels.nixpkgs`.
  # These channels are system-specific instances of NixPkgs that can be used to quickly
  # pull packages into your overlay.
  channels, # The namespace used for your Flake, defaulting to "internal" if not set.
  # Inputs from your flake.
  inputs,
  ...
}:

final: prev: {
  # For example, to pull a package from unstable NixPkgs make sure you have the
  # input `unstable = "github:nixos/nixpkgs/nixos-unstable"` in your flake.
  inherit (channels.nixpkgs-unstable) bazarr;
  intel-media-driver-stable = channels.nixpkgs-stable.intel-media-driver; # For Broadwell (2014) or newer processors. LIBVA_DRIVER_NAME=iHD;
  inherit (channels.nixpkgs-stable)
    libva-vdpau-driver # Previously vaapiVdpau
    # # OpenCL support for intel CPUs before 12th gen
    # # see: https://github.com/NixOS/nixpkgs/issues/356535
    intel-compute-runtime-legacy1
    vpl-gpu-rt # QSV okn 11th gen or newer
    intel-ocl # OpenCL support
    onevpl-intel-gpu
    ;
}
