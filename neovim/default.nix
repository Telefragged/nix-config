{ pkgs, inputs, ... }:
let
  vscode-lldb = pkgs.vscode-extensions.vadimcn.vscode-lldb;

  codelldb = "${vscode-lldb}/share/vscode/extensions/vadimcn.vscode-lldb/adapter/codelldb";
  liblldb = "${vscode-lldb}/share/vscode/extensions/vadimcn.vscode-lldb/lldb/lib/liblldb.so";
in
{
  programs.neovim = {
    defaultEditor = true;
    enable = true;
    viAlias = true;
    vimAlias = true;
    plugins = import ./plugins.nix { inherit pkgs inputs; };
    extraConfig = builtins.readFile ./customRC.vim;
    initLua = ''
      local codelldb_path = "${codelldb}"
      local liblldb_path = "${liblldb}"
    ''
    + builtins.readFile ./init.lua;

    withRuby = false;
    withPython3 = false;
  };
}
