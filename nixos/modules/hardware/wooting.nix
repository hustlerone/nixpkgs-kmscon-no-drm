{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.hardware.wooting;
in
{
  options.hardware.wooting = {
    enable = lib.mkEnableOption "support for Wooting keyboards";

    backgroundService = {
      enable = lib.mkEnableOption ''
        the Wooting background service. It keeps a link to the keyboard open
        while Wootility is closed, which is what app linking (per-application
        profile switching) and the light indicators (volume, battery, system
        info, Discord) rely on
      '';

      package = lib.mkPackageOption pkgs "wooting-bg-service" { };
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [
      pkgs.wootility
    ]
    ++ lib.optional cfg.backgroundService.enable cfg.backgroundService.package;
    services.udev.packages = lib.optional pkgs.stdenv.isLinux pkgs.wooting-udev-rules;

    # Tauri application with a tray icon and a webview, so it needs a graphical
    # session and cannot be a system service.
    systemd.user.services.wooting-bg-service = lib.mkIf cfg.backgroundService.enable {
      description = "Wooting background service";
      wantedBy = [ "graphical-session.target" ];
      partOf = [ "graphical-session.target" ];

      unitConfig = {
        After = "graphical-session.target";
        ConditionEnvironment = [
          "|WAYLAND_DISPLAY"
          "|DISPLAY"
        ];
      };

      serviceConfig = {
        Type = "simple";
        ExecStart = lib.getExe cfg.backgroundService.package;
        Restart = "on-failure";
        RestartSec = 3;
      };
    };
  };
}
