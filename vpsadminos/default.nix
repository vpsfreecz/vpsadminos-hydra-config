{ pulls ? ../simple-pr-dummy.json }:

let
  pkgs = import <nixpkgs>{};
in with (import ../lib.nix { inherit pkgs; });
with pkgs.lib;
let
  defaults = globalDefaults // {
    nixexprinput = "vpsadminos";
    nixexprpath = "release.nix";
  };
  primary_jobsets = {
    vpsadminos-unstable = defaults // {
      description = "vpsadminos-unstable";
      inputs = {
        vpsadminos = mkFetchGithub "https://github.com/vpsfreecz/vpsadminos master";
        nixpkgs = mkFetchGithub "https://github.com/nixos/nixpkgs-channels.git nixos-unstable-small";
        supportedSystems2 = { type = "nix"; value = ''[ "x86_64-linux" ]''; emailresponsible = false; };
      };
    };
    vpsadminos-master = defaults // {
      description = "vpsadminos-master";
      inputs = {
        vpsadminos = mkFetchGithub "https://github.com/vpsfreecz/vpsadminos master";
        nixpkgs = mkFetchGithub "https://github.com/nixos/nixpkgs.git master";
        supportedSystems2 = { type = "nix"; value = ''[ "x86_64-linux" ]''; emailresponsible = false; };
      };
    };
    vpsadminos-sorki = defaults // {
      description = "vpsadminos-sorki";
      inputs = {
        vpsadminos = mkFetchGithub "https://github.com/vpsfreecz/vpsadminos master";
        nixpkgs = mkFetchGithub "https://github.com/sorki/nixpkgs.git vpsadminos";
        supportedSystems2 = { type = "nix"; value = ''[ "x86_64-linux" ]''; emailresponsible = false; };
      };
    };
  };
  pr_data = builtins.fromJSON (builtins.readFile pulls);
  makePr = num: info: {
    name = "vpsadminos-${num}";
    value = defaults // {
      description = "PR ${num}: ${info.title}";
      inputs = {
        vpsadminos = mkFetchGithub "https://github.com/${info.head.repo.owner.login}/${info.head.repo.name}.git ${info.head.ref}";
        nixpkgs = mkFetchGithub "https://github.com/nixos/nixpkgs-channels.git nixos-unstable-small";
        supportedSystems2 = { type = "nix"; value = ''[ "x86_64-linux" ]''; emailresponsible = false; };
      };
    };
  };
  pull_requests = listToAttrs (mapAttrsToList makePr pr_data);
  jobsetsAttrs = pull_requests // primary_jobsets;
in {
  jobsets = pkgs.writeText "spec.json" (builtins.toJSON jobsetsAttrs);
}
