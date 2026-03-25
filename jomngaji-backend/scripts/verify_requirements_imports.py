import ast
from pathlib import Path


PROJECT_ROOT = Path(__file__).resolve().parents[1]
REQ_FILE = PROJECT_ROOT / "requirements.txt"

# mapping import module -> pip requirement name
IMPORT_TO_REQ = {
    "bcrypt": "bcrypt",
    "dotenv": "python-dotenv",
    "fastapi": "fastapi",
    "faster_whisper": "faster-whisper",
    "google": "google-auth",
    "jose": "python-jose",
    "jwt": "pyjwt",
    "mysql": "mysql-connector-python",
    "numpy": "numpy",
    "pydantic": "pydantic",
    "sqlalchemy": "sqlalchemy",
    "torch": "torch",
    "torchaudio": "torchaudio",
    "transformers": "transformers",
    "requests": "requests",
    "lxml": "lxml",
    "pydub": "pydub",
}


def collect_imports() -> set[str]:
    imports: set[str] = set()
    for pyfile in PROJECT_ROOT.rglob("*.py"):
        if pyfile.name == Path(__file__).name:
            continue
        tree = ast.parse(pyfile.read_text(encoding="utf-8"))
        for node in ast.walk(tree):
            if isinstance(node, ast.Import):
                for alias in node.names:
                    imports.add(alias.name.split(".")[0])
            elif isinstance(node, ast.ImportFrom) and node.module:
                imports.add(node.module.split(".")[0])
    return imports


def parse_requirements() -> set[str]:
    packages: set[str] = set()
    for line in REQ_FILE.read_text(encoding="utf-8").splitlines():
        raw = line.strip()
        if not raw or raw.startswith("#"):
            continue
        pkg = raw.split("==")[0].split(">=")[0].split("<=")[0]
        pkg = pkg.split("[")[0].strip().lower()
        packages.add(pkg)
    return packages


def main() -> None:
    used = collect_imports()
    reqs = parse_requirements()

    missing: list[tuple[str, str]] = []
    for imp, req_name in sorted(IMPORT_TO_REQ.items()):
        if imp in used and req_name.lower() not in reqs:
            missing.append((imp, req_name))

    if missing:
        print("Missing requirement entries:")
        for imp, req_name in missing:
            print(f"- import '{imp}' -> tambahkan '{req_name}'")
        raise SystemExit(1)

    print("OK: semua third-party import utama sudah tercakup di requirements.txt")


if __name__ == "__main__":
    main()
