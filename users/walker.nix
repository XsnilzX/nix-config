{config, pkgs, ...}:

{
  programs.walker = {
    enable = true;
    runAsService = true;

    config = {
      search.placeholder = "Suche...";
      ui.fullscreen = false;
      ui.font = "JetBrainsMono Nerd Font 14";
      ui.dpi = 110;

      list = {
        height = 300;
        iconSize = 25;
        showIcons = true;
      };

      theme.iconTheme = "Papirus";
      terminal = "ghostty";
    };

    style = ''
      * {
        background-color: #1e1e2e;
        color: #cdd6f4;
        border: 0;
        padding: 0;
        margin: 0;
      }

      window {
        width: 30%;
        background-color: #1e1e2e;
        border-radius: 10px;
      }

      input {
        padding: 12px;
        background-color: #313244;
        color: #cdd6f4;
        border-radius: 5px;
      }

      list {
        padding: 8px 12px;
        background-color: #1e1e2e;
      }

      listitem {
        padding: 8px 12px;
        background-color: rgba(30, 30, 46, 0.7);
        color: #a6adc8;
        border-radius: 0px;
      }

      listitem[selected] {
        background-color: #313244;
        color: #cdd6f4;
        border-radius: 5px;
      }

      icon {
        size: 25px;
        padding-right: 10px;
        background-color: transparent;
      }

      prompt {
        background-color: #313244;
        color: #cdd6f4;
        padding: 12px;
      }
    '';
  };
}
