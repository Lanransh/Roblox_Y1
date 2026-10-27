return {
    CommonConfig = {
        TrainingLevelUpCurve = {
            Type = [[Power]],
            M = 1,
            P = 2
        },
        RebirthConsumeCurve = {
            Type = [[Power]],
            M = 1,
            P = 3
        },
        TrainingLevelToStrength = 10,
        RebirthTrainingRate = {
            Type = [[Power]],
            M = 1,
            P = 2
        },
        RebirthMoneyRate = {
            Type = [[Power]],
            M = 1,
            P = 2
        },
        InviteFriendData = {
            MaxCount = 4,
            AddRate = 0.25,
            CD = 300
        },
        ItemData = {
            TimeSurvivel = 30,
            LuckSurvivelTime = 30,
            LuckRefreshInterval = 90
        },
        CollectionData = {
            UnlockCount = 1,
            TrainingRate = 0.01
        },
        OfflineReward = {
            Time = 14400,
            Rate = 0.25,
            VIPRate = 0.5
        },
        LoginData = {
            GemCount = 5
        },
        GiftData = {
            Gem = 5,
            Count = 1,
            Time = 600
        },
        ToyPriceRateRange = {
            [1] = 0.5,
            [2] = 1.5,
        },
        ToyCandidateCount = 6,
        ToyItemsPerStage = 3,
        ToyRefreshRatio = 0.333333333333333,
        ToyLuckyCount = 4,
        AnalyticsEnabled = true,
        AnalyticsExcludedUserIds = {
            [1] = 0,
        },
        LuckData = {
            DefaultLevel = 1,
            MaxLevel = 10,
            UpgradeCostBase = 1,
            UpgradeCostMultiplier = 1
        }
    },
    TrainingFieldData = {
        [1] = {
            Index = 1,
            NeedRebirhLevel = 0,
            DevGoodId = nil,
            TrainingRate = 1,
            Node = [[game.Workspace.BlockMeshs.World1Root.TrainingCenter.Training1]]
        },
        [2] = {
            Index = 2,
            NeedRebirhLevel = 3,
            DevGoodId = nil,
            TrainingRate = 2,
            Node = [[game.Workspace.BlockMeshs.World1Root.TrainingCenter.Training2]]
        },
        [3] = {
            Index = 3,
            NeedRebirhLevel = 6,
            DevGoodId = nil,
            TrainingRate = 5,
            Node = [[game.Workspace.BlockMeshs.World1Root.TrainingCenter.Training3]]
        },
        [4] = {
            Index = 4,
            NeedRebirhLevel = 9,
            DevGoodId = nil,
            TrainingRate = 9,
            Node = [[game.Workspace.BlockMeshs.World1Root.TrainingCenter.Training4]]
        },
        [5] = {
            Index = 5,
            NeedRebirhLevel = 12,
            DevGoodId = nil,
            TrainingRate = 14,
            Node = [[game.Workspace.BlockMeshs.World1Root.TrainingCenter.Training5]]
        }
    },
    ToolConfig = {
        [1] = {
            Index = 1,
            ToolId = 101,
            Name = [[Worn Wooden Pickaxe]],
            Price = 0,
            TrainingRate = 1,
            DevGoodId = nil,
            Img = [[99853650045862]],
            ModelId = [=[game.ReplicatedStorage.Assets.BlockMeshs.Tools["01WornWoodenPickaxe"]]=]
        },
        [2] = {
            Index = 2,
            ToolId = 102,
            Name = [[Heavy Wooden Hammer]],
            Price = 25,
            TrainingRate = 39,
            DevGoodId = nil,
            Img = [[116225665846279]],
            ModelId = [=[game.ReplicatedStorage.Assets.BlockMeshs.Tools["02HeavyWoodenHammer"]]=]
        },
        [3] = {
            Index = 3,
            ToolId = 103,
            Name = [[Crude Silver Pickaxe]],
            Price = 450,
            TrainingRate = 450,
            DevGoodId = nil,
            Img = [[136956773152573]],
            ModelId = [=[game.ReplicatedStorage.Assets.BlockMeshs.Tools["03CrudeSilverPickaxe"]]=]
        },
        [4] = {
            Index = 4,
            ToolId = 104,
            Name = [[Crude Silver Hammer]],
            Price = 4375,
            TrainingRate = 3282,
            DevGoodId = nil,
            Img = [[97553870039023]],
            ModelId = [=[game.ReplicatedStorage.Assets.BlockMeshs.Tools["04CrudeSilverHammer"]]=]
        },
        [5] = {
            Index = 5,
            ToolId = 105,
            Name = [[Reinforced Iron Pickaxe]],
            Price = 35000,
            TrainingRate = 19000,
            DevGoodId = nil,
            Img = [[118090700645855]],
            ModelId = [=[game.ReplicatedStorage.Assets.BlockMeshs.Tools["05ReinforcedIronPickaxe"]]=]
        },
        [6] = {
            Index = 6,
            ToolId = 106,
            Name = [[Reinforced Iron Hammer]],
            Price = 253000,
            TrainingRate = 95500,
            DevGoodId = nil,
            Img = [[138508042210191]],
            ModelId = [=[game.ReplicatedStorage.Assets.BlockMeshs.Tools["06ReinforcedIronHammer"]]=]
        },
        [7] = {
            Index = 7,
            ToolId = 107,
            Name = [[Fine Steel Mining Pickaxe]],
            Price = 1.89e+6,
            TrainingRate = 442000,
            DevGoodId = nil,
            Img = [[78371166922896]],
            ModelId = [=[game.ReplicatedStorage.Assets.BlockMeshs.Tools["07FineSteelMiningPickaxe"]]=]
        },
        [8] = {
            Index = 8,
            ToolId = 108,
            Name = [[Fine Steel Maul]],
            Price = 1.22e+7,
            TrainingRate = 1.93e+6,
            DevGoodId = nil,
            Img = [[132966760008713]],
            ModelId = [=[game.ReplicatedStorage.Assets.BlockMeshs.Tools["08FineSteelMaul"]]=]
        },
        [9] = {
            Index = 9,
            ToolId = 109,
            Name = [[Brass Mechanical Pickaxe]],
            Price = 7.62e+7,
            TrainingRate = 8.1e+6,
            DevGoodId = nil,
            Img = [[133927008310944]],
            ModelId = [=[game.ReplicatedStorage.Assets.BlockMeshs.Tools["09BrassMechanicalPickaxe"]]=]
        },
        [10] = {
            Index = 10,
            ToolId = 110,
            Name = [[Brass Mechanical Hammer]],
            Price = 4.65e+8,
            TrainingRate = 3.31e+7,
            DevGoodId = nil,
            Img = [[98415179467911]],
            ModelId = [=[game.ReplicatedStorage.Assets.BlockMeshs.Tools["10BrassMechanicalHammer"]]=]
        },
        [11] = {
            Index = 11,
            ToolId = 111,
            Name = [[Obsidian Battle Pickaxe]],
            Price = 2.78e+9,
            TrainingRate = 1.33e+8,
            DevGoodId = nil,
            Img = [[79276409476682]],
            ModelId = [=[game.ReplicatedStorage.Assets.BlockMeshs.Tools["11ObsidianBattlePickaxe"]]=]
        },
        [12] = {
            Index = 12,
            ToolId = 112,
            Name = [[Obsidian Great Hammer]],
            Price = 1.64e+10,
            TrainingRate = 5.25e+8,
            DevGoodId = nil,
            Img = [[86184044773576]],
            ModelId = [=[game.ReplicatedStorage.Assets.BlockMeshs.Tools["12ObsidianGreatHammer"]]=]
        },
        [13] = {
            Index = 13,
            ToolId = 113,
            Name = [[Emerald Guardian Pickaxe]],
            Price = 9.55e+10,
            TrainingRate = 2.05e+9,
            DevGoodId = nil,
            Img = [[85964386896273]],
            ModelId = [=[game.ReplicatedStorage.Assets.BlockMeshs.Tools["13EmeraldGuardianPickaxe"]]=]
        },
        [14] = {
            Index = 14,
            ToolId = 114,
            Name = [[Emerald Guardian Hammer]],
            Price = 5.49e+11,
            TrainingRate = 7.99e+9,
            DevGoodId = nil,
            Img = [[121813166897471]],
            ModelId = [=[game.ReplicatedStorage.Assets.BlockMeshs.Tools["14EmeraldGuardianHammer"]]=]
        },
        [15] = {
            Index = 15,
            ToolId = 115,
            Name = [[Red Crystal Forge Pickaxe]],
            Price = 3.13e+12,
            TrainingRate = 3.1e+10,
            DevGoodId = nil,
            Img = [[107669574278873]],
            ModelId = [=[game.ReplicatedStorage.Assets.BlockMeshs.Tools["15RedCrystalForgePickaxe"]]=]
        },
        [16] = {
            Index = 16,
            ToolId = 116,
            Name = [[Red Crystal Forge Hammer]],
            Price = 1.77e+13,
            TrainingRate = 1.2e+11,
            DevGoodId = nil,
            Img = [[98723580431394]],
            ModelId = [=[game.ReplicatedStorage.Assets.BlockMeshs.Tools["16RedCrystalForgeHammer"]]=]
        },
        [17] = {
            Index = 17,
            ToolId = 117,
            Name = [[Ice-Blue Star Crystal Pickaxe]],
            Price = 9.93e+13,
            TrainingRate = 4.62e+11,
            DevGoodId = nil,
            Img = [[126241505230536]],
            ModelId = [=[game.ReplicatedStorage.Assets.BlockMeshs.Tools["17IceBlueStarCrystalPickaxe"]]=]
        },
        [18] = {
            Index = 18,
            ToolId = 118,
            Name = [[Ice-Blue Star Crystal Hammer]],
            Price = 5.54e+14,
            TrainingRate = 1.78e+12,
            DevGoodId = nil,
            Img = [[78092021290844]],
            ModelId = [=[game.ReplicatedStorage.Assets.BlockMeshs.Tools["18IceBlueStarCrystalHammer"]]=]
        },
        [19] = {
            Index = 19,
            ToolId = 119,
            Name = [[Gilded Crown Pickaxe]],
            Price = 3.07e+15,
            TrainingRate = 6.9e+12,
            DevGoodId = nil,
            Img = [[138731887343821]],
            ModelId = [=[game.ReplicatedStorage.Assets.BlockMeshs.Tools["19GildedCrownPickaxe"]]=]
        },
        [20] = {
            Index = 20,
            ToolId = 120,
            Name = [[Gilded Crown Great Hammer]],
            Price = 1.69e+16,
            TrainingRate = 2.67e+13,
            DevGoodId = nil,
            Img = [[113127149166000]],
            ModelId = [=[game.ReplicatedStorage.Assets.BlockMeshs.Tools["20GildedCrownGreatHammer"]]=]
        },
        [21] = {
            Index = 21,
            ToolId = 121,
            Name = [[Deep Sea Anchor Hammer]],
            Price = 9.3e+16,
            TrainingRate = 1.04e+14,
            DevGoodId = nil,
            Img = [[96227746339558]],
            ModelId = [=[game.ReplicatedStorage.Assets.BlockMeshs.Tools["21DeepSeaAnchorHammer"]]=]
        },
        [22] = {
            Index = 22,
            ToolId = 122,
            Name = [[Deep Sea Hook Pickaxe]],
            Price = 5.08e+17,
            TrainingRate = 4.03e+14,
            DevGoodId = nil,
            Img = [[134869410236813]],
            ModelId = [=[game.ReplicatedStorage.Assets.BlockMeshs.Tools["22DeepSeaHookPickaxe"]]=]
        },
        [23] = {
            Index = 23,
            ToolId = 123,
            Name = [[Desert Colossus Bone Hammer]],
            Price = 2.77e+18,
            TrainingRate = 1.57e+15,
            DevGoodId = nil,
            Img = [[121268665996978]],
            ModelId = [=[game.ReplicatedStorage.Assets.BlockMeshs.Tools["23DesertColossusBoneHammer"]]=]
        },
        [24] = {
            Index = 24,
            ToolId = 124,
            Name = [[Sand King Fang Pickaxe]],
            Price = 1.45e+19,
            TrainingRate = 6.16e+15,
            DevGoodId = nil,
            Img = [[89972874141623]],
            ModelId = [=[game.ReplicatedStorage.Assets.BlockMeshs.Tools["24SandKingFangPickaxe"]]=]
        },
        [25] = {
            Index = 25,
            ToolId = 125,
            Name = [[Amethyst Star Ring Hammer]],
            Price = 7.84e+19,
            TrainingRate = 2.42e+16,
            DevGoodId = nil,
            Img = [[88597169256101]],
            ModelId = [=[game.ReplicatedStorage.Assets.BlockMeshs.Tools["25AmethystStarRingHammer"]]=]
        },
        [26] = {
            Index = 26,
            ToolId = 126,
            Name = [[Amethyst Star Ring Pickaxe]],
            Price = 4.23e+20,
            TrainingRate = 9.54e+16,
            DevGoodId = nil,
            Img = [[85002040484327]],
            ModelId = [=[game.ReplicatedStorage.Assets.BlockMeshs.Tools["26AmethystStarRingPickaxe"]]=]
        },
        [27] = {
            Index = 27,
            ToolId = 127,
            Name = [[Holy Crown Pickaxe]],
            Price = 2.28e+21,
            TrainingRate = 1.5e+17,
            DevGoodId = nil,
            Img = [[122188029381990]],
            ModelId = [=[game.ReplicatedStorage.Assets.AITools["01-holy-crown-pickaxe"]]=]
        },
        [28] = {
            Index = 28,
            ToolId = 128,
            Name = [[Holy Crown Hammer]],
            Price = 1.22e+22,
            TrainingRate = 3e+17,
            DevGoodId = nil,
            Img = [[111918297845046]],
            ModelId = [=[game.ReplicatedStorage.Assets.AITools["02-holy-crown-hammer"]]=]
        },
        [29] = {
            Index = 29,
            ToolId = 129,
            Name = [[Dragon Flame Pickaxe]],
            Price = 6.3499999999999996854272e+22,
            TrainingRate = 5.94e+17,
            DevGoodId = nil,
            Img = [[131796875082030]],
            ModelId = [=[game.ReplicatedStorage.Assets.AITools["03-dragon-flame-pickaxe"]]=]
        },
        [30] = {
            Index = 30,
            ToolId = 130,
            Name = [[Dragon Flame Hammer]],
            Price = 3.29000000000000006291456e+23,
            TrainingRate = 1.17e+18,
            DevGoodId = nil,
            Img = [[135291300946209]],
            ModelId = [=[game.ReplicatedStorage.Assets.AITools["04-dragon-flame-hammer"]]=]
        },
        [31] = {
            Index = 31,
            ToolId = 131,
            Name = [[Thunder Pickaxe]],
            Price = 1.700000000000000025165824e+24,
            TrainingRate = 2.27e+18,
            DevGoodId = nil,
            Img = [[135059340240171]],
            ModelId = [=[game.ReplicatedStorage.Assets.AITools["05-thunder-pickaxe"]]=]
        },
        [32] = {
            Index = 32,
            ToolId = 132,
            Name = [[Thunder Hammer]],
            Price = 8.810000000000000297795584e+24,
            TrainingRate = 4.37e+18,
            DevGoodId = nil,
            Img = [[138711849822666]],
            ModelId = [=[game.ReplicatedStorage.Assets.AITools["06-thunder-hammer"]]=]
        },
        [33] = {
            Index = 33,
            ToolId = 133,
            Name = [[Eastern Clouds Pickaxe]],
            Price = 4.5499999999999999505072128e+25,
            TrainingRate = 8.38e+18,
            DevGoodId = nil,
            Img = [[103077185243615]],
            ModelId = [=[game.ReplicatedStorage.Assets.AITools["07-eastern-clouds-pickaxe"]]=]
        },
        [34] = {
            Index = 34,
            ToolId = 134,
            Name = [[Eastern Clouds Hammer]],
            Price = 2.3499999999999998800429056e+26,
            TrainingRate = 1.59e+19,
            DevGoodId = nil,
            Img = [[119720961929827]],
            ModelId = [=[game.ReplicatedStorage.Assets.AITools["08-eastern-clouds-hammer"]]=]
        },
        [35] = {
            Index = 35,
            ToolId = 135,
            Name = [[Forest Guardian Pickaxe]],
            Price = 1.20999999999999995285602304e+27,
            TrainingRate = 3.01e+19,
            DevGoodId = nil,
            Img = [[104288707111612]],
            ModelId = [=[game.ReplicatedStorage.Assets.AITools["09-forest-guardian-pickaxe"]]=]
        },
        [36] = {
            Index = 36,
            ToolId = 136,
            Name = [[Forest Guardian Hammer]],
            Price = 6.230000000000000085530247168e+27,
            TrainingRate = 5.66e+19,
            DevGoodId = nil,
            Img = [[93955605202823]],
            ModelId = [=[game.ReplicatedStorage.Assets.AITools["10-forest-guardian-hammer"]]=]
        },
        [37] = {
            Index = 37,
            ToolId = 137,
            Name = [[Ice Crystal Pickaxe]],
            Price = 3.2000000000000000425201762304e+28,
            TrainingRate = 1.06e+20,
            DevGoodId = nil,
            Img = [[94920898798936]],
            ModelId = [=[game.ReplicatedStorage.Assets.AITools["11-ice-crystal-pickaxe"]]=]
        },
        [38] = {
            Index = 38,
            ToolId = 138,
            Name = [[Ice Crystal Hammer]],
            Price = 1.64999999999999992021964029952e+29,
            TrainingRate = 1.97e+20,
            DevGoodId = nil,
            Img = [[98900726428144]],
            ModelId = [=[game.ReplicatedStorage.Assets.AITools["12-ice-crystal-hammer"]]=]
        },
        [39] = {
            Index = 39,
            ToolId = 139,
            Name = [[Shadow Demon Pickaxe]],
            Price = 8.19000000000000067232478527488e+29,
            TrainingRate = 3.64e+20,
            DevGoodId = nil,
            Img = [[97673689505764]],
            ModelId = [=[game.ReplicatedStorage.Assets.AITools["13-shadow-demon-pickaxe"]]=]
        },
        [40] = {
            Index = 40,
            ToolId = 140,
            Name = [[Shadow Demon Hammer]],
            Price = 14,
            TrainingRate = 14,
            DevGoodId = nil,
            Img = [[133737570876290]],
            ModelId = [=[game.ReplicatedStorage.Assets.AITools["14-shadow-demon-hammer"]]=]
        }
    },
    TrainingRateConfig = {
        [1] = {
            Index = 1,
            Rate = 2,
            GemGoodsId = 150
        },
        [2] = {
            Index = 2,
            Rate = 4,
            GemGoodsId = 151
        },
        [3] = {
            Index = 3,
            Rate = 8,
            GemGoodsId = 152
        },
        [4] = {
            Index = 4,
            Rate = 16,
            GemGoodsId = 153
        },
        [5] = {
            Index = 5,
            Rate = 32,
            GemGoodsId = 154
        },
        [6] = {
            Index = 6,
            Rate = 64,
            GemGoodsId = 155
        },
        [7] = {
            Index = 7,
            Rate = 128,
            GemGoodsId = 156
        },
        [8] = {
            Index = 8,
            Rate = 256,
            GemGoodsId = 157
        },
        [9] = {
            Index = 9,
            Rate = 512,
            GemGoodsId = 158
        },
        [10] = {
            Index = 10,
            Rate = 1024,
            GemGoodsId = 159
        },
        [11] = {
            Index = 11,
            Rate = 2048,
            GemGoodsId = 160
        }
    },
    AuraConfig = {
        [1] = {
            Index = 1,
            AuraId = 101,
            Name = [[Common]],
            Price = 3750,
            TrainingRate = 1.5,
            Quality = 1,
            DevGoodId = nil,
            Img = [[88151748923443]],
            ModelId = [=[game.ReplicatedStorage.Assets.Effects.Aura["01_Common"]]=]
        },
        [2] = {
            Index = 2,
            AuraId = 102,
            Name = [[Uncommon]],
            Price = 1.38e+6,
            TrainingRate = 2.5,
            Quality = 2,
            DevGoodId = nil,
            Img = [[130646097070957]],
            ModelId = [=[game.ReplicatedStorage.Assets.Effects.Aura["02_Uncommon"]]=]
        },
        [3] = {
            Index = 3,
            AuraId = 103,
            Name = [[Toxic]],
            Price = 3.32e+8,
            TrainingRate = 3.5,
            Quality = 3,
            DevGoodId = nil,
            Img = [[86124893237823]],
            ModelId = [=[game.ReplicatedStorage.Assets.Effects.Aura["03_Toxic"]]=]
        },
        [4] = {
            Index = 4,
            AuraId = 104,
            Name = [[Rare]],
            Price = 7.3e+10,
            TrainingRate = 4.5,
            Quality = 4,
            DevGoodId = nil,
            Img = [[117901666423784]],
            ModelId = [=[game.ReplicatedStorage.Assets.Effects.Aura["04_Rare"]]=]
        },
        [5] = {
            Index = 5,
            AuraId = 105,
            Name = [[Bronze]],
            Price = 1.42e+13,
            TrainingRate = 5.5,
            Quality = 5,
            DevGoodId = nil,
            Img = [[133168932011408]],
            ModelId = [=[game.ReplicatedStorage.Assets.Effects.Aura["05_Bronze"]]=]
        },
        [6] = {
            Index = 6,
            AuraId = 106,
            Name = [[Abyss]],
            Price = 2.67e+15,
            TrainingRate = 6.5,
            Quality = 6,
            DevGoodId = nil,
            Img = [[71089861609803]],
            ModelId = [=[game.ReplicatedStorage.Assets.Effects.Aura["06_Abyss"]]=]
        },
        [7] = {
            Index = 7,
            AuraId = 107,
            Name = [[Void]],
            Price = 4.69e+17,
            TrainingRate = 7.5,
            Quality = 7,
            DevGoodId = nil,
            Img = [[71622349623563]],
            ModelId = [=[game.ReplicatedStorage.Assets.Effects.Aura["07_Void"]]=]
        },
        [8] = {
            Index = 8,
            AuraId = 108,
            Name = [[Crimson]],
            Price = 7.56e+19,
            TrainingRate = 8.5,
            Quality = 8,
            DevGoodId = nil,
            Img = [[126547452796781]],
            ModelId = [=[game.ReplicatedStorage.Assets.Effects.Aura["08_Crimson"]]=]
        },
        [9] = {
            Index = 9,
            AuraId = 109,
            Name = [[Silver]],
            Price = 1.18e+22,
            TrainingRate = 9.5,
            Quality = 9,
            DevGoodId = nil,
            Img = [[111693433253936]],
            ModelId = [=[game.ReplicatedStorage.Assets.Effects.Aura["09_Silver"]]=]
        },
        [10] = {
            Index = 10,
            AuraId = 110,
            Name = [[Epic]],
            Price = 1.649999999999999945474048e+24,
            TrainingRate = 12.5,
            Quality = 10,
            DevGoodId = nil,
            Img = [[126721700266409]],
            ModelId = [=[game.ReplicatedStorage.Assets.Effects.Aura["10_Epic"]]=]
        },
        [11] = {
            Index = 11,
            AuraId = 111,
            Name = [[Ocean]],
            Price = 2.27000000000000009613344768e+26,
            TrainingRate = 15.9,
            Quality = 11,
            DevGoodId = nil,
            Img = [[92711027530571]],
            ModelId = [=[game.ReplicatedStorage.Assets.Effects.Aura["11_Ocean"]]=]
        },
        [12] = {
            Index = 12,
            AuraId = 112,
            Name = [[Lunar]],
            Price = 3.0000000000000000948382466048e+28,
            TrainingRate = 19.7,
            Quality = 12,
            DevGoodId = nil,
            Img = [[140129159429440]],
            ModelId = [=[game.ReplicatedStorage.Assets.Effects.Aura["12_Lunar"]]=]
        },
        [13] = {
            Index = 13,
            AuraId = 113,
            Name = [[Legendary]],
            Price = 2.2299999999999999233084734046208e+31,
            TrainingRate = 21.3,
            Quality = 13,
            DevGoodId = nil,
            Img = [[125903398380406]],
            ModelId = [=[game.ReplicatedStorage.Assets.Effects.Aura["13_Legendary"]]=]
        },
        [14] = {
            Index = 14,
            AuraId = 114,
            Name = [[Emerald]],
            Price = 3.28999999999999980364868737826816e+33,
            TrainingRate = 22.9,
            Quality = 14,
            DevGoodId = nil,
            Img = [[110859814667398]],
            ModelId = [=[game.ReplicatedStorage.Assets.Effects.Aura["14_Emerald"]]=]
        },
        [15] = {
            Index = 15,
            AuraId = 115,
            Name = [[Sapphire]],
            Price = 4.78000000000000000502155017763946496e+35,
            TrainingRate = 24.5,
            Quality = 15,
            DevGoodId = nil,
            Img = [[71778195177377]],
            ModelId = [=[game.ReplicatedStorage.Assets.Effects.Aura["15_Sapphire"]]=]
        },
        [16] = {
            Index = 16,
            AuraId = 116,
            Name = [[Ruby]],
            Price = 6.7200000000000001433956886673113481216e+37,
            TrainingRate = 26.1,
            Quality = 16,
            DevGoodId = nil,
            Img = [[82261970902739]],
            ModelId = [=[game.ReplicatedStorage.Assets.Effects.Aura["16_Ruby"]]=]
        },
        [17] = {
            Index = 17,
            AuraId = 117,
            Name = [[Sakura]],
            Price = 9.610000000000000053779986854268576464896e+39,
            TrainingRate = 27.7,
            Quality = 17,
            DevGoodId = nil,
            Img = [[84969691879555]],
            ModelId = [=[game.ReplicatedStorage.Assets.Effects.Aura["17_Sakura"]]=]
        },
        [18] = {
            Index = 18,
            AuraId = 118,
            Name = [[Sunset]],
            Price = 18,
            TrainingRate = 18.5,
            Quality = 18,
            DevGoodId = nil,
            Img = [[135431835703650]],
            ModelId = [=[game.ReplicatedStorage.Assets.Effects.Aura["18_Sunset"]]=]
        },
        [19] = {
            Index = 19,
            AuraId = 119,
            Name = [[Frost]],
            Price = 19,
            TrainingRate = 19.5,
            Quality = 19,
            DevGoodId = nil,
            Img = [[84363202598659]],
            ModelId = [=[game.ReplicatedStorage.Assets.Effects.Aura["19_Frost"]]=]
        },
        [20] = {
            Index = 20,
            AuraId = 120,
            Name = [[Inferno]],
            Price = 20,
            TrainingRate = 20.5,
            Quality = 20,
            DevGoodId = nil,
            Img = [[140502552004582]],
            ModelId = [=[game.ReplicatedStorage.Assets.Effects.Aura["20_Inferno"]]=]
        },
        [21] = {
            Index = 21,
            AuraId = 121,
            Name = [[Storm]],
            Price = 21,
            TrainingRate = 21.5,
            Quality = 21,
            DevGoodId = nil,
            Img = [[110544423490869]],
            ModelId = [=[game.ReplicatedStorage.Assets.Effects.Aura["21_Storm"]]=]
        },
        [22] = {
            Index = 22,
            AuraId = 122,
            Name = [[Solar]],
            Price = 22,
            TrainingRate = 22.5,
            Quality = 22,
            DevGoodId = nil,
            Img = [[88436670368181]],
            ModelId = [=[game.ReplicatedStorage.Assets.Effects.Aura["22_Solar"]]=]
        },
        [23] = {
            Index = 23,
            AuraId = 123,
            Name = [[Neon]],
            Price = 23,
            TrainingRate = 23.5,
            Quality = 23,
            DevGoodId = nil,
            Img = [[101523513603326]],
            ModelId = [=[game.ReplicatedStorage.Assets.Effects.Aura["23_Neon"]]=]
        },
        [24] = {
            Index = 24,
            AuraId = 124,
            Name = [[Prismatic]],
            Price = 24,
            TrainingRate = 24.5,
            Quality = 24,
            DevGoodId = nil,
            Img = [[117557339704806]],
            ModelId = [=[game.ReplicatedStorage.Assets.Effects.Aura["24_Prismatic"]]=]
        },
        [25] = {
            Index = 25,
            AuraId = 125,
            Name = [[Astral]],
            Price = 25,
            TrainingRate = 25.5,
            Quality = 25,
            DevGoodId = nil,
            Img = [[94281665600637]],
            ModelId = [=[game.ReplicatedStorage.Assets.Effects.Aura["25_Astral"]]=]
        }
    },
    ItemData = {
        [1] = {
            Index = 1,
            Id = 1,
            Name = [[Steel Nail]],
            Quality = 1,
            IconId = [[113244405937302]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_001_Nail]],
            ModelType = [[Item]]
        },
        [2] = {
            Index = 2,
            Id = 2,
            Name = [[Tablet]],
            Quality = 1,
            IconId = [[105711056874756]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_002_Pill]],
            ModelType = [[Item]]
        },
        [3] = {
            Index = 3,
            Id = 3,
            Name = [[Capsule]],
            Quality = 1,
            IconId = [[82693303214454]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_003_Capsule]],
            ModelType = [[Item]]
        },
        [4] = {
            Index = 4,
            Id = 4,
            Name = [[Dry Cell Battery]],
            Quality = 1,
            IconId = [[102504658102706]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_004_Battery01]],
            ModelType = [[Item]]
        },
        [5] = {
            Index = 5,
            Id = 5,
            Name = [[9V Battery]],
            Quality = 2,
            IconId = [[83069096807916]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_005_Battery02]],
            ModelType = [[Item]]
        },
        [6] = {
            Index = 6,
            Id = 6,
            Name = [[Crackers]],
            Quality = 2,
            IconId = [[80534536398974]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_006_Biscuit01]],
            ModelType = [[Item]]
        },
        [7] = {
            Index = 7,
            Id = 7,
            Name = [[Sandwich Crackers]],
            Quality = 2,
            IconId = [[74246671448525]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_007_Biscuit02]],
            ModelType = [[Item]]
        },
        [8] = {
            Index = 8,
            Id = 8,
            Name = [[Packaged Crackers]],
            Quality = 2,
            IconId = [[71499702430100]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_008_Biscuit03]],
            ModelType = [[Item]]
        },
        [9] = {
            Index = 9,
            Id = 9,
            Name = [[Chocolate Stick]],
            Quality = 3,
            IconId = [[122909083001205]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_009_Chocolate01]],
            ModelType = [[Item]]
        },
        [10] = {
            Index = 10,
            Id = 10,
            Name = [[Chocolate Bar]],
            Quality = 3,
            IconId = [[128658267266293]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_010_Chocolate02]],
            ModelType = [[Item]]
        },
        [11] = {
            Index = 11,
            Id = 11,
            Name = [[Chocolate Drink]],
            Quality = 3,
            IconId = [[134748387119946]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_011_Chocolate_Drink]],
            ModelType = [[Item]]
        },
        [12] = {
            Index = 12,
            Id = 12,
            Name = [[Honey Jar]],
            Quality = 3,
            IconId = [[131559815185521]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_012_Honey01]],
            ModelType = [[Item]]
        },
        [13] = {
            Index = 13,
            Id = 13,
            Name = [[Open Honey Jar]],
            Quality = 4,
            IconId = [[135406755438948]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_013_Honey02]],
            ModelType = [[Item]]
        },
        [14] = {
            Index = 14,
            Id = 14,
            Name = [[Jam Jar]],
            Quality = 4,
            IconId = [[128433990441931]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_014_Jam01]],
            ModelType = [[Item]]
        },
        [15] = {
            Index = 15,
            Id = 15,
            Name = [[Open Jam Jar]],
            Quality = 4,
            IconId = [[86357992624263]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_015_Jam02]],
            ModelType = [[Item]]
        },
        [16] = {
            Index = 16,
            Id = 16,
            Name = [[Bottled Water]],
            Quality = 4,
            IconId = [[96128137486525]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_016_Water01]],
            ModelType = [[Item]]
        },
        [17] = {
            Index = 17,
            Id = 17,
            Name = [[Water Bottle with Handle]],
            Quality = 5,
            IconId = [[131913492630514]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_017_Water02]],
            ModelType = [[Item]]
        },
        [18] = {
            Index = 18,
            Id = 18,
            Name = [[Large Water Bottle]],
            Quality = 5,
            IconId = [[119579899338192]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_018_Water03]],
            ModelType = [[Item]]
        },
        [19] = {
            Index = 19,
            Id = 19,
            Name = [[Black Canteen]],
            Quality = 5,
            IconId = [[82472089572732]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_019_Waterbottle01]],
            ModelType = [[Item]]
        },
        [20] = {
            Index = 20,
            Id = 20,
            Name = [[Military Canteen]],
            Quality = 5,
            IconId = [[104108852156434]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_020_Waterbottle02]],
            ModelType = [[Item]]
        },
        [21] = {
            Index = 21,
            Id = 21,
            Name = [[Glass Bottle]],
            Quality = 6,
            IconId = [[79005623120233]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_021_Bottle01]],
            ModelType = [[Item]]
        },
        [22] = {
            Index = 22,
            Id = 22,
            Name = [[Round Bottle]],
            Quality = 6,
            IconId = [[97611938478078]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_022_Bottle02]],
            ModelType = [[Item]]
        },
        [23] = {
            Index = 23,
            Id = 23,
            Name = [[Broken Bottle]],
            Quality = 6,
            IconId = [[81806655827798]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_023_Bottle03]],
            ModelType = [[Item]]
        },
        [24] = {
            Index = 24,
            Id = 24,
            Name = [[Square Bottle]],
            Quality = 6,
            IconId = [[105716218867716]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_024_Bottle04]],
            ModelType = [[Item]]
        },
        [25] = {
            Index = 25,
            Id = 25,
            Name = [[Beer Bottle]],
            Quality = 7,
            IconId = [[128411546772202]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_025_Bottle05]],
            ModelType = [[Item]]
        },
        [26] = {
            Index = 26,
            Id = 26,
            Name = [[Canned Peas]],
            Quality = 7,
            IconId = [[139465058617680]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_026_Can01]],
            ModelType = [[Item]]
        },
        [27] = {
            Index = 27,
            Id = 27,
            Name = [[Open Can of Peas]],
            Quality = 7,
            IconId = [[81737011057690]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_027_Can02]],
            ModelType = [[Item]]
        },
        [28] = {
            Index = 28,
            Id = 28,
            Name = [[Canned Fish]],
            Quality = 7,
            IconId = [[81445862907930]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_028_Can03]],
            ModelType = [[Item]]
        },
        [29] = {
            Index = 29,
            Id = 29,
            Name = [[Open Can of Fish]],
            Quality = 8,
            IconId = [[123098432383687]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_029_Can04]],
            ModelType = [[Item]]
        },
        [30] = {
            Index = 30,
            Id = 30,
            Name = [[Canned Beans]],
            Quality = 8,
            IconId = [[131796260838154]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_030_Can05]],
            ModelType = [[Item]]
        },
        [31] = {
            Index = 31,
            Id = 31,
            Name = [[Open Can of Beans]],
            Quality = 8,
            IconId = [[116376878683736]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_031_Can06]],
            ModelType = [[Item]]
        },
        [32] = {
            Index = 32,
            Id = 32,
            Name = [[Canned Drink]],
            Quality = 8,
            IconId = [[100558097057142]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_032_Can07]],
            ModelType = [[Item]]
        },
        [33] = {
            Index = 33,
            Id = 33,
            Name = [[Medicine Bottle]],
            Quality = 9,
            IconId = [[92332707761527]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_033_Medicine_bottle01]],
            ModelType = [[Item]]
        },
        [34] = {
            Index = 34,
            Id = 34,
            Name = [[Pill Organizer]],
            Quality = 6,
            IconId = [[108895787734224]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_034_Medicine_bottle02]],
            ModelType = [[Item]]
        },
        [35] = {
            Index = 35,
            Id = 35,
            Name = [[Syringe]],
            Quality = 7,
            IconId = [[95471681056681]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_035_Injection]],
            ModelType = [[Item]]
        },
        [36] = {
            Index = 36,
            Id = 36,
            Name = [[Auto-Injector]],
            Quality = 9,
            IconId = [[104955598295323]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_036_InjectionA]],
            ModelType = [[Item]]
        },
        [37] = {
            Index = 37,
            Id = 37,
            Name = [[Bandage Roll]],
            Quality = 10,
            IconId = [[103175883366340]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_037_First_aid_Kit_Bandage]],
            ModelType = [[Item]]
        },
        [38] = {
            Index = 38,
            Id = 38,
            Name = [[IV Bag]],
            Quality = 10,
            IconId = [[114247164745798]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_038_Lv]],
            ModelType = [[Item]]
        },
        [39] = {
            Index = 39,
            Id = 39,
            Name = [[First Aid Bag]],
            Quality = 10,
            IconId = [[86017047390182]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_039_First_aid_Kit01]],
            ModelType = [[Item]]
        },
        [40] = {
            Index = 40,
            Id = 40,
            Name = [[First Aid Kit]],
            Quality = 10,
            IconId = [[81373582816266]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_040_First_aid_Kit02]],
            ModelType = [[Item]]
        },
        [41] = {
            Index = 41,
            Id = 41,
            Name = [[Medical Case]],
            Quality = 11,
            IconId = [[132788281080826]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_041_First_aid_Kit03]],
            ModelType = [[Item]]
        },
        [42] = {
            Index = 42,
            Id = 42,
            Name = [[Cleaning Spray]],
            Quality = 11,
            IconId = [[95162444285252]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_042_Detergent]],
            ModelType = [[Item]]
        },
        [43] = {
            Index = 43,
            Id = 43,
            Name = [[Bleach]],
            Quality = 11,
            IconId = [[95953438126479]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_043_Bleach]],
            ModelType = [[Item]]
        },
        [44] = {
            Index = 44,
            Id = 44,
            Name = [[Lubricant Spray]],
            Quality = 11,
            IconId = [[112039222887887]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_044_WD40]],
            ModelType = [[Item]]
        },
        [45] = {
            Index = 45,
            Id = 45,
            Name = [[Metal Pipe]],
            Quality = 12,
            IconId = [[95377459606647]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_045_Pipe]],
            ModelType = [[Item]]
        },
        [46] = {
            Index = 46,
            Id = 46,
            Name = [[Flip-Top Lighter]],
            Quality = 12,
            IconId = [[113983796605688]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_046_Zippo]],
            ModelType = [[Item]]
        },
        [47] = {
            Index = 47,
            Id = 47,
            Name = [[Red Fuel Can]],
            Quality = 12,
            IconId = [[117157716541352]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_047_Oilcan01]],
            ModelType = [[Item]]
        },
        [48] = {
            Index = 48,
            Id = 48,
            Name = [[Green Fuel Can]],
            Quality = 12,
            IconId = [[100893051807474]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_048_Oilcan02]],
            ModelType = [[Item]]
        },
        [49] = {
            Index = 49,
            Id = 49,
            Name = [[Jerry Can]],
            Quality = 13,
            IconId = [[137999782231090]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_049_Oilcan03]],
            ModelType = [[Item]]
        },
        [50] = {
            Index = 50,
            Id = 50,
            Name = [[Smartphone]],
            Quality = 13,
            IconId = [[127007149281218]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_050_Mobilephone]],
            ModelType = [[Item]]
        },
        [51] = {
            Index = 51,
            Id = 51,
            Name = [[Stopwatch]],
            Quality = 13,
            IconId = [[85273469740405]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_051_Watch01]],
            ModelType = [[Item]]
        },
        [52] = {
            Index = 52,
            Id = 52,
            Name = [[Pet ID Tag]],
            Quality = 13,
            IconId = [[85750403977754]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_052_IdentificationTag]],
            ModelType = [[Item]]
        },
        [53] = {
            Index = 53,
            Id = 53,
            Name = [[Compass]],
            Quality = 14,
            IconId = [[87658125570749]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_053_Compass]],
            ModelType = [[Item]]
        },
        [54] = {
            Index = 54,
            Id = 54,
            Name = [[Folding Compass]],
            Quality = 14,
            IconId = [[71386503893388]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_054_CompassA]],
            ModelType = [[Item]]
        },
        [55] = {
            Index = 55,
            Id = 55,
            Name = [[Fedora]],
            Quality = 14,
            IconId = [[117660867991736]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_055_Hat]],
            ModelType = [[Item]]
        },
        [56] = {
            Index = 56,
            Id = 56,
            Name = [[Baseball Cap]],
            Quality = 14,
            IconId = [[75602786825729]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_056_Cap_A_0]],
            ModelType = [[Item]]
        },
        [57] = {
            Index = 57,
            Id = 57,
            Name = [[Gold-Framed Sunglasses]],
            Quality = 15,
            IconId = [[97494295137425]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_057_Sunglass01]],
            ModelType = [[Item]]
        },
        [58] = {
            Index = 58,
            Id = 58,
            Name = [[Sunglasses]],
            Quality = 15,
            IconId = [[121387106380169]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_058_Sunglass02]],
            ModelType = [[Item]]
        },
        [59] = {
            Index = 59,
            Id = 59,
            Name = [[Safety Goggles]],
            Quality = 15,
            IconId = [[77703154963129]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_059_Goggle]],
            ModelType = [[Item]]
        },
        [60] = {
            Index = 60,
            Id = 60,
            Name = [[Tactical Goggles]],
            Quality = 15,
            IconId = [[82745313217810]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_060_GoggleA]],
            ModelType = [[Item]]
        },
        [61] = {
            Index = 61,
            Id = 61,
            Name = [[Dust Mask]],
            Quality = 16,
            IconId = [[78702263483439]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_061_MaskA]],
            ModelType = [[Item]]
        },
        [62] = {
            Index = 62,
            Id = 62,
            Name = [[Half-Face Respirator]],
            Quality = 16,
            IconId = [[103252845267522]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_062_GasMask01]],
            ModelType = [[Item]]
        },
        [63] = {
            Index = 63,
            Id = 63,
            Name = [[Gas Mask]],
            Quality = 16,
            IconId = [[93380659059014]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_063_GasMask02]],
            ModelType = [[Item]]
        },
        [64] = {
            Index = 64,
            Id = 64,
            Name = [[Brown Boots]],
            Quality = 16,
            IconId = [[124070618735034]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_064_Boots01]],
            ModelType = [[Item]]
        },
        [65] = {
            Index = 65,
            Id = 65,
            Name = [[Black Boots]],
            Quality = 17,
            IconId = [[82229267783572]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_065_Boots02]],
            ModelType = [[Item]]
        },
        [66] = {
            Index = 66,
            Id = 66,
            Name = [[Rubber Boots]],
            Quality = 17,
            IconId = [[90764663625426]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_066_Boots03]],
            ModelType = [[Item]]
        },
        [67] = {
            Index = 67,
            Id = 67,
            Name = [[Leather Shoes]],
            Quality = 17,
            IconId = [[89592774326120]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_067_Boots04]],
            ModelType = [[Item]]
        },
        [68] = {
            Index = 68,
            Id = 68,
            Name = [[Bulletproof Vest]],
            Quality = 17,
            IconId = [[96498729983354]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_068_BulletproofJacket01]],
            ModelType = [[Item]]
        },
        [69] = {
            Index = 69,
            Id = 69,
            Name = [[Heavy Armor Vest]],
            Quality = 18,
            IconId = [[137402232463633]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_069_BulletproofJacket02]],
            ModelType = [[Item]]
        },
        [70] = {
            Index = 70,
            Id = 70,
            Name = [[Helmet with Goggles]],
            Quality = 15,
            IconId = [[79717469784936]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_070_Helmet01]],
            ModelType = [[Item]]
        },
        [71] = {
            Index = 71,
            Id = 71,
            Name = [[Combat Helmet]],
            Quality = 16,
            IconId = [[86646811474956]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_071_Helmet02]],
            ModelType = [[Item]]
        },
        [72] = {
            Index = 72,
            Id = 72,
            Name = [[Riot Helmet]],
            Quality = 16,
            IconId = [[128217347353354]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_072_Helmet03]],
            ModelType = [[Item]]
        },
        [73] = {
            Index = 73,
            Id = 73,
            Name = [[Tactical Helmet]],
            Quality = 16,
            IconId = [[126321668579357]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_073_Helmet04]],
            ModelType = [[Item]]
        },
        [74] = {
            Index = 74,
            Id = 74,
            Name = [[Multi-Pocket Backpack]],
            Quality = 16,
            IconId = [[98351529529203]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_074_Bag01]],
            ModelType = [[Item]]
        },
        [75] = {
            Index = 75,
            Id = 75,
            Name = [[Tactical Backpack]],
            Quality = 17,
            IconId = [[81048668172712]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_075_Bag02]],
            ModelType = [[Item]]
        },
        [76] = {
            Index = 76,
            Id = 76,
            Name = [[Large Tactical Backpack]],
            Quality = 17,
            IconId = [[127615544859575]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_076_Bag03]],
            ModelType = [[Item]]
        },
        [77] = {
            Index = 77,
            Id = 77,
            Name = [[Toolbox]],
            Quality = 17,
            IconId = [[70656304136373]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_077_Box01]],
            ModelType = [[Item]]
        },
        [78] = {
            Index = 78,
            Id = 78,
            Name = [[Supply Case]],
            Quality = 17,
            IconId = [[134424174805013]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_078_Box02]],
            ModelType = [[Item]]
        },
        [79] = {
            Index = 79,
            Id = 79,
            Name = [[Equipment Case]],
            Quality = 18,
            IconId = [[127255485663084]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_079_Box03]],
            ModelType = [[Item]]
        },
        [80] = {
            Index = 80,
            Id = 80,
            Name = [[Cooking Pot]],
            Quality = 18,
            IconId = [[134027683373658]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_080_Pot01]],
            ModelType = [[Item]]
        },
        [81] = {
            Index = 81,
            Id = 81,
            Name = [[Red Barrel]],
            Quality = 18,
            IconId = [[112447657334137]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_081_Drum01]],
            ModelType = [[Item]]
        },
        [82] = {
            Index = 82,
            Id = 82,
            Name = [[Blue Barrel]],
            Quality = 18,
            IconId = [[104595008892706]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_082_Drum02]],
            ModelType = [[Item]]
        },
        [83] = {
            Index = 83,
            Id = 83,
            Name = [[Sealed Drum]],
            Quality = 19,
            IconId = [[82759045606098]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_083_Drum03]],
            ModelType = [[Item]]
        },
        [84] = {
            Index = 84,
            Id = 84,
            Name = [[Blue Steel Drum]],
            Quality = 19,
            IconId = [[105620837789519]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_084_Drum04]],
            ModelType = [[Item]]
        },
        [85] = {
            Index = 85,
            Id = 85,
            Name = [[Hazardous Materials Drum]],
            Quality = 19,
            IconId = [[111024567754480]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_085_Drum05]],
            ModelType = [[Item]]
        },
        [86] = {
            Index = 86,
            Id = 86,
            Name = [[Propane Tank]],
            Quality = 19,
            IconId = [[137153989969007]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_086_Propane]],
            ModelType = [[Item]]
        },
        [87] = {
            Index = 87,
            Id = 87,
            Name = [[Rope]],
            Quality = 20,
            IconId = [[74496996195913]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_087_RopeA]],
            ModelType = [[Item]]
        },
        [88] = {
            Index = 88,
            Id = 88,
            Name = [[Wire Coil]],
            Quality = 20,
            IconId = [[132785860315163]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_088_Wire]],
            ModelType = [[Item]]
        },
        [89] = {
            Index = 89,
            Id = 89,
            Name = [[Walkie-Talkie]],
            Quality = 20,
            IconId = [[117198962948319]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_089_Walkie_Talkie]],
            ModelType = [[Item]]
        },
        [90] = {
            Index = 90,
            Id = 90,
            Name = [[Field Radio]],
            Quality = 20,
            IconId = [[124449160476895]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_090_Walkie_TalkieA]],
            ModelType = [[Item]]
        },
        [91] = {
            Index = 91,
            Id = 91,
            Name = [[Flashlight]],
            Quality = 21,
            IconId = [[125887863438527]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_091_Flashlight01]],
            ModelType = [[Item]]
        },
        [92] = {
            Index = 92,
            Id = 92,
            Name = [[Headlamp]],
            Quality = 21,
            IconId = [[137692564728429]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_092_HeadLantern]],
            ModelType = [[Item]]
        },
        [93] = {
            Index = 93,
            Id = 93,
            Name = [[Lantern]],
            Quality = 21,
            IconId = [[82350951870220]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_093_Lantern]],
            ModelType = [[Item]]
        },
        [94] = {
            Index = 94,
            Id = 94,
            Name = [[Telescope]],
            Quality = 21,
            IconId = [[133019385929561]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_094_Telescope01]],
            ModelType = [[Item]]
        },
        [95] = {
            Index = 95,
            Id = 95,
            Name = [[Binoculars]],
            Quality = 22,
            IconId = [[82714807302588]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_095_Telescope02]],
            ModelType = [[Item]]
        },
        [96] = {
            Index = 96,
            Id = 96,
            Name = [[Claw Hammer]],
            Quality = 22,
            IconId = [[120409278538446]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_096_Hammer01]],
            ModelType = [[Item]]
        },
        [97] = {
            Index = 97,
            Id = 97,
            Name = [[Hammer]],
            Quality = 22,
            IconId = [[136303201068741]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_097_Hammer02]],
            ModelType = [[Item]]
        },
        [98] = {
            Index = 98,
            Id = 98,
            Name = [[Sledgehammer]],
            Quality = 22,
            IconId = [[76724781858184]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_098_Hammer03]],
            ModelType = [[Item]]
        },
        [99] = {
            Index = 99,
            Id = 99,
            Name = [[Adjustable Wrench]],
            Quality = 23,
            IconId = [[120125979830927]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_099_Wrench01]],
            ModelType = [[Item]]
        },
        [100] = {
            Index = 100,
            Id = 100,
            Name = [[Pipe Wrench]],
            Quality = 23,
            IconId = [[86921870572603]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_100_Wrench02]],
            ModelType = [[Item]]
        },
        [101] = {
            Index = 101,
            Id = 101,
            Name = [[Crowbar]],
            Quality = 23,
            IconId = [[126355990231048]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_101_Wrench03]],
            ModelType = [[Item]]
        },
        [102] = {
            Index = 102,
            Id = 102,
            Name = [[Entrenching Shovel]],
            Quality = 23,
            IconId = [[72326444062448]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_102_Shovel01]],
            ModelType = [[Item]]
        },
        [103] = {
            Index = 103,
            Id = 103,
            Name = [[Shovel]],
            Quality = 24,
            IconId = [[72257499044823]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_103_Shovel02]],
            ModelType = [[Item]]
        },
        [104] = {
            Index = 104,
            Id = 104,
            Name = [[Pickaxe]],
            Quality = 24,
            IconId = [[74695865349139]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_104_Pickax]],
            ModelType = [[Item]]
        },
        [105] = {
            Index = 105,
            Id = 105,
            Name = [[Croquet Mallet]],
            Quality = 24,
            IconId = [[98358488442985]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_105_GolfClub]],
            ModelType = [[Item]]
        },
        [106] = {
            Index = 106,
            Id = 106,
            Name = [[Hockey Stick]],
            Quality = 24,
            IconId = [[113636295509693]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_106_Hockey]],
            ModelType = [[Item]]
        },
        [107] = {
            Index = 107,
            Id = 107,
            Name = [[Wooden Baseball Bat]],
            Quality = 25,
            IconId = [[114047124407739]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_107_Bat01]],
            ModelType = [[Item]]
        },
        [108] = {
            Index = 108,
            Id = 108,
            Name = [[Metal Baseball Bat]],
            Quality = 25,
            IconId = [[95771403493939]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_108_Bat02]],
            ModelType = [[Item]]
        },
        [109] = {
            Index = 109,
            Id = 109,
            Name = [[Spiked Metal Bat]],
            Quality = 25,
            IconId = [[140393673870516]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_109_Bat03]],
            ModelType = [[Item]]
        },
        [110] = {
            Index = 110,
            Id = 110,
            Name = [[Nailed Wooden Bat]],
            Quality = 25,
            IconId = [[123109322631502]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_110_Bat04]],
            ModelType = [[Item]]
        },
        [111] = {
            Index = 111,
            Id = 111,
            Name = [[Chainsaw]],
            Quality = 26,
            IconId = [[98614967981417]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_111_ElectricSaw]],
            ModelType = [[Item]]
        },
        [112] = {
            Index = 112,
            Id = 112,
            Name = [[Hatchet]],
            Quality = 26,
            IconId = [[127369769981706]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_112_Ax01]],
            ModelType = [[Item]]
        },
        [113] = {
            Index = 113,
            Id = 113,
            Name = [[Chopping Axe]],
            Quality = 26,
            IconId = [[134574393827781]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_113_Ax02]],
            ModelType = [[Item]]
        },
        [114] = {
            Index = 114,
            Id = 114,
            Name = [[Double-Bladed Battle Axe]],
            Quality = 26,
            IconId = [[130258203281991]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_114_Ax03]],
            ModelType = [[Item]]
        },
        [115] = {
            Index = 115,
            Id = 115,
            Name = [[Knife]],
            Quality = 27,
            IconId = [[93953823085119]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_115_Knife01]],
            ModelType = [[Item]]
        },
        [116] = {
            Index = 116,
            Id = 116,
            Name = [[Hunting Knife]],
            Quality = 27,
            IconId = [[109802560542166]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_116_Knife02]],
            ModelType = [[Item]]
        },
        [117] = {
            Index = 117,
            Id = 117,
            Name = [[Knuckle Knife]],
            Quality = 27,
            IconId = [[130989494782889]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_117_Knife03]],
            ModelType = [[Item]]
        },
        [118] = {
            Index = 118,
            Id = 118,
            Name = [[Karambit]],
            Quality = 27,
            IconId = [[129408716253336]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_118_Knife04]],
            ModelType = [[Item]]
        },
        [119] = {
            Index = 119,
            Id = 119,
            Name = [[Cleaver]],
            Quality = 28,
            IconId = [[127772866805590]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_119_Knife05]],
            ModelType = [[Item]]
        },
        [120] = {
            Index = 120,
            Id = 120,
            Name = [[Machete]],
            Quality = 28,
            IconId = [[91938109188463]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_120_Knife06]],
            ModelType = [[Item]]
        },
        [121] = {
            Index = 121,
            Id = 121,
            Name = [[Spiked Mace]],
            Quality = 28,
            IconId = [[85077262752129]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_121_Ironmace]],
            ModelType = [[Item]]
        },
        [122] = {
            Index = 122,
            Id = 122,
            Name = [[Dynamite Stick]],
            Quality = 28,
            IconId = [[140335958193244]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_122_Dynamite01]],
            ModelType = [[Item]]
        },
        [123] = {
            Index = 123,
            Id = 123,
            Name = [[Dynamite Bundle]],
            Quality = 29,
            IconId = [[86732012145983]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_123_Dynamite02]],
            ModelType = [[Item]]
        },
        [124] = {
            Index = 124,
            Id = 124,
            Name = [[Dynamite with Detonator]],
            Quality = 29,
            IconId = [[78044122276865]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_124_Dynamite03]],
            ModelType = [[Item]]
        },
        [125] = {
            Index = 125,
            Id = 125,
            Name = [[Round Grenade]],
            Quality = 29,
            IconId = [[114974638199136]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_125_Grenade01]],
            ModelType = [[Item]]
        },
        [126] = {
            Index = 126,
            Id = 126,
            Name = [[Canister Grenade]],
            Quality = 29,
            IconId = [[83652207307759]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_126_Grenade02]],
            ModelType = [[Item]]
        },
        [127] = {
            Index = 127,
            Id = 127,
            Name = [[Energy Grenade]],
            Quality = 30,
            IconId = [[131787091355052]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_127_Grenade03]],
            ModelType = [[Item]]
        },
        [128] = {
            Index = 128,
            Id = 128,
            Name = [[Land Mine]],
            Quality = 30,
            IconId = [[99348381699835]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_128_Mine]],
            ModelType = [[Item]]
        },
        [129] = {
            Index = 129,
            Id = 129,
            Name = [[Bear Trap]],
            Quality = 30,
            IconId = [[75412160560516]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_129_Trap]],
            ModelType = [[Item]]
        },
        [130] = {
            Index = 130,
            Id = 130,
            Name = [[Pistol Round]],
            Quality = 30,
            IconId = [[105475505052937]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_130_Bullet01]],
            ModelType = [[Item]]
        },
        [131] = {
            Index = 131,
            Id = 131,
            Name = [[Pistol Ammo]],
            Quality = 31,
            IconId = [[125484119033793]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_131_Bullet02]],
            ModelType = [[Item]]
        },
        [132] = {
            Index = 132,
            Id = 132,
            Name = [[Ammo Crate]],
            Quality = 31,
            IconId = [[140608831780254]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_132_Bullet03]],
            ModelType = [[Item]]
        },
        [133] = {
            Index = 133,
            Id = 133,
            Name = [[Boxed Ammo]],
            Quality = 31,
            IconId = [[124177358025481]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_133_Bullet04]],
            ModelType = [[Item]]
        },
        [134] = {
            Index = 134,
            Id = 134,
            Name = [[Straight Magazine]],
            Quality = 31,
            IconId = [[129385390119523]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_134_Bullet05]],
            ModelType = [[Item]]
        },
        [135] = {
            Index = 135,
            Id = 135,
            Name = [[Curved Magazine]],
            Quality = 32,
            IconId = [[84940520003035]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_135_Bullet06]],
            ModelType = [[Item]]
        },
        [136] = {
            Index = 136,
            Id = 136,
            Name = [[Pellet Box]],
            Quality = 32,
            IconId = [[90031364711610]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_136_Bullet07]],
            ModelType = [[Item]]
        },
        [137] = {
            Index = 137,
            Id = 137,
            Name = [[Military Ammo Can]],
            Quality = 32,
            IconId = [[84418341821320]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_137_Cartridge]],
            ModelType = [[Item]]
        },
        [138] = {
            Index = 138,
            Id = 138,
            Name = [[Revolver]],
            Quality = 32,
            IconId = [[130255705800444]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_138_Gun01]],
            ModelType = [[Item]]
        },
        [139] = {
            Index = 139,
            Id = 139,
            Name = [[Single-Shot Pistol]],
            Quality = 33,
            IconId = [[123568265278671]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_139_Gun02]],
            ModelType = [[Item]]
        },
        [140] = {
            Index = 140,
            Id = 140,
            Name = [[Short-Barreled Assault Rifle]],
            Quality = 33,
            IconId = [[75689117044416]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_140_Rifle01]],
            ModelType = [[Item]]
        },
        [141] = {
            Index = 141,
            Id = 141,
            Name = [[Folding-Stock Assault Rifle]],
            Quality = 33,
            IconId = [[92309488435591]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_141_Rifle02]],
            ModelType = [[Item]]
        },
        [142] = {
            Index = 142,
            Id = 142,
            Name = [[Wooden-Stock Assault Rifle]],
            Quality = 33,
            IconId = [[106319308889290]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_142_Rifle03]],
            ModelType = [[Item]]
        },
        [143] = {
            Index = 143,
            Id = 143,
            Name = [[Grenade Launcher]],
            Quality = 34,
            IconId = [[123120949699520]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_143_Rifle04]],
            ModelType = [[Item]]
        },
        [144] = {
            Index = 144,
            Id = 144,
            Name = [[Sniper Rifle]],
            Quality = 34,
            IconId = [[111674856010497]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_144_Rifle05]],
            ModelType = [[Item]]
        },
        [145] = {
            Index = 145,
            Id = 145,
            Name = [[Submachine Gun]],
            Quality = 34,
            IconId = [[118080816505555]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_145_MachineGun01]],
            ModelType = [[Item]]
        },
        [146] = {
            Index = 146,
            Id = 146,
            Name = [[Suppressed Submachine Gun]],
            Quality = 34,
            IconId = [[105021574817966]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_146_MachineGun02]],
            ModelType = [[Item]]
        },
        [147] = {
            Index = 147,
            Id = 147,
            Name = [[Compact Submachine Gun]],
            Quality = 35,
            IconId = [[72690180103558]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_147_MachineGun03]],
            ModelType = [[Item]]
        },
        [148] = {
            Index = 148,
            Id = 148,
            Name = [[Wooden-Stock Submachine Gun]],
            Quality = 35,
            IconId = [[94914272618995]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_148_MachineGun04]],
            ModelType = [[Item]]
        }
    },
    AreaConfig = {
        [1] = {
            Index = 1,
            AreaId = 1,
            NormalRefreshCount = 80,
            LuckRefreshCount = 3,
            LuckRefreshRate = {
                [1] = 2.5,
                [2] = 3,
            }
        },
        [2] = {
            Index = 2,
            AreaId = 2,
            NormalRefreshCount = 4,
            LuckRefreshCount = 3,
            LuckRefreshRate = {
                [1] = 2.5,
                [2] = 3,
            }
        },
        [3] = {
            Index = 3,
            AreaId = 3,
            NormalRefreshCount = 4,
            LuckRefreshCount = 3,
            LuckRefreshRate = {
                [1] = 2.5,
                [2] = 3,
            }
        },
        [4] = {
            Index = 4,
            AreaId = 4,
            NormalRefreshCount = 4,
            LuckRefreshCount = 3,
            LuckRefreshRate = {
                [1] = 2.5,
                [2] = 3,
            }
        },
        [5] = {
            Index = 5,
            AreaId = 5,
            NormalRefreshCount = 4,
            LuckRefreshCount = 3,
            LuckRefreshRate = {
                [1] = 2.5,
                [2] = 3,
            }
        },
        [6] = {
            Index = 6,
            AreaId = 6,
            NormalRefreshCount = 4,
            LuckRefreshCount = 3,
            LuckRefreshRate = {
                [1] = 2.5,
                [2] = 3,
            }
        },
        [7] = {
            Index = 7,
            AreaId = 7,
            NormalRefreshCount = 4,
            LuckRefreshCount = 3,
            LuckRefreshRate = {
                [1] = 2.5,
                [2] = 3,
            }
        },
        [8] = {
            Index = 8,
            AreaId = 8,
            NormalRefreshCount = 4,
            LuckRefreshCount = 3,
            LuckRefreshRate = {
                [1] = 2.5,
                [2] = 3,
            }
        },
        [9] = {
            Index = 9,
            AreaId = 9,
            NormalRefreshCount = 4,
            LuckRefreshCount = 3,
            LuckRefreshRate = {
                [1] = 2.5,
                [2] = 3,
            }
        },
        [10] = {
            Index = 10,
            AreaId = 10,
            NormalRefreshCount = 4,
            LuckRefreshCount = 3,
            LuckRefreshRate = {
                [1] = 2.5,
                [2] = 3,
            }
        },
        [11] = {
            Index = 11,
            AreaId = 11,
            NormalRefreshCount = 4,
            LuckRefreshCount = 3,
            LuckRefreshRate = {
                [1] = 2.5,
                [2] = 3,
            }
        },
        [12] = {
            Index = 12,
            AreaId = 12,
            NormalRefreshCount = 4,
            LuckRefreshCount = 3,
            LuckRefreshRate = {
                [1] = 2.5,
                [2] = 3,
            }
        },
        [13] = {
            Index = 13,
            AreaId = 13,
            NormalRefreshCount = 4,
            LuckRefreshCount = 3,
            LuckRefreshRate = {
                [1] = 2.5,
                [2] = 3,
            }
        },
        [14] = {
            Index = 14,
            AreaId = 14,
            NormalRefreshCount = 4,
            LuckRefreshCount = 3,
            LuckRefreshRate = {
                [1] = 2.5,
                [2] = 3,
            }
        },
        [15] = {
            Index = 15,
            AreaId = 15,
            NormalRefreshCount = 4,
            LuckRefreshCount = 3,
            LuckRefreshRate = {
                [1] = 2.5,
                [2] = 3,
            }
        },
        [16] = {
            Index = 16,
            AreaId = 16,
            NormalRefreshCount = 4,
            LuckRefreshCount = 3,
            LuckRefreshRate = {
                [1] = 2.5,
                [2] = 3,
            }
        },
        [17] = {
            Index = 17,
            AreaId = 17,
            NormalRefreshCount = 4,
            LuckRefreshCount = 3,
            LuckRefreshRate = {
                [1] = 2.5,
                [2] = 3,
            }
        },
        [18] = {
            Index = 18,
            AreaId = 18,
            NormalRefreshCount = 4,
            LuckRefreshCount = 3,
            LuckRefreshRate = {
                [1] = 2.5,
                [2] = 3,
            }
        },
        [19] = {
            Index = 19,
            AreaId = 19,
            NormalRefreshCount = 4,
            LuckRefreshCount = 3,
            LuckRefreshRate = {
                [1] = 2.5,
                [2] = 3,
            }
        },
        [20] = {
            Index = 20,
            AreaId = 20,
            NormalRefreshCount = 4,
            LuckRefreshCount = 3,
            LuckRefreshRate = {
                [1] = 2.5,
                [2] = 3,
            }
        },
        [21] = {
            Index = 21,
            AreaId = 21,
            NormalRefreshCount = 4,
            LuckRefreshCount = 3,
            LuckRefreshRate = {
                [1] = 2.5,
                [2] = 3,
            }
        },
        [22] = {
            Index = 22,
            AreaId = 22,
            NormalRefreshCount = 4,
            LuckRefreshCount = 3,
            LuckRefreshRate = {
                [1] = 2.5,
                [2] = 3,
            }
        },
        [23] = {
            Index = 23,
            AreaId = 23,
            NormalRefreshCount = 4,
            LuckRefreshCount = 3,
            LuckRefreshRate = {
                [1] = 2.5,
                [2] = 3,
            }
        },
        [24] = {
            Index = 24,
            AreaId = 24,
            NormalRefreshCount = 4,
            LuckRefreshCount = 3,
            LuckRefreshRate = {
                [1] = 2.5,
                [2] = 3,
            }
        },
        [25] = {
            Index = 25,
            AreaId = 25,
            NormalRefreshCount = 4,
            LuckRefreshCount = 3,
            LuckRefreshRate = {
                [1] = 2.5,
                [2] = 3,
            }
        },
        [26] = {
            Index = 26,
            AreaId = 26,
            NormalRefreshCount = 4,
            LuckRefreshCount = 3,
            LuckRefreshRate = {
                [1] = 2.5,
                [2] = 3,
            }
        },
        [27] = {
            Index = 27,
            AreaId = 27,
            NormalRefreshCount = 4,
            LuckRefreshCount = 3,
            LuckRefreshRate = {
                [1] = 2.5,
                [2] = 3,
            }
        },
        [28] = {
            Index = 28,
            AreaId = 28,
            NormalRefreshCount = 4,
            LuckRefreshCount = 3,
            LuckRefreshRate = {
                [1] = 2.5,
                [2] = 3,
            }
        },
        [29] = {
            Index = 29,
            AreaId = 29,
            NormalRefreshCount = 4,
            LuckRefreshCount = 3,
            LuckRefreshRate = {
                [1] = 2.5,
                [2] = 3,
            }
        },
        [30] = {
            Index = 30,
            AreaId = 30,
            NormalRefreshCount = 4,
            LuckRefreshCount = 3,
            LuckRefreshRate = {
                [1] = 2.5,
                [2] = 3,
            }
        },
        [31] = {
            Index = 31,
            AreaId = 31,
            NormalRefreshCount = 4,
            LuckRefreshCount = 3,
            LuckRefreshRate = {
                [1] = 2.5,
                [2] = 3,
            }
        },
        [32] = {
            Index = 32,
            AreaId = 32,
            NormalRefreshCount = 4,
            LuckRefreshCount = 3,
            LuckRefreshRate = {
                [1] = 2.5,
                [2] = 3,
            }
        },
        [33] = {
            Index = 33,
            AreaId = 33,
            NormalRefreshCount = 4,
            LuckRefreshCount = 3,
            LuckRefreshRate = {
                [1] = 2.5,
                [2] = 3,
            }
        },
        [34] = {
            Index = 34,
            AreaId = 34,
            NormalRefreshCount = 4,
            LuckRefreshCount = 3,
            LuckRefreshRate = {
                [1] = 2.5,
                [2] = 3,
            }
        },
        [35] = {
            Index = 35,
            AreaId = 35,
            NormalRefreshCount = 4,
            LuckRefreshCount = 3,
            LuckRefreshRate = {
                [1] = 2.5,
                [2] = 3,
            }
        },
        [36] = {
            Index = 36,
            AreaId = 36,
            NormalRefreshCount = 4,
            LuckRefreshCount = 3,
            LuckRefreshRate = {
                [1] = 2.5,
                [2] = 3,
            }
        },
        [37] = {
            Index = 37,
            AreaId = 37,
            NormalRefreshCount = 4,
            LuckRefreshCount = 3,
            LuckRefreshRate = {
                [1] = 2.5,
                [2] = 3,
            }
        },
        [38] = {
            Index = 38,
            AreaId = 38,
            NormalRefreshCount = 4,
            LuckRefreshCount = 3,
            LuckRefreshRate = {
                [1] = 2.5,
                [2] = 3,
            }
        },
        [39] = {
            Index = 39,
            AreaId = 39,
            NormalRefreshCount = 4,
            LuckRefreshCount = 3,
            LuckRefreshRate = {
                [1] = 2.5,
                [2] = 3,
            }
        },
        [40] = {
            Index = 40,
            AreaId = 40,
            NormalRefreshCount = 4,
            LuckRefreshCount = 3,
            LuckRefreshRate = {
                [1] = 2.5,
                [2] = 3,
            }
        },
        [41] = {
            Index = 41,
            AreaId = 41,
            NormalRefreshCount = 4,
            LuckRefreshCount = 3,
            LuckRefreshRate = {
                [1] = 2.5,
                [2] = 3,
            }
        },
        [42] = {
            Index = 42,
            AreaId = 42,
            NormalRefreshCount = 4,
            LuckRefreshCount = 3,
            LuckRefreshRate = {
                [1] = 2.5,
                [2] = 3,
            }
        },
        [43] = {
            Index = 43,
            AreaId = 43,
            NormalRefreshCount = 4,
            LuckRefreshCount = 3,
            LuckRefreshRate = {
                [1] = 2.5,
                [2] = 3,
            }
        },
        [44] = {
            Index = 44,
            AreaId = 44,
            NormalRefreshCount = 4,
            LuckRefreshCount = 3,
            LuckRefreshRate = {
                [1] = 2.5,
                [2] = 3,
            }
        },
        [45] = {
            Index = 45,
            AreaId = 45,
            NormalRefreshCount = 4,
            LuckRefreshCount = 3,
            LuckRefreshRate = {
                [1] = 2.5,
                [2] = 3,
            }
        },
        [46] = {
            Index = 46,
            AreaId = 46,
            NormalRefreshCount = 4,
            LuckRefreshCount = 3,
            LuckRefreshRate = {
                [1] = 2.5,
                [2] = 3,
            }
        },
        [47] = {
            Index = 47,
            AreaId = 47,
            NormalRefreshCount = 4,
            LuckRefreshCount = 3,
            LuckRefreshRate = {
                [1] = 2.5,
                [2] = 3,
            }
        },
        [48] = {
            Index = 48,
            AreaId = 48,
            NormalRefreshCount = 4,
            LuckRefreshCount = 3,
            LuckRefreshRate = {
                [1] = 2.5,
                [2] = 3,
            }
        },
        [49] = {
            Index = 49,
            AreaId = 49,
            NormalRefreshCount = 4,
            LuckRefreshCount = 3,
            LuckRefreshRate = {
                [1] = 2.5,
                [2] = 3,
            }
        },
        [50] = {
            Index = 50,
            AreaId = 50,
            NormalRefreshCount = 4,
            LuckRefreshCount = 3,
            LuckRefreshRate = {
                [1] = 2.5,
                [2] = 3,
            }
        },
        [51] = {
            Index = 51,
            AreaId = 51,
            NormalRefreshCount = 4,
            LuckRefreshCount = 3,
            LuckRefreshRate = {
                [1] = 2.5,
                [2] = 3,
            }
        },
        [52] = {
            Index = 52,
            AreaId = 52,
            NormalRefreshCount = 4,
            LuckRefreshCount = 3,
            LuckRefreshRate = {
                [1] = 2.5,
                [2] = 3,
            }
        }
    },
    LevelConfig = {
        ["World1.Level_1"] = {
            LevelKey = [[World1.Level_1]],
            StoneHP = 2
        },
        ["World1.Level_2"] = {
            LevelKey = [[World1.Level_2]],
            StoneHP = 44800
        },
        ["World1.Level_3"] = {
            LevelKey = [[World1.Level_3]],
            StoneHP = 4.46e+6
        },
        ["World1.Level_4"] = {
            LevelKey = [[World1.Level_4]],
            StoneHP = 9.61e+7
        },
        ["World1.Level_5"] = {
            LevelKey = [[World1.Level_5]],
            StoneHP = 1.58e+9
        },
        ["World1.Level_6"] = {
            LevelKey = [[World1.Level_6]],
            StoneHP = 1.38e+10
        },
        ["World1.Level_7"] = {
            LevelKey = [[World1.Level_7]],
            StoneHP = 1.15e+11
        },
        ["World1.Level_8"] = {
            LevelKey = [[World1.Level_8]],
            StoneHP = 1.95e+12
        },
        ["World1.Level_9"] = {
            LevelKey = [[World1.Level_9]],
            StoneHP = 2.19e+13
        },
        ["World1.Level_10"] = {
            LevelKey = [[World1.Level_10]],
            StoneHP = 8.54e+13
        },
        ["World1.Level_11"] = {
            LevelKey = [[World1.Level_11]],
            StoneHP = 2.06e+14
        },
        ["World1.Level_12"] = {
            LevelKey = [[World1.Level_12]],
            StoneHP = 1.09e+15
        },
        ["World1.Level_13"] = {
            LevelKey = [[World1.Level_13]],
            StoneHP = 9.24e+15
        },
        ["World2.Level_14"] = {
            LevelKey = [[World2.Level_14]],
            StoneHP = 7.59e+16
        },
        ["World2.Level_15"] = {
            LevelKey = [[World2.Level_15]],
            StoneHP = 8.97e+17
        },
        ["World2.Level_16"] = {
            LevelKey = [[World2.Level_16]],
            StoneHP = 1.26e+19
        },
        ["World2.Level_17"] = {
            LevelKey = [[World2.Level_17]],
            StoneHP = 1.83e+20
        },
        ["World2.Level_18"] = {
            LevelKey = [[World2.Level_18]],
            StoneHP = 7.25e+20
        },
        ["World2.Level_19"] = {
            LevelKey = [[World2.Level_19]],
            StoneHP = 4.830000000000000524288e+21
        },
        ["World2.Level_20"] = {
            LevelKey = [[World2.Level_20]],
            StoneHP = 4.5099999999999996854272e+22
        },
        ["World2.Level_21"] = {
            LevelKey = [[World2.Level_21]],
            StoneHP = 2.33999999999999995805696e+23
        },
        ["World2.Level_22"] = {
            LevelKey = [[World2.Level_22]],
            StoneHP = 1.270000000000000037748736e+24
        },
        ["World2.Level_23"] = {
            LevelKey = [[World2.Level_23]],
            StoneHP = 6.75000000000000002097152e+24
        },
        ["World2.Level_24"] = {
            LevelKey = [[World2.Level_24]],
            StoneHP = 4.739999999999999823839232e+25
        },
        ["World2.Level_25"] = {
            LevelKey = [[World2.Level_25]],
            StoneHP = 3.3499999999999997558915072e+26
        },
        ["World2.Level_26"] = {
            LevelKey = [[World2.Level_26]],
            StoneHP = 2.23000000000000003238002688e+27
        },
        ["World3.Level_27"] = {
            LevelKey = [[World3.Level_27]],
            StoneHP = 5.529999999999999828838842368e+27
        },
        ["World3.Level_28"] = {
            LevelKey = [[World3.Level_28]],
            StoneHP = 1.3699999999999999055040086016e+28
        },
        ["World3.Level_29"] = {
            LevelKey = [[World3.Level_29]],
            StoneHP = 4.0199999999999996520942272512e+28
        },
        ["World3.Level_30"] = {
            LevelKey = [[World3.Level_30]],
            StoneHP = 8.8099999999999998064513253376e+28
        },
        ["World3.Level_31"] = {
            LevelKey = [[World3.Level_31]],
            StoneHP = 2.39000000000000007848650080256e+29
        },
        ["World3.Level_32"] = {
            LevelKey = [[World3.Level_32]],
            StoneHP = 7.1899999999999995265402535936e+29
        },
        ["World3.Level_33"] = {
            LevelKey = [[World3.Level_33]],
            StoneHP = 2.249999999999999974371661709312e+30
        },
        ["World3.Level_34"] = {
            LevelKey = [[World3.Level_34]],
            StoneHP = 6.650000000000000230748997025792e+30
        },
        ["World3.Level_35"] = {
            LevelKey = [[World3.Level_35]],
            StoneHP = 1.6700000000000000697990704529408e+31
        },
        ["World3.Level_36"] = {
            LevelKey = [[World3.Level_36]],
            StoneHP = 3.5900000000000000179055575957504e+31
        },
        ["World3.Level_37"] = {
            LevelKey = [[World3.Level_37]],
            StoneHP = 8.62000000000000055984093396992e+31
        },
        ["World3.Level_38"] = {
            LevelKey = [[World3.Level_38]],
            StoneHP = 2.01000000000000013848433777442816e+32
        },
        ["World3.Level_39"] = {
            LevelKey = [[World3.Level_39]],
            StoneHP = 4.0500000000000000101639864188928e+32
        }
    },
    GachaQualityData = {
        [1] = {
            Quality = 1,
            Weight = 3.03e+7,
            MinProbability = 0.05
        },
        [2] = {
            Quality = 2,
            Weight = 6.06e+6,
            MinProbability = 0.05
        },
        [3] = {
            Quality = 3,
            Weight = 1.212e+6,
            MinProbability = 0.05
        },
        [4] = {
            Quality = 4,
            Weight = 242928,
            MinProbability = 0.05
        },
        [5] = {
            Quality = 5,
            Weight = 29151,
            MinProbability = 0.05
        },
        [6] = {
            Quality = 6,
            Weight = 3498,
            MinProbability = 0.05
        },
        [7] = {
            Quality = 7,
            Weight = 318,
            MinProbability = 0.05
        },
        [8] = {
            Quality = 8,
            Weight = 29,
            MinProbability = 0
        },
        [9] = {
            Quality = 9,
            Weight = 3,
            MinProbability = 0
        }
    }
}