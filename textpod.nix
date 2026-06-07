{
  config,
  lib,
  pkgs,
  textpod,
  ...
}:
let
  cfg = config.services.textpod;
in
{
  options = {
    services.textpod = {
      enable = lib.mkEnableOption "Enable textpod web service";
      port = lib.mkOption {
        type = lib.types.port;
        description = "Textpod web service port";
        default = 3000;
      };
      directory = lib.mkOption {
        type = lib.types.str;
        description = "Textpod working directory for notes and attachments";
        default = "/var/lib/textpod";
      };
      user = lib.mkOption {
        type = lib.types.str;
        description = "Textpod user";
        default = "root";
      };
      group = lib.mkOption {
        type = lib.types.str;
        description = "Textpod group";
        default = "textpod";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [
      textpod
    ];

    users.groups = lib.optionalAttrs (cfg.group == "textpod") {
      textpod = { };
    };

    systemd.tmpfiles.rules = [
      "d ${cfg.directory} 0755 ${cfg.user} ${cfg.group} - -"
    ];

    systemd.services.textpod = {
      description = "Textpod notes app";
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Type = "simple";
        ExecStart = "${textpod}/bin/textpod -p ${builtins.toString cfg.port}";
        User = cfg.user;
        Group = cfg.group;
        Restart = "always";
        AmbientCapabilities = "";
        CapabilityBoundingSet = "";
        LockPersonality = true;
        MemoryDenyWriteExecute = false;
        WorkingDirectory = cfg.directory;
        ReadWritePaths = cfg.directory;
        MountAPIVFS = true;
        NoNewPrivileges = true;
        PrivateDevices = true;
        PrivateMounts = true;
        PrivateTmp = true;
        PrivateUsers = true;
        ProtectClock = true;
        ProtectControlGroups = "strict";
        ProtectHome = true;
        ProtectHostname = true;
        ProtectKernelLogs = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        ProtectProc = "invisible";
        ProtectSystem = "strict";
        RemoveIPC = true;
        RestrictAddressFamilies = [
          "AF_INET"
          "AF_INET6"
          "AF_UNIX"
          "AF_NETLINK"
        ];
        RestrictNamespaces = true;
        RestrictRealtime = true;
        RestrictSUIDSGID = true;
        SystemCallArchitectures = "native";
        UMask = 27;
      };
    };
  };
}
