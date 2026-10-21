{ pkgs, ... }:

{
  packages = with pkgs; [
    git
    curl
    jq
    neovim
  ];

  enterShell = ''
    echo "Arch Linux Developer Environment"
    echo "devenv aktif"
  '';
}
