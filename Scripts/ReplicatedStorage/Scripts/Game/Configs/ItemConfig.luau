return {
    Data = {
        [101] = {
            Id = 101,
            Type = [[WeekCard]],
            MaxStack = 1,
            UseHandler = [[WeekCard]],
            HeldHandler = [[Image]],
            NumberArray = nil,
            KVTable = {
                InstantGemCount = 100,
                DayTime = 6,
                DurationDays = 30
            }
        },
        [102] = {
            Id = 102,
            Type = [[WeekCard]],
            MaxStack = 1,
            UseHandler = [[WeekCard]],
            HeldHandler = [[Image]],
            NumberArray = nil,
            KVTable = {
                InstantGemCount = 400,
                DayTime = 6,
                DurationDays = 120
            }
        },
        [103] = {
            Id = 103,
            Type = [[DoubleSaleCard]],
            MaxStack = 1,
            UseHandler = nil,
            HeldHandler = [[Image]],
            NumberArray = nil,
            KVTable = nil
        },
        [104] = {
            Id = 104,
            Type = [[ExpandableBackpackCard]],
            MaxStack = 1,
            UseHandler = [[ExpandableBackpackCard]],
            HeldHandler = [[Image]],
            NumberArray = nil,
            KVTable = {
                Time = 3600,
                Count = 1
            }
        },
        [105] = {
            Id = 105,
            Type = [[TrainingCard]],
            MaxStack = 1,
            UseHandler = [[TrainingCard]],
            HeldHandler = [[Image]],
            NumberArray = nil,
            KVTable = {
                Time = 900
            }
        },
        [106] = {
            Id = 106,
            Type = [[TrainingCard]],
            MaxStack = 1,
            UseHandler = [[TrainingCard]],
            HeldHandler = [[Image]],
            NumberArray = nil,
            KVTable = {
                Time = 1800
            }
        },
        [107] = {
            Id = 107,
            Type = [[NpcCard]],
            MaxStack = 1,
            UseHandler = [[NpcCard]],
            HeldHandler = [[Image]],
            NumberArray = nil,
            KVTable = nil
        }
    },
    Display = {
        [101] = {
            Id = 101,
            Name = [[小周卡]],
            Desc = [[立即获得100钻石,每天签到多获得30钻石(6天)]],
            Quality = 12,
            IconId = [[sandboxId://UI/Icon/SmallWeekCard.png]],
            DisplayModelId = nil
        },
        [102] = {
            Id = 102,
            Name = [[大周卡]],
            Desc = [[立即获得400钻石,每天签到多获得120钻石(6天)]],
            Quality = 12,
            IconId = [[sandboxId://UI/Icon/GreatWeekCard.png]],
            DisplayModelId = nil
        },
        [103] = {
            Id = 103,
            Name = [[双倍出售卡]],
            Desc = [[双倍出售卡]],
            Quality = 12,
            IconId = [[sandboxId://UI/Icon/DoubleSaleCard.png]],
            DisplayModelId = nil
        },
        [104] = {
            Id = 104,
            Name = [[背包扩容卡(一小时)]],
            Desc = [[背包扩容卡(一小时)]],
            Quality = 12,
            IconId = [[sandboxId://UI/Icon/TemporaryBackpackCard.png]],
            DisplayModelId = nil
        },
        [105] = {
            Id = 105,
            Name = [[力量卡(15分钟)]],
            Desc = [[力量卡(15分钟)]],
            Quality = 12,
            IconId = [[sandboxId://UI/Icon/TrainingCard1.png]],
            DisplayModelId = nil
        },
        [106] = {
            Id = 106,
            Name = [[力量卡(30分钟)]],
            Desc = [[力量卡(30分钟)]],
            Quality = 12,
            IconId = [[sandboxId://UI/Icon/TrainingCard2.png]],
            DisplayModelId = nil
        },
        [107] = {
            Id = 107,
            Name = [[NPC进度卡]],
            Desc = [[NPC任务进度加1]],
            Quality = 12,
            IconId = [[sandboxId://UI/Icon/NpcCard.png]],
            DisplayModelId = nil
        }
    },
    ExtraDataSchema = {
        Animal = {
            level = 1,
            mutationExp = 1,
            size = 1,
            sizeMutationPityCount = 0
        }
    }
}