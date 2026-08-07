{
  appimageTools,
  fetchurl,
  lib,
}:

let
  pname = "wooting-bg-service";
  version = "0.5.0";

  src = fetchurl {
    name = "Wooting-Background-Service-${version}-amd64.AppImage";
    url = "https://api.wooting.io/public/bg-service/download-installer?target=linux&arch=x86_64&version=v${version}";
    hash = "sha256-e5NQ9rExdmvobXMEQDfrnU0ofIDOd14AEfH7SkRC6VU=";
  };

  contents = appimageTools.extract { inherit pname version src; };
in

appimageTools.wrapType2 {
  inherit version pname src;

  extraInstallCommands = ''
    install -Dm444 "${contents}/usr/share/applications/Wooting Background Service.desktop" \
      $out/share/applications/${pname}.desktop

    for size in 32x32 128x128; do
      install -Dm444 ${contents}/usr/share/icons/hicolor/$size/apps/${pname}.png \
        -t $out/share/icons/hicolor/$size/apps
    done
  '';

  meta = {
    homepage = "https://wooting.io/wootility";
    description = "Background service for Wooting keyboards";
    longDescription = ''
      Companion daemon for Wootility. It keeps a link to the keyboard open while
      Wootility is closed, which is what app linking (per-application profile
      switching) and the light indicators (volume, battery, system info, Discord)
      rely on.
    '';
    platforms = [ "x86_64-linux" ];
    license = lib.licenses.unfree;
    maintainers = with lib.maintainers; [ returntoreality ];
    mainProgram = pname;
  };
}
