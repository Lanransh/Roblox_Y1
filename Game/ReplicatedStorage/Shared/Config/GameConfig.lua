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
            Name = [[荒木战棍]],
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
            Name = [[铁木战斧]],
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
            Name = [[霜钢剑]],
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
            Name = [[黑曜石手斧]],
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
            Name = [[绯红晶格法杖]],
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
            Name = [[夜影战斧]],
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
            Name = [[符文战锤]],
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
            Name = [[暗角钉头锤]],
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
            Name = [[白银匕首]],
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
            Name = [[金辉日刃]],
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
            Name = [[星界霜刃]],
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
            Name = [[炼狱弯刀]],
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
            Name = [[翠毒刃]],
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
            Name = [[翠绿三叉戟]],
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
            Name = [[紫晶碎星枪]],
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
            Name = [[霜晶巨剑]],
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
            Name = [[熔岩裂地斧]],
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
            Name = [[烈焰之羽]],
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
            Name = [[耀阳权杖]],
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
            Name = [[辉光天翼剑]],
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
            Name = [[凤凰翼剑]],
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
            Name = [[时轮齿刃]],
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
            Name = [[裂魂镰刀]],
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
            Name = [[炼狱龙刃]],
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
            Name = [[虚空裂隙刃]],
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
            Name = [[噬界魔刃]],
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
            Name = [[赤影刃]],
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
            Name = [[星渊圣锋]],
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
            Name = [[血月魔剑]],
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
            Name = [[紫晶灾厄]],
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
            Name = [[天穹裁决]],
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
            Name = [[赤焰龙牙]],
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
            Name = [[幽影月镰]],
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
            Name = [[曜金帝剑]],
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
            Name = [[苍蓝龙魂]],
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
            Name = [[暮光巨刃]],
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
            Name = [[血族王锋]],
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
            Name = [[绯翼魔剑]],
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
            Name = [[灰烬锯刃]],
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
            Name = [[断魂鬼剑]],
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
            Name = [[绯樱蛇影]],
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
            Name = [[黑曜裁决]],
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
            Name = [[苍穹圣裁]],
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
            Name = [[天翼辉光]],
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
            Name = [[碧海云霄]],
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
            Name = [[王权天谴]],
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
            Name = [[寒渊狼牙]],
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
            Name = [[熔狱断罪]],
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
            Name = [[鸿运镇岳]],
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
            Name = [[影月血牙]],
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
            Name = [[幽冥锁刃]],
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
            Name = [[赤焰龙魂]],
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
            Name = [[曜金赤锋]],
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
            Name = [[1星拖尾]],
            Price = 3750,
            TrainingRate = 1.5,
            DevGoodId = nil,
            ModelId = [[Effects.Trail1]],
            Img = [[sandboxId://UI/Icon/Trail/Trail1Img.png]]
        },
        [2] = {
            Index = 2,
            TrailId = 102,
            Name = [[2星拖尾]],
            Price = 1.38e+6,
            TrainingRate = 2.5,
            DevGoodId = nil,
            ModelId = [[Effects.Trail2]],
            Img = [[sandboxId://UI/Icon/Trail/Trail2Img.png]]
        },
        [3] = {
            Index = 3,
            TrailId = 103,
            Name = [[3星拖尾]],
            Price = 3.32e+8,
            TrainingRate = 3.5,
            DevGoodId = nil,
            ModelId = [[Effects.Trail3]],
            Img = [[sandboxId://UI/Icon/Trail/Trail3Img.png]]
        },
        [4] = {
            Index = 4,
            TrailId = 104,
            Name = [[4星拖尾]],
            Price = 7.3e+10,
            TrainingRate = 4.5,
            DevGoodId = nil,
            ModelId = [[Effects.Trail4]],
            Img = [[sandboxId://UI/Icon/Trail/Trail4Img.png]]
        },
        [5] = {
            Index = 5,
            TrailId = 105,
            Name = [[5星拖尾]],
            Price = 1.42e+13,
            TrainingRate = 5.5,
            DevGoodId = nil,
            ModelId = [[Effects.Trail5]],
            Img = [[sandboxId://UI/Icon/Trail/Trail5Img.png]]
        },
        [6] = {
            Index = 6,
            TrailId = 106,
            Name = [[6星拖尾]],
            Price = 2.67e+15,
            TrainingRate = 6.5,
            DevGoodId = nil,
            ModelId = [[Effects.Trail6]],
            Img = [[sandboxId://UI/Icon/Trail/Trail6Img.png]]
        },
        [7] = {
            Index = 7,
            TrailId = 107,
            Name = [[7星拖尾]],
            Price = 4.69e+17,
            TrainingRate = 7.5,
            DevGoodId = nil,
            ModelId = [[Effects.Trail7]],
            Img = [[sandboxId://UI/Icon/Trail/Trail7Img.png]]
        },
        [8] = {
            Index = 8,
            TrailId = 108,
            Name = [[8星拖尾]],
            Price = 7.56e+19,
            TrainingRate = 8.5,
            DevGoodId = nil,
            ModelId = [[Effects.Trail8]],
            Img = [[sandboxId://UI/Icon/Trail/Trail8Img.png]]
        },
        [9] = {
            Index = 9,
            TrailId = 109,
            Name = [[9星拖尾]],
            Price = 1.18e+22,
            TrainingRate = 9.5,
            DevGoodId = nil,
            ModelId = [[Effects.Trail9]],
            Img = [[sandboxId://UI/Icon/Trail/Trail9Img.png]]
        },
        [10] = {
            Index = 10,
            TrailId = 110,
            Name = [[10星拖尾]],
            Price = 1.649999999999999945474048e+24,
            TrainingRate = 12.5,
            DevGoodId = nil,
            ModelId = [[Effects.Trail10]],
            Img = [[sandboxId://UI/Icon/Trail/Trail10Img.png]]
        },
        [11] = {
            Index = 11,
            TrailId = 111,
            Name = [[11星拖尾]],
            Price = 2.27000000000000009613344768e+26,
            TrainingRate = 15.9,
            DevGoodId = nil,
            ModelId = [[Effects.Trail11]],
            Img = [[sandboxId://UI/Icon/Trail/Trail11Img.png]]
        },
        [12] = {
            Index = 12,
            TrailId = 112,
            Name = [[12星拖尾]],
            Price = 3.0000000000000000948382466048e+28,
            TrainingRate = 19.7,
            DevGoodId = nil,
            ModelId = [[Effects.Trail12]],
            Img = [[sandboxId://UI/Icon/Trail/Trail12Img.png]]
        },
        [13] = {
            Index = 13,
            TrailId = 113,
            Name = [[13星拖尾]],
            Price = 2.2299999999999999233084734046208e+31,
            TrainingRate = 21.3,
            DevGoodId = nil,
            ModelId = [[Effects.Trail13]],
            Img = [[sandboxId://UI/Icon/Trail/Trail13Img.png]]
        },
        [14] = {
            Index = 14,
            TrailId = 114,
            Name = [[14星拖尾]],
            Price = 3.28999999999999980364868737826816e+33,
            TrainingRate = 22.9,
            DevGoodId = nil,
            ModelId = [[Effects.Trail14]],
            Img = [[sandboxId://UI/Icon/Trail/Trail14Img.png]]
        },
        [15] = {
            Index = 15,
            TrailId = 115,
            Name = [[15星拖尾]],
            Price = 4.78000000000000000502155017763946496e+35,
            TrainingRate = 24.5,
            DevGoodId = nil,
            ModelId = [[Effects.Trail15]],
            Img = [[sandboxId://UI/Icon/Trail/Trail15Img.png]]
        },
        [16] = {
            Index = 16,
            TrailId = 116,
            Name = [[16星拖尾]],
            Price = 6.7200000000000001433956886673113481216e+37,
            TrainingRate = 26.1,
            DevGoodId = nil,
            ModelId = [[Effects.Trail16]],
            Img = [[sandboxId://UI/Icon/Trail/Trail16Img.png]]
        },
        [17] = {
            Index = 17,
            TrailId = 117,
            Name = [[17星拖尾]],
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
            Name = [[打火机]],
            Pirce = 3,
            Quality = 1,
            IconId = [[sandboxId://Model/Item/png/046_Zippo.png]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_001_Nail]],
            ModelType = [[Item]]
        },
        [2] = {
            Index = 2,
            Id = 2,
            Name = [[矿泉水]],
            Pirce = 4,
            Quality = 1,
            IconId = [[sandboxId://Model/Item/png/016_Water01.png]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_002_Pill]],
            ModelType = [[Item]]
        },
        [3] = {
            Index = 3,
            Id = 3,
            Name = [[纯净水]],
            Pirce = 6,
            Quality = 1,
            IconId = [[sandboxId://Model/Item/png/017_Water02.png]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_003_Capsule]],
            ModelType = [[Item]]
        },
        [4] = {
            Index = 4,
            Id = 4,
            Name = [[苏打水]],
            Pirce = 8,
            Quality = 1,
            IconId = [[sandboxId://Model/Item/png/018_Water03.png]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_004_Battery01]],
            ModelType = [[Item]]
        },
        [5] = {
            Index = 5,
            Id = 5,
            Name = [[水桶]],
            Pirce = 13,
            Quality = 2,
            IconId = [[sandboxId://Model/Item/png/081_Drum01.png]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_005_Battery02]],
            ModelType = [[Item]]
        },
        [6] = {
            Index = 6,
            Id = 6,
            Name = [[玻璃瓶]],
            Pirce = 20,
            Quality = 2,
            IconId = [[sandboxId://Model/Item/png/021_Bottle01.png]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_006_Biscuit01]],
            ModelType = [[Item]]
        },
        [7] = {
            Index = 7,
            Id = 7,
            Name = [[啤酒瓶]],
            Pirce = 30,
            Quality = 2,
            IconId = [[sandboxId://Model/Item/png/022_Bottle02.png]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_007_Biscuit02]],
            ModelType = [[Item]]
        },
        [8] = {
            Index = 8,
            Id = 8,
            Name = [[红酒瓶]],
            Pirce = 38,
            Quality = 2,
            IconId = [[sandboxId://Model/Item/png/023_Bottle03.png]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_008_Biscuit03]],
            ModelType = [[Item]]
        },
        [9] = {
            Index = 9,
            Id = 9,
            Name = [[香槟瓶]],
            Pirce = 63,
            Quality = 3,
            IconId = [[sandboxId://Model/Item/png/024_Bottle04.png]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_009_Chocolate01]],
            ModelType = [[Item]]
        },
        [10] = {
            Index = 10,
            Id = 10,
            Name = [[收藏酒瓶]],
            Pirce = 100,
            Quality = 3,
            IconId = [[sandboxId://Model/Item/png/025_Bottle05.png]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_010_Chocolate02]],
            ModelType = [[Item]]
        },
        [11] = {
            Index = 11,
            Id = 11,
            Name = [[钢钉]],
            Pirce = 150,
            Quality = 3,
            IconId = [[sandboxId://Model/Item/png/001_Nail.png]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_011_Chocolate_Drink]],
            ModelType = [[Item]]
        },
        [12] = {
            Index = 12,
            Id = 12,
            Name = [[药片]],
            Pirce = 188,
            Quality = 3,
            IconId = [[sandboxId://Model/Item/png/002_Pill.png]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_012_Honey01]],
            ModelType = [[Item]]
        },
        [13] = {
            Index = 13,
            Id = 13,
            Name = [[曲奇]],
            Pirce = 313,
            Quality = 4,
            IconId = [[sandboxId://Model/Item/png/006_Biscuit01.png]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_013_Honey02]],
            ModelType = [[Item]]
        },
        [14] = {
            Index = 14,
            Id = 14,
            Name = [[苏打饼]],
            Pirce = 500,
            Quality = 4,
            IconId = [[sandboxId://Model/Item/png/007_Biscuit02.png]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_014_Jam01]],
            ModelType = [[Item]]
        },
        [15] = {
            Index = 15,
            Id = 15,
            Name = [[夹心饼]],
            Pirce = 750,
            Quality = 4,
            IconId = [[sandboxId://Model/Item/png/008_Biscuit03.png]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_015_Jam02]],
            ModelType = [[Item]]
        },
        [16] = {
            Index = 16,
            Id = 16,
            Name = [[黑巧克力]],
            Pirce = 938,
            Quality = 4,
            IconId = [[sandboxId://Model/Item/png/009_Chocolate01.png]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_016_Water01]],
            ModelType = [[Item]]
        },
        [17] = {
            Index = 17,
            Id = 17,
            Name = [[牛奶巧克力]],
            Pirce = 1563,
            Quality = 5,
            IconId = [[sandboxId://Model/Item/png/010_Chocolate02.png]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_017_Water02]],
            ModelType = [[Item]]
        },
        [18] = {
            Index = 18,
            Id = 18,
            Name = [[可可饮料]],
            Pirce = 2500,
            Quality = 5,
            IconId = [[sandboxId://Model/Item/png/011_Chocolate_Drink.png]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_018_Water03]],
            ModelType = [[Item]]
        },
        [19] = {
            Index = 19,
            Id = 19,
            Name = [[蜂蜜]],
            Pirce = 3750,
            Quality = 5,
            IconId = [[sandboxId://Model/Item/png/012_Honey01.png]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_019_Waterbottle01]],
            ModelType = [[Item]]
        },
        [20] = {
            Index = 20,
            Id = 20,
            Name = [[野蜂蜜]],
            Pirce = 4688,
            Quality = 5,
            IconId = [[sandboxId://Model/Item/png/013_Honey02.png]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_020_Waterbottle02]],
            ModelType = [[Item]]
        },
        [21] = {
            Index = 21,
            Id = 21,
            Name = [[草莓酱]],
            Pirce = 7800,
            Quality = 6,
            IconId = [[sandboxId://Model/Item/png/014_Jam01.png]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_021_Bottle01]],
            ModelType = [[Item]]
        },
        [22] = {
            Index = 22,
            Id = 22,
            Name = [[蓝莓酱]],
            Pirce = 12480,
            Quality = 6,
            IconId = [[sandboxId://Model/Item/png/015_Jam02.png]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_022_Bottle02]],
            ModelType = [[Item]]
        },
        [23] = {
            Index = 23,
            Id = 23,
            Name = [[肉罐头]],
            Pirce = 18720,
            Quality = 6,
            IconId = [[sandboxId://Model/Item/png/026_Can01.png]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_023_Bottle03]],
            ModelType = [[Item]]
        },
        [24] = {
            Index = 24,
            Id = 24,
            Name = [[鱼罐头]],
            Pirce = 23400,
            Quality = 6,
            IconId = [[sandboxId://Model/Item/png/027_Can02.png]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_024_Bottle04]],
            ModelType = [[Item]]
        },
        [25] = {
            Index = 25,
            Id = 25,
            Name = [[水果罐头]],
            Pirce = 39050,
            Quality = 7,
            IconId = [[sandboxId://Model/Item/png/028_Can03.png]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_025_Bottle05]],
            ModelType = [[Item]]
        },
        [26] = {
            Index = 26,
            Id = 26,
            Name = [[午餐肉]],
            Pirce = 62480,
            Quality = 7,
            IconId = [[sandboxId://Model/Item/png/029_Can04.png]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_026_Can01]],
            ModelType = [[Item]]
        },
        [27] = {
            Index = 27,
            Id = 27,
            Name = [[豆子罐头]],
            Pirce = 93720,
            Quality = 7,
            IconId = [[sandboxId://Model/Item/png/030_Can05.png]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_027_Can02]],
            ModelType = [[Item]]
        },
        [28] = {
            Index = 28,
            Id = 28,
            Name = [[军粮罐头]],
            Pirce = 117150,
            Quality = 7,
            IconId = [[sandboxId://Model/Item/png/031_Can06.png]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_028_Can03]],
            ModelType = [[Item]]
        },
        [29] = {
            Index = 29,
            Id = 29,
            Name = [[高级罐头]],
            Pirce = 195500,
            Quality = 8,
            IconId = [[sandboxId://Model/Item/png/032_Can07.png]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_029_Can04]],
            ModelType = [[Item]]
        },
        [30] = {
            Index = 30,
            Id = 30,
            Name = [[清洁剂]],
            Pirce = 312800,
            Quality = 8,
            IconId = [[sandboxId://Model/Item/png/042_Detergent.png]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_030_Can05]],
            ModelType = [[Item]]
        },
        [31] = {
            Index = 31,
            Id = 31,
            Name = [[漂白水]],
            Pirce = 469200,
            Quality = 8,
            IconId = [[sandboxId://Model/Item/png/043_Bleach.png]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_031_Can06]],
            ModelType = [[Item]]
        },
        [32] = {
            Index = 32,
            Id = 32,
            Name = [[润滑油]],
            Pirce = 586500,
            Quality = 8,
            IconId = [[sandboxId://Model/Item/png/044_WD40.png]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_032_Can07]],
            ModelType = [[Item]]
        },
        [33] = {
            Index = 33,
            Id = 33,
            Name = [[小油壶]],
            Pirce = 975000,
            Quality = 9,
            IconId = [[sandboxId://Model/Item/png/047_Oilcan01.png]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_033_Medicine_bottle01]],
            ModelType = [[Item]]
        },
        [34] = {
            Index = 34,
            Id = 34,
            Name = [[运动水壶]],
            Pirce = 1.56e+6,
            Quality = 6,
            IconId = [[sandboxId://Model/Item/png/019_Waterbottle01.png]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_034_Medicine_bottle02]],
            ModelType = [[Item]]
        },
        [35] = {
            Index = 35,
            Id = 35,
            Name = [[军用水壶]],
            Pirce = 2.34e+6,
            Quality = 7,
            IconId = [[sandboxId://Model/Item/png/020_Waterbottle02.png]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_035_Injection]],
            ModelType = [[Item]]
        },
        [36] = {
            Index = 36,
            Id = 36,
            Name = [[机油壶]],
            Pirce = 2.925e+6,
            Quality = 9,
            IconId = [[sandboxId://Model/Item/png/048_Oilcan02.png]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_036_InjectionA]],
            ModelType = [[Item]]
        },
        [37] = {
            Index = 37,
            Id = 37,
            Name = [[燃油罐]],
            Pirce = 4.885e+6,
            Quality = 10,
            IconId = [[sandboxId://Model/Item/png/049_Oilcan03.png]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_037_First_aid_Kit_Bandage]],
            ModelType = [[Item]]
        },
        [38] = {
            Index = 38,
            Id = 38,
            Name = [[礼帽]],
            Pirce = 7.816e+6,
            Quality = 10,
            IconId = [[sandboxId://Model/Item/png/055_Hat.png]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_038_Lv]],
            ModelType = [[Item]]
        },
        [39] = {
            Index = 39,
            Id = 39,
            Name = [[棒球帽]],
            Pirce = 1.1724e+7,
            Quality = 10,
            IconId = [[sandboxId://Model/Item/png/056_Cap_A_0.png]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_039_First_aid_Kit01]],
            ModelType = [[Item]]
        },
        [40] = {
            Index = 40,
            Id = 40,
            Name = [[墨镜]],
            Pirce = 1.4655e+7,
            Quality = 10,
            IconId = [[sandboxId://Model/Item/png/057_Sunglass01.png]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_040_First_aid_Kit02]],
            ModelType = [[Item]]
        },
        [41] = {
            Index = 41,
            Id = 41,
            Name = [[太阳镜]],
            Pirce = 2.44e+7,
            Quality = 11,
            IconId = [[sandboxId://Model/Item/png/058_Sunglass02.png]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_041_First_aid_Kit03]],
            ModelType = [[Item]]
        },
        [42] = {
            Index = 42,
            Id = 42,
            Name = [[护目镜]],
            Pirce = 3.904e+7,
            Quality = 11,
            IconId = [[sandboxId://Model/Item/png/059_Goggle.png]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_042_Detergent]],
            ModelType = [[Item]]
        },
        [43] = {
            Index = 43,
            Id = 43,
            Name = [[战术风镜]],
            Pirce = 5.856e+7,
            Quality = 11,
            IconId = [[sandboxId://Model/Item/png/060_GoggleA.png]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_043_Bleach]],
            ModelType = [[Item]]
        },
        [44] = {
            Index = 44,
            Id = 44,
            Name = [[口罩]],
            Pirce = 7.32e+7,
            Quality = 11,
            IconId = [[sandboxId://Model/Item/png/061_MaskA.png]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_044_WD40]],
            ModelType = [[Item]]
        },
        [45] = {
            Index = 45,
            Id = 45,
            Name = [[防毒面具]],
            Pirce = 1.22e+8,
            Quality = 12,
            IconId = [[sandboxId://Model/Item/png/062_GasMask01.png]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_045_Pipe]],
            ModelType = [[Item]]
        },
        [46] = {
            Index = 46,
            Id = 46,
            Name = [[战术面具]],
            Pirce = 1.952e+8,
            Quality = 12,
            IconId = [[sandboxId://Model/Item/png/063_GasMask02.png]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_046_Zippo]],
            ModelType = [[Item]]
        },
        [47] = {
            Index = 47,
            Id = 47,
            Name = [[皮靴]],
            Pirce = 2.928e+8,
            Quality = 12,
            IconId = [[sandboxId://Model/Item/png/064_Boots01.png]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_047_Oilcan01]],
            ModelType = [[Item]]
        },
        [48] = {
            Index = 48,
            Id = 48,
            Name = [[雨靴]],
            Pirce = 3.66e+8,
            Quality = 12,
            IconId = [[sandboxId://Model/Item/png/065_Boots02.png]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_048_Oilcan02]],
            ModelType = [[Item]]
        },
        [49] = {
            Index = 49,
            Id = 49,
            Name = [[登山靴]],
            Pirce = 6.1e+8,
            Quality = 13,
            IconId = [[sandboxId://Model/Item/png/066_Boots03.png]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_049_Oilcan03]],
            ModelType = [[Item]]
        },
        [50] = {
            Index = 50,
            Id = 50,
            Name = [[军靴]],
            Pirce = 9.76e+8,
            Quality = 13,
            IconId = [[sandboxId://Model/Item/png/067_Boots04.png]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_050_Mobilephone]],
            ModelType = [[Item]]
        },
        [51] = {
            Index = 51,
            Id = 51,
            Name = [[防弹背心]],
            Pirce = 1.464e+9,
            Quality = 13,
            IconId = [[sandboxId://Model/Item/png/068_BulletproofJacket01.png]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_051_Watch01]],
            ModelType = [[Item]]
        },
        [52] = {
            Index = 52,
            Id = 52,
            Name = [[重型护甲]],
            Pirce = 1.83e+9,
            Quality = 13,
            IconId = [[sandboxId://Model/Item/png/069_BulletproofJacket02.png]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_052_IdentificationTag]],
            ModelType = [[Item]]
        },
        [53] = {
            Index = 53,
            Id = 53,
            Name = [[工地头盔]],
            Pirce = 3.05e+9,
            Quality = 14,
            IconId = [[sandboxId://Model/Item/png/070_Helmet01.png]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_053_Compass]],
            ModelType = [[Item]]
        },
        [54] = {
            Index = 54,
            Id = 54,
            Name = [[骑行头盔]],
            Pirce = 4.88e+9,
            Quality = 14,
            IconId = [[sandboxId://Model/Item/png/071_Helmet02.png]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_054_CompassA]],
            ModelType = [[Item]]
        },
        [55] = {
            Index = 55,
            Id = 55,
            Name = [[防暴头盔]],
            Pirce = 7.32e+9,
            Quality = 14,
            IconId = [[sandboxId://Model/Item/png/072_Helmet03.png]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_055_Hat]],
            ModelType = [[Item]]
        },
        [56] = {
            Index = 56,
            Id = 56,
            Name = [[战术头盔]],
            Pirce = 9.15e+9,
            Quality = 14,
            IconId = [[sandboxId://Model/Item/png/073_Helmet04.png]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_056_Cap_A_0]],
            ModelType = [[Item]]
        },
        [57] = {
            Index = 57,
            Id = 57,
            Name = [[小背包]],
            Pirce = 1.525e+10,
            Quality = 15,
            IconId = [[sandboxId://Model/Item/png/074_Bag01.png]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_057_Sunglass01]],
            ModelType = [[Item]]
        },
        [58] = {
            Index = 58,
            Id = 58,
            Name = [[登山包]],
            Pirce = 2.44e+10,
            Quality = 15,
            IconId = [[sandboxId://Model/Item/png/075_Bag02.png]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_058_Sunglass02]],
            ModelType = [[Item]]
        },
        [59] = {
            Index = 59,
            Id = 59,
            Name = [[军用背包]],
            Pirce = 3.66e+10,
            Quality = 15,
            IconId = [[sandboxId://Model/Item/png/076_Bag03.png]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_059_Goggle]],
            ModelType = [[Item]]
        },
        [60] = {
            Index = 60,
            Id = 60,
            Name = [[铁锅]],
            Pirce = 4.575e+10,
            Quality = 15,
            IconId = [[sandboxId://Model/Item/png/080_Pot01.png]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_060_GoggleA]],
            ModelType = [[Item]]
        },
        [61] = {
            Index = 61,
            Id = 61,
            Name = [[木锤]],
            Pirce = 7.65e+10,
            Quality = 16,
            IconId = [[sandboxId://Model/Item/png/096_Hammer01.png]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_061_MaskA]],
            ModelType = [[Item]]
        },
        [62] = {
            Index = 62,
            Id = 62,
            Name = [[铁锤]],
            Pirce = 1.224e+11,
            Quality = 16,
            IconId = [[sandboxId://Model/Item/png/097_Hammer02.png]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_062_GasMask01]],
            ModelType = [[Item]]
        },
        [63] = {
            Index = 63,
            Id = 63,
            Name = [[大锤]],
            Pirce = 1.836e+11,
            Quality = 16,
            IconId = [[sandboxId://Model/Item/png/098_Hammer03.png]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_063_GasMask02]],
            ModelType = [[Item]]
        },
        [64] = {
            Index = 64,
            Id = 64,
            Name = [[扳手]],
            Pirce = 2.295e+11,
            Quality = 16,
            IconId = [[sandboxId://Model/Item/png/099_Wrench01.png]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_064_Boots01]],
            ModelType = [[Item]]
        },
        [65] = {
            Index = 65,
            Id = 65,
            Name = [[活动扳手]],
            Pirce = 3.815e+11,
            Quality = 17,
            IconId = [[sandboxId://Model/Item/png/100_Wrench02.png]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_065_Boots02]],
            ModelType = [[Item]]
        },
        [66] = {
            Index = 66,
            Id = 66,
            Name = [[管钳]],
            Pirce = 6.104e+11,
            Quality = 17,
            IconId = [[sandboxId://Model/Item/png/101_Wrench03.png]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_066_Boots03]],
            ModelType = [[Item]]
        },
        [67] = {
            Index = 67,
            Id = 67,
            Name = [[工兵铲]],
            Pirce = 9.156e+11,
            Quality = 17,
            IconId = [[sandboxId://Model/Item/png/102_Shovel01.png]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_067_Boots04]],
            ModelType = [[Item]]
        },
        [68] = {
            Index = 68,
            Id = 68,
            Name = [[铁锹]],
            Pirce = 1.1445e+12,
            Quality = 17,
            IconId = [[sandboxId://Model/Item/png/103_Shovel02.png]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_068_BulletproofJacket01]],
            ModelType = [[Item]]
        },
        [69] = {
            Index = 69,
            Id = 69,
            Name = [[十字镐]],
            Pirce = 1.905e+12,
            Quality = 18,
            IconId = [[sandboxId://Model/Item/png/104_Pickax.png]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_069_BulletproofJacket02]],
            ModelType = [[Item]]
        },
        [70] = {
            Index = 70,
            Id = 70,
            Name = [[胶囊]],
            Pirce = 3.048e+12,
            Quality = 15,
            IconId = [[sandboxId://Model/Item/png/003_Capsule.png]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_070_Helmet01]],
            ModelType = [[Item]]
        },
        [71] = {
            Index = 71,
            Id = 71,
            Name = [[干电池]],
            Pirce = 4.572e+12,
            Quality = 16,
            IconId = [[sandboxId://Model/Item/png/004_Battery01.png]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_071_Helmet02]],
            ModelType = [[Item]]
        },
        [72] = {
            Index = 72,
            Id = 72,
            Name = [[强力电池]],
            Pirce = 5.715e+12,
            Quality = 16,
            IconId = [[sandboxId://Model/Item/png/005_Battery02.png]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_072_Helmet03]],
            ModelType = [[Item]]
        },
        [73] = {
            Index = 73,
            Id = 73,
            Name = [[药瓶]],
            Pirce = 9.55e+12,
            Quality = 16,
            IconId = [[sandboxId://Model/Item/png/033_Medicine_bottle01.png]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_073_Helmet04]],
            ModelType = [[Item]]
        },
        [74] = {
            Index = 74,
            Id = 74,
            Name = [[急救药瓶]],
            Pirce = 1.528e+13,
            Quality = 16,
            IconId = [[sandboxId://Model/Item/png/034_Medicine_bottle02.png]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_074_Bag01]],
            ModelType = [[Item]]
        },
        [75] = {
            Index = 75,
            Id = 75,
            Name = [[注射器]],
            Pirce = 2.292e+13,
            Quality = 17,
            IconId = [[sandboxId://Model/Item/png/035_Injection.png]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_075_Bag02]],
            ModelType = [[Item]]
        },
        [76] = {
            Index = 76,
            Id = 76,
            Name = [[强化针]],
            Pirce = 2.865e+13,
            Quality = 17,
            IconId = [[sandboxId://Model/Item/png/036_InjectionA.png]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_076_Bag03]],
            ModelType = [[Item]]
        },
        [77] = {
            Index = 77,
            Id = 77,
            Name = [[医用绷带]],
            Pirce = 4.77e+13,
            Quality = 17,
            IconId = [[sandboxId://Model/Item/png/037_First_aid_Kit_Bandage.png]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_077_Box01]],
            ModelType = [[Item]]
        },
        [78] = {
            Index = 78,
            Id = 78,
            Name = [[绿色徽章]],
            Pirce = 7.632e+13,
            Quality = 17,
            IconId = [[sandboxId://Model/Item/png/038_Lv.png]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_078_Box02]],
            ModelType = [[Item]]
        },
        [79] = {
            Index = 79,
            Id = 79,
            Name = [[急救包]],
            Pirce = 1.1448e+14,
            Quality = 18,
            IconId = [[sandboxId://Model/Item/png/039_First_aid_Kit01.png]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_079_Box03]],
            ModelType = [[Item]]
        },
        [80] = {
            Index = 80,
            Id = 80,
            Name = [[医疗箱]],
            Pirce = 1.431e+14,
            Quality = 18,
            IconId = [[sandboxId://Model/Item/png/040_First_aid_Kit02.png]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_080_Pot01]],
            ModelType = [[Item]]
        },
        [81] = {
            Index = 81,
            Id = 81,
            Name = [[高级医疗箱]],
            Pirce = 2.385e+14,
            Quality = 18,
            IconId = [[sandboxId://Model/Item/png/041_First_aid_Kit03.png]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_081_Drum01]],
            ModelType = [[Item]]
        },
        [82] = {
            Index = 82,
            Id = 82,
            Name = [[钢管]],
            Pirce = 3.816e+14,
            Quality = 18,
            IconId = [[sandboxId://Model/Item/png/045_Pipe.png]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_082_Drum02]],
            ModelType = [[Item]]
        },
        [83] = {
            Index = 83,
            Id = 83,
            Name = [[手机]],
            Pirce = 5.724e+14,
            Quality = 19,
            IconId = [[sandboxId://Model/Item/png/050_Mobilephone.png]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_083_Drum03]],
            ModelType = [[Item]]
        },
        [84] = {
            Index = 84,
            Id = 84,
            Name = [[手表]],
            Pirce = 7.155e+14,
            Quality = 19,
            IconId = [[sandboxId://Model/Item/png/051_Watch01.png]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_084_Drum04]],
            ModelType = [[Item]]
        },
        [85] = {
            Index = 85,
            Id = 85,
            Name = [[身份牌]],
            Pirce = 1.19e+15,
            Quality = 19,
            IconId = [[sandboxId://Model/Item/png/052_IdentificationTag.png]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_085_Drum05]],
            ModelType = [[Item]]
        },
        [86] = {
            Index = 86,
            Id = 86,
            Name = [[指南针]],
            Pirce = 1.904e+15,
            Quality = 19,
            IconId = [[sandboxId://Model/Item/png/053_Compass.png]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_086_Propane]],
            ModelType = [[Item]]
        },
        [87] = {
            Index = 87,
            Id = 87,
            Name = [[军用罗盘]],
            Pirce = 2.856e+15,
            Quality = 20,
            IconId = [[sandboxId://Model/Item/png/054_CompassA.png]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_087_RopeA]],
            ModelType = [[Item]]
        },
        [88] = {
            Index = 88,
            Id = 88,
            Name = [[木箱]],
            Pirce = 3.57e+15,
            Quality = 20,
            IconId = [[sandboxId://Model/Item/png/077_Box01.png]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_088_Wire]],
            ModelType = [[Item]]
        },
        [89] = {
            Index = 89,
            Id = 89,
            Name = [[工具箱]],
            Pirce = 5.95e+15,
            Quality = 20,
            IconId = [[sandboxId://Model/Item/png/078_Box02.png]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_089_Walkie_Talkie]],
            ModelType = [[Item]]
        },
        [90] = {
            Index = 90,
            Id = 90,
            Name = [[补给箱]],
            Pirce = 9.52e+15,
            Quality = 20,
            IconId = [[sandboxId://Model/Item/png/079_Box03.png]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_090_Walkie_TalkieA]],
            ModelType = [[Item]]
        },
        [91] = {
            Index = 91,
            Id = 91,
            Name = [[油桶]],
            Pirce = 1.428e+16,
            Quality = 21,
            IconId = [[sandboxId://Model/Item/png/082_Drum02.png]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_091_Flashlight01]],
            ModelType = [[Item]]
        },
        [92] = {
            Index = 92,
            Id = 92,
            Name = [[储物桶]],
            Pirce = 1.785e+16,
            Quality = 21,
            IconId = [[sandboxId://Model/Item/png/083_Drum03.png]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_092_HeadLantern]],
            ModelType = [[Item]]
        },
        [93] = {
            Index = 93,
            Id = 93,
            Name = [[密封桶]],
            Pirce = 2.98e+16,
            Quality = 21,
            IconId = [[sandboxId://Model/Item/png/084_Drum04.png]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_093_Lantern]],
            ModelType = [[Item]]
        },
        [94] = {
            Index = 94,
            Id = 94,
            Name = [[大铁桶]],
            Pirce = 4.768e+16,
            Quality = 21,
            IconId = [[sandboxId://Model/Item/png/085_Drum05.png]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_094_Telescope01]],
            ModelType = [[Item]]
        },
        [95] = {
            Index = 95,
            Id = 95,
            Name = [[煤气罐]],
            Pirce = 7.152e+16,
            Quality = 22,
            IconId = [[sandboxId://Model/Item/png/086_Propane.png]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_095_Telescope02]],
            ModelType = [[Item]]
        },
        [96] = {
            Index = 96,
            Id = 96,
            Name = [[粗绳]],
            Pirce = 8.94e+16,
            Quality = 22,
            IconId = [[sandboxId://Model/Item/png/087_RopeA.png]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_096_Hammer01]],
            ModelType = [[Item]]
        },
        [97] = {
            Index = 97,
            Id = 97,
            Name = [[电线]],
            Pirce = 1.49e+17,
            Quality = 22,
            IconId = [[sandboxId://Model/Item/png/088_Wire.png]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_097_Hammer02]],
            ModelType = [[Item]]
        },
        [98] = {
            Index = 98,
            Id = 98,
            Name = [[对讲机]],
            Pirce = 2.384e+17,
            Quality = 22,
            IconId = [[sandboxId://Model/Item/png/089_Walkie_Talkie.png]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_098_Hammer03]],
            ModelType = [[Item]]
        },
        [99] = {
            Index = 99,
            Id = 99,
            Name = [[军用电台]],
            Pirce = 3.576e+17,
            Quality = 23,
            IconId = [[sandboxId://Model/Item/png/090_Walkie_TalkieA.png]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_099_Wrench01]],
            ModelType = [[Item]]
        },
        [100] = {
            Index = 100,
            Id = 100,
            Name = [[手电筒]],
            Pirce = 4.47e+17,
            Quality = 23,
            IconId = [[sandboxId://Model/Item/png/091_Flashlight01.png]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_100_Wrench02]],
            ModelType = [[Item]]
        },
        [101] = {
            Index = 101,
            Id = 101,
            Name = [[头灯]],
            Pirce = 7.45e+17,
            Quality = 23,
            IconId = [[sandboxId://Model/Item/png/092_HeadLantern.png]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_101_Wrench03]],
            ModelType = [[Item]]
        },
        [102] = {
            Index = 102,
            Id = 102,
            Name = [[提灯]],
            Pirce = 1.192e+18,
            Quality = 23,
            IconId = [[sandboxId://Model/Item/png/093_Lantern.png]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_102_Shovel01]],
            ModelType = [[Item]]
        },
        [103] = {
            Index = 103,
            Id = 103,
            Name = [[望远镜]],
            Pirce = 1.788e+18,
            Quality = 24,
            IconId = [[sandboxId://Model/Item/png/094_Telescope01.png]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_103_Shovel02]],
            ModelType = [[Item]]
        },
        [104] = {
            Index = 104,
            Id = 104,
            Name = [[高倍望远镜]],
            Pirce = 2.235e+18,
            Quality = 24,
            IconId = [[sandboxId://Model/Item/png/095_Telescope02.png]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_104_Pickax]],
            ModelType = [[Item]]
        },
        [105] = {
            Index = 105,
            Id = 105,
            Name = [[高尔夫球杆]],
            Pirce = 3.725e+18,
            Quality = 24,
            IconId = [[sandboxId://Model/Item/png/105_GolfClub.png]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_105_GolfClub]],
            ModelType = [[Item]]
        },
        [106] = {
            Index = 106,
            Id = 106,
            Name = [[冰球杆]],
            Pirce = 5.96e+18,
            Quality = 24,
            IconId = [[sandboxId://Model/Item/png/106_Hockey.png]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_106_Hockey]],
            ModelType = [[Item]]
        },
        [107] = {
            Index = 107,
            Id = 107,
            Name = [[木棒]],
            Pirce = 8.94e+18,
            Quality = 25,
            IconId = [[sandboxId://Model/Item/png/107_Bat01.png]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_107_Bat01]],
            ModelType = [[Item]]
        },
        [108] = {
            Index = 108,
            Id = 108,
            Name = [[球棒]],
            Pirce = 1.1175e+19,
            Quality = 25,
            IconId = [[sandboxId://Model/Item/png/108_Bat02.png]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_108_Bat02]],
            ModelType = [[Item]]
        },
        [109] = {
            Index = 109,
            Id = 109,
            Name = [[铁棒]],
            Pirce = 1.865e+19,
            Quality = 25,
            IconId = [[sandboxId://Model/Item/png/109_Bat03.png]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_109_Bat03]],
            ModelType = [[Item]]
        },
        [110] = {
            Index = 110,
            Id = 110,
            Name = [[战术棍]],
            Pirce = 2.984e+19,
            Quality = 25,
            IconId = [[sandboxId://Model/Item/png/110_Bat04.png]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_110_Bat04]],
            ModelType = [[Item]]
        },
        [111] = {
            Index = 111,
            Id = 111,
            Name = [[电锯]],
            Pirce = 4.476e+19,
            Quality = 26,
            IconId = [[sandboxId://Model/Item/png/111_ElectricSaw.png]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_111_ElectricSaw]],
            ModelType = [[Item]]
        },
        [112] = {
            Index = 112,
            Id = 112,
            Name = [[木斧]],
            Pirce = 5.595e+19,
            Quality = 26,
            IconId = [[sandboxId://Model/Item/png/112_Ax01.png]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_112_Ax01]],
            ModelType = [[Item]]
        },
        [113] = {
            Index = 113,
            Id = 113,
            Name = [[消防斧]],
            Pirce = 9.3e+19,
            Quality = 26,
            IconId = [[sandboxId://Model/Item/png/113_Ax02.png]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_113_Ax02]],
            ModelType = [[Item]]
        },
        [114] = {
            Index = 114,
            Id = 114,
            Name = [[战斧]],
            Pirce = 1.488e+20,
            Quality = 26,
            IconId = [[sandboxId://Model/Item/png/114_Ax03.png]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_114_Ax03]],
            ModelType = [[Item]]
        },
        [115] = {
            Index = 115,
            Id = 115,
            Name = [[小刀]],
            Pirce = 2.232e+20,
            Quality = 27,
            IconId = [[sandboxId://Model/Item/png/115_Knife01.png]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_115_Knife01]],
            ModelType = [[Item]]
        },
        [116] = {
            Index = 116,
            Id = 116,
            Name = [[猎刀]],
            Pirce = 2.79e+20,
            Quality = 27,
            IconId = [[sandboxId://Model/Item/png/116_Knife02.png]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_116_Knife02]],
            ModelType = [[Item]]
        },
        [117] = {
            Index = 117,
            Id = 117,
            Name = [[军刀]],
            Pirce = 4.655e+20,
            Quality = 27,
            IconId = [[sandboxId://Model/Item/png/117_Knife03.png]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_117_Knife03]],
            ModelType = [[Item]]
        },
        [118] = {
            Index = 118,
            Id = 118,
            Name = [[开山刀]],
            Pirce = 7.448e+20,
            Quality = 27,
            IconId = [[sandboxId://Model/Item/png/118_Knife04.png]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_118_Knife04]],
            ModelType = [[Item]]
        },
        [119] = {
            Index = 119,
            Id = 119,
            Name = [[匕首]],
            Pirce = 1.1172e+21,
            Quality = 28,
            IconId = [[sandboxId://Model/Item/png/119_Knife05.png]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_119_Knife05]],
            ModelType = [[Item]]
        },
        [120] = {
            Index = 120,
            Id = 120,
            Name = [[战术刀]],
            Pirce = 1.396499999999999868928e+21,
            Quality = 28,
            IconId = [[sandboxId://Model/Item/png/120_Knife06.png]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_120_Knife06]],
            ModelType = [[Item]]
        },
        [121] = {
            Index = 121,
            Id = 121,
            Name = [[狼牙棒]],
            Pirce = 2.33e+21,
            Quality = 28,
            IconId = [[sandboxId://Model/Item/png/121_Ironmace.png]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_121_Ironmace]],
            ModelType = [[Item]]
        },
        [122] = {
            Index = 122,
            Id = 122,
            Name = [[炸药罐]],
            Pirce = 3.728e+21,
            Quality = 28,
            IconId = [[sandboxId://Model/Item/png/122_Dynamite01.png]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_122_Dynamite01]],
            ModelType = [[Item]]
        },
        [123] = {
            Index = 123,
            Id = 123,
            Name = [[捆装炸药]],
            Pirce = 5.592e+21,
            Quality = 29,
            IconId = [[sandboxId://Model/Item/png/123_Dynamite02.png]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_123_Dynamite02]],
            ModelType = [[Item]]
        },
        [124] = {
            Index = 124,
            Id = 124,
            Name = [[遥控炸弹]],
            Pirce = 6.990000000000000524288e+21,
            Quality = 29,
            IconId = [[sandboxId://Model/Item/png/124_Dynamite03.png]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_124_Dynamite03]],
            ModelType = [[Item]]
        },
        [125] = {
            Index = 125,
            Id = 125,
            Name = [[圆形手雷]],
            Pirce = 1.1649999999999999475712e+22,
            Quality = 29,
            IconId = [[sandboxId://Model/Item/png/125_Grenade01.png]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_125_Grenade01]],
            ModelType = [[Item]]
        },
        [126] = {
            Index = 126,
            Id = 126,
            Name = [[高爆手雷]],
            Pirce = 1.864e+22,
            Quality = 29,
            IconId = [[sandboxId://Model/Item/png/126_Grenade02.png]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_126_Grenade02]],
            ModelType = [[Item]]
        },
        [127] = {
            Index = 127,
            Id = 127,
            Name = [[等离子手雷]],
            Pirce = 2.7960000000000002097152e+22,
            Quality = 30,
            IconId = [[sandboxId://Model/Item/png/127_Grenade03.png]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_127_Grenade03]],
            ModelType = [[Item]]
        },
        [128] = {
            Index = 128,
            Id = 128,
            Name = [[感应地雷]],
            Pirce = 3.4949999999999998427136e+22,
            Quality = 30,
            IconId = [[sandboxId://Model/Item/png/128_Mine.png]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_128_Mine]],
            ModelType = [[Item]]
        },
        [129] = {
            Index = 129,
            Id = 129,
            Name = [[捕兽夹]],
            Pirce = 5.7999999999999995805696e+22,
            Quality = 30,
            IconId = [[sandboxId://Model/Item/png/129_Trap.png]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_129_Trap]],
            ModelType = [[Item]]
        },
        [130] = {
            Index = 130,
            Id = 130,
            Name = [[手枪子弹]],
            Pirce = 9.28e+22,
            Quality = 30,
            IconId = [[sandboxId://Model/Item/png/130_Bullet01.png]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_130_Bullet01]],
            ModelType = [[Item]]
        },
        [131] = {
            Index = 131,
            Id = 131,
            Name = [[手枪弹药]],
            Pirce = 1.392e+23,
            Quality = 31,
            IconId = [[sandboxId://Model/Item/png/131_Bullet02.png]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_131_Bullet02]],
            ModelType = [[Item]]
        },
        [132] = {
            Index = 132,
            Id = 132,
            Name = [[整箱弹药]],
            Pirce = 1.73999999999999987417088e+23,
            Quality = 31,
            IconId = [[sandboxId://Model/Item/png/132_Bullet03.png]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_132_Bullet03]],
            ModelType = [[Item]]
        },
        [133] = {
            Index = 133,
            Id = 133,
            Name = [[盒装弹药]],
            Pirce = 2.91000000000000002097152e+23,
            Quality = 31,
            IconId = [[sandboxId://Model/Item/png/133_Bullet04.png]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_133_Bullet04]],
            ModelType = [[Item]]
        },
        [134] = {
            Index = 134,
            Id = 134,
            Name = [[直式弹匣]],
            Pirce = 4.65600000000000016777216e+23,
            Quality = 31,
            IconId = [[sandboxId://Model/Item/png/134_Bullet05.png]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_134_Bullet05]],
            ModelType = [[Item]]
        },
        [135] = {
            Index = 135,
            Id = 135,
            Name = [[弯式弹匣]],
            Pirce = 6.98400000000000058720256e+23,
            Quality = 32,
            IconId = [[sandboxId://Model/Item/png/135_Bullet06.png]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_135_Bullet06]],
            ModelType = [[Item]]
        },
        [136] = {
            Index = 136,
            Id = 136,
            Name = [[霰弹盒]],
            Pirce = 8.73000000000000006291456e+23,
            Quality = 32,
            IconId = [[sandboxId://Model/Item/png/136_Bullet07.png]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_136_Bullet07]],
            ModelType = [[Item]]
        },
        [137] = {
            Index = 137,
            Id = 137,
            Name = [[军用弹药箱]],
            Pirce = 1.45500000000000001048576e+24,
            Quality = 32,
            IconId = [[sandboxId://Model/Item/png/137_Cartridge.png]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_137_Cartridge]],
            ModelType = [[Item]]
        },
        [138] = {
            Index = 138,
            Id = 138,
            Name = [[左轮手枪]],
            Pirce = 2.328000000000000016777216e+24,
            Quality = 32,
            IconId = [[sandboxId://Model/Item/png/138_Gun01.png]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_138_Gun01]],
            ModelType = [[Item]]
        },
        [139] = {
            Index = 139,
            Id = 139,
            Name = [[单发手枪]],
            Pirce = 3.492000000000000025165824e+24,
            Quality = 33,
            IconId = [[sandboxId://Model/Item/png/139_Gun02.png]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_139_Gun02]],
            ModelType = [[Item]]
        },
        [140] = {
            Index = 140,
            Id = 140,
            Name = [[短管突击步枪]],
            Pirce = 4.364999999999999763021824e+24,
            Quality = 33,
            IconId = [[sandboxId://Model/Item/png/140_Rifle01.png]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_140_Rifle01]],
            ModelType = [[Item]]
        },
        [141] = {
            Index = 141,
            Id = 141,
            Name = [[战术突击步枪]],
            Pirce = 7.299999999999999823839232e+24,
            Quality = 33,
            IconId = [[sandboxId://Model/Item/png/141_Rifle02.png]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_141_Rifle02]],
            ModelType = [[Item]]
        },
        [142] = {
            Index = 142,
            Id = 142,
            Name = [[木托突击步枪]],
            Pirce = 1.168000000000000100663296e+25,
            Quality = 33,
            IconId = [[sandboxId://Model/Item/png/142_Rifle03.png]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_142_Rifle03]],
            ModelType = [[Item]]
        },
        [143] = {
            Index = 143,
            Id = 143,
            Name = [[战斗霰弹枪]],
            Pirce = 1.7520000000000000436207616e+25,
            Quality = 34,
            IconId = [[sandboxId://Model/Item/png/143_Rifle04.png]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_143_Rifle04]],
            ModelType = [[Item]]
        },
        [144] = {
            Index = 144,
            Id = 144,
            Name = [[狙击步枪]],
            Pirce = 2.190000000000000054525952e+25,
            Quality = 34,
            IconId = [[sandboxId://Model/Item/png/144_Rifle05.png]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_144_Rifle05]],
            ModelType = [[Item]]
        },
        [145] = {
            Index = 145,
            Id = 145,
            Name = [[冲锋枪]],
            Pirce = 3.6399999999999997886070784e+25,
            Quality = 34,
            IconId = [[sandboxId://Model/Item/png/145_MachineGun01.png]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_145_MachineGun01]],
            ModelType = [[Item]]
        },
        [146] = {
            Index = 146,
            Id = 146,
            Name = [[消音冲锋枪]],
            Pirce = 5.8240000000000003489660928e+25,
            Quality = 34,
            IconId = [[sandboxId://Model/Item/png/146_MachineGun02.png]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_146_MachineGun02]],
            ModelType = [[Item]]
        },
        [147] = {
            Index = 147,
            Id = 147,
            Name = [[微型冲锋枪]],
            Pirce = 8.7360000000000005234491392e+25,
            Quality = 35,
            IconId = [[sandboxId://Model/Item/png/147_MachineGun03.png]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_147_MachineGun03]],
            ModelType = [[Item]]
        },
        [148] = {
            Index = 148,
            Id = 148,
            Name = [[木托冲锋枪]],
            Pirce = 1.09200000000000002248146944e+26,
            Quality = 35,
            IconId = [[sandboxId://Model/Item/png/148_MachineGun04.png]],
            DisplayModelId = [[game.ReplicatedStorage.Assets.ItemModel.Y1_148_MachineGun04]],
            ModelType = [[Item]]
        },
        [149] = {
            Index = 149,
            Id = 149,
            Name = [[石斧]],
            Pirce = 1.81999999999999998020288512e+26,
            Quality = 35,
            IconId = [[sandboxId://Model/Aex/Png/axe_01.png]],
            DisplayModelId = nil,
            ModelType = [[Axe]]
        },
        [150] = {
            Index = 150,
            Id = 150,
            Name = [[铜斧]],
            Pirce = 2.91199999999999983088566272e+26,
            Quality = 35,
            IconId = [[sandboxId://Model/Aex/Png/axe_02.png]],
            DisplayModelId = nil,
            ModelType = [[Axe]]
        },
        [151] = {
            Index = 151,
            Id = 151,
            Name = [[银斧]],
            Pirce = 4.36800000000000008992587776e+26,
            Quality = 36,
            IconId = [[sandboxId://Model/Aex/Png/axe_03.png]],
            DisplayModelId = nil,
            ModelType = [[Axe]]
        },
        [152] = {
            Index = 152,
            Id = 152,
            Name = [[金斧]],
            Pirce = 5.45999999999999994060865536e+26,
            Quality = 36,
            IconId = [[sandboxId://Model/Aex/Png/axe_04.png]],
            DisplayModelId = nil,
            ModelType = [[Axe]]
        },
        [153] = {
            Index = 153,
            Id = 153,
            Name = [[神圣斧]],
            Pirce = 9.10000000000000058820919296e+26,
            Quality = 36,
            IconId = [[sandboxId://Model/Aex/Png/axe_05.png]],
            DisplayModelId = nil,
            ModelType = [[Axe]]
        },
        [154] = {
            Index = 154,
            Id = 154,
            Name = [[幻影斧]],
            Pirce = 1.455999999999999984162308096e+27,
            Quality = 36,
            IconId = [[sandboxId://Model/Aex/Png/axe_06.png]],
            DisplayModelId = nil,
            ModelType = [[Axe]]
        },
        [155] = {
            Index = 155,
            Id = 155,
            Name = [[骷髅斧]],
            Pirce = 2.183999999999999976243462144e+27,
            Quality = 37,
            IconId = [[sandboxId://Model/Aex/Png/axe_07.png]],
            DisplayModelId = nil,
            ModelType = [[Axe]]
        },
        [156] = {
            Index = 156,
            Id = 156,
            Name = [[符文斧]],
            Pirce = 2.729999999999999901584850944e+27,
            Quality = 37,
            IconId = [[sandboxId://Model/Aex/Png/axe_08.png]],
            DisplayModelId = nil,
            ModelType = [[Axe]]
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