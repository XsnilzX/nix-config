{ pkgs, ... }:

{
  wayland.windowManager.hyprland = {
    enable = true;
    # set the Hyprland and XDPH packages to null to use the ones from the NixOS module
    package = null;
    portalPackage = null;

    settings = {
      monitor = [ "DP-1, 2880x1800@120, 0x0, 1" ];

      env = [
        "XCURSOR_SIZE,24"
        "HYPRCURSOR_SIZE,24"
        "GTK_THEME,Arc-Dark"
        "QT_QPA_PLATFORMTHEME,qt5ct"
        "QT_QPA_PLATFORM,wayland"
        "HYPRSHOT_DIR,/home/richard/Bilder/Screenshot"
      ];

      exec-once = [
        "hypridle"
        "nm-applet --indicator & blueman-applet"
        "waybar & hyprpaper"
        "systemctl --user start hyprpolkitagent"
        "seafile-applet"
        "wl-paste --watch cliphist store"
        "/home/richard/.config/hypr/scripts/wallpaper-cycle.sh"
        "walker --gapplication-service"
      ];

      input = {
        kb_layout = "de";
        follow_mouse = 1;
        sensitivity = 0;
        touchpad = {
          natural_scroll = true;
        };
      };

      gestures.workspace_swipe = true;

      general = {
        gaps_in = 1;
        gaps_out = 3;
        border_size = 2;
        col.active_border = "rgba(33ccffee) rgba(00ff99ee) 45deg";
        col.inactive_border = "rgba(595959aa)";
        resize_on_border = false;
        allow_tearing = true;
        layout = "dwindle";
      };

      decoration = {
        rounding = 10;
        rounding_power = 2;
        active_opacity = 1.0;
        inactive_opacity = 1.0;
        shadow = {
          enabled = true;
          range = 4;
          render_power = 3;
          color = "rgba(1a1a1aee)";
        };
        blur = {
          enabled = true;
          size = 3;
          passes = 1;
          vibrancy = 0.1696;
        };
      };

      animations = {
        enabled = "yes, please :)";
        bezier = [
          "easeOutQuint,0.23,1,0.32,1"
          "easeInOutCubic,0.65,0.05,0.36,1"
          "linear,0,0,1,1"
          "almostLinear,0.5,0.5,0.75,1.0"
          "quick,0.15,0,0.1,1"
        ];
        animation = [
          "global, 1, 10, default"
          "border, 1, 5.39, easeOutQuint"
          "windows, 1, 4.79, easeOutQuint"
          "windowsIn, 1, 4.1, easeOutQuint, popin 87%"
          "windowsOut, 1, 1.49, linear, popin 87%"
          "fadeIn, 1, 1.73, almostLinear"
          "fadeOut, 1, 1.46, almostLinear"
          "fade, 1, 3.03, quick"
          "layers, 1, 3.81, easeOutQuint"
          "layersIn, 1, 4, easeOutQuint, fade"
          "layersOut, 1, 1.5, linear, fade"
          "fadeLayersIn, 1, 1.79, almostLinear"
          "fadeLayersOut, 1, 1.39, almostLinear"
          "workspaces, 1, 1.94, almostLinear, fade"
          "workspacesIn, 1, 1.21, almostLinear, fade"
          "workspacesOut, 1, 1.94, almostLinear, fade"
        ];
      };

      dwindle = {
        pseudotile = true;
        preserve_split = true;
      };

      master.new_status = "master";

      misc = {
        force_default_wallpaper = -1;
        disable_hyprland_logo = false;
      };

      "$mainMod" = "SUPER";

      bind = [
        "$mainMod, Q, exec, ghostty"
        "$mainMod, X, killactive,"
        "$mainMod, M, exit,"
        "$mainMod, E, exec, thunar"
        "$mainMod, V, togglefloating,"
        "$mainMod, SPACE, exec, walker"
        "$mainMod, P, pseudo,"
        "$mainMod, J, togglesplit,"
        "$mainMod, B, exec, zen-browser"
        "$mainMod, T, exec, thunderbird"
        "$mainMod, C, exec, vscodium --ozone-platform=wayland"
        # etc...
      ];

      bindm = [
        "$mainMod, mouse:272, movewindow"
        "$mainMod, mouse:273, resizewindow"
      ];

      bindel = [
        ",XF86AudioRaiseVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"
        ",XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
        ",XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
        ",XF86AudioMicMute, exec, wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"
        ",XF86MonBrightnessUp, exec, brightnessctl s 5%+"
        ",XF86MonBrightnessDown, exec, brightnessctl s 5%-"
      ];

      bindl = [
        ",XF86AudioNext, exec, playerctl next"
        ",XF86AudioPause, exec, playerctl play-pause"
        ",XF86AudioPlay, exec, playerctl play-pause"
        ",XF86AudioPrev, exec, playerctl previous"
      ];

      windowrulev2 = [
        "suppressevent maximize, class:.*"
        "nofocus,class:^$,title:^$,xwayland:1,floating:1,fullscreen:0,pinned:0"
        "opacity 0.0 override, class:^(xwaylandvideobridge)$"
        "noanim, class:^(xwaylandvideobridge)$"
        "noinitialfocus, class:^(xwaylandvideobridge)$"
        "maxsize 1 1, class:^(xwaylandvideobridge)$"
        "noblur, class:^(xwaylandvideobridge)$"
        "nofocus, class:^(xwaylandvideobridge)$"
      ];
    };
  };
  programs.waybar = {
    enable = true;
    package = pkgs.waybar;
  };
}
