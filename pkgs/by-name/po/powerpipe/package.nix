{
  buildGoModule,
  fetchFromGitHub,
  installShellFiles,
  lib,
  makeWrapper,
  nix-update-script,
  powerpipe,
  testers,
}:

buildGoModule rec {
  pname = "powerpipe";
  version = "0.4.1";

  src = fetchFromGitHub {
    owner = "turbot";
    repo = "powerpipe";
    rev = "refs/tags/v${version}";
    hash = "sha256-8gQ3+sXeWTiuFgj2XKh2ngo5qBBczoqnX3NiHflJGSU=";
  };

  vendorHash = "sha256-9SgGBkxPuelJrUpG8vnVPt0w5UdL4slxHJDSXDitaAQ=";
  proxyVendor = true;

  nativeBuildInputs = [
    installShellFiles
    makeWrapper
  ];

  ldflags = [
    "-s"
    "-w"
    "-X main.version=${version}"
  ];

  doCheck = true;

  checkFlags =
    let
      skippedTests = [
        # test fails in the original github.com/turbot/powerpipe project as well
        "TestGetAsSnapshotPropertyMap/card"
      ];
    in
    [ "-skip=^${builtins.concatStringsSep "$|^" skippedTests}$" ];

  postInstall = ''
    wrapProgram $out/bin/powerpipe \
      --set-default POWERPIPE_UPDATE_CHECK false \
      --set-default POWERPIPE_TELEMETRY none
  '';

  passthru = {
    tests.version = testers.testVersion {
      command = "${lib.getExe powerpipe} --version";
      package = powerpipe;
      version = "v${version}";
    };
    updateScript = nix-update-script { };
  };

  meta = {
    changelog = "https://github.com/turbot/powerpipe/blob/v${version}/CHANGELOG.md";
    description = "Dynamically query your cloud, code, logs & more with SQL";
    homepage = "https://powerpipe.io/";
    license = lib.licenses.agpl3Only;
    mainProgram = "powerpipe";
    maintainers = with lib.maintainers; [ weitzj ];
  };
}
