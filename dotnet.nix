{ pkgs ? import <nixpkgs> {}}:
with pkgs;
let
  fetchDotnet = { name, version, sha256 }: fetchurl {
    inherit sha256;
    url = "https://dotnetcli.azureedge.net/dotnet/Sdk/${version}/${name}-${version}-linux-x64.tar.gz";
  };
  dotnet3 = dotnetCorePackages.sdk_3_1.overrideAttrs(old: rec {
    version = "3.1.302";
    src = fetchDotnet {
      inherit version;
      name = old.pname;
      sha256 = "1j13pva9wvygna6y5wqpd7mv8lvwfihi8rq4i2g4aklpcmmkfzvp";
    };
  });
  dotnet5300 = dotnetCorePackages.sdk_5_0.overrideAttrs(old: rec {
    version = "5.0.300";
    src = fetchDotnet {
      inherit version;
      name = old.pname;
      sha256 = "180kc1njpql1x227skg2v5i2nnqw05z07f1hbz1731w80j9c4wl4";
    };
  });
  dotnet5400 = dotnetCorePackages.sdk_5_0.overrideAttrs(old: rec {
    version = "5.0.400";
    src = fetchDotnet {
      inherit version;
      name = old.pname;
      sha256 = "12wj26fmp0vz11kn8524ryzd18v11v7fbnxv976nr7gh52awcz8a";
    };
  });
  dotnet6100 = dotnetCorePackages.sdk_6_0.overrideAttrs(old: rec {
    version = "6.0.100";
    src = fetchDotnet {
      inherit version;
      name = old.pname;
      sha256 = "hImnmPzZBKMkEdZGNuJ0ft8QgZLgtlxsPM+w0wLaXss=";
    };
  });
in dotnetCorePackages.combinePackages
    [ dotnet3
      dotnet5300
      dotnet5400
      dotnet6100 ]
