"""Run exact engine-independent framework sources with the official Luau CLI."""
from pathlib import Path
import argparse
import subprocess

parser = argparse.ArgumentParser()
parser.add_argument("--luau", required=True, type=Path, help="Path to luau.exe")
args = parser.parse_args()
root = Path(__file__).resolve().parents[1]
core = root / "Game/ReplicatedStorage/Framework/Shared/Core"
parts = ["local _G = { FX = {} }\n"]
for name in ("FXClass", "FXTable", "FXTime"):
    parts.append(";(function()\n" + (core / f"{name}.lua").read_text(encoding="utf-8") + "\nend)()\n")
parts.append((root / "Tests/FrameworkPure.spec.lua").read_text(encoding="utf-8"))

output = root / "Build/FrameworkPure.bundle.luau"
output.parent.mkdir(exist_ok=True)
output.write_text("".join(parts), encoding="utf-8")
subprocess.run([str(args.luau.resolve()), str(output)], check=True, cwd=root)
