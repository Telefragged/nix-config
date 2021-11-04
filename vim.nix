{ pkgs ? import <nixpkgs> {}}:
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
            owner = "ionide";
            repo = "ionide-vim";
            rev = "0b688cccdb80598e09cd24cd3537145f8633e051";
            sha256 = "134c61fnsx4va4f4vrb1xfscaybph22347fd61xk7jjyyr9v6a7w";
        };
    };

    ddc-vim-lsp = fetchFromGitHub {
      owner = "shun";
      repo = "ddc-vim-lsp";
      rev = "f7e348afd0d72e8b29b5cadd16768a6f4b329517";
      sha256 = "1jq9cj67hp9cydv2s3c8f38chcir42j5c2yk50sw81ya1zcvkbqs";
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
        dontBuild = true;
        postInstall = ''
            mkdir -p $out/denops/@ddc-sources $out/denops/@ddc-filters
            cp -r ${ddc-vim-lsp}/denops/* $out/denops
            cp ${ddc-vim-lsp}/autoload/* $out/autoload
            cp ${ddc-around} $out/denops/@ddc-sources/around.ts
            cp ${ddc-matcher_head} $out/denops/@ddc-filters/matcher_head.ts
            cp ${ddc-sorter_rank} $out/denops/@ddc-filters/sorter_rank.ts
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
        dontBuild = true;
        src = pkgs.fetchFromGitHub {
            owner = "vim-denops";
            repo = "denops.vim";
            rev = "228d446132825bd8035a5530a206611f639f9a74";
            sha256 = "00szxrclnrq0wsdpwip6557yzizcc88f2c3kndpas2zzxjaix2bq";
        };
    };

    vim-lsp-settings = pkgs.vimUtils.buildVimPlugin {
        name = "vim-lsp-settings";
        nativeBuildInputs = [ shellcheck ];
        src = pkgs.fetchFromGitHub {
            owner = "mattn";
            repo = "vim-lsp-settings";
            rev = "7372894af0248da1353df39db31b0b8dbac72c2a";
            sha256 = "10phpgd65jb869ry2p7rybn103x8y36jjkffdrzmcvvadnqfj3sm";
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
in vim_configurable.customize {
    name = "vim";
    vimrcConfig.plug.plugins = with pkgs.vimPlugins; [
        vim-nix
        vim-sensible
        vim-airline
        vim-airline-themes

        vim-deus
        vim-deep-space

        vim-lsp
        vim-lsp-settings

        deno-vim
        ddc-vim

        nerdtree

        ionide-vim
    ];
    vimrcConfig.customRC = ''
        set rnu
        set encoding=utf-8
        set tabstop=4

        nnoremap <S-Up> :m-2<CR>
        nnoremap <S-Down> :m+<CR>
        inoremap <S-Up> <Esc>:m-2<CR>
        inoremap <S-Down> <Esc>:m+<CR>

        autocmd BufWritePre * :%s/\s\+$//e

        set background=dark
        colors deus

        if executable('rnix-lsp')
            au User lsp_setup call lsp#register_server({
                \ 'name': 'rnix-lsp',
                \ 'cmd': {server_info->[&shell, &shellcmdflag, 'rnix-lsp']},
                \ 'whitelist': ['nix'],
                \ })
        endif

        call ddc#custom#patch_global('sources', ['vim-lsp', 'around'])

        call ddc#custom#patch_global('sourceOptions', {
            \ '_': {
            \   'matchers': ['matcher_head'],
            \   'sorters': ['sorter_rank']},
            \ })

        " <TAB>: completion.
        inoremap <silent><expr> <TAB>
        \ pumvisible() ? '<C-n>' :
        \ (col('.') <= 1 <Bar><Bar> getline('.')[col('.') - 2] =~# '\s') ?
        \ '<TAB>' : ddc#map#manual_complete()

        " <S-TAB>: completion back.
        inoremap <expr><S-TAB>  pumvisible() ? '<C-p>' : '<C-h>'

        call ddc#enable()
        '';
}
