# Add flake.nix test inputs as arguments here
{
  self,
  plugin-name,
  inputs,
}: final: prev: let
  nvim-nightly = final.neovim-nightly;

  mkNeorocksTest = {
    name,
    nvim ? final.neovim-unwrapped,
    extraPkgs ? [],
  }: let
    nvim-wrapped = final.pkgs.wrapNeovim nvim {
      configure = {
        packages.myVimPackage = {
          start = [
            # Add plugin dependencies that aren't on LuaRocks here
          ];
        };
      };
    };
  in
    final.pkgs.neorocksTest {
      inherit name;
      pname = plugin-name;
      src = self;
      neovim = nvim-wrapped;

      # luaPackages = ps: with ps; [];
      # extraPackages = [];

      preCheck = ''
        export HOME=$(realpath .)
      '';

      buildPhase = ''
        mkdir -p $out
        cp -r tests $out
      '';
    };

  docgen = final.writeShellApplication {
    name = "docgen";
    runtimeInputs = [
      inputs.cats-doc.packages.${final.system}.default
    ];
    text = ''
      mkdir -p doc
      lemmy-help lua/rocks-edit/api.lua > doc/rocks-edit.txt
    '';
  };
in {
  nvim-stable-tests = mkNeorocksTest {name = "neovim-stable-tests";};
  nvim-nightly-tests = mkNeorocksTest {
    name = "neovim-nightly-tests";
    nvim = nvim-nightly;
  };
  inherit docgen;
}
