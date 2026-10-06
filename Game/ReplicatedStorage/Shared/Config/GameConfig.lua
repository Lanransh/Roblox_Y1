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
        }
    },
    TrainingFieldData = {
        [1] = {
            Index = 1,
            NeedRebirhLevel = 0,
            DevGoodId = nil,
            TrainingRate = 1,
            Node = [[BlockModels.TrainingField1.Field4]]
        },
        [2] = {
            Index = 2,
            NeedRebirhLevel = 3,
            DevGoodId = nil,
            TrainingRate = 2,
            Node = [[BlockModels.TrainingField1.Field3]]
        },
        [3] = {
            Index = 3,
            NeedRebirhLevel = 6,
            DevGoodId = nil,
            TrainingRate = 5,
            Node = [[BlockModels.TrainingField1.Field2]]
        },
        [4] = {
            Index = 4,
            NeedRebirhLevel = 9,
            DevGoodId = nil,
            TrainingRate = 9,
            Node = [[BlockModels.TrainingField1.Field1]]
        },
        [5] = {
            Index = 5,
            NeedRebirhLevel = 12,
            DevGoodId = nil,
            TrainingRate = 14,
            Node = [[BlockModels.TrainingField1.Field0]]
        },
        [6] = {
            Index = 6,
            NeedRebirhLevel = 15,
            DevGoodId = nil,
            TrainingRate = 20,
            Node = [[BlockModels.TrainingField2.Field4]]
        },
        [7] = {
            Index = 7,
            NeedRebirhLevel = 18,
            DevGoodId = nil,
            TrainingRate = 27,
            Node = [[BlockModels.TrainingField2.Field3]]
        },
        [8] = {
            Index = 8,
            NeedRebirhLevel = 21,
            DevGoodId = nil,
            TrainingRate = 35,
            Node = [[BlockModels.TrainingField2.Field2]]
        },
        [9] = {
            Index = 9,
            NeedRebirhLevel = 24,
            DevGoodId = nil,
            TrainingRate = 44,
            Node = [[BlockModels.TrainingField2.Field1]]
        },
        [10] = {
            Index = 10,
            NeedRebirhLevel = 27,
            DevGoodId = nil,
            TrainingRate = 54,
            Node = [[BlockModels.TrainingField3.Field4]]
        },
        [11] = {
            Index = 11,
            NeedRebirhLevel = 30,
            DevGoodId = nil,
            TrainingRate = 65,
            Node = [[BlockModels.TrainingField3.Field3]]
        },
        [12] = {
            Index = 12,
            NeedRebirhLevel = 33,
            DevGoodId = nil,
            TrainingRate = 76,
            Node = [[BlockModels.TrainingField3.Field2]]
        },
        [13] = {
            Index = 13,
            NeedRebirhLevel = 36,
            DevGoodId = nil,
            TrainingRate = 89,
            Node = [[BlockModels.TrainingField3.Field1]]
        },
        [14] = {
            Index = 14,
            NeedRebirhLevel = 39,
            DevGoodId = nil,
            TrainingRate = 103,
            Node = [[BlockModels.TrainingField4.Field4]]
        },
        [15] = {
            Index = 15,
            NeedRebirhLevel = 42,
            DevGoodId = nil,
            TrainingRate = 117,
            Node = [[BlockModels.TrainingField4.Field3]]
        },
        [16] = {
            Index = 16,
            NeedRebirhLevel = 45,
            DevGoodId = nil,
            TrainingRate = 132,
            Node = [[BlockModels.TrainingField4.Field2]]
        },
        [17] = {
            Index = 17,
            NeedRebirhLevel = 48,
            DevGoodId = nil,
            TrainingRate = 149,
            Node = [[BlockModels.TrainingField4.Field1]]
        }
    },
    SlicerConfig = {
        [1] = {
            Index = 1,
            SlicerId = 101,
            Name = [[Wildwood Club]],
            Price = 0,
            TrainingRate = 1,
            DevGoodId = nil,
            Img = [[sandboxId://Model/Slicer/Png/01_WildwoodWarclub.png]],
            ModelId = [[sandboxId://Model/Slicer/Model/01_WildwoodWarclub/WildwoodWarclub.obj]],
            TextureId = [[sandboxId://Model/Slicer/Model/01_WildwoodWarclub/WildwoodWarclub.png]]
        },
        [2] = {
            Index = 2,
            SlicerId = 102,
            Name = [[Ironwood Battle Axe]],
            Price = 25,
            TrainingRate = 39,
            DevGoodId = nil,
            Img = [[sandboxId://Model/Slicer/Png/02_IronwoodBattleaxe.png]],
            ModelId = [[sandboxId://Model/Slicer/Model/02_IronwoodBattleaxe/IronwoodBattleaxe.obj]],
            TextureId = [[sandboxId://Model/Slicer/Model/02_IronwoodBattleaxe/IronwoodBattleaxe.png]]
        },
        [3] = {
            Index = 3,
            SlicerId = 103,
            Name = [[Froststeel Sword]],
            Price = 450,
            TrainingRate = 450,
            DevGoodId = nil,
            Img = [[sandboxId://Model/Slicer/Png/03_FroststeelSword.png]],
            ModelId = [[sandboxId://Model/Slicer/Model/03_FroststeelSword/FroststeelSword.obj]],
            TextureId = [[sandboxId://Model/Slicer/Model/03_FroststeelSword/FroststeelSword.png]]
        },
        [4] = {
            Index = 4,
            SlicerId = 104,
            Name = [[Obsidian Hatchet]],
            Price = 4375,
            TrainingRate = 3282,
            DevGoodId = nil,
            Img = [[sandboxId://Model/Slicer/Png/04_ObsidianHandAxe.png]],
            ModelId = [[sandboxId://Model/Slicer/Model/04_ObsidianHandAxe/ObsidianHandAxe.obj]],
            TextureId = [[sandboxId://Model/Slicer/Model/04_ObsidianHandAxe/ObsidianHandAxe.png]]
        },
        [5] = {
            Index = 5,
            SlicerId = 105,
            Name = [[Crimson Crystal Staff]],
            Price = 35000,
            TrainingRate = 19000,
            DevGoodId = nil,
            Img = [[sandboxId://Model/Slicer/Png/05_CrimsonLatticeStaff.png]],
            ModelId = [[sandboxId://Model/Slicer/Model/05_CrimsonLatticeStaff/CrimsonLatticeStaff.obj]],
            TextureId = [[sandboxId://Model/Slicer/Model/05_CrimsonLatticeStaff/CrimsonLatticeStaff.png]]
        },
        [6] = {
            Index = 6,
            SlicerId = 106,
            Name = [[Nightshadow Battle Axe]],
            Price = 253000,
            TrainingRate = 95500,
            DevGoodId = nil,
            Img = [[sandboxId://Model/Slicer/Png/06_NightshadeWarAxe.png]],
            ModelId = [[sandboxId://Model/Slicer/Model/06_NightshadeWarAxe/NightshadeWarAxe.obj]],
            TextureId = [[sandboxId://Model/Slicer/Model/06_NightshadeWarAxe/NightshadeWarAxe.png]]
        },
        [7] = {
            Index = 7,
            SlicerId = 107,
            Name = [[Runic Warhammer]],
            Price = 1.89e+6,
            TrainingRate = 442000,
            DevGoodId = nil,
            Img = [[sandboxId://Model/Slicer/Png/07_RuneboundWarhammer.png]],
            ModelId = [[sandboxId://Model/Slicer/Model/07_RuneboundWarhammer/RuneboundWarhammer.obj]],
            TextureId = [[sandboxId://Model/Slicer/Model/07_RuneboundWarhammer/RuneboundWarhammer.png]]
        },
        [8] = {
            Index = 8,
            SlicerId = 108,
            Name = [[Darkhorn Mace]],
            Price = 1.22e+7,
            TrainingRate = 1.93e+6,
            DevGoodId = nil,
            Img = [[sandboxId://Model/Slicer/Png/08_DarkhornMace.png]],
            ModelId = [[sandboxId://Model/Slicer/Model/08_DarkhornMace/DarkhornMace.obj]],
            TextureId = [[sandboxId://Model/Slicer/Model/08_DarkhornMace/DarkhornMace.png]]
        },
        [9] = {
            Index = 9,
            SlicerId = 109,
            Name = [[Silver Dagger]],
            Price = 7.62e+7,
            TrainingRate = 8.1e+6,
            DevGoodId = nil,
            Img = [[sandboxId://Model/Slicer/Png/09_SilverDagger.png]],
            ModelId = [[sandboxId://Model/Slicer/Model/09_SilverDagger/SilverDagger.obj]],
            TextureId = [[sandboxId://Model/Slicer/Model/09_SilverDagger/SilverDagger.png]]
        },
        [10] = {
            Index = 10,
            SlicerId = 110,
            Name = [[Golden Sunblade]],
            Price = 4.65e+8,
            TrainingRate = 3.31e+7,
            DevGoodId = nil,
            Img = [[sandboxId://Model/Slicer/Png/10_AuricSunblade.png]],
            ModelId = [[sandboxId://Model/Slicer/Model/10_AuricSunblade/AuricSunblade.obj]],
            TextureId = [[sandboxId://Model/Slicer/Model/10_AuricSunblade/AuricSunblade.png]]
        },
        [11] = {
            Index = 11,
            SlicerId = 111,
            Name = [[Astral Frostblade]],
            Price = 2.78e+9,
            TrainingRate = 1.33e+8,
            DevGoodId = nil,
            Img = [[sandboxId://Model/Slicer/Png/11_AstralFrostblade.png]],
            ModelId = [[sandboxId://Model/Slicer/Model/11_AstralFrostblade/AstralFrostblade.obj]],
            TextureId = [[sandboxId://Model/Slicer/Model/11_AstralFrostblade/AstralFrostblade.png]]
        },
        [12] = {
            Index = 12,
            SlicerId = 112,
            Name = [[Infernal Scimitar]],
            Price = 1.64e+10,
            TrainingRate = 5.25e+8,
            DevGoodId = nil,
            Img = [[sandboxId://Model/Slicer/Png/12_InfernalScimitar.png]],
            ModelId = [[sandboxId://Model/Slicer/Model/12_InfernalScimitar/InfernalScimitar.obj]],
            TextureId = [[sandboxId://Model/Slicer/Model/12_InfernalScimitar/InfernalScimitar.png]]
        },
        [13] = {
            Index = 13,
            SlicerId = 113,
            Name = [[Emerald Venomblade]],
            Price = 9.55e+10,
            TrainingRate = 2.05e+9,
            DevGoodId = nil,
            Img = [[sandboxId://Model/Slicer/Png/13_VerdantVenomblade.png]],
            ModelId = [[sandboxId://Model/Slicer/Model/13_VerdantVenomblade/VerdantVenomblade.obj]],
            TextureId = [[sandboxId://Model/Slicer/Model/13_VerdantVenomblade/VerdantVenomblade.png]]
        },
        [14] = {
            Index = 14,
            SlicerId = 114,
            Name = [[Emerald Trident]],
            Price = 5.49e+11,
            TrainingRate = 7.99e+9,
            DevGoodId = nil,
            Img = [[sandboxId://Model/Slicer/Png/14_VerdantTrident.png]],
            ModelId = [[sandboxId://Model/Slicer/Model/14_VerdantTrident/VerdantTrident.obj]],
            TextureId = [[sandboxId://Model/Slicer/Model/14_VerdantTrident/VerdantTrident.png]]
        },
        [15] = {
            Index = 15,
            SlicerId = 115,
            Name = [[Amethyst Starbreaker Spear]],
            Price = 3.13e+12,
            TrainingRate = 3.1e+10,
            DevGoodId = nil,
            Img = [[sandboxId://Model/Slicer/Png/15_AmethystStarbreakerSpear.png]],
            ModelId = [[sandboxId://Model/Slicer/Model/15_AmethystStarbreakerSpear/AmethystStarbreakerSpear.obj]],
            TextureId = [[sandboxId://Model/Slicer/Model/15_AmethystStarbreakerSpear/AmethystStarbreakerSpear.png]]
        },
        [16] = {
            Index = 16,
            SlicerId = 116,
            Name = [[Frostcrystal Greatsword]],
            Price = 1.77e+13,
            TrainingRate = 1.2e+11,
            DevGoodId = nil,
            Img = [[sandboxId://Model/Slicer/Png/16_FrostcrystalGreatsword.png]],
            ModelId = [[sandboxId://Model/Slicer/Model/16_FrostcrystalGreatsword/FrostcrystalGreatsword.obj]],
            TextureId = [[sandboxId://Model/Slicer/Model/16_FrostcrystalGreatsword/FrostcrystalGreatsword.png]]
        },
        [17] = {
            Index = 17,
            SlicerId = 117,
            Name = [[Lava Earthsplitter Axe]],
            Price = 9.93e+13,
            TrainingRate = 4.62e+11,
            DevGoodId = nil,
            Img = [[sandboxId://Model/Slicer/Png/17_MagmaEarthsplitter.png]],
            ModelId = [[sandboxId://Model/Slicer/Model/17_MagmaEarthsplitter/MagmaEarthsplitter.obj]],
            TextureId = [[sandboxId://Model/Slicer/Model/17_MagmaEarthsplitter/MagmaEarthsplitter.png]]
        },
        [18] = {
            Index = 18,
            SlicerId = 118,
            Name = [[Flame Feather]],
            Price = 5.54e+14,
            TrainingRate = 1.78e+12,
            DevGoodId = nil,
            Img = [[sandboxId://Model/Slicer/Png/18_FlamingFeather.png]],
            ModelId = [[sandboxId://Model/Slicer/Model/18_FlamingFeather/FlamingFeather.obj]],
            TextureId = [[sandboxId://Model/Slicer/Model/18_FlamingFeather/FlamingFeather.png]]
        },
        [19] = {
            Index = 19,
            SlicerId = 119,
            Name = [[Sunlight Scepter]],
            Price = 3.07e+15,
            TrainingRate = 6.9e+12,
            DevGoodId = nil,
            Img = [[sandboxId://Model/Slicer/Png/19_SunburstScepter.png]],
            ModelId = [[sandboxId://Model/Slicer/Model/19_SunburstScepter/SunburstScepter.obj]],
            TextureId = [[sandboxId://Model/Slicer/Model/19_SunburstScepter/SunburstScepter.png]]
        },
        [20] = {
            Index = 20,
            SlicerId = 120,
            Name = [[Radiant Skywing Sword]],
            Price = 1.69e+16,
            TrainingRate = 2.67e+13,
            DevGoodId = nil,
            Img = [[sandboxId://Model/Slicer/Png/20_RadiantSkywingSword.png]],
            ModelId = [[sandboxId://Model/Slicer/Model/20_RadiantSkywingSword/RadiantSkywingSword.obj]],
            TextureId = [[sandboxId://Model/Slicer/Model/20_RadiantSkywingSword/RadiantSkywingSword.png]]
        },
        [21] = {
            Index = 21,
            SlicerId = 121,
            Name = [[Phoenix Wing Sword]],
            Price = 9.3e+16,
            TrainingRate = 1.04e+14,
            DevGoodId = nil,
            Img = [[sandboxId://Model/Slicer/Png/21_PhoenixwingSword.png]],
            ModelId = [[sandboxId://Model/Slicer/Model/21_PhoenixwingSword/PhoenixwingSword.obj]],
            TextureId = [[sandboxId://Model/Slicer/Model/21_PhoenixwingSword/PhoenixwingSword.png]]
        },
        [22] = {
            Index = 22,
            SlicerId = 122,
            Name = [[Clockwork Blade]],
            Price = 5.08e+17,
            TrainingRate = 4.03e+14,
            DevGoodId = nil,
            Img = [[sandboxId://Model/Slicer/Png/22_ChronoGearblade.png]],
            ModelId = [[sandboxId://Model/Slicer/Model/22_ChronoGearblade/ChronoGearblade.obj]],
            TextureId = [[sandboxId://Model/Slicer/Model/22_ChronoGearblade/ChronoGearblade.png]]
        },
        [23] = {
            Index = 23,
            SlicerId = 123,
            Name = [[Soulreaper Scythe]],
            Price = 2.77e+18,
            TrainingRate = 1.57e+15,
            DevGoodId = nil,
            Img = [[sandboxId://Model/Slicer/Png/23_SoulrenderScythe.png]],
            ModelId = [[sandboxId://Model/Slicer/Model/23_SoulrenderScythe/SoulrenderScythe.obj]],
            TextureId = [[sandboxId://Model/Slicer/Model/23_SoulrenderScythe/SoulrenderScythe.png]]
        },
        [24] = {
            Index = 24,
            SlicerId = 124,
            Name = [[Infernal Dragonblade]],
            Price = 1.45e+19,
            TrainingRate = 6.16e+15,
            DevGoodId = nil,
            Img = [[sandboxId://Model/Slicer/Png/24_InfernoDragonblade.png]],
            ModelId = [[sandboxId://Model/Slicer/Model/24_InfernoDragonblade/InfernoDragonblade.obj]],
            TextureId = [[sandboxId://Model/Slicer/Model/24_InfernoDragonblade/InfernoDragonblade.png]]
        },
        [25] = {
            Index = 25,
            SlicerId = 125,
            Name = [[Void Riftblade]],
            Price = 7.84e+19,
            TrainingRate = 2.42e+16,
            DevGoodId = nil,
            Img = [[sandboxId://Model/Slicer/Png/25_VoidriftBlade.png]],
            ModelId = [[sandboxId://Model/Slicer/Model/25_VoidriftBlade/VoidriftBlade.obj]],
            TextureId = [[sandboxId://Model/Slicer/Model/25_VoidriftBlade/VoidriftBlade.png]]
        },
        [26] = {
            Index = 26,
            SlicerId = 126,
            Name = [[World-Eater Blade]],
            Price = 4.23e+20,
            TrainingRate = 9.54e+16,
            DevGoodId = nil,
            Img = [[sandboxId://Model/Slicer/Png/26_WorldeaterDemonblade.png]],
            ModelId = [[sandboxId://Model/Slicer/Model/26_WorldeaterDemonblade/WorldeaterDemonblade.obj]],
            TextureId = [[sandboxId://Model/Slicer/Model/26_WorldeaterDemonblade/WorldeaterDemonblade.png]]
        },
        [27] = {
            Index = 27,
            SlicerId = 127,
            Name = [[Crimson Shadowblade]],
            Price = 2.28e+21,
            TrainingRate = 1.5e+17,
            DevGoodId = nil,
            Img = [[sandboxId://Model/ExtraSlicer/Png/27Wp_Ansi.png]],
            ModelId = [[sandboxId://Model/ExtraSlicer/Model/27Wp_Ansi_01.obj]],
            TextureId = [[sandboxId://Model/ExtraSlicer/Maps/27Wp_Ansi_01.png]]
        },
        [28] = {
            Index = 28,
            SlicerId = 128,
            Name = [[Star Abyss Holy Blade]],
            Price = 1.22e+22,
            TrainingRate = 3e+17,
            DevGoodId = nil,
            Img = [[sandboxId://Model/ExtraSlicer/Png/028_Wp_Ml_Sword_004.png]],
            ModelId = [[sandboxId://Model/ExtraSlicer/Model/028_Wp_Ml_Sword_004.obj]],
            TextureId = [[sandboxId://Model/ExtraSlicer/Maps/028_Wp_Ml_Sword_004_D.png]]
        },
        [29] = {
            Index = 29,
            SlicerId = 129,
            Name = [[Blood Moon Sword]],
            Price = 6.3499999999999996854272e+22,
            TrainingRate = 5.94e+17,
            DevGoodId = nil,
            Img = [[sandboxId://Model/ExtraSlicer/Png/029_Wp_Ml_Sword_003.png]],
            ModelId = [[sandboxId://Model/ExtraSlicer/Model/029_Wp_Ml_Sword_003.obj]],
            TextureId = [[sandboxId://Model/ExtraSlicer/Maps/029_Wp_Ml_Sword_003_D.png]]
        },
        [30] = {
            Index = 30,
            SlicerId = 130,
            Name = [[Amethyst Calamity]],
            Price = 3.29000000000000006291456e+23,
            TrainingRate = 1.17e+18,
            DevGoodId = nil,
            Img = [[sandboxId://Model/ExtraSlicer/Png/030_Wp_Dt_Sword_003.png]],
            ModelId = [[sandboxId://Model/ExtraSlicer/Model/030_Wp_Dt_Sword_003.obj]],
            TextureId = [[sandboxId://Model/ExtraSlicer/Maps/030_Wp_Dt_Sword_003_D.png]]
        },
        [31] = {
            Index = 31,
            SlicerId = 131,
            Name = [[Sky Judgment]],
            Price = 1.700000000000000025165824e+24,
            TrainingRate = 2.27e+18,
            DevGoodId = nil,
            Img = [[sandboxId://Model/ExtraSlicer/Png/031_Wp_Dt_Sword_004.png]],
            ModelId = [[sandboxId://Model/ExtraSlicer/Model/031_Wp_Dt_Sword_004.obj]],
            TextureId = [[sandboxId://Model/ExtraSlicer/Maps/031_Wp_Dt_Sword_004_D.png]]
        },
        [32] = {
            Index = 32,
            SlicerId = 132,
            Name = [[Crimson Dragonfang]],
            Price = 8.810000000000000297795584e+24,
            TrainingRate = 4.37e+18,
            DevGoodId = nil,
            Img = [[sandboxId://Model/ExtraSlicer/Png/032_Wp_Dt_Sword_001.png]],
            ModelId = [[sandboxId://Model/ExtraSlicer/Model/032_Wp_Dt_Sword_001.obj]],
            TextureId = [[sandboxId://Model/ExtraSlicer/Maps/032_Wp_Dt_Sword_001_D.png]]
        },
        [33] = {
            Index = 33,
            SlicerId = 133,
            Name = [[Shadowmoon Scythe]],
            Price = 4.5499999999999999505072128e+25,
            TrainingRate = 8.38e+18,
            DevGoodId = nil,
            Img = [[sandboxId://Model/ExtraSlicer/Png/033_Wp_Kris_Mn_DualBlades_01_1.png]],
            ModelId = [[sandboxId://Model/ExtraSlicer/Model/033_Wp_Kris_Mn_DualBlades_01_1.obj]],
            TextureId = [[sandboxId://Model/ExtraSlicer/Maps/033_Wp_Kris_Mn_DualBlades_01_1_D.png]]
        },
        [34] = {
            Index = 34,
            SlicerId = 134,
            Name = [[Golden Imperial Sword]],
            Price = 2.3499999999999998800429056e+26,
            TrainingRate = 1.59e+19,
            DevGoodId = nil,
            Img = [[sandboxId://Model/ExtraSlicer/Png/034_Wp_Cc_Sword_003.png]],
            ModelId = [[sandboxId://Model/ExtraSlicer/Model/034_Wp_Cc_Sword_003.obj]],
            TextureId = [[sandboxId://Model/ExtraSlicer/Maps/034_Wp_Cc_Sword_003_D.png]]
        },
        [35] = {
            Index = 35,
            SlicerId = 135,
            Name = [[Azure Dragon Soul]],
            Price = 1.20999999999999995285602304e+27,
            TrainingRate = 3.01e+19,
            DevGoodId = nil,
            Img = [[sandboxId://Model/ExtraSlicer/Png/035_Wp_Evan_Sword_01.png]],
            ModelId = [[sandboxId://Model/ExtraSlicer/Model/035_Wp_Evan_Sword_01.obj]],
            TextureId = [[sandboxId://Model/ExtraSlicer/Maps/035_Wp_Evan_Sword_01_D.png]]
        },
        [36] = {
            Index = 36,
            SlicerId = 136,
            Name = [[Twilight Greatblade]],
            Price = 6.230000000000000085530247168e+27,
            TrainingRate = 5.66e+19,
            DevGoodId = nil,
            Img = [[sandboxId://Model/ExtraSlicer/Png/036_Wp_Kris_Mn_GreatSword_01.png]],
            ModelId = [[sandboxId://Model/ExtraSlicer/Model/036_Wp_Kris_Mn_GreatSword_01.obj]],
            TextureId = [[sandboxId://Model/ExtraSlicer/Maps/036_Wp_Kris_Mn_GreatSword_01_D.png]]
        },
        [37] = {
            Index = 37,
            SlicerId = 137,
            Name = [[Vampire King Blade]],
            Price = 3.2000000000000000425201762304e+28,
            TrainingRate = 1.06e+20,
            DevGoodId = nil,
            Img = [[sandboxId://Model/ExtraSlicer/Png/037_WP_Boss_Vampire_01.png]],
            ModelId = [[sandboxId://Model/ExtraSlicer/Model/037_WP_Boss_Vampire_01.obj]],
            TextureId = [[sandboxId://Model/ExtraSlicer/Maps/037_WP_Boss_Vampire_01_D.png]]
        },
        [38] = {
            Index = 38,
            SlicerId = 138,
            Name = [[Crimson Wing Sword]],
            Price = 1.64999999999999992021964029952e+29,
            TrainingRate = 1.97e+20,
            DevGoodId = nil,
            Img = [[sandboxId://Model/ExtraSlicer/Png/038_Wp_Shane_Avatar_R.png]],
            ModelId = [[sandboxId://Model/ExtraSlicer/Model/038_Wp_Shane_Avatar_R.obj]],
            TextureId = [[sandboxId://Model/ExtraSlicer/Maps/038_Wp_Shane_Avatar_R_D.png]]
        },
        [39] = {
            Index = 39,
            SlicerId = 139,
            Name = [[Ash Sawblade]],
            Price = 8.19000000000000067232478527488e+29,
            TrainingRate = 3.64e+20,
            DevGoodId = nil,
            Img = [[sandboxId://Model/ExtraSlicer/Png/039_Wp_Serbinus_01.png]],
            ModelId = [[sandboxId://Model/ExtraSlicer/Model/039_Wp_Serbinus_01.obj]],
            TextureId = [[sandboxId://Model/ExtraSlicer/Maps/039_Wp_Serbinus_01_D.png]]
        },
        [40] = {
            Index = 40,
            SlicerId = 140,
            Name = [[Soulbreaker Sword]],
            Price = 4.200000000000000027220428980224e+30,
            TrainingRate = 6.71e+20,
            DevGoodId = nil,
            Img = [[sandboxId://Model/ExtraSlicer/Png/040_Wp_Shane_Ghost_Sword_01.png]],
            ModelId = [[sandboxId://Model/ExtraSlicer/Model/040_Wp_Shane_Ghost_Sword_01.obj]],
            TextureId = [[sandboxId://Model/ExtraSlicer/Maps/040_Wp_Shane_Ghost_Sword_01_D.png]]
        },
        [41] = {
            Index = 41,
            SlicerId = 141,
            Name = [[Crimson Blossom Serpent]],
            Price = 2.2299999999999999233084734046208e+31,
            TrainingRate = 9.25e+20,
            DevGoodId = nil,
            Img = [[sandboxId://Model/ExtraSlicer/Png/041_Wp_Kagura_Mn_01.png]],
            ModelId = [[sandboxId://Model/ExtraSlicer/Model/041_Wp_Kagura_Mn_01.obj]],
            TextureId = [[sandboxId://Model/ExtraSlicer/Maps/041_Wp_Kagura_Mn_01_D.png]]
        },
        [42] = {
            Index = 42,
            SlicerId = 142,
            Name = [[Obsidian Judgment]],
            Price = 1.13999999999999994948497837129728e+32,
            TrainingRate = 1.27e+21,
            DevGoodId = nil,
            Img = [[sandboxId://Model/ExtraSlicer/Png/042_Wp_oscar_dagger_02.png]],
            ModelId = [[sandboxId://Model/ExtraSlicer/Model/042_Wp_oscar_dagger_02.obj]],
            TextureId = [[sandboxId://Model/ExtraSlicer/Maps/042_Wp_oscar_dagger_02_D.png]]
        },
        [43] = {
            Index = 43,
            SlicerId = 143,
            Name = [[Heavenly Judgment]],
            Price = 6.04000000000000008632613682020352e+32,
            TrainingRate = 1.72e+21,
            DevGoodId = nil,
            Img = [[sandboxId://Model/ExtraSlicer/Png/043_Wp_GS_Sword_003.png]],
            ModelId = [[sandboxId://Model/ExtraSlicer/Model/043_Wp_GS_Sword_003.obj]],
            TextureId = [[sandboxId://Model/ExtraSlicer/Maps/043_Wp_GS_Sword_003_D.png]]
        },
        [44] = {
            Index = 44,
            SlicerId = 144,
            Name = [[Skywing Radiance]],
            Price = 3.19000000000000021261369089196032e+33,
            TrainingRate = 2.32e+21,
            DevGoodId = nil,
            Img = [[sandboxId://Model/ExtraSlicer/Png/044_Wp_GS_Sword_004.png]],
            ModelId = [[sandboxId://Model/ExtraSlicer/Model/044_Wp_GS_Sword_004.obj]],
            TextureId = [[sandboxId://Model/ExtraSlicer/Maps/044_Wp_GS_Sword_004_D.png]]
        },
        [45] = {
            Index = 45,
            SlicerId = 145,
            Name = [[Ocean Skyblade]],
            Price = 1.6300000000000000208151694465302528e+34,
            TrainingRate = 3.1e+21,
            DevGoodId = nil,
            Img = [[sandboxId://Model/ExtraSlicer/Png/045_Wp_Cc_Sword_002.png]],
            ModelId = [[sandboxId://Model/ExtraSlicer/Model/045_Wp_Cc_Sword_002.obj]],
            TextureId = [[sandboxId://Model/ExtraSlicer/Maps/045_Wp_Cc_Sword_002_D.png]]
        },
        [46] = {
            Index = 46,
            SlicerId = 146,
            Name = [[Royal Wrath]],
            Price = 8.5999999999999998778234378706223104e+34,
            TrainingRate = 4.13e+21,
            DevGoodId = nil,
            Img = [[sandboxId://Model/ExtraSlicer/Png/046_Wp_Rudy_Mn_BigSword_01.png]],
            ModelId = [[sandboxId://Model/ExtraSlicer/Model/046_Wp_Rudy_Mn_BigSword_01.obj]],
            TextureId = [[sandboxId://Model/ExtraSlicer/Maps/046_Wp_Rudy_Mn_BigSword_01_D.png]]
        },
        [47] = {
            Index = 47,
            SlicerId = 147,
            Name = [[Frozen Wolf Fang]],
            Price = 4.39999999999999971441415615871451136e+35,
            TrainingRate = 5.46e+21,
            DevGoodId = nil,
            Img = [[sandboxId://Model/ExtraSlicer/Png/047_Wp_Teo_01.png]],
            ModelId = [[sandboxId://Model/ExtraSlicer/Model/047_Wp_Teo_01.obj]],
            TextureId = [[sandboxId://Model/ExtraSlicer/Maps/047_Wp_Teo_01_D.png]]
        },
        [48] = {
            Index = 48,
            SlicerId = 148,
            Name = [[Infernal Condemnation]],
            Price = 2.30999999999999996074789642558242816e+36,
            TrainingRate = 7.18e+21,
            DevGoodId = nil,
            Img = [[sandboxId://Model/ExtraSlicer/Png/048_Wp_ML_sword_003_R.png]],
            ModelId = [[sandboxId://Model/ExtraSlicer/Model/048_Wp_ML_sword_003_R.obj]],
            TextureId = [[sandboxId://Model/ExtraSlicer/Maps/048_Wp_ML_sword_003_R_D.png]]
        },
        [49] = {
            Index = 49,
            SlicerId = 149,
            Name = [[Fortune Mountaincrusher]],
            Price = 1.2199999999999999838691594050507636736e+37,
            TrainingRate = 9.390000000000000524288e+21,
            DevGoodId = nil,
            Img = [[sandboxId://Model/ExtraSlicer/Png/049_Wp_Ml_Sword_002.png]],
            ModelId = [[sandboxId://Model/ExtraSlicer/Model/049_Wp_Ml_Sword_002.obj]],
            TextureId = [[sandboxId://Model/ExtraSlicer/Maps/049_Wp_Ml_Sword_002_D.png]]
        },
        [50] = {
            Index = 50,
            SlicerId = 150,
            Name = [[Shadowmoon Bloodfang]],
            Price = 6.2000000000000003515523232727172120576e+37,
            TrainingRate = 1.22e+22,
            DevGoodId = nil,
            Img = [[sandboxId://Model/ExtraSlicer/Png/050_Wp_oscar_dagger_01.png]],
            ModelId = [[sandboxId://Model/ExtraSlicer/Model/050_Wp_oscar_dagger_01.obj]],
            TextureId = [[sandboxId://Model/ExtraSlicer/Maps/050_Wp_oscar_dagger_01_D.png]]
        },
        [51] = {
            Index = 51,
            SlicerId = 151,
            Name = [[Nether Chainblade]],
            Price = 3.25000000000000006850731374841046237184e+38,
            TrainingRate = 1.58e+22,
            DevGoodId = nil,
            Img = [[sandboxId://Model/ExtraSlicer/Png/051_Wp_Shane_Ghost_Sword_Whip_01.png]],
            ModelId = [[sandboxId://Model/ExtraSlicer/Model/051_Wp_Shane_Ghost_Sword_Whip_01.obj]],
            TextureId = [[sandboxId://Model/ExtraSlicer/Maps/051_Wp_Shane_Ghost_Sword_Whip_01_D.png]]
        },
        [52] = {
            Index = 52,
            SlicerId = 152,
            Name = [[Crimson Dragon Soul]],
            Price = 1.699999999999999942840301067273997647872e+39,
            TrainingRate = 2.0300000000000001048576e+22,
            DevGoodId = nil,
            Img = [[sandboxId://Model/ExtraSlicer/Png/052_Wp_Cc_Sword_004.png]],
            ModelId = [[sandboxId://Model/ExtraSlicer/Model/052_Wp_Cc_Sword_004.obj]],
            TextureId = [[sandboxId://Model/ExtraSlicer/Maps/052_Wp_Cc_Sword_004_D.png]]
        },
        [53] = {
            Index = 53,
            SlicerId = 153,
            Name = [[Golden Crimsonblade]],
            Price = 8.68999999999999940202594931783558496256e+39,
            TrainingRate = 2.6e+22,
            DevGoodId = nil,
            Img = [[sandboxId://Model/ExtraSlicer/Png/053_Wp_oscar_01.png]],
            ModelId = [[sandboxId://Model/ExtraSlicer/Model/053_Wp_oscar_01.obj]],
            TextureId = [[sandboxId://Model/ExtraSlicer/Maps/053_Wp_oscar_01_D.png]]
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
    TrailConfig = {
        [1] = {
            Index = 1,
            TrailId = 101,
            Name = [[1-Star Trail]],
            Price = 3750,
            TrainingRate = 1.5,
            DevGoodId = nil,
            ModelId = [[Effects.Trail1]],
            Img = [[sandboxId://UI/Icon/Trail/Trail1Img.png]]
        },
        [2] = {
            Index = 2,
            TrailId = 102,
            Name = [[2-Star Trail]],
            Price = 1.38e+6,
            TrainingRate = 2.5,
            DevGoodId = nil,
            ModelId = [[Effects.Trail2]],
            Img = [[sandboxId://UI/Icon/Trail/Trail2Img.png]]
        },
        [3] = {
            Index = 3,
            TrailId = 103,
            Name = [[3-Star Trail]],
            Price = 3.32e+8,
            TrainingRate = 3.5,
            DevGoodId = nil,
            ModelId = [[Effects.Trail3]],
            Img = [[sandboxId://UI/Icon/Trail/Trail3Img.png]]
        },
        [4] = {
            Index = 4,
            TrailId = 104,
            Name = [[4-Star Trail]],
            Price = 7.3e+10,
            TrainingRate = 4.5,
            DevGoodId = nil,
            ModelId = [[Effects.Trail4]],
            Img = [[sandboxId://UI/Icon/Trail/Trail4Img.png]]
        },
        [5] = {
            Index = 5,
            TrailId = 105,
            Name = [[5-Star Trail]],
            Price = 1.42e+13,
            TrainingRate = 5.5,
            DevGoodId = nil,
            ModelId = [[Effects.Trail5]],
            Img = [[sandboxId://UI/Icon/Trail/Trail5Img.png]]
        },
        [6] = {
            Index = 6,
            TrailId = 106,
            Name = [[6-Star Trail]],
            Price = 2.67e+15,
            TrainingRate = 6.5,
            DevGoodId = nil,
            ModelId = [[Effects.Trail6]],
            Img = [[sandboxId://UI/Icon/Trail/Trail6Img.png]]
        },
        [7] = {
            Index = 7,
            TrailId = 107,
            Name = [[7-Star Trail]],
            Price = 4.69e+17,
            TrainingRate = 7.5,
            DevGoodId = nil,
            ModelId = [[Effects.Trail7]],
            Img = [[sandboxId://UI/Icon/Trail/Trail7Img.png]]
        },
        [8] = {
            Index = 8,
            TrailId = 108,
            Name = [[8-Star Trail]],
            Price = 7.56e+19,
            TrainingRate = 8.5,
            DevGoodId = nil,
            ModelId = [[Effects.Trail8]],
            Img = [[sandboxId://UI/Icon/Trail/Trail8Img.png]]
        },
        [9] = {
            Index = 9,
            TrailId = 109,
            Name = [[9-Star Trail]],
            Price = 1.18e+22,
            TrainingRate = 9.5,
            DevGoodId = nil,
            ModelId = [[Effects.Trail9]],
            Img = [[sandboxId://UI/Icon/Trail/Trail9Img.png]]
        },
        [10] = {
            Index = 10,
            TrailId = 110,
            Name = [[10-Star Trail]],
            Price = 1.649999999999999945474048e+24,
            TrainingRate = 12.5,
            DevGoodId = nil,
            ModelId = [[Effects.Trail10]],
            Img = [[sandboxId://UI/Icon/Trail/Trail10Img.png]]
        },
        [11] = {
            Index = 11,
            TrailId = 111,
            Name = [[11-Star Trail]],
            Price = 2.27000000000000009613344768e+26,
            TrainingRate = 15.9,
            DevGoodId = nil,
            ModelId = [[Effects.Trail11]],
            Img = [[sandboxId://UI/Icon/Trail/Trail11Img.png]]
        },
        [12] = {
            Index = 12,
            TrailId = 112,
            Name = [[12-Star Trail]],
            Price = 3.0000000000000000948382466048e+28,
            TrainingRate = 19.7,
            DevGoodId = nil,
            ModelId = [[Effects.Trail12]],
            Img = [[sandboxId://UI/Icon/Trail/Trail12Img.png]]
        },
        [13] = {
            Index = 13,
            TrailId = 113,
            Name = [[13-Star Trail]],
            Price = 2.2299999999999999233084734046208e+31,
            TrainingRate = 21.3,
            DevGoodId = nil,
            ModelId = [[Effects.Trail13]],
            Img = [[sandboxId://UI/Icon/Trail/Trail13Img.png]]
        },
        [14] = {
            Index = 14,
            TrailId = 114,
            Name = [[14-Star Trail]],
            Price = 3.28999999999999980364868737826816e+33,
            TrainingRate = 22.9,
            DevGoodId = nil,
            ModelId = [[Effects.Trail14]],
            Img = [[sandboxId://UI/Icon/Trail/Trail14Img.png]]
        },
        [15] = {
            Index = 15,
            TrailId = 115,
            Name = [[15-Star Trail]],
            Price = 4.78000000000000000502155017763946496e+35,
            TrainingRate = 24.5,
            DevGoodId = nil,
            ModelId = [[Effects.Trail15]],
            Img = [[sandboxId://UI/Icon/Trail/Trail15Img.png]]
        },
        [16] = {
            Index = 16,
            TrailId = 116,
            Name = [[16-Star Trail]],
            Price = 6.7200000000000001433956886673113481216e+37,
            TrainingRate = 26.1,
            DevGoodId = nil,
            ModelId = [[Effects.Trail16]],
            Img = [[sandboxId://UI/Icon/Trail/Trail16Img.png]]
        },
        [17] = {
            Index = 17,
            TrailId = 117,
            Name = [[17-Star Trail]],
            Price = 9.610000000000000053779986854268576464896e+39,
            TrainingRate = 27.7,
            DevGoodId = nil,
            ModelId = [[Effects.Trail17]],
            Img = [[sandboxId://UI/Icon/Trail/Trail17Img.png]]
        }
    },
    AreaRefreshData = {
        [1] = {
            Index = 1,
            AreaId = 1,
            RewardPool = {
                [1] = {
                    x = 1,
                    y = 35
                },
                [2] = {
                    x = 2,
                    y = 30
                },
                [3] = {
                    x = 3,
                    y = 20
                },
                [4] = {
                    x = 4,
                    y = 15
                },
            },
            ObjectType = [[SItemObjectClass]]
        },
        [2] = {
            Index = 2,
            AreaId = 2,
            RewardPool = {
                [1] = {
                    x = 5,
                    y = 35
                },
                [2] = {
                    x = 6,
                    y = 30
                },
                [3] = {
                    x = 7,
                    y = 20
                },
                [4] = {
                    x = 8,
                    y = 15
                },
            },
            ObjectType = [[SItemObjectClass]]
        },
        [3] = {
            Index = 3,
            AreaId = 3,
            RewardPool = {
                [1] = {
                    x = 9,
                    y = 35
                },
                [2] = {
                    x = 10,
                    y = 30
                },
                [3] = {
                    x = 11,
                    y = 20
                },
                [4] = {
                    x = 12,
                    y = 15
                },
            },
            ObjectType = [[SItemObjectClass]]
        },
        [4] = {
            Index = 4,
            AreaId = 4,
            RewardPool = {
                [1] = {
                    x = 13,
                    y = 35
                },
                [2] = {
                    x = 14,
                    y = 30
                },
                [3] = {
                    x = 15,
                    y = 20
                },
                [4] = {
                    x = 16,
                    y = 15
                },
            },
            ObjectType = [[SItemObjectClass]]
        },
        [5] = {
            Index = 5,
            AreaId = 5,
            RewardPool = {
                [1] = {
                    x = 17,
                    y = 35
                },
                [2] = {
                    x = 18,
                    y = 30
                },
                [3] = {
                    x = 19,
                    y = 20
                },
                [4] = {
                    x = 20,
                    y = 15
                },
            },
            ObjectType = [[SItemObjectClass]]
        },
        [6] = {
            Index = 6,
            AreaId = 6,
            RewardPool = {
                [1] = {
                    x = 21,
                    y = 35
                },
                [2] = {
                    x = 22,
                    y = 30
                },
                [3] = {
                    x = 23,
                    y = 20
                },
                [4] = {
                    x = 24,
                    y = 15
                },
            },
            ObjectType = [[SItemObjectClass]]
        },
        [7] = {
            Index = 7,
            AreaId = 7,
            RewardPool = {
                [1] = {
                    x = 25,
                    y = 35
                },
                [2] = {
                    x = 26,
                    y = 30
                },
                [3] = {
                    x = 27,
                    y = 20
                },
                [4] = {
                    x = 28,
                    y = 15
                },
            },
            ObjectType = [[SItemObjectClass]]
        },
        [8] = {
            Index = 8,
            AreaId = 8,
            RewardPool = {
                [1] = {
                    x = 29,
                    y = 35
                },
                [2] = {
                    x = 30,
                    y = 30
                },
                [3] = {
                    x = 31,
                    y = 20
                },
                [4] = {
                    x = 32,
                    y = 15
                },
            },
            ObjectType = [[SItemObjectClass]]
        },
        [9] = {
            Index = 9,
            AreaId = 9,
            RewardPool = {
                [1] = {
                    x = 33,
                    y = 35
                },
                [2] = {
                    x = 34,
                    y = 30
                },
                [3] = {
                    x = 35,
                    y = 20
                },
                [4] = {
                    x = 36,
                    y = 15
                },
            },
            ObjectType = [[SItemObjectClass]]
        },
        [10] = {
            Index = 10,
            AreaId = 10,
            RewardPool = {
                [1] = {
                    x = 37,
                    y = 35
                },
                [2] = {
                    x = 38,
                    y = 30
                },
                [3] = {
                    x = 39,
                    y = 20
                },
                [4] = {
                    x = 40,
                    y = 15
                },
            },
            ObjectType = [[SItemObjectClass]]
        },
        [11] = {
            Index = 11,
            AreaId = 11,
            RewardPool = {
                [1] = {
                    x = 41,
                    y = 35
                },
                [2] = {
                    x = 42,
                    y = 30
                },
                [3] = {
                    x = 43,
                    y = 20
                },
                [4] = {
                    x = 44,
                    y = 15
                },
            },
            ObjectType = [[SItemObjectClass]]
        },
        [12] = {
            Index = 12,
            AreaId = 12,
            RewardPool = {
                [1] = {
                    x = 45,
                    y = 35
                },
                [2] = {
                    x = 46,
                    y = 30
                },
                [3] = {
                    x = 47,
                    y = 20
                },
                [4] = {
                    x = 48,
                    y = 15
                },
            },
            ObjectType = [[SItemObjectClass]]
        },
        [13] = {
            Index = 13,
            AreaId = 13,
            RewardPool = {
                [1] = {
                    x = 49,
                    y = 35
                },
                [2] = {
                    x = 50,
                    y = 30
                },
                [3] = {
                    x = 51,
                    y = 20
                },
                [4] = {
                    x = 52,
                    y = 15
                },
            },
            ObjectType = [[SItemObjectClass]]
        },
        [14] = {
            Index = 14,
            AreaId = 14,
            RewardPool = {
                [1] = {
                    x = 53,
                    y = 35
                },
                [2] = {
                    x = 54,
                    y = 30
                },
                [3] = {
                    x = 55,
                    y = 20
                },
                [4] = {
                    x = 56,
                    y = 15
                },
            },
            ObjectType = [[SItemObjectClass]]
        },
        [15] = {
            Index = 15,
            AreaId = 15,
            RewardPool = {
                [1] = {
                    x = 57,
                    y = 35
                },
                [2] = {
                    x = 58,
                    y = 30
                },
                [3] = {
                    x = 59,
                    y = 20
                },
                [4] = {
                    x = 60,
                    y = 15
                },
            },
            ObjectType = [[SItemObjectClass]]
        },
        [16] = {
            Index = 16,
            AreaId = 16,
            RewardPool = {
                [1] = {
                    x = 61,
                    y = 35
                },
                [2] = {
                    x = 62,
                    y = 30
                },
                [3] = {
                    x = 63,
                    y = 20
                },
                [4] = {
                    x = 64,
                    y = 15
                },
            },
            ObjectType = [[SItemObjectClass]]
        },
        [17] = {
            Index = 17,
            AreaId = 17,
            RewardPool = {
                [1] = {
                    x = 65,
                    y = 35
                },
                [2] = {
                    x = 66,
                    y = 30
                },
                [3] = {
                    x = 67,
                    y = 20
                },
                [4] = {
                    x = 68,
                    y = 15
                },
            },
            ObjectType = [[SItemObjectClass]]
        },
        [18] = {
            Index = 18,
            AreaId = 18,
            RewardPool = {
                [1] = {
                    x = 69,
                    y = 35
                },
                [2] = {
                    x = 70,
                    y = 30
                },
                [3] = {
                    x = 71,
                    y = 20
                },
                [4] = {
                    x = 72,
                    y = 15
                },
            },
            ObjectType = [[SItemObjectClass]]
        },
        [19] = {
            Index = 19,
            AreaId = 19,
            RewardPool = {
                [1] = {
                    x = 73,
                    y = 35
                },
                [2] = {
                    x = 74,
                    y = 30
                },
                [3] = {
                    x = 75,
                    y = 20
                },
                [4] = {
                    x = 76,
                    y = 15
                },
            },
            ObjectType = [[SItemObjectClass]]
        },
        [20] = {
            Index = 20,
            AreaId = 20,
            RewardPool = {
                [1] = {
                    x = 77,
                    y = 35
                },
                [2] = {
                    x = 78,
                    y = 30
                },
                [3] = {
                    x = 79,
                    y = 20
                },
                [4] = {
                    x = 80,
                    y = 15
                },
            },
            ObjectType = [[SItemObjectClass]]
        },
        [21] = {
            Index = 21,
            AreaId = 21,
            RewardPool = {
                [1] = {
                    x = 81,
                    y = 35
                },
                [2] = {
                    x = 82,
                    y = 30
                },
                [3] = {
                    x = 83,
                    y = 20
                },
                [4] = {
                    x = 84,
                    y = 15
                },
            },
            ObjectType = [[SItemObjectClass]]
        },
        [22] = {
            Index = 22,
            AreaId = 22,
            RewardPool = {
                [1] = {
                    x = 85,
                    y = 35
                },
                [2] = {
                    x = 86,
                    y = 30
                },
                [3] = {
                    x = 87,
                    y = 20
                },
                [4] = {
                    x = 88,
                    y = 15
                },
            },
            ObjectType = [[SItemObjectClass]]
        },
        [23] = {
            Index = 23,
            AreaId = 23,
            RewardPool = {
                [1] = {
                    x = 89,
                    y = 35
                },
                [2] = {
                    x = 90,
                    y = 30
                },
                [3] = {
                    x = 91,
                    y = 20
                },
                [4] = {
                    x = 92,
                    y = 15
                },
            },
            ObjectType = [[SItemObjectClass]]
        },
        [24] = {
            Index = 24,
            AreaId = 24,
            RewardPool = {
                [1] = {
                    x = 93,
                    y = 35
                },
                [2] = {
                    x = 94,
                    y = 30
                },
                [3] = {
                    x = 95,
                    y = 20
                },
                [4] = {
                    x = 96,
                    y = 15
                },
            },
            ObjectType = [[SItemObjectClass]]
        },
        [25] = {
            Index = 25,
            AreaId = 25,
            RewardPool = {
                [1] = {
                    x = 97,
                    y = 35
                },
                [2] = {
                    x = 98,
                    y = 30
                },
                [3] = {
                    x = 99,
                    y = 20
                },
                [4] = {
                    x = 100,
                    y = 15
                },
            },
            ObjectType = [[SItemObjectClass]]
        },
        [26] = {
            Index = 26,
            AreaId = 26,
            RewardPool = {
                [1] = {
                    x = 101,
                    y = 35
                },
                [2] = {
                    x = 102,
                    y = 30
                },
                [3] = {
                    x = 103,
                    y = 20
                },
                [4] = {
                    x = 104,
                    y = 15
                },
            },
            ObjectType = [[SItemObjectClass]]
        },
        [27] = {
            Index = 27,
            AreaId = 27,
            RewardPool = {
                [1] = {
                    x = 105,
                    y = 35
                },
                [2] = {
                    x = 106,
                    y = 30
                },
                [3] = {
                    x = 107,
                    y = 20
                },
                [4] = {
                    x = 108,
                    y = 15
                },
            },
            ObjectType = [[SItemObjectClass]]
        },
        [28] = {
            Index = 28,
            AreaId = 28,
            RewardPool = {
                [1] = {
                    x = 109,
                    y = 35
                },
                [2] = {
                    x = 110,
                    y = 30
                },
                [3] = {
                    x = 111,
                    y = 20
                },
                [4] = {
                    x = 112,
                    y = 15
                },
            },
            ObjectType = [[SItemObjectClass]]
        },
        [29] = {
            Index = 29,
            AreaId = 29,
            RewardPool = {
                [1] = {
                    x = 113,
                    y = 35
                },
                [2] = {
                    x = 114,
                    y = 30
                },
                [3] = {
                    x = 115,
                    y = 20
                },
                [4] = {
                    x = 116,
                    y = 15
                },
            },
            ObjectType = [[SItemObjectClass]]
        },
        [30] = {
            Index = 30,
            AreaId = 30,
            RewardPool = {
                [1] = {
                    x = 117,
                    y = 35
                },
                [2] = {
                    x = 118,
                    y = 30
                },
                [3] = {
                    x = 119,
                    y = 20
                },
                [4] = {
                    x = 120,
                    y = 15
                },
            },
            ObjectType = [[SItemObjectClass]]
        },
        [31] = {
            Index = 31,
            AreaId = 31,
            RewardPool = {
                [1] = {
                    x = 121,
                    y = 35
                },
                [2] = {
                    x = 122,
                    y = 30
                },
                [3] = {
                    x = 123,
                    y = 20
                },
                [4] = {
                    x = 124,
                    y = 15
                },
            },
            ObjectType = [[SItemObjectClass]]
        },
        [32] = {
            Index = 32,
            AreaId = 32,
            RewardPool = {
                [1] = {
                    x = 125,
                    y = 35
                },
                [2] = {
                    x = 126,
                    y = 30
                },
                [3] = {
                    x = 127,
                    y = 20
                },
                [4] = {
                    x = 128,
                    y = 15
                },
            },
            ObjectType = [[SItemObjectClass]]
        },
        [33] = {
            Index = 33,
            AreaId = 33,
            RewardPool = {
                [1] = {
                    x = 129,
                    y = 35
                },
                [2] = {
                    x = 130,
                    y = 30
                },
                [3] = {
                    x = 131,
                    y = 20
                },
                [4] = {
                    x = 132,
                    y = 15
                },
            },
            ObjectType = [[SItemObjectClass]]
        },
        [34] = {
            Index = 34,
            AreaId = 34,
            RewardPool = {
                [1] = {
                    x = 133,
                    y = 35
                },
                [2] = {
                    x = 134,
                    y = 30
                },
                [3] = {
                    x = 135,
                    y = 20
                },
                [4] = {
                    x = 136,
                    y = 15
                },
            },
            ObjectType = [[SItemObjectClass]]
        },
        [35] = {
            Index = 35,
            AreaId = 35,
            RewardPool = {
                [1] = {
                    x = 137,
                    y = 35
                },
                [2] = {
                    x = 138,
                    y = 30
                },
                [3] = {
                    x = 139,
                    y = 20
                },
                [4] = {
                    x = 140,
                    y = 15
                },
            },
            ObjectType = [[SItemObjectClass]]
        },
        [36] = {
            Index = 36,
            AreaId = 36,
            RewardPool = {
                [1] = {
                    x = 141,
                    y = 35
                },
                [2] = {
                    x = 142,
                    y = 30
                },
                [3] = {
                    x = 143,
                    y = 20
                },
                [4] = {
                    x = 144,
                    y = 15
                },
            },
            ObjectType = [[SItemObjectClass]]
        },
        [37] = {
            Index = 37,
            AreaId = 37,
            RewardPool = {
                [1] = {
                    x = 145,
                    y = 35
                },
                [2] = {
                    x = 146,
                    y = 30
                },
                [3] = {
                    x = 147,
                    y = 20
                },
                [4] = {
                    x = 148,
                    y = 15
                },
            },
            ObjectType = [[SItemObjectClass]]
        },
        [38] = {
            Index = 38,
            AreaId = 38,
            RewardPool = {
                [1] = {
                    x = 149,
                    y = 35
                },
                [2] = {
                    x = 150,
                    y = 30
                },
                [3] = {
                    x = 151,
                    y = 20
                },
                [4] = {
                    x = 152,
                    y = 15
                },
            },
            ObjectType = [[SItemObjectClass]]
        },
        [39] = {
            Index = 39,
            AreaId = 39,
            RewardPool = {
                [1] = {
                    x = 153,
                    y = 35
                },
                [2] = {
                    x = 154,
                    y = 30
                },
                [3] = {
                    x = 155,
                    y = 20
                },
                [4] = {
                    x = 156,
                    y = 15
                },
            },
            ObjectType = [[SItemObjectClass]]
        },
        [40] = {
            Index = 40,
            AreaId = 40,
            RewardPool = {
                [1] = {
                    x = 157,
                    y = 35
                },
                [2] = {
                    x = 158,
                    y = 30
                },
                [3] = {
                    x = 159,
                    y = 20
                },
                [4] = {
                    x = 160,
                    y = 15
                },
            },
            ObjectType = [[SItemObjectClass]]
        },
        [41] = {
            Index = 41,
            AreaId = 41,
            RewardPool = {
                [1] = {
                    x = 161,
                    y = 35
                },
                [2] = {
                    x = 162,
                    y = 30
                },
                [3] = {
                    x = 163,
                    y = 20
                },
                [4] = {
                    x = 164,
                    y = 15
                },
            },
            ObjectType = [[SItemObjectClass]]
        },
        [42] = {
            Index = 42,
            AreaId = 42,
            RewardPool = {
                [1] = {
                    x = 165,
                    y = 35
                },
                [2] = {
                    x = 166,
                    y = 30
                },
                [3] = {
                    x = 167,
                    y = 20
                },
                [4] = {
                    x = 168,
                    y = 15
                },
            },
            ObjectType = [[SItemObjectClass]]
        },
        [43] = {
            Index = 43,
            AreaId = 43,
            RewardPool = {
                [1] = {
                    x = 169,
                    y = 35
                },
                [2] = {
                    x = 170,
                    y = 30
                },
                [3] = {
                    x = 171,
                    y = 20
                },
                [4] = {
                    x = 172,
                    y = 15
                },
            },
            ObjectType = [[SItemObjectClass]]
        },
        [44] = {
            Index = 44,
            AreaId = 44,
            RewardPool = {
                [1] = {
                    x = 173,
                    y = 35
                },
                [2] = {
                    x = 174,
                    y = 30
                },
                [3] = {
                    x = 175,
                    y = 20
                },
                [4] = {
                    x = 176,
                    y = 15
                },
            },
            ObjectType = [[SItemObjectClass]]
        },
        [45] = {
            Index = 45,
            AreaId = 45,
            RewardPool = {
                [1] = {
                    x = 177,
                    y = 35
                },
                [2] = {
                    x = 178,
                    y = 30
                },
                [3] = {
                    x = 179,
                    y = 20
                },
                [4] = {
                    x = 180,
                    y = 15
                },
            },
            ObjectType = [[SItemObjectClass]]
        },
        [46] = {
            Index = 46,
            AreaId = 46,
            RewardPool = {
                [1] = {
                    x = 181,
                    y = 35
                },
                [2] = {
                    x = 182,
                    y = 30
                },
                [3] = {
                    x = 183,
                    y = 20
                },
                [4] = {
                    x = 184,
                    y = 15
                },
            },
            ObjectType = [[SItemObjectClass]]
        },
        [47] = {
            Index = 47,
            AreaId = 47,
            RewardPool = {
                [1] = {
                    x = 185,
                    y = 35
                },
                [2] = {
                    x = 186,
                    y = 30
                },
                [3] = {
                    x = 187,
                    y = 20
                },
                [4] = {
                    x = 188,
                    y = 15
                },
            },
            ObjectType = [[SItemObjectClass]]
        },
        [48] = {
            Index = 48,
            AreaId = 48,
            RewardPool = {
                [1] = {
                    x = 189,
                    y = 35
                },
                [2] = {
                    x = 190,
                    y = 30
                },
                [3] = {
                    x = 191,
                    y = 20
                },
                [4] = {
                    x = 192,
                    y = 15
                },
            },
            ObjectType = [[SItemObjectClass]]
        },
        [49] = {
            Index = 49,
            AreaId = 49,
            RewardPool = {
                [1] = {
                    x = 193,
                    y = 35
                },
                [2] = {
                    x = 194,
                    y = 30
                },
                [3] = {
                    x = 195,
                    y = 20
                },
                [4] = {
                    x = 196,
                    y = 15
                },
            },
            ObjectType = [[SItemObjectClass]]
        },
        [50] = {
            Index = 50,
            AreaId = 50,
            RewardPool = {
                [1] = {
                    x = 197,
                    y = 35
                },
                [2] = {
                    x = 198,
                    y = 30
                },
                [3] = {
                    x = 199,
                    y = 20
                },
                [4] = {
                    x = 200,
                    y = 15
                },
            },
            ObjectType = [[SItemObjectClass]]
        },
        [51] = {
            Index = 51,
            AreaId = 51,
            RewardPool = {
                [1] = {
                    x = 201,
                    y = 35
                },
                [2] = {
                    x = 202,
                    y = 30
                },
                [3] = {
                    x = 203,
                    y = 20
                },
                [4] = {
                    x = 204,
                    y = 15
                },
            },
            ObjectType = [[SItemObjectClass]]
        },
        [52] = {
            Index = 52,
            AreaId = 52,
            RewardPool = {
                [1] = {
                    x = 205,
                    y = 35
                },
                [2] = {
                    x = 206,
                    y = 30
                },
                [3] = {
                    x = 207,
                    y = 20
                },
                [4] = {
                    x = 208,
                    y = 15
                },
            },
            ObjectType = [[SItemObjectClass]]
        }
    },
    ItemData = {
        [1] = {
            Index = 1,
            Id = 1,
            Name = [[Lighter]],
            Pirce = 3,
            Quality = 1,
            IconId = [[sandboxId://Model/Item/png/046_Zippo.png]],
            DisplayModelId = [[sandboxId://Model/Item/obj/046_Zippo.obj]],
            ModelType = [[Item]]
        },
        [2] = {
            Index = 2,
            Id = 2,
            Name = [[Mineral Water]],
            Pirce = 4,
            Quality = 1,
            IconId = [[sandboxId://Model/Item/png/016_Water01.png]],
            DisplayModelId = [[sandboxId://Model/Item/obj/016_Water01.obj]],
            ModelType = [[Item]]
        },
        [3] = {
            Index = 3,
            Id = 3,
            Name = [[Purified Water]],
            Pirce = 6,
            Quality = 1,
            IconId = [[sandboxId://Model/Item/png/017_Water02.png]],
            DisplayModelId = [[sandboxId://Model/Item/obj/017_Water02.obj]],
            ModelType = [[Item]]
        },
        [4] = {
            Index = 4,
            Id = 4,
            Name = [[Soda Water]],
            Pirce = 8,
            Quality = 1,
            IconId = [[sandboxId://Model/Item/png/018_Water03.png]],
            DisplayModelId = [[sandboxId://Model/Item/obj/018_Water03.obj]],
            ModelType = [[Item]]
        },
        [5] = {
            Index = 5,
            Id = 5,
            Name = [[Bucket]],
            Pirce = 13,
            Quality = 2,
            IconId = [[sandboxId://Model/Item/png/081_Drum01.png]],
            DisplayModelId = [[sandboxId://Model/Item/obj/081_Drum01.obj]],
            ModelType = [[Item]]
        },
        [6] = {
            Index = 6,
            Id = 6,
            Name = [[Glass Bottle]],
            Pirce = 20,
            Quality = 2,
            IconId = [[sandboxId://Model/Item/png/021_Bottle01.png]],
            DisplayModelId = [[sandboxId://Model/Item/obj/021_Bottle01.obj]],
            ModelType = [[Item]]
        },
        [7] = {
            Index = 7,
            Id = 7,
            Name = [[Beer Bottle]],
            Pirce = 30,
            Quality = 2,
            IconId = [[sandboxId://Model/Item/png/022_Bottle02.png]],
            DisplayModelId = [[sandboxId://Model/Item/obj/022_Bottle02.obj]],
            ModelType = [[Item]]
        },
        [8] = {
            Index = 8,
            Id = 8,
            Name = [[Wine Bottle]],
            Pirce = 38,
            Quality = 2,
            IconId = [[sandboxId://Model/Item/png/023_Bottle03.png]],
            DisplayModelId = [[sandboxId://Model/Item/obj/023_Bottle03.obj]],
            ModelType = [[Item]]
        },
        [9] = {
            Index = 9,
            Id = 9,
            Name = [[Champagne Bottle]],
            Pirce = 63,
            Quality = 3,
            IconId = [[sandboxId://Model/Item/png/024_Bottle04.png]],
            DisplayModelId = [[sandboxId://Model/Item/obj/024_Bottle04.obj]],
            ModelType = [[Item]]
        },
        [10] = {
            Index = 10,
            Id = 10,
            Name = [[Collectible Wine Bottle]],
            Pirce = 100,
            Quality = 3,
            IconId = [[sandboxId://Model/Item/png/025_Bottle05.png]],
            DisplayModelId = [[sandboxId://Model/Item/obj/025_Bottle05.obj]],
            ModelType = [[Item]]
        },
        [11] = {
            Index = 11,
            Id = 11,
            Name = [[Steel Nail]],
            Pirce = 150,
            Quality = 3,
            IconId = [[sandboxId://Model/Item/png/001_Nail.png]],
            DisplayModelId = [[sandboxId://Model/Item/obj/001_Nail.obj]],
            ModelType = [[Item]]
        },
        [12] = {
            Index = 12,
            Id = 12,
            Name = [[Tablet]],
            Pirce = 188,
            Quality = 3,
            IconId = [[sandboxId://Model/Item/png/002_Pill.png]],
            DisplayModelId = [[sandboxId://Model/Item/obj/002_Pill.obj]],
            ModelType = [[Item]]
        },
        [13] = {
            Index = 13,
            Id = 13,
            Name = [[Cookie]],
            Pirce = 313,
            Quality = 4,
            IconId = [[sandboxId://Model/Item/png/006_Biscuit01.png]],
            DisplayModelId = [[sandboxId://Model/Item/obj/006_Biscuit01.obj]],
            ModelType = [[Item]]
        },
        [14] = {
            Index = 14,
            Id = 14,
            Name = [[Soda Cracker]],
            Pirce = 500,
            Quality = 4,
            IconId = [[sandboxId://Model/Item/png/007_Biscuit02.png]],
            DisplayModelId = [[sandboxId://Model/Item/obj/007_Biscuit02.obj]],
            ModelType = [[Item]]
        },
        [15] = {
            Index = 15,
            Id = 15,
            Name = [[Sandwich Cookie]],
            Pirce = 750,
            Quality = 4,
            IconId = [[sandboxId://Model/Item/png/008_Biscuit03.png]],
            DisplayModelId = [[sandboxId://Model/Item/obj/008_Biscuit03.obj]],
            ModelType = [[Item]]
        },
        [16] = {
            Index = 16,
            Id = 16,
            Name = [[Dark Chocolate]],
            Pirce = 938,
            Quality = 4,
            IconId = [[sandboxId://Model/Item/png/009_Chocolate01.png]],
            DisplayModelId = [[sandboxId://Model/Item/obj/009_Chocolate01.obj]],
            ModelType = [[Item]]
        },
        [17] = {
            Index = 17,
            Id = 17,
            Name = [[Milk Chocolate]],
            Pirce = 1563,
            Quality = 5,
            IconId = [[sandboxId://Model/Item/png/010_Chocolate02.png]],
            DisplayModelId = [[sandboxId://Model/Item/obj/010_Chocolate02.obj]],
            ModelType = [[Item]]
        },
        [18] = {
            Index = 18,
            Id = 18,
            Name = [[Cocoa Drink]],
            Pirce = 2500,
            Quality = 5,
            IconId = [[sandboxId://Model/Item/png/011_Chocolate_Drink.png]],
            DisplayModelId = [[sandboxId://Model/Item/obj/011_Chocolate_Drink.obj]],
            ModelType = [[Item]]
        },
        [19] = {
            Index = 19,
            Id = 19,
            Name = [[Honey]],
            Pirce = 3750,
            Quality = 5,
            IconId = [[sandboxId://Model/Item/png/012_Honey01.png]],
            DisplayModelId = [[sandboxId://Model/Item/obj/012_Honey01.obj]],
            ModelType = [[Item]]
        },
        [20] = {
            Index = 20,
            Id = 20,
            Name = [[Wild Honey]],
            Pirce = 4688,
            Quality = 5,
            IconId = [[sandboxId://Model/Item/png/013_Honey02.png]],
            DisplayModelId = [[sandboxId://Model/Item/obj/013_Honey02.obj]],
            ModelType = [[Item]]
        },
        [21] = {
            Index = 21,
            Id = 21,
            Name = [[Strawberry Jam]],
            Pirce = 7800,
            Quality = 6,
            IconId = [[sandboxId://Model/Item/png/014_Jam01.png]],
            DisplayModelId = [[sandboxId://Model/Item/obj/014_Jam01.obj]],
            ModelType = [[Item]]
        },
        [22] = {
            Index = 22,
            Id = 22,
            Name = [[Blueberry Jam]],
            Pirce = 12480,
            Quality = 6,
            IconId = [[sandboxId://Model/Item/png/015_Jam02.png]],
            DisplayModelId = [[sandboxId://Model/Item/obj/015_Jam02.obj]],
            ModelType = [[Item]]
        },
        [23] = {
            Index = 23,
            Id = 23,
            Name = [[Canned Meat]],
            Pirce = 18720,
            Quality = 6,
            IconId = [[sandboxId://Model/Item/png/026_Can01.png]],
            DisplayModelId = [[sandboxId://Model/Item/obj/026_Can01.obj]],
            ModelType = [[Item]]
        },
        [24] = {
            Index = 24,
            Id = 24,
            Name = [[Canned Fish]],
            Pirce = 23400,
            Quality = 6,
            IconId = [[sandboxId://Model/Item/png/027_Can02.png]],
            DisplayModelId = [[sandboxId://Model/Item/obj/027_Can02.obj]],
            ModelType = [[Item]]
        },
        [25] = {
            Index = 25,
            Id = 25,
            Name = [[Canned Fruit]],
            Pirce = 39050,
            Quality = 7,
            IconId = [[sandboxId://Model/Item/png/028_Can03.png]],
            DisplayModelId = [[sandboxId://Model/Item/obj/028_Can03.obj]],
            ModelType = [[Item]]
        },
        [26] = {
            Index = 26,
            Id = 26,
            Name = [[Luncheon Meat]],
            Pirce = 62480,
            Quality = 7,
            IconId = [[sandboxId://Model/Item/png/029_Can04.png]],
            DisplayModelId = [[sandboxId://Model/Item/obj/029_Can04.obj]],
            ModelType = [[Item]]
        },
        [27] = {
            Index = 27,
            Id = 27,
            Name = [[Canned Beans]],
            Pirce = 93720,
            Quality = 7,
            IconId = [[sandboxId://Model/Item/png/030_Can05.png]],
            DisplayModelId = [[sandboxId://Model/Item/obj/030_Can05.obj]],
            ModelType = [[Item]]
        },
        [28] = {
            Index = 28,
            Id = 28,
            Name = [[Canned Rations]],
            Pirce = 117150,
            Quality = 7,
            IconId = [[sandboxId://Model/Item/png/031_Can06.png]],
            DisplayModelId = [[sandboxId://Model/Item/obj/031_Can06.obj]],
            ModelType = [[Item]]
        },
        [29] = {
            Index = 29,
            Id = 29,
            Name = [[Premium Canned Food]],
            Pirce = 195500,
            Quality = 8,
            IconId = [[sandboxId://Model/Item/png/032_Can07.png]],
            DisplayModelId = [[sandboxId://Model/Item/obj/032_Can07.obj]],
            ModelType = [[Item]]
        },
        [30] = {
            Index = 30,
            Id = 30,
            Name = [[Detergent]],
            Pirce = 312800,
            Quality = 8,
            IconId = [[sandboxId://Model/Item/png/042_Detergent.png]],
            DisplayModelId = [[sandboxId://Model/Item/obj/042_Detergent.obj]],
            ModelType = [[Item]]
        },
        [31] = {
            Index = 31,
            Id = 31,
            Name = [[Bleach]],
            Pirce = 469200,
            Quality = 8,
            IconId = [[sandboxId://Model/Item/png/043_Bleach.png]],
            DisplayModelId = [[sandboxId://Model/Item/obj/043_Bleach.obj]],
            ModelType = [[Item]]
        },
        [32] = {
            Index = 32,
            Id = 32,
            Name = [[Lubricating Oil]],
            Pirce = 586500,
            Quality = 8,
            IconId = [[sandboxId://Model/Item/png/044_WD40.png]],
            DisplayModelId = [[sandboxId://Model/Item/obj/044_WD40.obj]],
            ModelType = [[Item]]
        },
        [33] = {
            Index = 33,
            Id = 33,
            Name = [[Small Oil Can]],
            Pirce = 975000,
            Quality = 9,
            IconId = [[sandboxId://Model/Item/png/047_Oilcan01.png]],
            DisplayModelId = [[sandboxId://Model/Item/obj/047_Oilcan01.obj]],
            ModelType = [[Item]]
        },
        [34] = {
            Index = 34,
            Id = 34,
            Name = [[Sports Bottle]],
            Pirce = 1.56e+6,
            Quality = 6,
            IconId = [[sandboxId://Model/Item/png/019_Waterbottle01.png]],
            DisplayModelId = [[sandboxId://Model/Item/obj/019_Waterbottle01.obj]],
            ModelType = [[Item]]
        },
        [35] = {
            Index = 35,
            Id = 35,
            Name = [[Military Canteen]],
            Pirce = 2.34e+6,
            Quality = 7,
            IconId = [[sandboxId://Model/Item/png/020_Waterbottle02.png]],
            DisplayModelId = [[sandboxId://Model/Item/obj/020_Waterbottle02.obj]],
            ModelType = [[Item]]
        },
        [36] = {
            Index = 36,
            Id = 36,
            Name = [[Motor Oil Can]],
            Pirce = 2.925e+6,
            Quality = 9,
            IconId = [[sandboxId://Model/Item/png/048_Oilcan02.png]],
            DisplayModelId = [[sandboxId://Model/Item/obj/048_Oilcan02.obj]],
            ModelType = [[Item]]
        },
        [37] = {
            Index = 37,
            Id = 37,
            Name = [[Fuel Can]],
            Pirce = 4.885e+6,
            Quality = 10,
            IconId = [[sandboxId://Model/Item/png/049_Oilcan03.png]],
            DisplayModelId = [[sandboxId://Model/Item/obj/049_Oilcan03.obj]],
            ModelType = [[Item]]
        },
        [38] = {
            Index = 38,
            Id = 38,
            Name = [[Top Hat]],
            Pirce = 7.816e+6,
            Quality = 10,
            IconId = [[sandboxId://Model/Item/png/055_Hat.png]],
            DisplayModelId = [[sandboxId://Model/Item/obj/055_Hat.obj]],
            ModelType = [[Item]]
        },
        [39] = {
            Index = 39,
            Id = 39,
            Name = [[Baseball Cap]],
            Pirce = 1.1724e+7,
            Quality = 10,
            IconId = [[sandboxId://Model/Item/png/056_Cap_A_0.png]],
            DisplayModelId = [[sandboxId://Model/Item/obj/056_Cap_A_0.obj]],
            ModelType = [[Item]]
        },
        [40] = {
            Index = 40,
            Id = 40,
            Name = [[Dark Glasses]],
            Pirce = 1.4655e+7,
            Quality = 10,
            IconId = [[sandboxId://Model/Item/png/057_Sunglass01.png]],
            DisplayModelId = [[sandboxId://Model/Item/obj/057_Sunglass01.obj]],
            ModelType = [[Item]]
        },
        [41] = {
            Index = 41,
            Id = 41,
            Name = [[Sunglasses]],
            Pirce = 2.44e+7,
            Quality = 11,
            IconId = [[sandboxId://Model/Item/png/058_Sunglass02.png]],
            DisplayModelId = [[sandboxId://Model/Item/obj/058_Sunglass02.obj]],
            ModelType = [[Item]]
        },
        [42] = {
            Index = 42,
            Id = 42,
            Name = [[Safety Goggles]],
            Pirce = 3.904e+7,
            Quality = 11,
            IconId = [[sandboxId://Model/Item/png/059_Goggle.png]],
            DisplayModelId = [[sandboxId://Model/Item/obj/059_Goggle.obj]],
            ModelType = [[Item]]
        },
        [43] = {
            Index = 43,
            Id = 43,
            Name = [[Tactical Goggles]],
            Pirce = 5.856e+7,
            Quality = 11,
            IconId = [[sandboxId://Model/Item/png/060_GoggleA.png]],
            DisplayModelId = [[sandboxId://Model/Item/obj/060_GoggleA.obj]],
            ModelType = [[Item]]
        },
        [44] = {
            Index = 44,
            Id = 44,
            Name = [[Face Mask]],
            Pirce = 7.32e+7,
            Quality = 11,
            IconId = [[sandboxId://Model/Item/png/061_MaskA.png]],
            DisplayModelId = [[sandboxId://Model/Item/obj/061_MaskA.obj]],
            ModelType = [[Item]]
        },
        [45] = {
            Index = 45,
            Id = 45,
            Name = [[Gas Mask]],
            Pirce = 1.22e+8,
            Quality = 12,
            IconId = [[sandboxId://Model/Item/png/062_GasMask01.png]],
            DisplayModelId = [[sandboxId://Model/Item/obj/062_GasMask01.obj]],
            ModelType = [[Item]]
        },
        [46] = {
            Index = 46,
            Id = 46,
            Name = [[Tactical Mask]],
            Pirce = 1.952e+8,
            Quality = 12,
            IconId = [[sandboxId://Model/Item/png/063_GasMask02.png]],
            DisplayModelId = [[sandboxId://Model/Item/obj/063_GasMask02.obj]],
            ModelType = [[Item]]
        },
        [47] = {
            Index = 47,
            Id = 47,
            Name = [[Leather Boots]],
            Pirce = 2.928e+8,
            Quality = 12,
            IconId = [[sandboxId://Model/Item/png/064_Boots01.png]],
            DisplayModelId = [[sandboxId://Model/Item/obj/064_Boots01.obj]],
            ModelType = [[Item]]
        },
        [48] = {
            Index = 48,
            Id = 48,
            Name = [[Rain Boots]],
            Pirce = 3.66e+8,
            Quality = 12,
            IconId = [[sandboxId://Model/Item/png/065_Boots02.png]],
            DisplayModelId = [[sandboxId://Model/Item/obj/065_Boots02.obj]],
            ModelType = [[Item]]
        },
        [49] = {
            Index = 49,
            Id = 49,
            Name = [[Hiking Boots]],
            Pirce = 6.1e+8,
            Quality = 13,
            IconId = [[sandboxId://Model/Item/png/066_Boots03.png]],
            DisplayModelId = [[sandboxId://Model/Item/obj/066_Boots03.obj]],
            ModelType = [[Item]]
        },
        [50] = {
            Index = 50,
            Id = 50,
            Name = [[Military Boots]],
            Pirce = 9.76e+8,
            Quality = 13,
            IconId = [[sandboxId://Model/Item/png/067_Boots04.png]],
            DisplayModelId = [[sandboxId://Model/Item/obj/067_Boots04.obj]],
            ModelType = [[Item]]
        },
        [51] = {
            Index = 51,
            Id = 51,
            Name = [[Bulletproof Vest]],
            Pirce = 1.464e+9,
            Quality = 13,
            IconId = [[sandboxId://Model/Item/png/068_BulletproofJacket01.png]],
            DisplayModelId = [[sandboxId://Model/Item/obj/068_BulletproofJacket01.obj]],
            ModelType = [[Item]]
        },
        [52] = {
            Index = 52,
            Id = 52,
            Name = [[Heavy Armor]],
            Pirce = 1.83e+9,
            Quality = 13,
            IconId = [[sandboxId://Model/Item/png/069_BulletproofJacket02.png]],
            DisplayModelId = [[sandboxId://Model/Item/obj/069_BulletproofJacket02.obj]],
            ModelType = [[Item]]
        },
        [53] = {
            Index = 53,
            Id = 53,
            Name = [[Hard Hat]],
            Pirce = 3.05e+9,
            Quality = 14,
            IconId = [[sandboxId://Model/Item/png/070_Helmet01.png]],
            DisplayModelId = [[sandboxId://Model/Item/obj/070_Helmet01.obj]],
            ModelType = [[Item]]
        },
        [54] = {
            Index = 54,
            Id = 54,
            Name = [[Cycling Helmet]],
            Pirce = 4.88e+9,
            Quality = 14,
            IconId = [[sandboxId://Model/Item/png/071_Helmet02.png]],
            DisplayModelId = [[sandboxId://Model/Item/obj/071_Helmet02.obj]],
            ModelType = [[Item]]
        },
        [55] = {
            Index = 55,
            Id = 55,
            Name = [[Riot Helmet]],
            Pirce = 7.32e+9,
            Quality = 14,
            IconId = [[sandboxId://Model/Item/png/072_Helmet03.png]],
            DisplayModelId = [[sandboxId://Model/Item/obj/072_Helmet03.obj]],
            ModelType = [[Item]]
        },
        [56] = {
            Index = 56,
            Id = 56,
            Name = [[Tactical Helmet]],
            Pirce = 9.15e+9,
            Quality = 14,
            IconId = [[sandboxId://Model/Item/png/073_Helmet04.png]],
            DisplayModelId = [[sandboxId://Model/Item/obj/073_Helmet04.obj]],
            ModelType = [[Item]]
        },
        [57] = {
            Index = 57,
            Id = 57,
            Name = [[Small Backpack]],
            Pirce = 1.525e+10,
            Quality = 15,
            IconId = [[sandboxId://Model/Item/png/074_Bag01.png]],
            DisplayModelId = [[sandboxId://Model/Item/obj/074_Bag01.obj]],
            ModelType = [[Item]]
        },
        [58] = {
            Index = 58,
            Id = 58,
            Name = [[Hiking Backpack]],
            Pirce = 2.44e+10,
            Quality = 15,
            IconId = [[sandboxId://Model/Item/png/075_Bag02.png]],
            DisplayModelId = [[sandboxId://Model/Item/obj/075_Bag02.obj]],
            ModelType = [[Item]]
        },
        [59] = {
            Index = 59,
            Id = 59,
            Name = [[Military Backpack]],
            Pirce = 3.66e+10,
            Quality = 15,
            IconId = [[sandboxId://Model/Item/png/076_Bag03.png]],
            DisplayModelId = [[sandboxId://Model/Item/obj/076_Bag03.obj]],
            ModelType = [[Item]]
        },
        [60] = {
            Index = 60,
            Id = 60,
            Name = [[Iron Pot]],
            Pirce = 4.575e+10,
            Quality = 15,
            IconId = [[sandboxId://Model/Item/png/080_Pot01.png]],
            DisplayModelId = [[sandboxId://Model/Item/obj/080_Pot01.obj]],
            ModelType = [[Item]]
        },
        [61] = {
            Index = 61,
            Id = 61,
            Name = [[Wooden Mallet]],
            Pirce = 7.65e+10,
            Quality = 16,
            IconId = [[sandboxId://Model/Item/png/096_Hammer01.png]],
            DisplayModelId = [[sandboxId://Model/Item/obj/096_Hammer01.obj]],
            ModelType = [[Item]]
        },
        [62] = {
            Index = 62,
            Id = 62,
            Name = [[Iron Hammer]],
            Pirce = 1.224e+11,
            Quality = 16,
            IconId = [[sandboxId://Model/Item/png/097_Hammer02.png]],
            DisplayModelId = [[sandboxId://Model/Item/obj/097_Hammer02.obj]],
            ModelType = [[Item]]
        },
        [63] = {
            Index = 63,
            Id = 63,
            Name = [[Sledgehammer]],
            Pirce = 1.836e+11,
            Quality = 16,
            IconId = [[sandboxId://Model/Item/png/098_Hammer03.png]],
            DisplayModelId = [[sandboxId://Model/Item/obj/098_Hammer03.obj]],
            ModelType = [[Item]]
        },
        [64] = {
            Index = 64,
            Id = 64,
            Name = [[Wrench]],
            Pirce = 2.295e+11,
            Quality = 16,
            IconId = [[sandboxId://Model/Item/png/099_Wrench01.png]],
            DisplayModelId = [[sandboxId://Model/Item/obj/099_Wrench01.obj]],
            ModelType = [[Item]]
        },
        [65] = {
            Index = 65,
            Id = 65,
            Name = [[Adjustable Wrench]],
            Pirce = 3.815e+11,
            Quality = 17,
            IconId = [[sandboxId://Model/Item/png/100_Wrench02.png]],
            DisplayModelId = [[sandboxId://Model/Item/obj/100_Wrench02.obj]],
            ModelType = [[Item]]
        },
        [66] = {
            Index = 66,
            Id = 66,
            Name = [[Pipe Wrench]],
            Pirce = 6.104e+11,
            Quality = 17,
            IconId = [[sandboxId://Model/Item/png/101_Wrench03.png]],
            DisplayModelId = [[sandboxId://Model/Item/obj/101_Wrench03.obj]],
            ModelType = [[Item]]
        },
        [67] = {
            Index = 67,
            Id = 67,
            Name = [[Entrenching Shovel]],
            Pirce = 9.156e+11,
            Quality = 17,
            IconId = [[sandboxId://Model/Item/png/102_Shovel01.png]],
            DisplayModelId = [[sandboxId://Model/Item/obj/102_Shovel01.obj]],
            ModelType = [[Item]]
        },
        [68] = {
            Index = 68,
            Id = 68,
            Name = [[Shovel]],
            Pirce = 1.1445e+12,
            Quality = 17,
            IconId = [[sandboxId://Model/Item/png/103_Shovel02.png]],
            DisplayModelId = [[sandboxId://Model/Item/obj/103_Shovel02.obj]],
            ModelType = [[Item]]
        },
        [69] = {
            Index = 69,
            Id = 69,
            Name = [[Pickaxe]],
            Pirce = 1.905e+12,
            Quality = 18,
            IconId = [[sandboxId://Model/Item/png/104_Pickax.png]],
            DisplayModelId = [[sandboxId://Model/Item/obj/104_Pickax.obj]],
            ModelType = [[Item]]
        },
        [70] = {
            Index = 70,
            Id = 70,
            Name = [[Capsule]],
            Pirce = 3.048e+12,
            Quality = 15,
            IconId = [[sandboxId://Model/Item/png/003_Capsule.png]],
            DisplayModelId = [[sandboxId://Model/Item/obj/003_Capsule.obj]],
            ModelType = [[Item]]
        },
        [71] = {
            Index = 71,
            Id = 71,
            Name = [[Battery]],
            Pirce = 4.572e+12,
            Quality = 16,
            IconId = [[sandboxId://Model/Item/png/004_Battery01.png]],
            DisplayModelId = [[sandboxId://Model/Item/obj/004_Battery01.obj]],
            ModelType = [[Item]]
        },
        [72] = {
            Index = 72,
            Id = 72,
            Name = [[High-Power Battery]],
            Pirce = 5.715e+12,
            Quality = 16,
            IconId = [[sandboxId://Model/Item/png/005_Battery02.png]],
            DisplayModelId = [[sandboxId://Model/Item/obj/005_Battery02.obj]],
            ModelType = [[Item]]
        },
        [73] = {
            Index = 73,
            Id = 73,
            Name = [[Medicine Bottle]],
            Pirce = 9.55e+12,
            Quality = 16,
            IconId = [[sandboxId://Model/Item/png/033_Medicine_bottle01.png]],
            DisplayModelId = [[sandboxId://Model/Item/obj/033_Medicine_bottle01.obj]],
            ModelType = [[Item]]
        },
        [74] = {
            Index = 74,
            Id = 74,
            Name = [[First Aid Medicine]],
            Pirce = 1.528e+13,
            Quality = 16,
            IconId = [[sandboxId://Model/Item/png/034_Medicine_bottle02.png]],
            DisplayModelId = [[sandboxId://Model/Item/obj/034_Medicine_bottle02.obj]],
            ModelType = [[Item]]
        },
        [75] = {
            Index = 75,
            Id = 75,
            Name = [[Syringe]],
            Pirce = 2.292e+13,
            Quality = 17,
            IconId = [[sandboxId://Model/Item/png/035_Injection.png]],
            DisplayModelId = [[sandboxId://Model/Item/obj/035_Injection.obj]],
            ModelType = [[Item]]
        },
        [76] = {
            Index = 76,
            Id = 76,
            Name = [[Boost Injector]],
            Pirce = 2.865e+13,
            Quality = 17,
            IconId = [[sandboxId://Model/Item/png/036_InjectionA.png]],
            DisplayModelId = [[sandboxId://Model/Item/obj/036_InjectionA.obj]],
            ModelType = [[Item]]
        },
        [77] = {
            Index = 77,
            Id = 77,
            Name = [[Medical Bandage]],
            Pirce = 4.77e+13,
            Quality = 17,
            IconId = [[sandboxId://Model/Item/png/037_First_aid_Kit_Bandage.png]],
            DisplayModelId = [[sandboxId://Model/Item/obj/037_First_aid_Kit_Bandage.obj]],
            ModelType = [[Item]]
        },
        [78] = {
            Index = 78,
            Id = 78,
            Name = [[Green Badge]],
            Pirce = 7.632e+13,
            Quality = 17,
            IconId = [[sandboxId://Model/Item/png/038_Lv.png]],
            DisplayModelId = [[sandboxId://Model/Item/obj/038_Lv.obj]],
            ModelType = [[Item]]
        },
        [79] = {
            Index = 79,
            Id = 79,
            Name = [[First Aid Kit]],
            Pirce = 1.1448e+14,
            Quality = 18,
            IconId = [[sandboxId://Model/Item/png/039_First_aid_Kit01.png]],
            DisplayModelId = [[sandboxId://Model/Item/obj/039_First_aid_Kit01.obj]],
            ModelType = [[Item]]
        },
        [80] = {
            Index = 80,
            Id = 80,
            Name = [[Medical Kit]],
            Pirce = 1.431e+14,
            Quality = 18,
            IconId = [[sandboxId://Model/Item/png/040_First_aid_Kit02.png]],
            DisplayModelId = [[sandboxId://Model/Item/obj/040_First_aid_Kit02.obj]],
            ModelType = [[Item]]
        },
        [81] = {
            Index = 81,
            Id = 81,
            Name = [[Advanced Medical Kit]],
            Pirce = 2.385e+14,
            Quality = 18,
            IconId = [[sandboxId://Model/Item/png/041_First_aid_Kit03.png]],
            DisplayModelId = [[sandboxId://Model/Item/obj/041_First_aid_Kit03.obj]],
            ModelType = [[Item]]
        },
        [82] = {
            Index = 82,
            Id = 82,
            Name = [[Steel Pipe]],
            Pirce = 3.816e+14,
            Quality = 18,
            IconId = [[sandboxId://Model/Item/png/045_Pipe.png]],
            DisplayModelId = [[sandboxId://Model/Item/obj/045_Pipe.obj]],
            ModelType = [[Item]]
        },
        [83] = {
            Index = 83,
            Id = 83,
            Name = [[Phone]],
            Pirce = 5.724e+14,
            Quality = 19,
            IconId = [[sandboxId://Model/Item/png/050_Mobilephone.png]],
            DisplayModelId = [[sandboxId://Model/Item/obj/050_Mobilephone.obj]],
            ModelType = [[Item]]
        },
        [84] = {
            Index = 84,
            Id = 84,
            Name = [[Watch]],
            Pirce = 7.155e+14,
            Quality = 19,
            IconId = [[sandboxId://Model/Item/png/051_Watch01.png]],
            DisplayModelId = [[sandboxId://Model/Item/obj/051_Watch01.obj]],
            ModelType = [[Item]]
        },
        [85] = {
            Index = 85,
            Id = 85,
            Name = [[ID Tag]],
            Pirce = 1.19e+15,
            Quality = 19,
            IconId = [[sandboxId://Model/Item/png/052_IdentificationTag.png]],
            DisplayModelId = [[sandboxId://Model/Item/obj/052_IdentificationTag.obj]],
            ModelType = [[Item]]
        },
        [86] = {
            Index = 86,
            Id = 86,
            Name = [[Compass]],
            Pirce = 1.904e+15,
            Quality = 19,
            IconId = [[sandboxId://Model/Item/png/053_Compass.png]],
            DisplayModelId = [[sandboxId://Model/Item/obj/053_Compass.obj]],
            ModelType = [[Item]]
        },
        [87] = {
            Index = 87,
            Id = 87,
            Name = [[Military Compass]],
            Pirce = 2.856e+15,
            Quality = 20,
            IconId = [[sandboxId://Model/Item/png/054_CompassA.png]],
            DisplayModelId = [[sandboxId://Model/Item/obj/054_CompassA.obj]],
            ModelType = [[Item]]
        },
        [88] = {
            Index = 88,
            Id = 88,
            Name = [[Wooden Crate]],
            Pirce = 3.57e+15,
            Quality = 20,
            IconId = [[sandboxId://Model/Item/png/077_Box01.png]],
            DisplayModelId = [[sandboxId://Model/Item/obj/077_Box01.obj]],
            ModelType = [[Item]]
        },
        [89] = {
            Index = 89,
            Id = 89,
            Name = [[Toolbox]],
            Pirce = 5.95e+15,
            Quality = 20,
            IconId = [[sandboxId://Model/Item/png/078_Box02.png]],
            DisplayModelId = [[sandboxId://Model/Item/obj/078_Box02.obj]],
            ModelType = [[Item]]
        },
        [90] = {
            Index = 90,
            Id = 90,
            Name = [[Supply Crate]],
            Pirce = 9.52e+15,
            Quality = 20,
            IconId = [[sandboxId://Model/Item/png/079_Box03.png]],
            DisplayModelId = [[sandboxId://Model/Item/obj/079_Box03.obj]],
            ModelType = [[Item]]
        },
        [91] = {
            Index = 91,
            Id = 91,
            Name = [[Oil Drum]],
            Pirce = 1.428e+16,
            Quality = 21,
            IconId = [[sandboxId://Model/Item/png/082_Drum02.png]],
            DisplayModelId = [[sandboxId://Model/Item/obj/082_Drum02.obj]],
            ModelType = [[Item]]
        },
        [92] = {
            Index = 92,
            Id = 92,
            Name = [[Storage Barrel]],
            Pirce = 1.785e+16,
            Quality = 21,
            IconId = [[sandboxId://Model/Item/png/083_Drum03.png]],
            DisplayModelId = [[sandboxId://Model/Item/obj/083_Drum03.obj]],
            ModelType = [[Item]]
        },
        [93] = {
            Index = 93,
            Id = 93,
            Name = [[Sealed Barrel]],
            Pirce = 2.98e+16,
            Quality = 21,
            IconId = [[sandboxId://Model/Item/png/084_Drum04.png]],
            DisplayModelId = [[sandboxId://Model/Item/obj/084_Drum04.obj]],
            ModelType = [[Item]]
        },
        [94] = {
            Index = 94,
            Id = 94,
            Name = [[Large Iron Drum]],
            Pirce = 4.768e+16,
            Quality = 21,
            IconId = [[sandboxId://Model/Item/png/085_Drum05.png]],
            DisplayModelId = [[sandboxId://Model/Item/obj/085_Drum05.obj]],
            ModelType = [[Item]]
        },
        [95] = {
            Index = 95,
            Id = 95,
            Name = [[Gas Cylinder]],
            Pirce = 7.152e+16,
            Quality = 22,
            IconId = [[sandboxId://Model/Item/png/086_Propane.png]],
            DisplayModelId = [[sandboxId://Model/Item/obj/086_Propane.obj]],
            ModelType = [[Item]]
        },
        [96] = {
            Index = 96,
            Id = 96,
            Name = [[Thick Rope]],
            Pirce = 8.94e+16,
            Quality = 22,
            IconId = [[sandboxId://Model/Item/png/087_RopeA.png]],
            DisplayModelId = [[sandboxId://Model/Item/obj/087_RopeA.obj]],
            ModelType = [[Item]]
        },
        [97] = {
            Index = 97,
            Id = 97,
            Name = [[Wire]],
            Pirce = 1.49e+17,
            Quality = 22,
            IconId = [[sandboxId://Model/Item/png/088_Wire.png]],
            DisplayModelId = [[sandboxId://Model/Item/obj/088_Wire.obj]],
            ModelType = [[Item]]
        },
        [98] = {
            Index = 98,
            Id = 98,
            Name = [[Walkie-Talkie]],
            Pirce = 2.384e+17,
            Quality = 22,
            IconId = [[sandboxId://Model/Item/png/089_Walkie_Talkie.png]],
            DisplayModelId = [[sandboxId://Model/Item/obj/089_Walkie_Talkie.obj]],
            ModelType = [[Item]]
        },
        [99] = {
            Index = 99,
            Id = 99,
            Name = [[Military Radio]],
            Pirce = 3.576e+17,
            Quality = 23,
            IconId = [[sandboxId://Model/Item/png/090_Walkie_TalkieA.png]],
            DisplayModelId = [[sandboxId://Model/Item/obj/090_Walkie_TalkieA.obj]],
            ModelType = [[Item]]
        },
        [100] = {
            Index = 100,
            Id = 100,
            Name = [[Flashlight]],
            Pirce = 4.47e+17,
            Quality = 23,
            IconId = [[sandboxId://Model/Item/png/091_Flashlight01.png]],
            DisplayModelId = [[sandboxId://Model/Item/obj/091_Flashlight01.obj]],
            ModelType = [[Item]]
        },
        [101] = {
            Index = 101,
            Id = 101,
            Name = [[Headlamp]],
            Pirce = 7.45e+17,
            Quality = 23,
            IconId = [[sandboxId://Model/Item/png/092_HeadLantern.png]],
            DisplayModelId = [[sandboxId://Model/Item/obj/092_HeadLantern.obj]],
            ModelType = [[Item]]
        },
        [102] = {
            Index = 102,
            Id = 102,
            Name = [[Lantern]],
            Pirce = 1.192e+18,
            Quality = 23,
            IconId = [[sandboxId://Model/Item/png/093_Lantern.png]],
            DisplayModelId = [[sandboxId://Model/Item/obj/093_Lantern.obj]],
            ModelType = [[Item]]
        },
        [103] = {
            Index = 103,
            Id = 103,
            Name = [[Binoculars]],
            Pirce = 1.788e+18,
            Quality = 24,
            IconId = [[sandboxId://Model/Item/png/094_Telescope01.png]],
            DisplayModelId = [[sandboxId://Model/Item/obj/094_Telescope01.obj]],
            ModelType = [[Item]]
        },
        [104] = {
            Index = 104,
            Id = 104,
            Name = [[High-Power Binoculars]],
            Pirce = 2.235e+18,
            Quality = 24,
            IconId = [[sandboxId://Model/Item/png/095_Telescope02.png]],
            DisplayModelId = [[sandboxId://Model/Item/obj/095_Telescope02.obj]],
            ModelType = [[Item]]
        },
        [105] = {
            Index = 105,
            Id = 105,
            Name = [[Golf Club]],
            Pirce = 3.725e+18,
            Quality = 24,
            IconId = [[sandboxId://Model/Item/png/105_GolfClub.png]],
            DisplayModelId = [[sandboxId://Model/Item/obj/105_GolfClub.obj]],
            ModelType = [[Item]]
        },
        [106] = {
            Index = 106,
            Id = 106,
            Name = [[Hockey Stick]],
            Pirce = 5.96e+18,
            Quality = 24,
            IconId = [[sandboxId://Model/Item/png/106_Hockey.png]],
            DisplayModelId = [[sandboxId://Model/Item/obj/106_Hockey.obj]],
            ModelType = [[Item]]
        },
        [107] = {
            Index = 107,
            Id = 107,
            Name = [[Wooden Stick]],
            Pirce = 8.94e+18,
            Quality = 25,
            IconId = [[sandboxId://Model/Item/png/107_Bat01.png]],
            DisplayModelId = [[sandboxId://Model/Item/obj/107_Bat01.obj]],
            ModelType = [[Item]]
        },
        [108] = {
            Index = 108,
            Id = 108,
            Name = [[Baseball Bat]],
            Pirce = 1.1175e+19,
            Quality = 25,
            IconId = [[sandboxId://Model/Item/png/108_Bat02.png]],
            DisplayModelId = [[sandboxId://Model/Item/obj/108_Bat02.obj]],
            ModelType = [[Item]]
        },
        [109] = {
            Index = 109,
            Id = 109,
            Name = [[Iron Rod]],
            Pirce = 1.865e+19,
            Quality = 25,
            IconId = [[sandboxId://Model/Item/png/109_Bat03.png]],
            DisplayModelId = [[sandboxId://Model/Item/obj/109_Bat03.obj]],
            ModelType = [[Item]]
        },
        [110] = {
            Index = 110,
            Id = 110,
            Name = [[Tactical Baton]],
            Pirce = 2.984e+19,
            Quality = 25,
            IconId = [[sandboxId://Model/Item/png/110_Bat04.png]],
            DisplayModelId = [[sandboxId://Model/Item/obj/110_Bat04.obj]],
            ModelType = [[Item]]
        },
        [111] = {
            Index = 111,
            Id = 111,
            Name = [[Chainsaw]],
            Pirce = 4.476e+19,
            Quality = 26,
            IconId = [[sandboxId://Model/Item/png/111_ElectricSaw.png]],
            DisplayModelId = [[sandboxId://Model/Item/obj/111_ElectricSaw.obj]],
            ModelType = [[Item]]
        },
        [112] = {
            Index = 112,
            Id = 112,
            Name = [[Wood Axe]],
            Pirce = 5.595e+19,
            Quality = 26,
            IconId = [[sandboxId://Model/Item/png/112_Ax01.png]],
            DisplayModelId = [[sandboxId://Model/Item/obj/112_Ax01.obj]],
            ModelType = [[Item]]
        },
        [113] = {
            Index = 113,
            Id = 113,
            Name = [[Fire Axe]],
            Pirce = 9.3e+19,
            Quality = 26,
            IconId = [[sandboxId://Model/Item/png/113_Ax02.png]],
            DisplayModelId = [[sandboxId://Model/Item/obj/113_Ax02.obj]],
            ModelType = [[Item]]
        },
        [114] = {
            Index = 114,
            Id = 114,
            Name = [[Battle Axe]],
            Pirce = 1.488e+20,
            Quality = 26,
            IconId = [[sandboxId://Model/Item/png/114_Ax03.png]],
            DisplayModelId = [[sandboxId://Model/Item/obj/114_Ax03.obj]],
            ModelType = [[Item]]
        },
        [115] = {
            Index = 115,
            Id = 115,
            Name = [[Small Knife]],
            Pirce = 2.232e+20,
            Quality = 27,
            IconId = [[sandboxId://Model/Item/png/115_Knife01.png]],
            DisplayModelId = [[sandboxId://Model/Item/obj/115_Knife01.obj]],
            ModelType = [[Item]]
        },
        [116] = {
            Index = 116,
            Id = 116,
            Name = [[Hunting Knife]],
            Pirce = 2.79e+20,
            Quality = 27,
            IconId = [[sandboxId://Model/Item/png/116_Knife02.png]],
            DisplayModelId = [[sandboxId://Model/Item/obj/116_Knife02.obj]],
            ModelType = [[Item]]
        },
        [117] = {
            Index = 117,
            Id = 117,
            Name = [[Military Knife]],
            Pirce = 4.655e+20,
            Quality = 27,
            IconId = [[sandboxId://Model/Item/png/117_Knife03.png]],
            DisplayModelId = [[sandboxId://Model/Item/obj/117_Knife03.obj]],
            ModelType = [[Item]]
        },
        [118] = {
            Index = 118,
            Id = 118,
            Name = [[Machete]],
            Pirce = 7.448e+20,
            Quality = 27,
            IconId = [[sandboxId://Model/Item/png/118_Knife04.png]],
            DisplayModelId = [[sandboxId://Model/Item/obj/118_Knife04.obj]],
            ModelType = [[Item]]
        },
        [119] = {
            Index = 119,
            Id = 119,
            Name = [[Dagger]],
            Pirce = 1.1172e+21,
            Quality = 28,
            IconId = [[sandboxId://Model/Item/png/119_Knife05.png]],
            DisplayModelId = [[sandboxId://Model/Item/obj/119_Knife05.obj]],
            ModelType = [[Item]]
        },
        [120] = {
            Index = 120,
            Id = 120,
            Name = [[Tactical Knife]],
            Pirce = 1.396499999999999868928e+21,
            Quality = 28,
            IconId = [[sandboxId://Model/Item/png/120_Knife06.png]],
            DisplayModelId = [[sandboxId://Model/Item/obj/120_Knife06.obj]],
            ModelType = [[Item]]
        },
        [121] = {
            Index = 121,
            Id = 121,
            Name = [[Spiked Club]],
            Pirce = 2.33e+21,
            Quality = 28,
            IconId = [[sandboxId://Model/Item/png/121_Ironmace.png]],
            DisplayModelId = [[sandboxId://Model/Item/obj/121_Ironmace.obj]],
            ModelType = [[Item]]
        },
        [122] = {
            Index = 122,
            Id = 122,
            Name = [[Explosive Canister]],
            Pirce = 3.728e+21,
            Quality = 28,
            IconId = [[sandboxId://Model/Item/png/122_Dynamite01.png]],
            DisplayModelId = [[sandboxId://Model/Item/obj/122_Dynamite01.obj]],
            ModelType = [[Item]]
        },
        [123] = {
            Index = 123,
            Id = 123,
            Name = [[Bundle of Dynamite]],
            Pirce = 5.592e+21,
            Quality = 29,
            IconId = [[sandboxId://Model/Item/png/123_Dynamite02.png]],
            DisplayModelId = [[sandboxId://Model/Item/obj/123_Dynamite02.obj]],
            ModelType = [[Item]]
        },
        [124] = {
            Index = 124,
            Id = 124,
            Name = [[Remote Bomb]],
            Pirce = 6.990000000000000524288e+21,
            Quality = 29,
            IconId = [[sandboxId://Model/Item/png/124_Dynamite03.png]],
            DisplayModelId = [[sandboxId://Model/Item/obj/124_Dynamite03.obj]],
            ModelType = [[Item]]
        },
        [125] = {
            Index = 125,
            Id = 125,
            Name = [[Round Grenade]],
            Pirce = 1.1649999999999999475712e+22,
            Quality = 29,
            IconId = [[sandboxId://Model/Item/png/125_Grenade01.png]],
            DisplayModelId = [[sandboxId://Model/Item/obj/125_Grenade01.obj]],
            ModelType = [[Item]]
        },
        [126] = {
            Index = 126,
            Id = 126,
            Name = [[High-Explosive Grenade]],
            Pirce = 1.864e+22,
            Quality = 29,
            IconId = [[sandboxId://Model/Item/png/126_Grenade02.png]],
            DisplayModelId = [[sandboxId://Model/Item/obj/126_Grenade02.obj]],
            ModelType = [[Item]]
        },
        [127] = {
            Index = 127,
            Id = 127,
            Name = [[Plasma Grenade]],
            Pirce = 2.7960000000000002097152e+22,
            Quality = 30,
            IconId = [[sandboxId://Model/Item/png/127_Grenade03.png]],
            DisplayModelId = [[sandboxId://Model/Item/obj/127_Grenade03.obj]],
            ModelType = [[Item]]
        },
        [128] = {
            Index = 128,
            Id = 128,
            Name = [[Proximity Mine]],
            Pirce = 3.4949999999999998427136e+22,
            Quality = 30,
            IconId = [[sandboxId://Model/Item/png/128_Mine.png]],
            DisplayModelId = [[sandboxId://Model/Item/obj/128_Mine.obj]],
            ModelType = [[Item]]
        },
        [129] = {
            Index = 129,
            Id = 129,
            Name = [[Bear Trap]],
            Pirce = 5.7999999999999995805696e+22,
            Quality = 30,
            IconId = [[sandboxId://Model/Item/png/129_Trap.png]],
            DisplayModelId = [[sandboxId://Model/Item/obj/129_Trap.obj]],
            ModelType = [[Item]]
        },
        [130] = {
            Index = 130,
            Id = 130,
            Name = [[Pistol Bullet]],
            Pirce = 9.28e+22,
            Quality = 30,
            IconId = [[sandboxId://Model/Item/png/130_Bullet01.png]],
            DisplayModelId = [[sandboxId://Model/Item/obj/130_Bullet01.obj]],
            ModelType = [[Item]]
        },
        [131] = {
            Index = 131,
            Id = 131,
            Name = [[Pistol Ammo]],
            Pirce = 1.392e+23,
            Quality = 31,
            IconId = [[sandboxId://Model/Item/png/131_Bullet02.png]],
            DisplayModelId = [[sandboxId://Model/Item/obj/131_Bullet02.obj]],
            ModelType = [[Item]]
        },
        [132] = {
            Index = 132,
            Id = 132,
            Name = [[Ammo Crate]],
            Pirce = 1.73999999999999987417088e+23,
            Quality = 31,
            IconId = [[sandboxId://Model/Item/png/132_Bullet03.png]],
            DisplayModelId = [[sandboxId://Model/Item/obj/132_Bullet03.obj]],
            ModelType = [[Item]]
        },
        [133] = {
            Index = 133,
            Id = 133,
            Name = [[Boxed Ammo]],
            Pirce = 2.91000000000000002097152e+23,
            Quality = 31,
            IconId = [[sandboxId://Model/Item/png/133_Bullet04.png]],
            DisplayModelId = [[sandboxId://Model/Item/obj/133_Bullet04.obj]],
            ModelType = [[Item]]
        },
        [134] = {
            Index = 134,
            Id = 134,
            Name = [[Straight Magazine]],
            Pirce = 4.65600000000000016777216e+23,
            Quality = 31,
            IconId = [[sandboxId://Model/Item/png/134_Bullet05.png]],
            DisplayModelId = [[sandboxId://Model/Item/obj/134_Bullet05.obj]],
            ModelType = [[Item]]
        },
        [135] = {
            Index = 135,
            Id = 135,
            Name = [[Curved Magazine]],
            Pirce = 6.98400000000000058720256e+23,
            Quality = 32,
            IconId = [[sandboxId://Model/Item/png/135_Bullet06.png]],
            DisplayModelId = [[sandboxId://Model/Item/obj/135_Bullet06.obj]],
            ModelType = [[Item]]
        },
        [136] = {
            Index = 136,
            Id = 136,
            Name = [[Shotgun Shell Box]],
            Pirce = 8.73000000000000006291456e+23,
            Quality = 32,
            IconId = [[sandboxId://Model/Item/png/136_Bullet07.png]],
            DisplayModelId = [[sandboxId://Model/Item/obj/136_Bullet07.obj]],
            ModelType = [[Item]]
        },
        [137] = {
            Index = 137,
            Id = 137,
            Name = [[Military Ammo Box]],
            Pirce = 1.45500000000000001048576e+24,
            Quality = 32,
            IconId = [[sandboxId://Model/Item/png/137_Cartridge.png]],
            DisplayModelId = [[sandboxId://Model/Item/obj/137_Cartridge.obj]],
            ModelType = [[Item]]
        },
        [138] = {
            Index = 138,
            Id = 138,
            Name = [[Revolver]],
            Pirce = 2.328000000000000016777216e+24,
            Quality = 32,
            IconId = [[sandboxId://Model/Item/png/138_Gun01.png]],
            DisplayModelId = [[sandboxId://Model/Item/obj/138_Gun01.obj]],
            ModelType = [[Item]]
        },
        [139] = {
            Index = 139,
            Id = 139,
            Name = [[Single-Shot Pistol]],
            Pirce = 3.492000000000000025165824e+24,
            Quality = 33,
            IconId = [[sandboxId://Model/Item/png/139_Gun02.png]],
            DisplayModelId = [[sandboxId://Model/Item/obj/139_Gun02.obj]],
            ModelType = [[Item]]
        },
        [140] = {
            Index = 140,
            Id = 140,
            Name = [[Short-Barrel Assault Rifle]],
            Pirce = 4.364999999999999763021824e+24,
            Quality = 33,
            IconId = [[sandboxId://Model/Item/png/140_Rifle01.png]],
            DisplayModelId = [[sandboxId://Model/Item/obj/140_Rifle01.obj]],
            ModelType = [[Item]]
        },
        [141] = {
            Index = 141,
            Id = 141,
            Name = [[Tactical Assault Rifle]],
            Pirce = 7.299999999999999823839232e+24,
            Quality = 33,
            IconId = [[sandboxId://Model/Item/png/141_Rifle02.png]],
            DisplayModelId = [[sandboxId://Model/Item/obj/141_Rifle02.obj]],
            ModelType = [[Item]]
        },
        [142] = {
            Index = 142,
            Id = 142,
            Name = [[Wood-Stock Assault Rifle]],
            Pirce = 1.168000000000000100663296e+25,
            Quality = 33,
            IconId = [[sandboxId://Model/Item/png/142_Rifle03.png]],
            DisplayModelId = [[sandboxId://Model/Item/obj/142_Rifle03.obj]],
            ModelType = [[Item]]
        },
        [143] = {
            Index = 143,
            Id = 143,
            Name = [[Combat Shotgun]],
            Pirce = 1.7520000000000000436207616e+25,
            Quality = 34,
            IconId = [[sandboxId://Model/Item/png/143_Rifle04.png]],
            DisplayModelId = [[sandboxId://Model/Item/obj/143_Rifle04.obj]],
            ModelType = [[Item]]
        },
        [144] = {
            Index = 144,
            Id = 144,
            Name = [[Sniper Rifle]],
            Pirce = 2.190000000000000054525952e+25,
            Quality = 34,
            IconId = [[sandboxId://Model/Item/png/144_Rifle05.png]],
            DisplayModelId = [[sandboxId://Model/Item/obj/144_Rifle05.obj]],
            ModelType = [[Item]]
        },
        [145] = {
            Index = 145,
            Id = 145,
            Name = [[SMG]],
            Pirce = 3.6399999999999997886070784e+25,
            Quality = 34,
            IconId = [[sandboxId://Model/Item/png/145_MachineGun01.png]],
            DisplayModelId = [[sandboxId://Model/Item/obj/145_MachineGun01.obj]],
            ModelType = [[Item]]
        },
        [146] = {
            Index = 146,
            Id = 146,
            Name = [[Silenced SMG]],
            Pirce = 5.8240000000000003489660928e+25,
            Quality = 34,
            IconId = [[sandboxId://Model/Item/png/146_MachineGun02.png]],
            DisplayModelId = [[sandboxId://Model/Item/obj/146_MachineGun02.obj]],
            ModelType = [[Item]]
        },
        [147] = {
            Index = 147,
            Id = 147,
            Name = [[Micro SMG]],
            Pirce = 8.7360000000000005234491392e+25,
            Quality = 35,
            IconId = [[sandboxId://Model/Item/png/147_MachineGun03.png]],
            DisplayModelId = [[sandboxId://Model/Item/obj/147_MachineGun03.obj]],
            ModelType = [[Item]]
        },
        [148] = {
            Index = 148,
            Id = 148,
            Name = [[Wood-Stock SMG]],
            Pirce = 1.09200000000000002248146944e+26,
            Quality = 35,
            IconId = [[sandboxId://Model/Item/png/148_MachineGun04.png]],
            DisplayModelId = [[sandboxId://Model/Item/obj/148_MachineGun04.obj]],
            ModelType = [[Item]]
        },
        [149] = {
            Index = 149,
            Id = 149,
            Name = [[Stone Axe]],
            Pirce = 1.81999999999999998020288512e+26,
            Quality = 35,
            IconId = [[sandboxId://Model/Aex/Png/axe_01.png]],
            DisplayModelId = [[sandboxId://Model/Aex/Axe01/Axe1.prefab]],
            ModelType = [[Axe]]
        },
        [150] = {
            Index = 150,
            Id = 150,
            Name = [[Copper Axe]],
            Pirce = 2.91199999999999983088566272e+26,
            Quality = 35,
            IconId = [[sandboxId://Model/Aex/Png/axe_02.png]],
            DisplayModelId = [[sandboxId://Model/Aex/Axe1/Axe1.prefab]],
            ModelType = [[Axe]]
        },
        [151] = {
            Index = 151,
            Id = 151,
            Name = [[Silver Axe]],
            Pirce = 4.36800000000000008992587776e+26,
            Quality = 36,
            IconId = [[sandboxId://Model/Aex/Png/axe_03.png]],
            DisplayModelId = [[sandboxId://Model/Aex/Axe11/Axe11.prefab]],
            ModelType = [[Axe]]
        },
        [152] = {
            Index = 152,
            Id = 152,
            Name = [[Gold Axe]],
            Pirce = 5.45999999999999994060865536e+26,
            Quality = 36,
            IconId = [[sandboxId://Model/Aex/Png/axe_04.png]],
            DisplayModelId = [[sandboxId://Model/Aex/Axe02/Axe2.prefab]],
            ModelType = [[Axe]]
        },
        [153] = {
            Index = 153,
            Id = 153,
            Name = [[Holy Axe]],
            Pirce = 9.10000000000000058820919296e+26,
            Quality = 36,
            IconId = [[sandboxId://Model/Aex/Png/axe_05.png]],
            DisplayModelId = [[sandboxId://Model/Aex/Axe9/Axe9.prefab]],
            ModelType = [[Axe]]
        },
        [154] = {
            Index = 154,
            Id = 154,
            Name = [[Phantom Axe]],
            Pirce = 1.455999999999999984162308096e+27,
            Quality = 36,
            IconId = [[sandboxId://Model/Aex/Png/axe_06.png]],
            DisplayModelId = [[sandboxId://Model/Aex/Axe8/Axe8.prefab]],
            ModelType = [[Axe]]
        },
        [155] = {
            Index = 155,
            Id = 155,
            Name = [[Skull Axe]],
            Pirce = 2.183999999999999976243462144e+27,
            Quality = 37,
            IconId = [[sandboxId://Model/Aex/Png/axe_07.png]],
            DisplayModelId = [[sandboxId://Model/Aex/Axe12/Axe12.prefab]],
            ModelType = [[Axe]]
        },
        [156] = {
            Index = 156,
            Id = 156,
            Name = [[Runic Axe]],
            Pirce = 2.729999999999999901584850944e+27,
            Quality = 37,
            IconId = [[sandboxId://Model/Aex/Png/axe_08.png]],
            DisplayModelId = [[sandboxId://Model/Aex/Axe18/Axe18.prefab]],
            ModelType = [[Axe]]
        },
        [157] = {
            Index = 157,
            Id = 157,
            Name = [[Yellow Chicken]],
            Pirce = 4.545000000000000174466269184e+27,
            Quality = 37,
            IconId = [[sandboxId://UI/Icon/Animals/1.png]],
            DisplayModelId = [[Models.Animals.Animal_1]],
            ModelType = [[Animal]]
        },
        [158] = {
            Index = 158,
            Id = 158,
            Name = [[Chick]],
            Pirce = 7.271999999999999839341379584e+27,
            Quality = 37,
            IconId = [[sandboxId://UI/Icon/Animals/2.png]],
            DisplayModelId = [[Models.Animals.Animal_2]],
            ModelType = [[Animal]]
        },
        [159] = {
            Index = 159,
            Id = 159,
            Name = [[Mallard Duck]],
            Pirce = 1.0908000000000000858523697152e+28,
            Quality = 38,
            IconId = [[sandboxId://UI/Icon/Animals/3.png]],
            DisplayModelId = [[Models.Animals.Animal_3]],
            ModelType = [[Animal]]
        },
        [160] = {
            Index = 160,
            Id = 160,
            Name = [[White Rabbit]],
            Pirce = 1.3634999999999999423887179776e+28,
            Quality = 38,
            IconId = [[sandboxId://UI/Icon/Animals/4.png]],
            DisplayModelId = [[Models.Animals.Animal_4]],
            ModelType = [[Animal]]
        },
        [161] = {
            Index = 161,
            Id = 161,
            Name = [[Brown Rabbit]],
            Pirce = 2.2749999999999998446866006016e+28,
            Quality = 38,
            IconId = [[sandboxId://UI/Icon/Animals/5.png]],
            DisplayModelId = [[Models.Animals.Animal_5]],
            ModelType = [[Animal]]
        },
        [162] = {
            Index = 162,
            Id = 162,
            Name = [[White Sheep]],
            Pirce = 3.6400000000000000153813516288e+28,
            Quality = 38,
            IconId = [[sandboxId://UI/Icon/Animals/6.png]],
            DisplayModelId = [[Models.Animals.Animal_6]],
            ModelType = [[Animal]]
        },
        [163] = {
            Index = 163,
            Id = 163,
            Name = [[Pink Sheep]],
            Pirce = 5.459999999999999803169701888e+28,
            Quality = 39,
            IconId = [[sandboxId://UI/Icon/Animals/7.png]],
            DisplayModelId = [[Models.Animals.Animal_7]],
            ModelType = [[Animal]]
        },
        [164] = {
            Index = 164,
            Id = 164,
            Name = [[Black Sheep]],
            Pirce = 6.8249999999999999738644529152e+28,
            Quality = 39,
            IconId = [[sandboxId://UI/Icon/Animals/8.png]],
            DisplayModelId = [[Models.Animals.Animal_8]],
            ModelType = [[Animal]]
        },
        [165] = {
            Index = 165,
            Id = 165,
            Name = [[Pink Pig]],
            Pirce = 1.1350000000000000549386715136e+29,
            Quality = 39,
            IconId = [[sandboxId://UI/Icon/Animals/9.png]],
            DisplayModelId = [[Models.Animals.Animal_9]],
            ModelType = [[Animal]]
        },
        [166] = {
            Index = 166,
            Id = 166,
            Name = [[White Alpaca]],
            Pirce = 1.81600000000000008790187442176e+29,
            Quality = 39,
            IconId = [[sandboxId://UI/Icon/Animals/10.png]],
            DisplayModelId = [[Models.Animals.Animal_10]],
            ModelType = [[Animal]]
        },
        [167] = {
            Index = 167,
            Id = 167,
            Name = [[Black Alpaca]],
            Pirce = 2.72400000000000013185281163264e+29,
            Quality = 40,
            IconId = [[sandboxId://UI/Icon/Animals/11.png]],
            DisplayModelId = [[Models.Animals.Animal_11]],
            ModelType = [[Animal]]
        },
        [168] = {
            Index = 168,
            Id = 168,
            Name = [[White Horse]],
            Pirce = 3.40499999999999981297229365248e+29,
            Quality = 40,
            IconId = [[sandboxId://UI/Icon/Animals/12.png]],
            DisplayModelId = [[Models.Animals.Animal_12]],
            ModelType = [[Animal]]
        },
        [169] = {
            Index = 169,
            Id = 169,
            Name = [[Brown Horse]],
            Pirce = 5.69999999999999991630987788288e+29,
            Quality = 40,
            IconId = [[sandboxId://UI/Icon/Animals/13.png]],
            DisplayModelId = [[Models.Animals.Animal_13]],
            ModelType = [[Animal]]
        },
        [170] = {
            Index = 170,
            Id = 170,
            Name = [[Black Goat]],
            Pirce = 9.12000000000000042904575803392e+29,
            Quality = 40,
            IconId = [[sandboxId://UI/Icon/Animals/14.png]],
            DisplayModelId = [[Models.Animals.Animal_14]],
            ModelType = [[Animal]]
        },
        [171] = {
            Index = 171,
            Id = 171,
            Name = [[Yellow Antelope]],
            Pirce = 1.36799999999999992361937534976e+30,
            Quality = 41,
            IconId = [[sandboxId://UI/Icon/Animals/15.png]],
            DisplayModelId = [[Models.Animals.Animal_15]],
            ModelType = [[Animal]]
        },
        [172] = {
            Index = 172,
            Id = 172,
            Name = [[Horned Goat]],
            Pirce = 1.710000000000000115630451720192e+30,
            Quality = 41,
            IconId = [[sandboxId://UI/Icon/Animals/16.png]],
            DisplayModelId = [[Models.Animals.Animal_16]],
            ModelType = [[Animal]]
        },
        [173] = {
            Index = 173,
            Id = 173,
            Name = [[Cow]],
            Pirce = 2.839999999999999820033354104832e+30,
            Quality = 41,
            IconId = [[sandboxId://UI/Icon/Animals/17.png]],
            DisplayModelId = [[Models.Animals.Animal_17]],
            ModelType = [[Animal]]
        },
        [174] = {
            Index = 174,
            Id = 174,
            Name = [[Bull]],
            Pirce = 4.543999999999999937233347936256e+30,
            Quality = 41,
            IconId = [[sandboxId://UI/Icon/Animals/18.png]],
            DisplayModelId = [[Models.Animals.Animal_18]],
            ModelType = [[Animal]]
        },
        [175] = {
            Index = 175,
            Id = 175,
            Name = [[Buffalo]],
            Pirce = 6.816000000000000468799975325696e+30,
            Quality = 42,
            IconId = [[sandboxId://UI/Icon/Animals/19.png]],
            DisplayModelId = [[Models.Animals.Animal_19]],
            ModelType = [[Animal]]
        },
        [176] = {
            Index = 176,
            Id = 176,
            Name = [[Brown Platypus]],
            Pirce = 8.520000000000000023050015735808e+30,
            Quality = 42,
            IconId = [[sandboxId://UI/Icon/Animals/20.png]],
            DisplayModelId = [[Models.Animals.Animal_20]],
            ModelType = [[Animal]]
        },
        [177] = {
            Index = 177,
            Id = 177,
            Name = [[Light Platypus]],
            Pirce = 1.4199999999999999663116723945472e+31,
            Quality = 42,
            IconId = [[sandboxId://UI/Icon/Animals/21.png]],
            DisplayModelId = [[Models.Animals.Animal_21]],
            ModelType = [[Animal]]
        },
        [178] = {
            Index = 178,
            Id = 178,
            Name = [[Hedgehog]],
            Pirce = 2.2719999999999998560266832838656e+31,
            Quality = 42,
            IconId = [[sandboxId://UI/Icon/Animals/22.png]],
            DisplayModelId = [[Models.Animals.Animal_22]],
            ModelType = [[Animal]]
        },
        [179] = {
            Index = 179,
            Id = 179,
            Name = [[Skunk]],
            Pirce = 3.4080000000000000092200062943232e+31,
            Quality = 43,
            IconId = [[sandboxId://UI/Icon/Animals/23.png]],
            DisplayModelId = [[Models.Animals.Animal_23]],
            ModelType = [[Animal]]
        },
        [180] = {
            Index = 180,
            Id = 180,
            Name = [[Striped Chipmunk]],
            Pirce = 4.2600000000000001241149985521664e+31,
            Quality = 43,
            IconId = [[sandboxId://UI/Icon/Animals/24.png]],
            DisplayModelId = [[Models.Animals.Animal_24]],
            ModelType = [[Animal]]
        },
        [181] = {
            Index = 181,
            Id = 181,
            Name = [[Red Squirrel]],
            Pirce = 7.0999999999999996063783806042112e+31,
            Quality = 43,
            IconId = [[sandboxId://UI/Icon/Animals/25.png]],
            DisplayModelId = [[Models.Animals.Animal_25]],
            ModelType = [[Animal]]
        },
        [182] = {
            Index = 182,
            Id = 182,
            Name = [[Gray Donkey]],
            Pirce = 1.13599999999999997304933791563776e+32,
            Quality = 43,
            IconId = [[sandboxId://UI/Icon/Animals/26.png]],
            DisplayModelId = [[Models.Animals.Animal_26]],
            ModelType = [[Animal]]
        },
        [183] = {
            Index = 183,
            Id = 183,
            Name = [[Brown Donkey]],
            Pirce = 1.70400000000000004964599942086656e+32,
            Quality = 44,
            IconId = [[sandboxId://UI/Icon/Animals/27.png]],
            DisplayModelId = [[Models.Animals.Animal_27]],
            ModelType = [[Animal]]
        },
        [184] = {
            Index = 184,
            Id = 184,
            Name = [[Ostrich]],
            Pirce = 2.13000000000000015212949182349312e+32,
            Quality = 44,
            IconId = [[sandboxId://UI/Icon/Animals/28.png]],
            DisplayModelId = [[Models.Animals.Animal_28]],
            ModelType = [[Animal]]
        },
        [185] = {
            Index = 185,
            Id = 185,
            Name = [[Meerkat]],
            Pirce = 3.55499999999999972869774459797504e+32,
            Quality = 44,
            IconId = [[sandboxId://UI/Icon/Animals/29.png]],
            DisplayModelId = [[Models.Animals.Animal_29]],
            ModelType = [[Animal]]
        },
        [186] = {
            Index = 186,
            Id = 186,
            Name = [[Raccoon]],
            Pirce = 5.68799999999999999826195558432768e+32,
            Quality = 44,
            IconId = [[sandboxId://UI/Icon/Animals/30.png]],
            DisplayModelId = [[Models.Animals.Animal_30]],
            ModelType = [[Animal]]
        },
        [187] = {
            Index = 187,
            Id = 187,
            Name = [[Red Fox]],
            Pirce = 8.53199999999999963710496318685184e+32,
            Quality = 45,
            IconId = [[sandboxId://UI/Icon/Animals/31.png]],
            DisplayModelId = [[Models.Animals.Animal_31]],
            ModelType = [[Animal]]
        },
        [188] = {
            Index = 188,
            Id = 188,
            Name = [[Koala]],
            Pirce = 1.066499999999999990666917417320448e+33,
            Quality = 45,
            IconId = [[sandboxId://UI/Icon/Animals/32.png]],
            DisplayModelId = [[Models.Animals.Animal_32]],
            ModelType = [[Animal]]
        },
        [189] = {
            Index = 189,
            Id = 189,
            Name = [[Leopard]],
            Pirce = 1.77499999999999994663059142475776e+33,
            Quality = 45,
            IconId = [[sandboxId://UI/Icon/Animals/33.png]],
            DisplayModelId = [[Models.Animals.Animal_33]],
            ModelType = [[Animal]]
        },
        [190] = {
            Index = 190,
            Id = 190,
            Name = [[Snow Leopard]],
            Pirce = 2.839999999999999914608946279612416e+33,
            Quality = 45,
            IconId = [[sandboxId://UI/Icon/Animals/34.png]],
            DisplayModelId = [[Models.Animals.Animal_34]],
            ModelType = [[Animal]]
        },
        [191] = {
            Index = 191,
            Id = 191,
            Name = [[Black Wolf]],
            Pirce = 4.259999999999999871913419419418624e+33,
            Quality = 46,
            IconId = [[sandboxId://UI/Icon/Animals/35.png]],
            DisplayModelId = [[Models.Animals.Animal_35]],
            ModelType = [[Animal]]
        },
        [192] = {
            Index = 192,
            Id = 192,
            Name = [[Red-Eared Wolf]],
            Pirce = 5.325000000000000128122150425985024e+33,
            Quality = 46,
            IconId = [[sandboxId://UI/Icon/Animals/36.png]],
            DisplayModelId = [[Models.Animals.Animal_36]],
            ModelType = [[Animal]]
        },
        [193] = {
            Index = 193,
            Id = 193,
            Name = [[Brown Boar]],
            Pirce = 8.900000000000000495602834700500992e+33,
            Quality = 46,
            IconId = [[sandboxId://UI/Icon/Animals/37.png]],
            DisplayModelId = [[Models.Animals.Animal_37]],
            ModelType = [[Animal]]
        },
        [194] = {
            Index = 194,
            Id = 194,
            Name = [[Black Boar]],
            Pirce = 1.4239999999999999409458729992585216e+34,
            Quality = 46,
            IconId = [[sandboxId://UI/Icon/Animals/38.png]],
            DisplayModelId = [[Models.Animals.Animal_38]],
            ModelType = [[Animal]]
        },
        [195] = {
            Index = 195,
            Id = 195,
            Name = [[Brown Gorilla]],
            Pirce = 2.13600000000000002671095995957248e+34,
            Quality = 47,
            IconId = [[sandboxId://UI/Icon/Animals/39.png]],
            DisplayModelId = [[Models.Animals.Animal_39]],
            ModelType = [[Animal]]
        },
        [196] = {
            Index = 196,
            Id = 196,
            Name = [[Silverback Gorilla]],
            Pirce = 2.6700000000000001486808504101502976e+34,
            Quality = 47,
            IconId = [[sandboxId://UI/Icon/Animals/40.png]],
            DisplayModelId = [[Models.Animals.Animal_40]],
            ModelType = [[Animal]]
        },
        [197] = {
            Index = 197,
            Id = 197,
            Name = [[White Wolf]],
            Pirce = 4.440000000000000288697917701619712e+34,
            Quality = 47,
            IconId = [[sandboxId://UI/Icon/Animals/41.png]],
            DisplayModelId = [[Models.Animals.Animal_41]],
            ModelType = [[Animal]]
        },
        [198] = {
            Index = 198,
            Id = 198,
            Name = [[Black Wolf]],
            Pirce = 7.1039999999999995395794646371139584e+34,
            Quality = 47,
            IconId = [[sandboxId://UI/Icon/Animals/42.png]],
            DisplayModelId = [[Models.Animals.Animal_42]],
            ModelType = [[Animal]]
        },
        [199] = {
            Index = 199,
            Id = 199,
            Name = [[Polar Bear]],
            Pirce = 1.06560000000000006928750024838873088e+35,
            Quality = 48,
            IconId = [[sandboxId://UI/Icon/Animals/43.png]],
            DisplayModelId = [[Models.Animals.Animal_43]],
            ModelType = [[Animal]]
        },
        [200] = {
            Index = 200,
            Id = 200,
            Name = [[Tiger]],
            Pirce = 1.3320000000000000866093753104859136e+35,
            Quality = 48,
            IconId = [[sandboxId://UI/Icon/Animals/44.png]],
            DisplayModelId = [[Models.Animals.Animal_44]],
            ModelType = [[Animal]]
        },
        [201] = {
            Index = 201,
            Id = 201,
            Name = [[Muscular Grizzly]],
            Pirce = 2.220000000000000144348958850809856e+35,
            Quality = 48,
            IconId = [[sandboxId://UI/Icon/Animals/45.png]],
            DisplayModelId = [[Models.Animals.Animal_45]],
            ModelType = [[Animal]]
        },
        [202] = {
            Index = 202,
            Id = 202,
            Name = [[Elite Muscular Brown Bear]],
            Pirce = 3.5520000000000002309583341612957696e+35,
            Quality = 48,
            IconId = [[sandboxId://UI/Icon/Animals/46.png]],
            DisplayModelId = [[Models.Animals.Animal_46]],
            ModelType = [[Animal]]
        },
        [203] = {
            Index = 203,
            Id = 203,
            Name = [[White Unicorn]],
            Pirce = 5.3280000000000003464375012419436544e+35,
            Quality = 49,
            IconId = [[sandboxId://UI/Icon/Animals/47.png]],
            DisplayModelId = [[Models.Animals.Animal_47]],
            ModelType = [[Animal]]
        },
        [204] = {
            Index = 204,
            Id = 204,
            Name = [[Unicorn]],
            Pirce = 6.65999999999999969517711360404750336e+35,
            Quality = 49,
            IconId = [[sandboxId://UI/Icon/Animals/48.png]],
            DisplayModelId = [[Models.Animals.Animal_48]],
            ModelType = [[Animal]]
        },
        [205] = {
            Index = 205,
            Id = 205,
            Name = [[Gray Lamb]],
            Pirce = 1.109999999999999998387503130566721536e+36,
            Quality = 49,
            IconId = [[sandboxId://UI/Icon/Island5Animal/XiaoYang1.png]],
            DisplayModelId = [[Models.Island5Animal.Animal_1]],
            ModelType = [[Animal]]
        },
        [206] = {
            Index = 206,
            Id = 206,
            Name = [[Yellow Lamb]],
            Pirce = 1.7760000000000001154791670806478848e+36,
            Quality = 49,
            IconId = [[sandboxId://UI/Icon/Island5Animal/XiaoHuangYang1.png]],
            DisplayModelId = [[Models.Island5Animal.Animal_2]],
            ModelType = [[Animal]]
        },
        [207] = {
            Index = 207,
            Id = 207,
            Name = [[Piglet]],
            Pirce = 2.663999999999999878070845441619001344e+36,
            Quality = 50,
            IconId = [[sandboxId://UI/Icon/Island5Animal/XiaoZhu.png]],
            DisplayModelId = [[Models.Island5Animal.Animal_3]],
            ModelType = [[Animal]]
        },
        [208] = {
            Index = 208,
            Id = 208,
            Name = [[White Puppy]],
            Pirce = 3.32999999999999984758855680202375168e+36,
            Quality = 50,
            IconId = [[sandboxId://UI/Icon/Island5Animal/XiaoBaiGou1.png]],
            DisplayModelId = [[Models.Island5Animal.Animal_4]],
            ModelType = [[Animal]]
        }
    },
    AreaConfig = {
        [1] = {
            Index = 1,
            AreaId = 1,
            NormalRefreshInterval = 20,
            NormalRefreshCount = 4,
            LuckRefreshCount = 3,
            LuckRefreshRate = {
                [1] = 2.5,
                [2] = 3,
            }
        },
        [2] = {
            Index = 2,
            AreaId = 2,
            NormalRefreshInterval = 20,
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
            NormalRefreshInterval = 20,
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
            NormalRefreshInterval = 20,
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
            NormalRefreshInterval = 20,
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
            NormalRefreshInterval = 20,
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
            NormalRefreshInterval = 20,
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
            NormalRefreshInterval = 20,
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
            NormalRefreshInterval = 20,
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
            NormalRefreshInterval = 20,
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
            NormalRefreshInterval = 20,
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
            NormalRefreshInterval = 20,
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
            NormalRefreshInterval = 20,
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
            NormalRefreshInterval = 20,
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
            NormalRefreshInterval = 20,
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
            NormalRefreshInterval = 20,
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
            NormalRefreshInterval = 20,
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
            NormalRefreshInterval = 20,
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
            NormalRefreshInterval = 20,
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
            NormalRefreshInterval = 20,
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
            NormalRefreshInterval = 20,
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
            NormalRefreshInterval = 20,
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
            NormalRefreshInterval = 30,
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
            NormalRefreshInterval = 31,
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
            NormalRefreshInterval = 32,
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
            NormalRefreshInterval = 33,
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
            NormalRefreshInterval = 34,
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
            NormalRefreshInterval = 35,
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
            NormalRefreshInterval = 30,
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
            NormalRefreshInterval = 30,
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
            NormalRefreshInterval = 30,
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
            NormalRefreshInterval = 30,
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
            NormalRefreshInterval = 30,
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
            NormalRefreshInterval = 30,
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
            NormalRefreshInterval = 30,
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
            NormalRefreshInterval = 30,
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
            NormalRefreshInterval = 30,
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
            NormalRefreshInterval = 30,
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
            NormalRefreshInterval = 30,
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
            NormalRefreshInterval = 30,
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
            NormalRefreshInterval = 30,
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
            NormalRefreshInterval = 30,
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
            NormalRefreshInterval = 30,
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
            NormalRefreshInterval = 30,
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
            NormalRefreshInterval = 30,
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
            NormalRefreshInterval = 30,
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
            NormalRefreshInterval = 30,
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
            NormalRefreshInterval = 30,
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
            NormalRefreshInterval = 30,
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
            NormalRefreshInterval = 30,
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
            NormalRefreshInterval = 30,
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
            NormalRefreshInterval = 30,
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
