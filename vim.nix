{ pkgs ? import <nixpkgs> {} }:
with pkgs;
let
    fsac-archive = fetchurl {
        url = https://github.com/fsharp/FsAutoComplete/releases/latest/download/fsautocomplete.netcore.zip;
        sha256 = "1lb3m1yxh2kjbzqs9pixc6jp334wnq2yh3wg3i7d3zixa664dr6m";
    };
    ionide-vim = pkgs.vimUtils.buildVimPlugin {
        name = "ionide-vim";
        nativeBuildInputs = [ which curl unzip ];
        configurePhase = ''
            substituteInPlace ./Makefile --replace 'curl -L "$(ac_url)" -o "$(bin_d)/$(ac_archive)"' 'cp ${fsac-archive} $(bin_d)/$(ac_archive)'
        '';
        buildPhase = ''
            make fsautocomplete
        '';
        src = pkgs.fetchFromGitHub {
            owner = "Telefragged";
            repo = "ionide-vim";
            rev = "efe622a8133b1acbbed7b72c761ea4d663abe555";
            sha256 = "TbqWPJ1CKRVIBQQiLT7aYnbI08nOEPFM0tF/tVFeIpc=";
        };
    };

    ddc-nvim-lsp = fetchFromGitHub {
      owner = "Shougo";
      repo = "ddc-nvim-lsp";
      rev = "626a9e36b4fb98b311f879234c1a5006a5f9794a";
      sha256 = "f8wZApcB8ybcwKYlrdl3oHHzoSw7u8N0ru4LDPcrffg=";
    };

    ddc-fuzzy = fetchFromGitHub {
      owner = "tani";
      repo = "ddc-fuzzy";
      rev = "36df7f829559b0e1c9f72062a3f778faeefad867";
      sha256 = "3r5sImKebXAk6IzBo2kAjewho4yHeX7ElUyxYWtQ7bA=";
    };

    ddc-around = fetchurl {
        url = https://raw.githubusercontent.com/Shougo/ddc-around/f551408180c28da552ee5fe745e030f51907bca5/denops/%40ddc-sources/around.ts;
        sha256 = "0j5d9cn41b4z97nq2k4bycz0jinfj0waznkqpghj76rrjvg6ki6r";
    };

    ddc-matcher_head = fetchurl {
        url = https://raw.githubusercontent.com/Shougo/ddc-matcher_head/5ad85629b1d91a5c599c742cbbb6e48a8c2933f5/denops/%40ddc-filters/matcher_head.ts;
        sha256 = "03vwjvka1y6ssk39h40rrai7fc0kwxl8d8my6sxpihmxpny9q7yk";
    };

    ddc-sorter_rank = fetchurl {
        url = https://raw.githubusercontent.com/Shougo/ddc-sorter_rank/5ac213151681bf1c1aee8e89974f8982550458eb/denops/%40ddc-filters/sorter_rank.ts;
        sha256 = "0qswfyck264yix6v410z936c20ffa3cz26r7s5s8pf07dz48marx";
    };

    ddc-vim = pkgs.vimUtils.buildVimPlugin {
        name = "ddc-vim";
        nativeBuildInputs = [ vim-vint deno ];
        postInstall = ''
            mkdir -p $out/denops/@ddc-sources $out/denops/@ddc-filters $out/lua
            cp -r ${ddc-nvim-lsp}/denops/* $out/denops
            cp -r ${ddc-nvim-lsp}/lua/* $out/lua
            cp -r ${ddc-fuzzy}/denops/* $out/denops
            cp -r ${ddc-fuzzy}/fuzzy.ts $out/fuzzy.ts
            cp ${ddc-around} $out/denops/@ddc-sources/around.ts
        '';
        src = pkgs.fetchFromGitHub {
            owner = "Shougo";
            repo = "ddc.vim";
            rev = "c9cf4a274b96967a14080673e84c77655b77f39e";
            sha256 = "1mar08cgw0y7zf8zg44vv4cvnn87g0cq6d2sna1r6mjbz169mi30";
        };
    };

    deno-vim = pkgs.vimUtils.buildVimPlugin {
        name = "deno-vim";
        nativeBuildInputs = [ perl ];
        src = pkgs.fetchFromGitHub {
            owner = "vim-denops";
            repo = "denops.vim";
            rev = "228d446132825bd8035a5530a206611f639f9a74";
            sha256 = "00szxrclnrq0wsdpwip6557yzizcc88f2c3kndpas2zzxjaix2bq";
        };
    };

    vim-deep-space = pkgs.vimUtils.buildVimPlugin {
        name = "vim-deep-space";
        nativeBuildInputs = [ ];
        src = pkgs.fetchFromGitHub {
            owner = "tyrannicaltoucan";
            repo = "vim-deep-space";
            rev = "126d52f4f77877385cd44d983709053d1aab6635";
            sha256 = "1gi4281bzzhbjqbs5r8248bssvxmw9cvyxfynd55wyiijlk200s4";
        };
    };
in neovim.override {
    configure = {
        packages.myVimPackage = with pkgs.vimPlugins; {
            start = [
              vim-nix
              vim-airline
              vim-airline-themes

              vim-deus

              nvim-lspconfig
              deno-vim
              ddc-vim

              ionide-vim

              nerdtree

              vim-fugitive
          ];
        };
        customRC = builtins.readFile ./.vimrc;
    };
}
