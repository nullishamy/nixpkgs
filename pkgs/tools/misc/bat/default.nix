{ lib
, stdenv
, rustPlatform
, fetchFromGitHub
, pkg-config
, less
, Security
, libiconv
, installShellFiles
, makeWrapper
}:

rustPlatform.buildRustPackage rec {
  pname = "bat";
  version = "0.23.0";

  src = fetchFromGitHub {
    owner = "sharkdp";
    repo = "bat";
    rev = "v${version}";
    hash = "sha256-cGHxB3Wp8yEcJBMtSOec6l7iBsMLhUtJ7nh5fijnWZs=";
  };
  cargoHash = "sha256-wZNdYGCLKD80gV1QUTgKsFSNYkbDubknPB3e6dsyEgs=";

  nativeBuildInputs = [ pkg-config installShellFiles makeWrapper ];

  buildInputs = lib.optionals stdenv.isDarwin [ Security libiconv ];

  postInstall = ''
    installManPage $releaseDir/build/bat-*/out/assets/manual/bat.1
    installShellCompletion $releaseDir/build/bat-*/out/assets/completions/bat.{bash,fish,zsh}
  '';

  # Insert Nix-built `less` into PATH because the system-provided one may be too old to behave as
  # expected with certain flag combinations.
  postFixup = ''
    wrapProgram "$out/bin/bat" \
      --prefix PATH : "${lib.makeBinPath [ less ]}"
  '';

  checkFlags = [ "--skip=pager_more" "--skip=pager_most" ];

  doInstallCheck = true;
  installCheckPhase = ''
    runHook preInstallCheck

    testFile=$(mktemp /tmp/bat-test.XXXX)
    echo -ne 'Foobar\n\n\n42' > $testFile
    $out/bin/bat -p $testFile | grep "Foobar"
    $out/bin/bat -p $testFile -r 4:4 | grep 42
    rm $testFile

    runHook postInstallCheck
  '';

  meta = with lib; {
    description = "A cat(1) clone with syntax highlighting and Git integration";
    homepage = "https://github.com/sharkdp/bat";
    changelog = "https://github.com/sharkdp/bat/raw/v${version}/CHANGELOG.md";
    license = with licenses; [ asl20 /* or */ mit ];
    mainProgram = "bat";
    maintainers = with maintainers; [ dywedir lilyball zowoq SuperSandro2000 ];
  };
}
