{ pname
, version
, src
, lib
, stdenv
, fetchFromGitHub
, cmake
, boost17x
, pkg-config
, libusb1
, zstd
, libressl
, enableSdl2 ? true, SDL2
, enableQt ? true, qtbase, qtmultimedia, wrapQtAppsHook
, enableQtTranslation ? enableQt, qttools
, enableWebService ? true
, enableCubeb ? true, libpulseaudio
, enableFfmpegAudioDecoder ? true
, enableFfmpegVideoDumper ? true
, ffmpeg_4
, useDiscordRichPresence ? true, rapidjson
, enableFdk ? false, fdk_aac
}:
assert lib.assertMsg (!enableFfmpegAudioDecoder || !enableFdk) "Can't enable both enableFfmpegAudioDecoder and enableFdk";

let
  compat-list = ./compat-list;
  source = /etc/nixos/citra-unified-source.tar;
in
stdenv.mkDerivation rec {
  pname = "citra-nightly";
  version = "1907";

  # src = fetchFromGitHub {
  #   owner = "citra-emu";
  #   repo = "citra-nightly";
  #   rev = "nightly-${version}";
  #   sha256 = "l4pqok42/ybnRX90Qwhcgm2JR4/9C5bbCTk3j4QuWtw=";
  #   fetchSubmodules = true;
  # };

  src = ${source};

  unpackPhase = ''
    runHook preUnpack
    tar --extract --file=${src}
    runHook postUnpack
  '';

  nativeBuildInputs = [
    cmake
    pkg-config
  ] ++ lib.optionals enableQt [ wrapQtAppsHook ];

  buildInputs = [
    boost17x
    libusb1
  ] ++ lib.optionals enableQt [ qtbase qtmultimedia ]
    ++ lib.optional enableSdl2 SDL2
    ++ lib.optional enableQtTranslation qttools
    ++ lib.optional enableCubeb libpulseaudio
    ++ lib.optional (enableFfmpegAudioDecoder || enableFfmpegVideoDumper) ffmpeg_4
    ++ lib.optional useDiscordRichPresence rapidjson
    ++ lib.optional enableFdk fdk_aac;

  cmakeFlags = [
    "-DUSE_SYSTEM_BOOST=ON"
    "-DCITRA_USE_BUNDLED_FFMPEG=OFF"
    "-DCITRA_USE_BUNDLED_QT=OFF"
    "-DUSE_SYSTEM_SDL2=ON"
    "-DCMAKE_INSTALL_INCLUDEDIR=include"
    "-DCMAKE_INSTALL_LIBDIR=lib"

    # We dont want to bother upstream with potentially outdated compat reports
    "-DCITRA_ENABLE_COMPATIBILITY_REPORTING=ON"
    "-DENABLE_COMPATIBILITY_LIST_DOWNLOAD=OFF" # We provide this deterministically
  ] ++ lib.optional (!enableSdl2) "-DENABLE_SDL2=OFF"
    ++ lib.optional (!enableQt) "-DENABLE_QT=OFF"
    ++ lib.optional enableQtTranslation "-DENABLE_QT_TRANSLATION=ON"
    ++ lib.optional (!enableWebService) "-DENABLE_WEB_SERVICE=OFF"
    ++ lib.optional (!enableCubeb) "-DENABLE_CUBEB=OFF"
    ++ lib.optional enableFfmpegAudioDecoder "-DENABLE_FFMPEG_AUDIO_DECODER=ON"
    ++ lib.optional enableFfmpegVideoDumper "-DENABLE_FFMPEG_VIDEO_DUMPER=ON"
    ++ lib.optional useDiscordRichPresence "-DUSE_DISCORD_PRESENCE=ON"
    ++ lib.optional enableFdk "-DENABLE_FDK=ON";

  postPatch = ''
    # Fix file not found when looking in var/empty instead of opt
    mkdir externals/dynarmic/src/dynarmic/ir/var
    ln -s ../opt externals/dynarmic/src/dynarmic/ir/var/empty

    # Prep compatibilitylist
    ln -s ${compat-list} ./dist/compatibility_list/compatibility_list.json

    # We already know the submodules are present
    substituteInPlace CMakeLists.txt \
      --replace "check_submodules_present()" ""

    # Devendoring
    rm -rf externals/zstd externals/libressl
    cp -r ${zstd.src} externals/zstd
    tar xf ${libressl.src} -C externals/
    mv externals/${libressl.name} externals/libressl
    chmod -R a+w externals/zstd
  '';

  # Fixes https://github.com/NixOS/nixpkgs/issues/171173
  postInstall = lib.optionalString (enableCubeb && enableSdl2) ''
    wrapProgram "$out/bin/citra" \
      --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath [ libpulseaudio ]}
  '';

  meta = with lib; {
    broken = (stdenv.isLinux && stdenv.isAarch64);
    description = "The nightly branch of an open-source emulator for the Ninteno 3DS";
    longDescription = ''
      A Nintendo 3DS Emulator written in C++
      Using the nightly branch is recommended for general usage.
    '';
    mainProgram = if enableQt then "citra-qt" else "citra";
    platforms = platforms.linux;
    license = licenses.gpl2Plus;
  };
}