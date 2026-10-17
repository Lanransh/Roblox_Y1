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
            UnlockCount = 10,
            TrainingRate = 0.25
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
            Count = 5,
            Time = 10
        },
        ToyPriceRateRange = {
            [1] = 0.5,
            [2] = 1.5,
        },
        ToyCandidateCount = 6,
        ToyItemsPerStage = 3,
        ToyRefreshRatio = 0.333333333333333,
        ToyLuckyCount = 4
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
            Name = [[WornWoodenPickaxe]],
            Price = 0,
            TrainingRate = 1,
            DevGoodId = nil,
            Img = [[99853650045862]],
            ModelId = [=[game.ReplicatedStorage.Assets.BlockMeshs.Tools["01WornWoodenPickaxe"]]=]
        },
        [2] = {
            Index = 2,
            ToolId = 102,
            Name = [[HeavyWoodenHammer]],
            Price = 25,
            TrainingRate = 39,
            DevGoodId = nil,
            Img = [[116225665846279]],
            ModelId = [=[game.ReplicatedStorage.Assets.BlockMeshs.Tools["02HeavyWoodenHammer"]]=]
        },
        [3] = {
            Index = 3,
            ToolId = 103,
            Name = [[CrudeSilverPickaxe]],
            Price = 450,
            TrainingRate = 450,
            DevGoodId = nil,
            Img = [[136956773152573]],
            ModelId = [=[game.ReplicatedStorage.Assets.BlockMeshs.Tools["03CrudeSilverPickaxe"]]=]
        },
        [4] = {
            Index = 4,
            ToolId = 104,
            Name = [[CrudeSilverHammer]],
            Price = 4375,
            TrainingRate = 3282,
            DevGoodId = nil,
            Img = [[97553870039023]],
            ModelId = [=[game.ReplicatedStorage.Assets.BlockMeshs.Tools["04CrudeSilverHammer"]]=]
        },
        [5] = {
            Index = 5,
            ToolId = 105,
            Name = [[ReinforcedIronPickaxe]],
            Price = 35000,
            TrainingRate = 19000,
            DevGoodId = nil,
            Img = [[118090700645855]],
            ModelId = [=[game.ReplicatedStorage.Assets.BlockMeshs.Tools["05ReinforcedIronPickaxe"]]=]
        },
        [6] = {
            Index = 6,
            ToolId = 106,
            Name = [[ReinforcedIronHammer]],
            Price = 253000,
            TrainingRate = 95500,
            DevGoodId = nil,
            Img = [[138508042210191]],
            ModelId = [=[game.ReplicatedStorage.Assets.BlockMeshs.Tools["06ReinforcedIronHammer"]]=]
        },
        [7] = {
            Index = 7,
            ToolId = 107,
            Name = [[FineSteelMiningPickaxe]],
            Price = 1.89e+6,
            TrainingRate = 442000,
            DevGoodId = nil,
            Img = [[78371166922896]],
            ModelId = [=[game.ReplicatedStorage.Assets.BlockMeshs.Tools["07FineSteelMiningPickaxe"]]=]
        },
        [8] = {
            Index = 8,
            ToolId = 108,
            Name = [[FineSteelMaul]],
            Price = 1.22e+7,
            TrainingRate = 1.93e+6,
            DevGoodId = nil,
            Img = [[132966760008713]],
            ModelId = [=[game.ReplicatedStorage.Assets.BlockMeshs.Tools["08FineSteelMaul"]]=]
        },
        [9] = {
            Index = 9,
            ToolId = 109,
            Name = [[BrassMechanicalPickaxe]],
            Price = 7.62e+7,
            TrainingRate = 8.1e+6,
            DevGoodId = nil,
            Img = [[133927008310944]],
            ModelId = [=[game.ReplicatedStorage.Assets.BlockMeshs.Tools["09BrassMechanicalPickaxe"]]=]
        },
        [10] = {
            Index = 10,
            ToolId = 110,
            Name = [[BrassMechanicalHammer]],
            Price = 4.65e+8,
            TrainingRate = 3.31e+7,
            DevGoodId = nil,
            Img = [[98415179467911]],
            ModelId = [=[game.ReplicatedStorage.Assets.BlockMeshs.Tools["10BrassMechanicalHammer"]]=]
        },
        [11] = {
            Index = 11,
            ToolId = 111,
            Name = [[ObsidianBattlePickaxe]],
            Price = 2.78e+9,
            TrainingRate = 1.33e+8,
            DevGoodId = nil,
            Img = [[79276409476682]],
            ModelId = [=[game.ReplicatedStorage.Assets.BlockMeshs.Tools["11ObsidianBattlePickaxe"]]=]
        },
        [12] = {
            Index = 12,
            ToolId = 112,
            Name = [[ObsidianGreatHammer]],
            Price = 1.64e+10,
            TrainingRate = 5.25e+8,
            DevGoodId = nil,
            Img = [[86184044773576]],
            ModelId = [=[game.ReplicatedStorage.Assets.BlockMeshs.Tools["12ObsidianGreatHammer"]]=]
        },
        [13] = {
            Index = 13,
            ToolId = 113,
            Name = [[EmeraldGuardianPickaxe]],
            Price = 9.55e+10,
            TrainingRate = 2.05e+9,
            DevGoodId = nil,
            Img = [[85964386896273]],
            ModelId = [=[game.ReplicatedStorage.Assets.BlockMeshs.Tools["13EmeraldGuardianPickaxe"]]=]
        },
        [14] = {
            Index = 14,
            ToolId = 114,
            Name = [[EmeraldGuardianHammer]],
            Price = 5.49e+11,
            TrainingRate = 7.99e+9,
            DevGoodId = nil,
            Img = [[121813166897471]],
            ModelId = [=[game.ReplicatedStorage.Assets.BlockMeshs.Tools["14EmeraldGuardianHammer"]]=]
        },
        [15] = {
            Index = 15,
            ToolId = 115,
            Name = [[RedCrystalForgePickaxe]],
            Price = 3.13e+12,
            TrainingRate = 3.1e+10,
            DevGoodId = nil,
            Img = [[107669574278873]],
            ModelId = [=[game.ReplicatedStorage.Assets.BlockMeshs.Tools["15RedCrystalForgePickaxe"]]=]
        },
        [16] = {
            Index = 16,
            ToolId = 116,
            Name = [[RedCrystalForgeHammer]],
            Price = 1.77e+13,
            TrainingRate = 1.2e+11,
            DevGoodId = nil,
            Img = [[98723580431394]],
            ModelId = [=[game.ReplicatedStorage.Assets.BlockMeshs.Tools["16RedCrystalForgeHammer"]]=]
        },
        [17] = {
            Index = 17,
            ToolId = 117,
            Name = [[IceBlueStarCrystalPickaxe]],
            Price = 9.93e+13,
            TrainingRate = 4.62e+11,
            DevGoodId = nil,
            Img = [[126241505230536]],
            ModelId = [=[game.ReplicatedStorage.Assets.BlockMeshs.Tools["17IceBlueStarCrystalPickaxe"]]=]
        },
        [18] = {
            Index = 18,
            ToolId = 118,
            Name = [[IceBlueStarCrystalHammer]],
            Price = 5.54e+14,
            TrainingRate = 1.78e+12,
            DevGoodId = nil,
            Img = [[78092021290844]],
            ModelId = [=[game.ReplicatedStorage.Assets.BlockMeshs.Tools["18IceBlueStarCrystalHammer"]]=]
        },
        [19] = {
            Index = 19,
            ToolId = 119,
            Name = [[GildedCrownPickaxe]],
            Price = 3.07e+15,
            TrainingRate = 6.9e+12,
            DevGoodId = nil,
            Img = [[138731887343821]],
            ModelId = [=[game.ReplicatedStorage.Assets.BlockMeshs.Tools["19GildedCrownPickaxe"]]=]
        },
        [20] = {
            Index = 20,
            ToolId = 120,
            Name = [[GildedCrownGreatHammer]],
            Price = 1.69e+16,
            TrainingRate = 2.67e+13,
            DevGoodId = nil,
            Img = [[113127149166000]],
            ModelId = [=[game.ReplicatedStorage.Assets.BlockMeshs.Tools["20GildedCrownGreatHammer"]]=]
        },
        [21] = {
            Index = 21,
            ToolId = 121,
            Name = [[DeepSeaAnchorHammer]],
            Price = 8.45e+16,
            TrainingRate = 8.01e+13,
            DevGoodId = nil,
            Img = [[96227746339558]],
            ModelId = [=[game.ReplicatedStorage.Assets.BlockMeshs.Tools["21DeepSeaAnchorHammer"]]=]
        },
        [22] = {
            Index = 22,
            ToolId = 122,
            Name = [[DeepSeaHookPickaxe]],
            Price = 4.23e+17,
            TrainingRate = 2.4e+14,
            DevGoodId = nil,
            Img = [[134869410236813]],
            ModelId = [=[game.ReplicatedStorage.Assets.BlockMeshs.Tools["22DeepSeaHookPickaxe"]]=]
        },
        [23] = {
            Index = 23,
            ToolId = 123,
            Name = [[DesertColossusBoneHammer]],
            Price = 2.12e+18,
            TrainingRate = 7.2e+14,
            DevGoodId = nil,
            Img = [[121268665996978]],
            ModelId = [=[game.ReplicatedStorage.Assets.BlockMeshs.Tools["23DesertColossusBoneHammer"]]=]
        },
        [24] = {
            Index = 24,
            ToolId = 124,
            Name = [[SandKingFangPickaxe]],
            Price = 1.06e+19,
            TrainingRate = 2.16e+15,
            DevGoodId = nil,
            Img = [[89972874141623]],
            ModelId = [=[game.ReplicatedStorage.Assets.BlockMeshs.Tools["24SandKingFangPickaxe"]]=]
        },
        [25] = {
            Index = 25,
            ToolId = 125,
            Name = [[AmethystStarRingHammer]],
            Price = 5.3e+19,
            TrainingRate = 6.48e+15,
            DevGoodId = nil,
            Img = [[88597169256101]],
            ModelId = [=[game.ReplicatedStorage.Assets.BlockMeshs.Tools["25AmethystStarRingHammer"]]=]
        },
        [26] = {
            Index = 26,
            ToolId = 126,
            Name = [[AmethystStarRingPickaxe]],
            Price = 2.65e+20,
            TrainingRate = 1.94e+16,
            DevGoodId = nil,
            Img = [[85002040484327]],
            ModelId = [=[game.ReplicatedStorage.Assets.BlockMeshs.Tools["26AmethystStarRingPickaxe"]]=]
        },
        [27] = {
            Index = 27,
            ToolId = 127,
            Name = [[HolyCrownPickaxe]],
            Price = 1,
            TrainingRate = 1,
            DevGoodId = nil,
            Img = [[122188029381990]],
            ModelId = [=[game.ReplicatedStorage.Assets.AITools["01-holy-crown-pickaxe"]]=]
        },
        [28] = {
            Index = 28,
            ToolId = 128,
            Name = [[HolyCrownHammer]],
            Price = 2,
            TrainingRate = 2,
            DevGoodId = nil,
            Img = [[111918297845046]],
            ModelId = [=[game.ReplicatedStorage.Assets.AITools["02-holy-crown-hammer"]]=]
        },
        [29] = {
            Index = 29,
            ToolId = 129,
            Name = [[DragonFlamePickaxe]],
            Price = 3,
            TrainingRate = 3,
            DevGoodId = nil,
            Img = [[131796875082030]],
            ModelId = [=[game.ReplicatedStorage.Assets.AITools["03-dragon-flame-pickaxe"]]=]
        },
        [30] = {
            Index = 30,
            ToolId = 130,
            Name = [[DragonFlameHammer]],
            Price = 4,
            TrainingRate = 4,
            DevGoodId = nil,
            Img = [[135291300946209]],
            ModelId = [=[game.ReplicatedStorage.Assets.AITools["04-dragon-flame-hammer"]]=]
        },
        [31] = {
            Index = 31,
            ToolId = 131,
            Name = [[ThunderPickaxe]],
            Price = 5,
            TrainingRate = 5,
            DevGoodId = nil,
            Img = [[135059340240171]],
            ModelId = [=[game.ReplicatedStorage.Assets.AITools["05-thunder-pickaxe"]]=]
        },
        [32] = {
            Index = 32,
            ToolId = 132,
            Name = [[ThunderHammer]],
            Price = 6,
            TrainingRate = 6,
            DevGoodId = nil,
            Img = [[138711849822666]],
            ModelId = [=[game.ReplicatedStorage.Assets.AITools["06-thunder-hammer"]]=]
        },
        [33] = {
            Index = 33,
            ToolId = 133,
            Name = [[EasternCloudsPickaxe]],
            Price = 7,
            TrainingRate = 7,
            DevGoodId = nil,
            Img = [[103077185243615]],
            ModelId = [=[game.ReplicatedStorage.Assets.AITools["07-eastern-clouds-pickaxe"]]=]
        },
        [34] = {
            Index = 34,
            ToolId = 134,
            Name = [[EasternCloudsHammer]],
            Price = 8,
            TrainingRate = 8,
            DevGoodId = nil,
            Img = [[119720961929827]],
            ModelId = [=[game.ReplicatedStorage.Assets.AITools["08-eastern-clouds-hammer"]]=]
        },
        [35] = {
            Index = 35,
            ToolId = 135,
            Name = [[ForestGuardianPickaxe]],
            Price = 9,
            TrainingRate = 9,
            DevGoodId = nil,
            Img = [[104288707111612]],
            ModelId = [=[game.ReplicatedStorage.Assets.AITools["09-forest-guardian-pickaxe"]]=]
        },
        [36] = {
            Index = 36,
            ToolId = 136,
            Name = [[ForestGuardianHammer]],
            Price = 10,
            TrainingRate = 10,
            DevGoodId = nil,
            Img = [[93955605202823]],
            ModelId = [=[game.ReplicatedStorage.Assets.AITools["10-forest-guardian-hammer"]]=]
        },
        [37] = {
            Index = 37,
            ToolId = 137,
            Name = [[IceCrystalPickaxe]],
            Price = 11,
            TrainingRate = 11,
            DevGoodId = nil,
            Img = [[94920898798936]],
            ModelId = [=[game.ReplicatedStorage.Assets.AITools["11-ice-crystal-pickaxe"]]=]
        },
        [38] = {
            Index = 38,
            ToolId = 138,
            Name = [[IceCrystalHammer]],
            Price = 12,
            TrainingRate = 12,
            DevGoodId = nil,
            Img = [[98900726428144]],
            ModelId = [=[game.ReplicatedStorage.Assets.AITools["12-ice-crystal-hammer"]]=]
        },
        [39] = {
            Index = 39,
            ToolId = 139,
            Name = [[ShadowDemonPickaxe]],
            Price = 13,
            TrainingRate = 13,
            DevGoodId = nil,
            Img = [[97673689505764]],
            ModelId = [=[game.ReplicatedStorage.Assets.AITools["13-shadow-demon-pickaxe"]]=]
        },
        [40] = {
            Index = 40,
            ToolId = 140,
            Name = [[ShadowDemonHammer]],
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
            Price = 1,
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
            Price = 2,
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
            Price = 3,
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
            Price = 4,
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
            Price = 5,
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
            Price = 6,
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
            Price = 7,
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
            Price = 8,
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
            Price = 9,
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
            Price = 10,
            TrainingRate = 10.5,
            Quality = 10,
            DevGoodId = nil,
            Img = [[126721700266409]],
            ModelId = [=[game.ReplicatedStorage.Assets.Effects.Aura["10_Epic"]]=]
        },
        [11] = {
            Index = 11,
            AuraId = 111,
            Name = [[Ocean]],
            Price = 11,
            TrainingRate = 11.5,
            Quality = 11,
            DevGoodId = nil,
            Img = [[92711027530571]],
            ModelId = [=[game.ReplicatedStorage.Assets.Effects.Aura["11_Ocean"]]=]
        },
        [12] = {
            Index = 12,
            AuraId = 112,
            Name = [[Lunar]],
            Price = 12,
            TrainingRate = 12.5,
            Quality = 12,
            DevGoodId = nil,
            Img = [[140129159429440]],
            ModelId = [=[game.ReplicatedStorage.Assets.Effects.Aura["12_Lunar"]]=]
        },
        [13] = {
            Index = 13,
            AuraId = 113,
            Name = [[Legendary]],
            Price = 13,
            TrainingRate = 13.5,
            Quality = 13,
            DevGoodId = nil,
            Img = [[125903398380406]],
            ModelId = [=[game.ReplicatedStorage.Assets.Effects.Aura["13_Legendary"]]=]
        },
        [14] = {
            Index = 14,
            AuraId = 114,
            Name = [[Emerald]],
            Price = 14,
            TrainingRate = 14.5,
            Quality = 14,
            DevGoodId = nil,
            Img = [[110859814667398]],
            ModelId = [=[game.ReplicatedStorage.Assets.Effects.Aura["14_Emerald"]]=]
        },
        [15] = {
            Index = 15,
            AuraId = 115,
            Name = [[Sapphire]],
            Price = 15,
            TrainingRate = 15.5,
            Quality = 15,
            DevGoodId = nil,
            Img = [[71778195177377]],
            ModelId = [=[game.ReplicatedStorage.Assets.Effects.Aura["15_Sapphire"]]=]
        },
        [16] = {
            Index = 16,
            AuraId = 116,
            Name = [[Ruby]],
            Price = 16,
            TrainingRate = 16.5,
            Quality = 16,
            DevGoodId = nil,
            Img = [[82261970902739]],
            ModelId = [=[game.ReplicatedStorage.Assets.Effects.Aura["16_Ruby"]]=]
        },
        [17] = {
            Index = 17,
            AuraId = 117,
            Name = [[Sakura]],
            Price = 17,
            TrainingRate = 17.5,
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
            Name = [[打火机]],
            Quality = 1,
            IconId = [[113244405937302]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_001_Nail]],
            ModelType = [[Item]]
        },
        [2] = {
            Index = 2,
            Id = 2,
            Name = [[矿泉水]],
            Quality = 1,
            IconId = [[105711056874756]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_002_Pill]],
            ModelType = [[Item]]
        },
        [3] = {
            Index = 3,
            Id = 3,
            Name = [[纯净水]],
            Quality = 1,
            IconId = [[82693303214454]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_003_Capsule]],
            ModelType = [[Item]]
        },
        [4] = {
            Index = 4,
            Id = 4,
            Name = [[苏打水]],
            Quality = 1,
            IconId = [[102504658102706]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_004_Battery01]],
            ModelType = [[Item]]
        },
        [5] = {
            Index = 5,
            Id = 5,
            Name = [[水桶]],
            Quality = 2,
            IconId = [[83069096807916]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_005_Battery02]],
            ModelType = [[Item]]
        },
        [6] = {
            Index = 6,
            Id = 6,
            Name = [[玻璃瓶]],
            Quality = 2,
            IconId = [[80534536398974]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_006_Biscuit01]],
            ModelType = [[Item]]
        },
        [7] = {
            Index = 7,
            Id = 7,
            Name = [[啤酒瓶]],
            Quality = 2,
            IconId = [[74246671448525]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_007_Biscuit02]],
            ModelType = [[Item]]
        },
        [8] = {
            Index = 8,
            Id = 8,
            Name = [[红酒瓶]],
            Quality = 2,
            IconId = [[71499702430100]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_008_Biscuit03]],
            ModelType = [[Item]]
        },
        [9] = {
            Index = 9,
            Id = 9,
            Name = [[香槟瓶]],
            Quality = 3,
            IconId = [[122909083001205]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_009_Chocolate01]],
            ModelType = [[Item]]
        },
        [10] = {
            Index = 10,
            Id = 10,
            Name = [[收藏酒瓶]],
            Quality = 3,
            IconId = [[128658267266293]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_010_Chocolate02]],
            ModelType = [[Item]]
        },
        [11] = {
            Index = 11,
            Id = 11,
            Name = [[钢钉]],
            Quality = 3,
            IconId = [[134748387119946]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_011_Chocolate_Drink]],
            ModelType = [[Item]]
        },
        [12] = {
            Index = 12,
            Id = 12,
            Name = [[药片]],
            Quality = 3,
            IconId = [[131559815185521]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_012_Honey01]],
            ModelType = [[Item]]
        },
        [13] = {
            Index = 13,
            Id = 13,
            Name = [[曲奇]],
            Quality = 4,
            IconId = [[135406755438948]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_013_Honey02]],
            ModelType = [[Item]]
        },
        [14] = {
            Index = 14,
            Id = 14,
            Name = [[苏打饼]],
            Quality = 4,
            IconId = [[128433990441931]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_014_Jam01]],
            ModelType = [[Item]]
        },
        [15] = {
            Index = 15,
            Id = 15,
            Name = [[夹心饼]],
            Quality = 4,
            IconId = [[86357992624263]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_015_Jam02]],
            ModelType = [[Item]]
        },
        [16] = {
            Index = 16,
            Id = 16,
            Name = [[黑巧克力]],
            Quality = 4,
            IconId = [[96128137486525]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_016_Water01]],
            ModelType = [[Item]]
        },
        [17] = {
            Index = 17,
            Id = 17,
            Name = [[牛奶巧克力]],
            Quality = 5,
            IconId = [[131913492630514]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_017_Water02]],
            ModelType = [[Item]]
        },
        [18] = {
            Index = 18,
            Id = 18,
            Name = [[可可饮料]],
            Quality = 5,
            IconId = [[119579899338192]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_018_Water03]],
            ModelType = [[Item]]
        },
        [19] = {
            Index = 19,
            Id = 19,
            Name = [[蜂蜜]],
            Quality = 5,
            IconId = [[82472089572732]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_019_Waterbottle01]],
            ModelType = [[Item]]
        },
        [20] = {
            Index = 20,
            Id = 20,
            Name = [[野蜂蜜]],
            Quality = 5,
            IconId = [[104108852156434]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_020_Waterbottle02]],
            ModelType = [[Item]]
        },
        [21] = {
            Index = 21,
            Id = 21,
            Name = [[草莓酱]],
            Quality = 6,
            IconId = [[79005623120233]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_021_Bottle01]],
            ModelType = [[Item]]
        },
        [22] = {
            Index = 22,
            Id = 22,
            Name = [[蓝莓酱]],
            Quality = 6,
            IconId = [[97611938478078]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_022_Bottle02]],
            ModelType = [[Item]]
        },
        [23] = {
            Index = 23,
            Id = 23,
            Name = [[肉罐头]],
            Quality = 6,
            IconId = [[81806655827798]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_023_Bottle03]],
            ModelType = [[Item]]
        },
        [24] = {
            Index = 24,
            Id = 24,
            Name = [[鱼罐头]],
            Quality = 6,
            IconId = [[105716218867716]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_024_Bottle04]],
            ModelType = [[Item]]
        },
        [25] = {
            Index = 25,
            Id = 25,
            Name = [[水果罐头]],
            Quality = 7,
            IconId = [[128411546772202]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_025_Bottle05]],
            ModelType = [[Item]]
        },
        [26] = {
            Index = 26,
            Id = 26,
            Name = [[午餐肉]],
            Quality = 7,
            IconId = [[139465058617680]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_026_Can01]],
            ModelType = [[Item]]
        },
        [27] = {
            Index = 27,
            Id = 27,
            Name = [[豆子罐头]],
            Quality = 7,
            IconId = [[81737011057690]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_027_Can02]],
            ModelType = [[Item]]
        },
        [28] = {
            Index = 28,
            Id = 28,
            Name = [[军粮罐头]],
            Quality = 7,
            IconId = [[81445862907930]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_028_Can03]],
            ModelType = [[Item]]
        },
        [29] = {
            Index = 29,
            Id = 29,
            Name = [[高级罐头]],
            Quality = 8,
            IconId = [[123098432383687]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_029_Can04]],
            ModelType = [[Item]]
        },
        [30] = {
            Index = 30,
            Id = 30,
            Name = [[清洁剂]],
            Quality = 8,
            IconId = [[131796260838154]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_030_Can05]],
            ModelType = [[Item]]
        },
        [31] = {
            Index = 31,
            Id = 31,
            Name = [[漂白水]],
            Quality = 8,
            IconId = [[116376878683736]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_031_Can06]],
            ModelType = [[Item]]
        },
        [32] = {
            Index = 32,
            Id = 32,
            Name = [[润滑油]],
            Quality = 8,
            IconId = [[100558097057142]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_032_Can07]],
            ModelType = [[Item]]
        },
        [33] = {
            Index = 33,
            Id = 33,
            Name = [[小油壶]],
            Quality = 9,
            IconId = [[92332707761527]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_033_Medicine_bottle01]],
            ModelType = [[Item]]
        },
        [34] = {
            Index = 34,
            Id = 34,
            Name = [[运动水壶]],
            Quality = 6,
            IconId = [[108895787734224]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_034_Medicine_bottle02]],
            ModelType = [[Item]]
        },
        [35] = {
            Index = 35,
            Id = 35,
            Name = [[军用水壶]],
            Quality = 7,
            IconId = [[95471681056681]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_035_Injection]],
            ModelType = [[Item]]
        },
        [36] = {
            Index = 36,
            Id = 36,
            Name = [[机油壶]],
            Quality = 9,
            IconId = [[104955598295323]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_036_InjectionA]],
            ModelType = [[Item]]
        },
        [37] = {
            Index = 37,
            Id = 37,
            Name = [[燃油罐]],
            Quality = 10,
            IconId = [[103175883366340]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_037_First_aid_Kit_Bandage]],
            ModelType = [[Item]]
        },
        [38] = {
            Index = 38,
            Id = 38,
            Name = [[礼帽]],
            Quality = 10,
            IconId = [[114247164745798]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_038_Lv]],
            ModelType = [[Item]]
        },
        [39] = {
            Index = 39,
            Id = 39,
            Name = [[棒球帽]],
            Quality = 10,
            IconId = [[86017047390182]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_039_First_aid_Kit01]],
            ModelType = [[Item]]
        },
        [40] = {
            Index = 40,
            Id = 40,
            Name = [[墨镜]],
            Quality = 10,
            IconId = [[81373582816266]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_040_First_aid_Kit02]],
            ModelType = [[Item]]
        },
        [41] = {
            Index = 41,
            Id = 41,
            Name = [[太阳镜]],
            Quality = 11,
            IconId = [[132788281080826]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_041_First_aid_Kit03]],
            ModelType = [[Item]]
        },
        [42] = {
            Index = 42,
            Id = 42,
            Name = [[护目镜]],
            Quality = 11,
            IconId = [[95162444285252]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_042_Detergent]],
            ModelType = [[Item]]
        },
        [43] = {
            Index = 43,
            Id = 43,
            Name = [[战术风镜]],
            Quality = 11,
            IconId = [[95953438126479]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_043_Bleach]],
            ModelType = [[Item]]
        },
        [44] = {
            Index = 44,
            Id = 44,
            Name = [[口罩]],
            Quality = 11,
            IconId = [[112039222887887]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_044_WD40]],
            ModelType = [[Item]]
        },
        [45] = {
            Index = 45,
            Id = 45,
            Name = [[防毒面具]],
            Quality = 12,
            IconId = [[95377459606647]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_045_Pipe]],
            ModelType = [[Item]]
        },
        [46] = {
            Index = 46,
            Id = 46,
            Name = [[战术面具]],
            Quality = 12,
            IconId = [[113983796605688]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_046_Zippo]],
            ModelType = [[Item]]
        },
        [47] = {
            Index = 47,
            Id = 47,
            Name = [[皮靴]],
            Quality = 12,
            IconId = [[117157716541352]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_047_Oilcan01]],
            ModelType = [[Item]]
        },
        [48] = {
            Index = 48,
            Id = 48,
            Name = [[雨靴]],
            Quality = 12,
            IconId = [[100893051807474]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_048_Oilcan02]],
            ModelType = [[Item]]
        },
        [49] = {
            Index = 49,
            Id = 49,
            Name = [[登山靴]],
            Quality = 13,
            IconId = [[137999782231090]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_049_Oilcan03]],
            ModelType = [[Item]]
        },
        [50] = {
            Index = 50,
            Id = 50,
            Name = [[军靴]],
            Quality = 13,
            IconId = [[127007149281218]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_050_Mobilephone]],
            ModelType = [[Item]]
        },
        [51] = {
            Index = 51,
            Id = 51,
            Name = [[防弹背心]],
            Quality = 13,
            IconId = [[85273469740405]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_051_Watch01]],
            ModelType = [[Item]]
        },
        [52] = {
            Index = 52,
            Id = 52,
            Name = [[重型护甲]],
            Quality = 13,
            IconId = [[85750403977754]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_052_IdentificationTag]],
            ModelType = [[Item]]
        },
        [53] = {
            Index = 53,
            Id = 53,
            Name = [[工地头盔]],
            Quality = 14,
            IconId = [[87658125570749]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_053_Compass]],
            ModelType = [[Item]]
        },
        [54] = {
            Index = 54,
            Id = 54,
            Name = [[骑行头盔]],
            Quality = 14,
            IconId = [[71386503893388]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_054_CompassA]],
            ModelType = [[Item]]
        },
        [55] = {
            Index = 55,
            Id = 55,
            Name = [[防暴头盔]],
            Quality = 14,
            IconId = [[117660867991736]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_055_Hat]],
            ModelType = [[Item]]
        },
        [56] = {
            Index = 56,
            Id = 56,
            Name = [[战术头盔]],
            Quality = 14,
            IconId = [[75602786825729]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_056_Cap_A_0]],
            ModelType = [[Item]]
        },
        [57] = {
            Index = 57,
            Id = 57,
            Name = [[小背包]],
            Quality = 15,
            IconId = [[97494295137425]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_057_Sunglass01]],
            ModelType = [[Item]]
        },
        [58] = {
            Index = 58,
            Id = 58,
            Name = [[登山包]],
            Quality = 15,
            IconId = [[121387106380169]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_058_Sunglass02]],
            ModelType = [[Item]]
        },
        [59] = {
            Index = 59,
            Id = 59,
            Name = [[军用背包]],
            Quality = 15,
            IconId = [[77703154963129]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_059_Goggle]],
            ModelType = [[Item]]
        },
        [60] = {
            Index = 60,
            Id = 60,
            Name = [[铁锅]],
            Quality = 15,
            IconId = [[82745313217810]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_060_GoggleA]],
            ModelType = [[Item]]
        },
        [61] = {
            Index = 61,
            Id = 61,
            Name = [[木锤]],
            Quality = 16,
            IconId = [[78702263483439]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_061_MaskA]],
            ModelType = [[Item]]
        },
        [62] = {
            Index = 62,
            Id = 62,
            Name = [[铁锤]],
            Quality = 16,
            IconId = [[103252845267522]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_062_GasMask01]],
            ModelType = [[Item]]
        },
        [63] = {
            Index = 63,
            Id = 63,
            Name = [[大锤]],
            Quality = 16,
            IconId = [[93380659059014]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_063_GasMask02]],
            ModelType = [[Item]]
        },
        [64] = {
            Index = 64,
            Id = 64,
            Name = [[扳手]],
            Quality = 16,
            IconId = [[124070618735034]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_064_Boots01]],
            ModelType = [[Item]]
        },
        [65] = {
            Index = 65,
            Id = 65,
            Name = [[活动扳手]],
            Quality = 17,
            IconId = [[82229267783572]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_065_Boots02]],
            ModelType = [[Item]]
        },
        [66] = {
            Index = 66,
            Id = 66,
            Name = [[管钳]],
            Quality = 17,
            IconId = [[90764663625426]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_066_Boots03]],
            ModelType = [[Item]]
        },
        [67] = {
            Index = 67,
            Id = 67,
            Name = [[工兵铲]],
            Quality = 17,
            IconId = [[89592774326120]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_067_Boots04]],
            ModelType = [[Item]]
        },
        [68] = {
            Index = 68,
            Id = 68,
            Name = [[铁锹]],
            Quality = 17,
            IconId = [[96498729983354]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_068_BulletproofJacket01]],
            ModelType = [[Item]]
        },
        [69] = {
            Index = 69,
            Id = 69,
            Name = [[十字镐]],
            Quality = 18,
            IconId = [[137402232463633]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_069_BulletproofJacket02]],
            ModelType = [[Item]]
        },
        [70] = {
            Index = 70,
            Id = 70,
            Name = [[胶囊]],
            Quality = 15,
            IconId = [[79717469784936]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_070_Helmet01]],
            ModelType = [[Item]]
        },
        [71] = {
            Index = 71,
            Id = 71,
            Name = [[干电池]],
            Quality = 16,
            IconId = [[86646811474956]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_071_Helmet02]],
            ModelType = [[Item]]
        },
        [72] = {
            Index = 72,
            Id = 72,
            Name = [[强力电池]],
            Quality = 16,
            IconId = [[128217347353354]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_072_Helmet03]],
            ModelType = [[Item]]
        },
        [73] = {
            Index = 73,
            Id = 73,
            Name = [[药瓶]],
            Quality = 16,
            IconId = [[126321668579357]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_073_Helmet04]],
            ModelType = [[Item]]
        },
        [74] = {
            Index = 74,
            Id = 74,
            Name = [[急救药瓶]],
            Quality = 16,
            IconId = [[98351529529203]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_074_Bag01]],
            ModelType = [[Item]]
        },
        [75] = {
            Index = 75,
            Id = 75,
            Name = [[注射器]],
            Quality = 17,
            IconId = [[81048668172712]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_075_Bag02]],
            ModelType = [[Item]]
        },
        [76] = {
            Index = 76,
            Id = 76,
            Name = [[强化针]],
            Quality = 17,
            IconId = [[127615544859575]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_076_Bag03]],
            ModelType = [[Item]]
        },
        [77] = {
            Index = 77,
            Id = 77,
            Name = [[医用绷带]],
            Quality = 17,
            IconId = [[70656304136373]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_077_Box01]],
            ModelType = [[Item]]
        },
        [78] = {
            Index = 78,
            Id = 78,
            Name = [[绿色徽章]],
            Quality = 17,
            IconId = [[134424174805013]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_078_Box02]],
            ModelType = [[Item]]
        },
        [79] = {
            Index = 79,
            Id = 79,
            Name = [[急救包]],
            Quality = 18,
            IconId = [[127255485663084]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_079_Box03]],
            ModelType = [[Item]]
        },
        [80] = {
            Index = 80,
            Id = 80,
            Name = [[医疗箱]],
            Quality = 18,
            IconId = [[134027683373658]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_080_Pot01]],
            ModelType = [[Item]]
        },
        [81] = {
            Index = 81,
            Id = 81,
            Name = [[高级医疗箱]],
            Quality = 18,
            IconId = [[112447657334137]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_081_Drum01]],
            ModelType = [[Item]]
        },
        [82] = {
            Index = 82,
            Id = 82,
            Name = [[钢管]],
            Quality = 18,
            IconId = [[104595008892706]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_082_Drum02]],
            ModelType = [[Item]]
        },
        [83] = {
            Index = 83,
            Id = 83,
            Name = [[手机]],
            Quality = 19,
            IconId = [[82759045606098]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_083_Drum03]],
            ModelType = [[Item]]
        },
        [84] = {
            Index = 84,
            Id = 84,
            Name = [[手表]],
            Quality = 19,
            IconId = [[105620837789519]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_084_Drum04]],
            ModelType = [[Item]]
        },
        [85] = {
            Index = 85,
            Id = 85,
            Name = [[身份牌]],
            Quality = 19,
            IconId = [[111024567754480]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_085_Drum05]],
            ModelType = [[Item]]
        },
        [86] = {
            Index = 86,
            Id = 86,
            Name = [[指南针]],
            Quality = 19,
            IconId = [[137153989969007]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_086_Propane]],
            ModelType = [[Item]]
        },
        [87] = {
            Index = 87,
            Id = 87,
            Name = [[军用罗盘]],
            Quality = 20,
            IconId = [[74496996195913]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_087_RopeA]],
            ModelType = [[Item]]
        },
        [88] = {
            Index = 88,
            Id = 88,
            Name = [[木箱]],
            Quality = 20,
            IconId = [[132785860315163]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_088_Wire]],
            ModelType = [[Item]]
        },
        [89] = {
            Index = 89,
            Id = 89,
            Name = [[工具箱]],
            Quality = 20,
            IconId = [[117198962948319]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_089_Walkie_Talkie]],
            ModelType = [[Item]]
        },
        [90] = {
            Index = 90,
            Id = 90,
            Name = [[补给箱]],
            Quality = 20,
            IconId = [[124449160476895]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_090_Walkie_TalkieA]],
            ModelType = [[Item]]
        },
        [91] = {
            Index = 91,
            Id = 91,
            Name = [[油桶]],
            Quality = 21,
            IconId = [[125887863438527]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_091_Flashlight01]],
            ModelType = [[Item]]
        },
        [92] = {
            Index = 92,
            Id = 92,
            Name = [[储物桶]],
            Quality = 21,
            IconId = [[137692564728429]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_092_HeadLantern]],
            ModelType = [[Item]]
        },
        [93] = {
            Index = 93,
            Id = 93,
            Name = [[密封桶]],
            Quality = 21,
            IconId = [[82350951870220]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_093_Lantern]],
            ModelType = [[Item]]
        },
        [94] = {
            Index = 94,
            Id = 94,
            Name = [[大铁桶]],
            Quality = 21,
            IconId = [[133019385929561]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_094_Telescope01]],
            ModelType = [[Item]]
        },
        [95] = {
            Index = 95,
            Id = 95,
            Name = [[煤气罐]],
            Quality = 22,
            IconId = [[82714807302588]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_095_Telescope02]],
            ModelType = [[Item]]
        },
        [96] = {
            Index = 96,
            Id = 96,
            Name = [[粗绳]],
            Quality = 22,
            IconId = [[120409278538446]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_096_Hammer01]],
            ModelType = [[Item]]
        },
        [97] = {
            Index = 97,
            Id = 97,
            Name = [[电线]],
            Quality = 22,
            IconId = [[136303201068741]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_097_Hammer02]],
            ModelType = [[Item]]
        },
        [98] = {
            Index = 98,
            Id = 98,
            Name = [[对讲机]],
            Quality = 22,
            IconId = [[76724781858184]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_098_Hammer03]],
            ModelType = [[Item]]
        },
        [99] = {
            Index = 99,
            Id = 99,
            Name = [[军用电台]],
            Quality = 23,
            IconId = [[120125979830927]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_099_Wrench01]],
            ModelType = [[Item]]
        },
        [100] = {
            Index = 100,
            Id = 100,
            Name = [[手电筒]],
            Quality = 23,
            IconId = [[86921870572603]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_100_Wrench02]],
            ModelType = [[Item]]
        },
        [101] = {
            Index = 101,
            Id = 101,
            Name = [[头灯]],
            Quality = 23,
            IconId = [[126355990231048]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_101_Wrench03]],
            ModelType = [[Item]]
        },
        [102] = {
            Index = 102,
            Id = 102,
            Name = [[提灯]],
            Quality = 23,
            IconId = [[72326444062448]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_102_Shovel01]],
            ModelType = [[Item]]
        },
        [103] = {
            Index = 103,
            Id = 103,
            Name = [[望远镜]],
            Quality = 24,
            IconId = [[72257499044823]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_103_Shovel02]],
            ModelType = [[Item]]
        },
        [104] = {
            Index = 104,
            Id = 104,
            Name = [[高倍望远镜]],
            Quality = 24,
            IconId = [[74695865349139]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_104_Pickax]],
            ModelType = [[Item]]
        },
        [105] = {
            Index = 105,
            Id = 105,
            Name = [[高尔夫球杆]],
            Quality = 24,
            IconId = [[98358488442985]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_105_GolfClub]],
            ModelType = [[Item]]
        },
        [106] = {
            Index = 106,
            Id = 106,
            Name = [[冰球杆]],
            Quality = 24,
            IconId = [[113636295509693]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_106_Hockey]],
            ModelType = [[Item]]
        },
        [107] = {
            Index = 107,
            Id = 107,
            Name = [[木棒]],
            Quality = 25,
            IconId = [[114047124407739]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_107_Bat01]],
            ModelType = [[Item]]
        },
        [108] = {
            Index = 108,
            Id = 108,
            Name = [[球棒]],
            Quality = 25,
            IconId = [[95771403493939]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_108_Bat02]],
            ModelType = [[Item]]
        },
        [109] = {
            Index = 109,
            Id = 109,
            Name = [[铁棒]],
            Quality = 25,
            IconId = [[140393673870516]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_109_Bat03]],
            ModelType = [[Item]]
        },
        [110] = {
            Index = 110,
            Id = 110,
            Name = [[战术棍]],
            Quality = 25,
            IconId = [[123109322631502]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_110_Bat04]],
            ModelType = [[Item]]
        },
        [111] = {
            Index = 111,
            Id = 111,
            Name = [[电锯]],
            Quality = 26,
            IconId = [[98614967981417]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_111_ElectricSaw]],
            ModelType = [[Item]]
        },
        [112] = {
            Index = 112,
            Id = 112,
            Name = [[木斧]],
            Quality = 26,
            IconId = [[127369769981706]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_112_Ax01]],
            ModelType = [[Item]]
        },
        [113] = {
            Index = 113,
            Id = 113,
            Name = [[消防斧]],
            Quality = 26,
            IconId = [[134574393827781]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_113_Ax02]],
            ModelType = [[Item]]
        },
        [114] = {
            Index = 114,
            Id = 114,
            Name = [[战斧]],
            Quality = 26,
            IconId = [[130258203281991]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_114_Ax03]],
            ModelType = [[Item]]
        },
        [115] = {
            Index = 115,
            Id = 115,
            Name = [[小刀]],
            Quality = 27,
            IconId = [[93953823085119]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_115_Knife01]],
            ModelType = [[Item]]
        },
        [116] = {
            Index = 116,
            Id = 116,
            Name = [[猎刀]],
            Quality = 27,
            IconId = [[109802560542166]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_116_Knife02]],
            ModelType = [[Item]]
        },
        [117] = {
            Index = 117,
            Id = 117,
            Name = [[军刀]],
            Quality = 27,
            IconId = [[130989494782889]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_117_Knife03]],
            ModelType = [[Item]]
        },
        [118] = {
            Index = 118,
            Id = 118,
            Name = [[开山刀]],
            Quality = 27,
            IconId = [[129408716253336]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_118_Knife04]],
            ModelType = [[Item]]
        },
        [119] = {
            Index = 119,
            Id = 119,
            Name = [[匕首]],
            Quality = 28,
            IconId = [[127772866805590]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_119_Knife05]],
            ModelType = [[Item]]
        },
        [120] = {
            Index = 120,
            Id = 120,
            Name = [[战术刀]],
            Quality = 28,
            IconId = [[91938109188463]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_120_Knife06]],
            ModelType = [[Item]]
        },
        [121] = {
            Index = 121,
            Id = 121,
            Name = [[狼牙棒]],
            Quality = 28,
            IconId = [[85077262752129]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_121_Ironmace]],
            ModelType = [[Item]]
        },
        [122] = {
            Index = 122,
            Id = 122,
            Name = [[炸药罐]],
            Quality = 28,
            IconId = [[140335958193244]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_122_Dynamite01]],
            ModelType = [[Item]]
        },
        [123] = {
            Index = 123,
            Id = 123,
            Name = [[捆装炸药]],
            Quality = 29,
            IconId = [[86732012145983]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_123_Dynamite02]],
            ModelType = [[Item]]
        },
        [124] = {
            Index = 124,
            Id = 124,
            Name = [[遥控炸弹]],
            Quality = 29,
            IconId = [[78044122276865]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_124_Dynamite03]],
            ModelType = [[Item]]
        },
        [125] = {
            Index = 125,
            Id = 125,
            Name = [[圆形手雷]],
            Quality = 29,
            IconId = [[114974638199136]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_125_Grenade01]],
            ModelType = [[Item]]
        },
        [126] = {
            Index = 126,
            Id = 126,
            Name = [[高爆手雷]],
            Quality = 29,
            IconId = [[83652207307759]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_126_Grenade02]],
            ModelType = [[Item]]
        },
        [127] = {
            Index = 127,
            Id = 127,
            Name = [[等离子手雷]],
            Quality = 30,
            IconId = [[131787091355052]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_127_Grenade03]],
            ModelType = [[Item]]
        },
        [128] = {
            Index = 128,
            Id = 128,
            Name = [[感应地雷]],
            Quality = 30,
            IconId = [[99348381699835]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_128_Mine]],
            ModelType = [[Item]]
        },
        [129] = {
            Index = 129,
            Id = 129,
            Name = [[捕兽夹]],
            Quality = 30,
            IconId = [[75412160560516]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_129_Trap]],
            ModelType = [[Item]]
        },
        [130] = {
            Index = 130,
            Id = 130,
            Name = [[手枪子弹]],
            Quality = 30,
            IconId = [[105475505052937]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_130_Bullet01]],
            ModelType = [[Item]]
        },
        [131] = {
            Index = 131,
            Id = 131,
            Name = [[手枪弹药]],
            Quality = 31,
            IconId = [[125484119033793]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_131_Bullet02]],
            ModelType = [[Item]]
        },
        [132] = {
            Index = 132,
            Id = 132,
            Name = [[整箱弹药]],
            Quality = 31,
            IconId = [[140608831780254]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_132_Bullet03]],
            ModelType = [[Item]]
        },
        [133] = {
            Index = 133,
            Id = 133,
            Name = [[盒装弹药]],
            Quality = 31,
            IconId = [[124177358025481]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_133_Bullet04]],
            ModelType = [[Item]]
        },
        [134] = {
            Index = 134,
            Id = 134,
            Name = [[直式弹匣]],
            Quality = 31,
            IconId = [[129385390119523]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_134_Bullet05]],
            ModelType = [[Item]]
        },
        [135] = {
            Index = 135,
            Id = 135,
            Name = [[弯式弹匣]],
            Quality = 32,
            IconId = [[84940520003035]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_135_Bullet06]],
            ModelType = [[Item]]
        },
        [136] = {
            Index = 136,
            Id = 136,
            Name = [[霰弹盒]],
            Quality = 32,
            IconId = [[90031364711610]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_136_Bullet07]],
            ModelType = [[Item]]
        },
        [137] = {
            Index = 137,
            Id = 137,
            Name = [[军用弹药箱]],
            Quality = 32,
            IconId = [[84418341821320]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_137_Cartridge]],
            ModelType = [[Item]]
        },
        [138] = {
            Index = 138,
            Id = 138,
            Name = [[左轮手枪]],
            Quality = 32,
            IconId = [[130255705800444]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_138_Gun01]],
            ModelType = [[Item]]
        },
        [139] = {
            Index = 139,
            Id = 139,
            Name = [[单发手枪]],
            Quality = 33,
            IconId = [[123568265278671]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_139_Gun02]],
            ModelType = [[Item]]
        },
        [140] = {
            Index = 140,
            Id = 140,
            Name = [[短管突击步枪]],
            Quality = 33,
            IconId = [[75689117044416]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_140_Rifle01]],
            ModelType = [[Item]]
        },
        [141] = {
            Index = 141,
            Id = 141,
            Name = [[战术突击步枪]],
            Quality = 33,
            IconId = [[92309488435591]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_141_Rifle02]],
            ModelType = [[Item]]
        },
        [142] = {
            Index = 142,
            Id = 142,
            Name = [[木托突击步枪]],
            Quality = 33,
            IconId = [[106319308889290]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_142_Rifle03]],
            ModelType = [[Item]]
        },
        [143] = {
            Index = 143,
            Id = 143,
            Name = [[战斗霰弹枪]],
            Quality = 34,
            IconId = [[123120949699520]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_143_Rifle04]],
            ModelType = [[Item]]
        },
        [144] = {
            Index = 144,
            Id = 144,
            Name = [[狙击步枪]],
            Quality = 34,
            IconId = [[111674856010497]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_144_Rifle05]],
            ModelType = [[Item]]
        },
        [145] = {
            Index = 145,
            Id = 145,
            Name = [[冲锋枪]],
            Quality = 34,
            IconId = [[118080816505555]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_145_MachineGun01]],
            ModelType = [[Item]]
        },
        [146] = {
            Index = 146,
            Id = 146,
            Name = [[消音冲锋枪]],
            Quality = 34,
            IconId = [[105021574817966]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_146_MachineGun02]],
            ModelType = [[Item]]
        },
        [147] = {
            Index = 147,
            Id = 147,
            Name = [[微型冲锋枪]],
            Quality = 35,
            IconId = [[72690180103558]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_147_MachineGun03]],
            ModelType = [[Item]]
        },
        [148] = {
            Index = 148,
            Id = 148,
            Name = [[木托冲锋枪]],
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
            GrassClumpsHP = 29,
            Texture = [[sandboxId://Model/Block/SegmenteGrassClump/Ground1.png]]
        },
        ["World1.Level_2"] = {
            LevelKey = [[World1.Level_2]],
            GrassClumpsHP = 122,
            Texture = [[sandboxId://Model/Block/SegmenteGrassClump/Ground2.png]]
        },
        ["World1.Level_3"] = {
            LevelKey = [[World1.Level_3]],
            GrassClumpsHP = 520,
            Texture = [[sandboxId://Model/Block/SegmenteGrassClump/Ground3.png]]
        },
        ["World1.Level_4"] = {
            LevelKey = [[World1.Level_4]],
            GrassClumpsHP = 2176,
            Texture = [[sandboxId://Model/Block/SegmenteGrassClump/Ground4.png]]
        },
        ["World1.Level_5"] = {
            LevelKey = [[World1.Level_5]],
            GrassClumpsHP = 9101,
            Texture = [[sandboxId://Model/Block/SegmenteGrassClump/Ground5.png]]
        },
        ["World1.Level_6"] = {
            LevelKey = [[World1.Level_6]],
            GrassClumpsHP = 38000,
            Texture = [[sandboxId://Model/Block/SegmenteGrassClump/Ground6.png]]
        },
        ["World1.Level_7"] = {
            LevelKey = [[World1.Level_7]],
            GrassClumpsHP = 159000,
            Texture = [[sandboxId://Model/Block/SegmenteGrassClump/Ground7.png]]
        },
        ["World1.Level_8"] = {
            LevelKey = [[World1.Level_8]],
            GrassClumpsHP = 664000,
            Texture = [[sandboxId://Model/Block/SegmenteGrassClump/Ground8.png]]
        },
        ["World1.Level_9"] = {
            LevelKey = [[World1.Level_9]],
            GrassClumpsHP = 2.77e+6,
            Texture = [[sandboxId://Model/Block/SegmenteGrassClump/Ground9.png]]
        },
        ["World1.Level_10"] = {
            LevelKey = [[World1.Level_10]],
            GrassClumpsHP = 1.16e+7,
            Texture = [[sandboxId://Model/Block/SegmenteGrassClump/Ground10.png]]
        },
        ["World1.Level_11"] = {
            LevelKey = [[World1.Level_11]],
            GrassClumpsHP = 4.84e+7,
            Texture = [[sandboxId://Model/Block/SegmenteGrassClump/Ground11.png]]
        },
        ["World1.Level_12"] = {
            LevelKey = [[World1.Level_12]],
            GrassClumpsHP = 2.02e+8,
            Texture = [[sandboxId://Model/Block/SegmenteGrassClump/Ground12.png]]
        },
        ["World1.Level_13"] = {
            LevelKey = [[World1.Level_13]],
            GrassClumpsHP = 8.44e+8,
            Texture = [[sandboxId://Model/Block/SegmenteGrassClump/Ground13.png]]
        },
        ["World2.Level_14"] = {
            LevelKey = [[World2.Level_14]],
            GrassClumpsHP = 3.53e+9,
            Texture = [[sandboxId://Model/Block/SegmenteGrassClump/Ground14.png]]
        },
        ["World2.Level_15"] = {
            LevelKey = [[World2.Level_15]],
            GrassClumpsHP = 1.47e+10,
            Texture = [[sandboxId://Model/Block/SegmenteGrassClump/Ground15.png]]
        },
        ["World2.Level_16"] = {
            LevelKey = [[World2.Level_16]],
            GrassClumpsHP = 6.15e+10,
            Texture = [[sandboxId://Model/Block/SegmenteGrassClump/Ground16.png]]
        },
        ["World2.Level_17"] = {
            LevelKey = [[World2.Level_17]],
            GrassClumpsHP = 2.57e+11,
            Texture = [[sandboxId://Model/Block/SegmenteGrassClump/Ground17.png]]
        },
        ["World2.Level_18"] = {
            LevelKey = [[World2.Level_18]],
            GrassClumpsHP = 1.07e+12,
            Texture = [[sandboxId://Model/Block/SegmenteGrassClump/Ground18.png]]
        },
        ["World2.Level_19"] = {
            LevelKey = [[World2.Level_19]],
            GrassClumpsHP = 4.48e+12,
            Texture = [[sandboxId://Model/Block/SegmenteGrassClump/Ground19.png]]
        },
        ["World2.Level_20"] = {
            LevelKey = [[World2.Level_20]],
            GrassClumpsHP = 1.87e+13,
            Texture = [[sandboxId://Model/Block/SegmenteGrassClump/Ground20.png]]
        },
        ["World2.Level_21"] = {
            LevelKey = [[World2.Level_21]],
            GrassClumpsHP = 7.82e+13,
            Texture = [[sandboxId://Model/Block/SegmenteGrassClump/Ground21.png]]
        },
        ["World2.Level_22"] = {
            LevelKey = [[World2.Level_22]],
            GrassClumpsHP = 3.27e+14,
            Texture = [[sandboxId://Model/Block/SegmenteGrassClump/Ground22.png]]
        },
        ["World2.Level_23"] = {
            LevelKey = [[World2.Level_23]],
            GrassClumpsHP = 1.37e+15,
            Texture = [[sandboxId://Model/Block/SegmenteGrassClump/Ground23.png]]
        },
        ["World2.Level_24"] = {
            LevelKey = [[World2.Level_24]],
            GrassClumpsHP = 5.7e+15,
            Texture = [[sandboxId://Model/Block/SegmenteGrassClump/Ground24.png]]
        },
        ["World2.Level_25"] = {
            LevelKey = [[World2.Level_25]],
            GrassClumpsHP = 2.38e+16,
            Texture = [[sandboxId://Model/Block/SegmenteGrassClump/Ground25.png]]
        },
        ["World2.Level_26"] = {
            LevelKey = [[World2.Level_26]],
            GrassClumpsHP = 9.95e+16,
            Texture = [[sandboxId://Model/Block/SegmenteGrassClump/Ground26.png]]
        },
        ["World3.Level_27"] = {
            LevelKey = [[World3.Level_27]],
            GrassClumpsHP = 4.16e+17,
            Texture = [[sandboxId://Model/Block/SegmenteGrassClump/Ground27.png]]
        },
        ["World3.Level_28"] = {
            LevelKey = [[World3.Level_28]],
            GrassClumpsHP = 1.74e+18,
            Texture = [[sandboxId://Model/Block/SegmenteGrassClump/Ground28.png]]
        },
        ["World3.Level_29"] = {
            LevelKey = [[World3.Level_29]],
            GrassClumpsHP = 7.25e+18,
            Texture = [[sandboxId://Model/Block/SegmenteGrassClump/Ground29.png]]
        },
        ["World3.Level_30"] = {
            LevelKey = [[World3.Level_30]],
            GrassClumpsHP = 3.03e+19,
            Texture = [[sandboxId://Model/Block/SegmenteGrassClump/Ground30.png]]
        },
        ["World3.Level_31"] = {
            LevelKey = [[World3.Level_31]],
            GrassClumpsHP = 1.27e+20,
            Texture = [[sandboxId://Model/Block/SegmenteGrassClump/Ground31.png]]
        },
        ["World3.Level_32"] = {
            LevelKey = [[World3.Level_32]],
            GrassClumpsHP = 5.29e+20,
            Texture = [[sandboxId://Model/Block/SegmenteGrassClump/Ground32.png]]
        },
        ["World3.Level_33"] = {
            LevelKey = [[World3.Level_33]],
            GrassClumpsHP = 2.21e+21,
            Texture = [[sandboxId://Model/Block/SegmenteGrassClump/Ground33.png]]
        },
        ["World3.Level_34"] = {
            LevelKey = [[World3.Level_34]],
            GrassClumpsHP = 9.230000000000000524288e+21,
            Texture = [[sandboxId://Model/Block/SegmenteGrassClump/Ground34.png]]
        },
        ["World3.Level_35"] = {
            LevelKey = [[World3.Level_35]],
            GrassClumpsHP = 3.8499999999999998951424e+22,
            Texture = [[sandboxId://Model/Block/SegmenteGrassClump/Ground35.png]]
        },
        ["World3.Level_36"] = {
            LevelKey = [[World3.Level_36]],
            GrassClumpsHP = 1.6099999999999998951424e+23,
            Texture = [[sandboxId://Model/Block/SegmenteGrassClump/Ground36.png]]
        },
        ["World3.Level_37"] = {
            LevelKey = [[World3.Level_37]],
            GrassClumpsHP = 6.72999999999999955959808e+23,
            Texture = [[sandboxId://Model/Block/SegmenteGrassClump/Ground37.png]]
        },
        ["World3.Level_38"] = {
            LevelKey = [[World3.Level_38]],
            GrassClumpsHP = 2.809999999999999861587968e+24,
            Texture = [[sandboxId://Model/Block/SegmenteGrassClump/Ground38.png]]
        },
        ["World3.Level_39"] = {
            LevelKey = [[World3.Level_39]],
            GrassClumpsHP = 1.1699999999999999320522752e+25,
            Texture = [[sandboxId://Model/Block/SegmenteGrassClump/Ground39.png]]
        },
        ["World4.Level_40"] = {
            LevelKey = [[World4.Level_40]],
            GrassClumpsHP = 4.9000000000000000788529152e+25,
            Texture = [[sandboxId://Model/Block/SegmenteGrassClump/Ground40.png]]
        },
        ["World4.Level_41"] = {
            LevelKey = [[World4.Level_41]],
            GrassClumpsHP = 2.04999999999999991728832512e+26,
            Texture = [[sandboxId://Model/Block/SegmenteGrassClump/Ground41.png]]
        },
        ["World4.Level_42"] = {
            LevelKey = [[World4.Level_42]],
            GrassClumpsHP = 8.54999999999999979749900288e+26,
            Texture = [[sandboxId://Model/Block/SegmenteGrassClump/Ground42.png]]
        },
        ["World4.Level_43"] = {
            LevelKey = [[World4.Level_43]],
            GrassClumpsHP = 3.570000000000000209614536704e+27,
            Texture = [[sandboxId://Model/Block/SegmenteGrassClump/Ground43.png]]
        },
        ["World4.Level_44"] = {
            LevelKey = [[World4.Level_44]],
            GrassClumpsHP = 1.489999999999999918093631488e+28,
            Texture = [[sandboxId://Model/Block/SegmenteGrassClump/Ground44.png]]
        },
        ["World4.Level_45"] = {
            LevelKey = [[World4.Level_45]],
            GrassClumpsHP = 6.239999999999999775051087872e+28,
            Texture = [[sandboxId://Model/Block/SegmenteGrassClump/Ground45.png]]
        },
        ["World4.Level_46"] = {
            LevelKey = [[World4.Level_46]],
            GrassClumpsHP = 2.60000000000000002355252690944e+29,
            Texture = [[sandboxId://Model/Block/SegmenteGrassClump/Ground46.png]]
        },
        ["World4.Level_47"] = {
            LevelKey = [[World4.Level_47]],
            GrassClumpsHP = 1.089999999999999996341493170176e+30,
            Texture = [[sandboxId://Model/Block/SegmenteGrassClump/Ground47.png]]
        },
        ["World4.Level_48"] = {
            LevelKey = [[World4.Level_48]],
            GrassClumpsHP = 4.539999999999999938279709343744e+30,
            Texture = [[sandboxId://Model/Block/SegmenteGrassClump/Ground48.png]]
        },
        ["World4.Level_49"] = {
            LevelKey = [[World4.Level_49]],
            GrassClumpsHP = 1.900000000000000065928284864512e+31,
            Texture = [[sandboxId://Model/Block/SegmenteGrassClump/Ground49.png]]
        },
        ["World4.Level_50"] = {
            LevelKey = [[World4.Level_50]],
            GrassClumpsHP = 7.9299999999999996707333652611072e+31,
            Texture = [[sandboxId://Model/Block/SegmenteGrassClump/Ground50.png]]
        },
        ["World4.Level_51"] = {
            LevelKey = [[World4.Level_51]],
            GrassClumpsHP = 3.3099999999999998659708747513856e+32,
            Texture = [[sandboxId://Model/Block/SegmenteGrassClump/Ground51.png]]
        },
        ["World4.Level_52"] = {
            LevelKey = [[World4.Level_52]],
            GrassClumpsHP = 1.380000000000000120890474545283072e+33,
            Texture = [[sandboxId://Model/Block/SegmenteGrassClump/Ground52.png]]
        }
    }
}