{ lib
, buildPythonApplication
, fetchFromGitHub
, hatchling
, pyqt6
, numpy
, pillow
, pycryptodome
, mutagen
, pyusb
, wasmtime  # provided by wasmtime-py.nix, not nixpkgs
, certifi
, feedparser
, requests
, packaging
, tqdm
, python-dateutil
, wrapQtAppsHook
}:

buildPythonApplication rec {
  pname = "iopenpod";
  version = "1.0.53";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "TheRealSavi";
    repo = "iOpenPod";
    rev = "v${version}";
    hash = "sha256-Ll+N5xl5hH7YNhdz9uGvoXcHl7xK641SOEQPRzhEzcg=";
  };

  # Relax version constraints that are slightly ahead of nixpkgs-unstable at
  # the time of packaging. These are minor semver bumps with no API changes.
  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace-fail 'pyqt6>=6.9.1,<7.0.0' 'pyqt6>=6.9.0,<7.0.0' \
      --replace-fail 'numpy>=2.3.0,<3.0.0'  'numpy>=2.2.0,<3.0.0'
  '';

  nativeBuildInputs = [
    hatchling
    wrapQtAppsHook
  ];

  propagatedBuildInputs = [
    pyqt6
    numpy
    pillow
    pycryptodome
    mutagen
    pyusb
    wasmtime
    certifi
    feedparser
    requests
    packaging
    tqdm
    python-dateutil
  ];

  # buildPythonApplication creates its own wrapper; let it absorb the Qt env
  # vars rather than having wrapQtAppsHook double-wrap the binary.
  dontWrapQtApps = true;
  preFixup = ''
    makeWrapperArgs+=("''${qtWrapperArgs[@]}")
  '';

  meta = with lib; {
    description = "Open-source iPod sync tool — manage your iPod without iTunes";
    longDescription = ''
      iOpenPod lets you sync music, podcasts, and metadata to any click-wheel
      iPod (Classic, Nano, Shuffle) without iTunes. Supports automatic audio
      format conversion (FLAC/OGG → MP3/AAC), podcast subscriptions, acoustic
      fingerprinting, album art, play count sync, and ListenBrainz scrobbling.
    '';
    homepage = "https://github.com/TheRealSavi/iOpenPod";
    license = licenses.mit;
    mainProgram = "iopenpod";
    platforms = platforms.linux ++ platforms.darwin;
    maintainers = [ ];
  };
}
