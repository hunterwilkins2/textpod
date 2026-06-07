{
  config,
  lib,
  pkgs,
  textpod,
  ...
}:
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
    };
  };

  config = lib.mkIf config.services.textpod.enable {
    environment.systemPackages = [
      textpod
    ];

    systemd.services.textpod = {
      description = "Textpod notes app";
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Type = "simple";
        ExecStart = "${textpod}/bin/textpod -p ${builtins.toString config.services.textpod.port}";
        User = config.services.textpod.user;
        Group = config.services.textpod.user;
        Restart = "always";
        AmbientCapabilities = "";
        CapabilityBoundingSet = "";
        LockPersonality = true;
        MemoryDenyWriteExecute = false;
        WorkingDirectory = config.services.textpod.directory;
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
