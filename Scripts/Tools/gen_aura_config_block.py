import math

tiers = [
    (1, "Common", 101, "01_Common", None, None, "91469233823349", "#8C8C8C"),
    (2, "Uncommon", 102, "02_Uncommon", None, None, "112048940124762", "#64DC5F"),
    (3, "Toxic", 106, "03_Toxic", "#40FF20", None, "91469233823349", "#40FF20"),
    (4, "Rare", 103, "04_Rare", None, None, "114920101659350", "#37AFFF"),
    (5, "Bronze", 107, "05_Bronze", "#C87830", None, "91469233823349", "#C87830"),
    (6, "Abyss", 108, "06_Abyss", "#204060", None, "91469233823349", "#204060"),
    (7, "Void", 109, "07_Void", "#8040A0", None, "91469233823349", "#8040A0"),
    (8, "Crimson", 110, "08_Crimson", None, ["#FFC8C8", "#FF2848", "#500018"], "91469233823349", "#FF2848"),
    (9, "Silver", 111, "09_Silver", "#C0CCD8", None, "91469233823349", "#C0CCD8"),
    (10, "Epic", 104, "10_Epic", None, None, "76680071023422", "#BE5AFF"),
    (11, "Ocean", 112, "11_Ocean", "#00C8A8", None, "91469233823349", "#00C8A8"),
    (12, "Lunar", 113, "12_Lunar", "#A0B0D8", None, "91469233823349", "#A0B0D8"),
    (13, "Legendary", 105, "13_Legendary", None, None, "98163950325063", "#FFCD46"),
    (14, "Emerald", 114, "14_Emerald", "#18C868", None, "91469233823349", "#18C868"),
    (15, "Sapphire", 115, "15_Sapphire", "#1860D0", None, "91469233823349", "#1860D0"),
    (16, "Ruby", 116, "16_Ruby", "#E81858", None, "91469233823349", "#E81858"),
    (17, "Sakura", 117, "17_Sakura", None, ["#FFF5FA", "#FF90C8", "#B01070"], "91469233823349", "#FF90C8"),
    (18, "Sunset", 118, "18_Sunset", None, ["#FFE8A0", "#FF6088", "#6020A0"], "91469233823349", "#FF6088"),
    (19, "Frost", 119, "19_Frost", None, ["#FFFFFF", "#B0F0FF", "#2878E8"], "91469233823349", "#B0F0FF"),
    (20, "Inferno", 120, "20_Inferno", None, ["#FFF8C0", "#FF6800", "#7A1500"], "91469233823349", "#FF6800"),
    (21, "Storm", 121, "21_Storm", None, ["#FFFFFF", "#FFE840", "#5878F0"], "91469233823349", "#FFE840"),
    (22, "Solar", 122, "22_Solar", None, ["#FFFFE8", "#FFD020", "#FF9010"], "91469233823349", "#FFD020"),
    (23, "Neon", 123, "23_Neon", None, ["#FF50FF", "#00F0FF", "#FF2088"], "91469233823349", "#00F0FF"),
    (24, "Prismatic", 124, "24_Prismatic", None, ["#FFFFFF", "#FF70D0", "#60D0FF", "#FFF060"], "91469233823349", "#FF70D0"),
    (25, "Astral", 125, "25_Astral", None, ["#FFFFFF", "#E8D0FF", "#50B8FF", "#F0F8FF"], "91469233823349", "#50B8FF"),
]

anchors_p = [(1, 3750), (2, 1.38e6), (4, 3.32e8), (10, 7.3e10), (13, 1.42e13), (25, 5e16)]
anchors_t = [(1, 1.5), (2, 2.5), (4, 3.5), (10, 4.5), (13, 5.5), (25, 12.5)]


def interp(anchors, x, log=False):
    if x <= anchors[0][0]:
        return anchors[0][1]
    if x >= anchors[-1][0]:
        return anchors[-1][1]
    for (x0, y0), (x1, y1) in zip(anchors, anchors[1:]):
        if x0 <= x <= x1:
            t = (x - x0) / (x1 - x0)
            if log:
                y0, y1 = math.log10(y0), math.log10(y1)
                return 10 ** (y0 + t * (y1 - y0))
            return y0 + t * (y1 - y0)
    return anchors[-1][1]


def fmt_price(p):
    if p >= 1e4:
        return f"{p:.3g}"
    return str(int(round(p)))


def fmt_rate(t):
    return f"{round(t, 2):.2f}".rstrip("0").rstrip(".")


lines = ["    AuraConfig = {"]
for idx, name, aid, folder, solid, grad, img, dc in tiers:
    p = interp(anchors_p, idx, True)
    t = interp(anchors_t, idx, False)
    lines.append(f"        [{idx}] = {{")
    lines.append(f"            Index = {idx},")
    lines.append(f"            AuraId = {aid},")
    lines.append(f"            Name = [[{name}]],")
    lines.append(f"            Price = {fmt_price(p).replace("+", "")},")
    lines.append(f"            TrainingRate = {fmt_rate(t)},")
    lines.append(f"            Quality = {idx},")
    lines.append(f"            DisplayColor = [[{dc}]],")
    lines.append(f"            DevGoodId = nil,")
    lines.append(f"            Img = [[{img}]],")
    lines.append(f'            ModelId = [=[game.ReplicatedStorage.Assets.Effects.Aura["{folder}"]]=]')
    lines.append("        },")
lines.append("    },")

print("\n".join(lines))
