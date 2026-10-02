"""Test original addon modules with deterministic Roblox service/storage doubles.

This checks logic and async ordering, not engine rendering or live social APIs.
"""

import argparse
from pathlib import Path
import subprocess

parser = argparse.ArgumentParser()
parser.add_argument("--luau", required=True, type=Path)
args = parser.parse_args()
root = Path(__file__).resolve().parents[1]
shared = "ReplicatedStorage/Scripts/Framework"
server = "ReplicatedStorage/Scripts/Framework/Server"
client = "ReplicatedStorage/Scripts/Framework/Client"
parts = [(root / "Tests/FrameworkAddons.harness.lua").read_text(encoding="utf-8")]
for module in (
    f"{shared}/Shared/Core/FXClass.lua",
    f"{shared}/Shared/Core/FXTable.lua",
    f"{shared}/Shared/Object/FXObjectBaseClass.lua",
    f"{shared}/Shared/Object/FXCompBaseClass.lua",
    f"{server}/Player/FSPlayerCompClass.lua",
    f"{server}/SItemClass.lua",
    f"{server}/Player/FSInventoryCompClass.lua",
    f"{server}/Player/FSRewardCompClass.lua",
    f"{server}/Modules/FSFriendService.lua",
    f"{client}/Player/FCPlayerCompClass.lua",
    f"{client}/Player/FCFriendCompClass.lua",
    f"{client}/Player/FCCommonUICompClass.lua",
):
    parts.append("\n;(function()\n" + (root / module).read_text(encoding="utf-8") + "\nend)()\n")
parts.append((root / "Tests/FrameworkAddons.spec.lua").read_text(encoding="utf-8"))

output = root / "Build/FrameworkAddons.bundle.luau"
output.parent.mkdir(exist_ok=True)
output.write_text("".join(parts), encoding="utf-8")
subprocess.run([str(args.luau.resolve()), str(output)], check=True, cwd=root)
