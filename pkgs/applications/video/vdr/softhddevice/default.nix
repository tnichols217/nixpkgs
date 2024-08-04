{ lib
, stdenv
, vdr
, alsa-lib
, fetchFromGitHub
, xcbutilwm
, xorgserver
, ffmpeg
, libva
, libvdpau
, xorg
, libGL
, libGLU
}:
stdenv.mkDerivation rec {
  pname = "vdr-softhddevice";
  version = "2.3.6";

  src = fetchFromGitHub {
    owner = "ua0lnj";
    repo = "vdr-plugin-softhddevice";
    sha256 = "sha256-T3OG93Bx1RVyXeqkNJvhOSGojZHIWT3DHHEIzUoykds=";
    rev = "v${version}";
  };

  buildInputs = [
    vdr
    xcbutilwm
    ffmpeg
    alsa-lib
    libva
    libvdpau
    xorg.libxcb
    xorg.libX11
    libGL
    libGLU
  ];

  makeFlags = [ "DESTDIR=$(out)" ];

  postPatch = ''
    substituteInPlace softhddev.c \
      --replace "LOCALBASE \"/bin/X\"" "\"${xorgserver}/bin/X\""
  '';

  meta = with lib; {
    inherit (src.meta) homepage;
    description = "VDR SoftHDDevice Plug-in";
    maintainers = [ maintainers.ck3d ];
    license = licenses.gpl2;
    inherit (vdr.meta) platforms;
  };

}
