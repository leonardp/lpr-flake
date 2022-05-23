{
  description = "LPR flake";

  inputs = {
    #nixpkgs   = { url = "github:nixos/nixpkgs/nixos-unstable"; };
    darknet   = { url = "github:leonardp/darknet-flake/main"; };
  };

  outputs = { self, nixpkgs, darknet, ... }:
    let
      supportedSystems = [ "x86_64-linux" "aarch64-linux" ];
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
      nixpkgsFor = forAllSystems (system: import nixpkgs { inherit system; });

      #
      ## (un)comment the flags you want here
      #

      opencvOverride = {
        enableGtk3 = true;
      };

      darknetOverride = {
      #  cudaSupport = true;
      #  cudnnSupport = true;
      };

    in {

      devShells = forAllSystems (system:
        let pkgs = nixpkgsFor.${system};
        in {
          default = pkgs.mkShell {
            buildInputs = with pkgs; [
              (python3.withPackages(ps: with ps; [
                ipython
                jupyter
                graphviz
                numpy
                pandas
                matplotlib
                darknet.packages.${system}.pydnet
                (opencv4.override opencvOverride)
              ]))

              (darknet.packages.${system}.darknet.override darknetOverride
                // { opencv = (opencv.override opencvOverride); })
            ];

            shellHook = "jupyter notebook";
          };
      });
  };
}
