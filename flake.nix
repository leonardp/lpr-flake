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

      opencvOverride = {
        #enableGtk3 = true;
      };

      cudaOverride = {
        cudaSupport = true;
        cudnnSupport = true;
      };

    in {

      devShells = forAllSystems (system:
        let
          pkgs = nixpkgsFor.${system};

          shellPackages = with pkgs; [
              (python3.withPackages(ps: with ps; [
                jupyter
                graphviz
                numpy
                pandas
                matplotlib
                pytesseract
                darknet.packages.${system}.pydnet
                (opencv4.override opencvOverride)
              ]))
              cowsay
              (darknet.packages.${system}.darknet.override { opencv = (opencv.override opencvOverride); })
            ];

        in {

          default = pkgs.mkShell {
            buildInputs = shellPackages;
            shellHook = "cowsay Oh hai!";
          };

          cuda = pkgs.mkShell {
            buildInputs = shellPackages ++ [
              (darknet.packages.${system}.darknet.override cudaOverride)
            ];
            shellHook = "cowsay -w Oh hai!";
          };

          notebook = pkgs.mkShell {
            buildInputs = shellPackages;
            shellHook = "jupyter notebook";
          };
      });
  };
}
