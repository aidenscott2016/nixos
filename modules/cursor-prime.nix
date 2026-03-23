{ ... }:
{
  # Cursor's Electron shell disables X11 occlusion detection
  # (CalculateNativeWinOcclusion), causing its compositor to repaint
  # continuously regardless of window visibility. On an Intel+NVIDIA PRIME
  # system this heat lands on the shared CPU/iGPU die. Offloading rendering
  # to the discrete GPU keeps the thermal budget separate from the CPU.
  #
  # Requires hardware.nvidia.prime.offload.enable = true (nvidia module).
  flake.modules.nixos.cursor-prime =
    { pkgs, ... }:
    {
      nixpkgs.overlays = [
        (final: prev: {
          code-cursor = prev.symlinkJoin {
            name = "code-cursor-nvidia";
            paths = [ prev.code-cursor ];
            buildInputs = [ prev.makeWrapper ];
            postBuild = ''
              wrapProgram $out/bin/cursor \
                --set __NV_PRIME_RENDER_OFFLOAD 1 \
                --set __NV_PRIME_RENDER_OFFLOAD_PROVIDER NVIDIA-G0 \
                --set __GLX_VENDOR_LIBRARY_NAME nvidia \
                --set __VK_LAYER_NV_optimus PRIME-V2
            '';
          };
        })
      ];
    };
}
