{
  fetchFromGitHub,
  python3Packages,
  beets,
  lib,
}:

let
  version = "0.24.1";
in

python3Packages.buildPythonApplication {
  pname = "beetcamp";
  inherit version;
  pyproject = true;

  src = fetchFromGitHub {
    owner = "snejus";
    repo = "beetcamp";
    tag = "0.24.1";
    hash = "sha256-Oe5pZ4gYgqBHuzt9LBe4G14+RYXrNL+L5GIGMMflyMI=";
  };

  build-system = [
    python3Packages.poetry-core
  ];

  nativeBuildInputs = [
    beets
  ];

  dependencies = [
    python3Packages.pycountry
    python3Packages.httpx
    python3Packages.packaging
  ];

  postPatch = ''
    substituteInPlace beetcamp/helpers.py \
      --replace-fail 'data.pop("genres")' 'data.pop("genres", None)'
    substituteInPlace beetcamp/__init__.py \
      --replace-fail '"truncate_comments": False,' '"truncate_comments": False, "data_source_mismatch_penalty": 0.5,'
  '';

  doCheck = false;

  meta = {
    description = "Music tagger and library organizer";
    homepage = "https://beets.io";
    license = lib.licenses.gpl2;
    mainProgram = "beetcamp";
  };
}
