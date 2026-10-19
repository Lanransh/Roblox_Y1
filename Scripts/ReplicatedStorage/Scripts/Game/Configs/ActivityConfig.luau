return {
    DailyTaskConfig = {
        [1] = {
            Index = 1,
            Type = [[GetItem]],
            Name = [[Pick up an item]],
            Desc = [[Pick up 50 items]],
            Target = 50,
            Rewards = {
                [1] = {
                    Type = [[Gem]],
                    Count = 3
                },
            }
        },
        [2] = {
            Index = 2,
            Type = [[GetItem]],
            Name = [[Pick up an item]],
            Desc = [[Pick up 80 items]],
            Target = 80,
            Rewards = {
                [1] = {
                    Type = [[Item]],
                    Id = 105,
                    Count = 1
                },
            }
        },
        [3] = {
            Index = 3,
            Type = [[OnlineTime]],
            Name = [[Stay online for 30 minutes]],
            Desc = [[Stay online for 30 minutes]],
            Target = 30,
            Rewards = {
                [1] = {
                    Type = [[Gem]],
                    Count = 5
                },
            }
        },
        [4] = {
            Index = 4,
            Type = [[GetDog]],
            Name = [[Pick up a dog]],
            Desc = [[Pick up 10 dogs]],
            Target = 10,
            Rewards = {
                [1] = {
                    Type = [[Gem]],
                    Count = 3
                },
            }
        },
        [5] = {
            Index = 5,
            Type = [[ForFriendPlay]],
            Name = [[Be in the same room as a friend]],
            Desc = [[Be in the same room as 2 friends]],
            Target = 2,
            Rewards = {
                [1] = {
                    Type = [[Gem]],
                    Count = 2
                },
            }
        }
    },
    LoginMilestoneData = {
        [1] = {
            Index = 1,
            LoginDays = 1,
            Desc = [[背包扩容卡X1]],
            Reward = {
                Type = [[Item]],
                Id = 104,
                Count = 1
            }
        },
        [2] = {
            Index = 2,
            LoginDays = 2,
            Desc = [[15钻石]],
            Reward = {
                Type = [[Gem]],
                Count = 15
            }
        },
        [3] = {
            Index = 3,
            LoginDays = 3,
            Desc = [[双倍出售卡X3]],
            Reward = {
                Type = [[Item]],
                Id = 103,
                Count = 3
            }
        },
        [4] = {
            Index = 4,
            LoginDays = 4,
            Desc = [[30分钟力量卡X2]],
            Reward = {
                Type = [[Item]],
                Id = 106,
                Count = 2
            }
        },
        [5] = {
            Index = 5,
            LoginDays = 5,
            Desc = [[15钻石]],
            Reward = {
                Type = [[Gem]],
                Count = 15
            }
        },
        [6] = {
            Index = 6,
            LoginDays = 6,
            Desc = [[背包扩容卡X2]],
            Reward = {
                Type = [[Item]],
                Id = 104,
                Count = 2
            }
        },
        [7] = {
            Index = 7,
            LoginDays = 7,
            Desc = [[20钻石]],
            Reward = {
                Type = [[Gem]],
                Count = 20
            }
        }
    },
    OnlineRewardData = {
        [1] = {
            Index = 1,
            TargetMinutes = 5,
            Desc = [[NPC卡X2]],
            Reward = {
                Type = [[Item]],
                Id = 107,
                Count = 2
            }
        },
        [2] = {
            Index = 2,
            TargetMinutes = 10,
            Desc = [[15分钟力量卡]],
            Reward = {
                Type = [[Item]],
                Id = 105,
                Count = 1
            }
        },
        [3] = {
            Index = 3,
            TargetMinutes = 20,
            Desc = [[双倍出售卡X1]],
            Reward = {
                Type = [[Item]],
                Id = 103,
                Count = 1
            }
        },
        [4] = {
            Index = 4,
            TargetMinutes = 25,
            Desc = [[2钻石]],
            Reward = {
                Type = [[Gem]],
                Count = 2
            }
        },
        [5] = {
            Index = 5,
            TargetMinutes = 35,
            Desc = [[30分钟力量卡X1]],
            Reward = {
                Type = [[Item]],
                Id = 106,
                Count = 1
            }
        },
        [6] = {
            Index = 6,
            TargetMinutes = 45,
            Desc = [[3钻石]],
            Reward = {
                Type = [[Gem]],
                Count = 3
            }
        },
        [7] = {
            Index = 7,
            TargetMinutes = 55,
            Desc = [[背包扩容卡(一小时)]],
            Reward = {
                Type = [[Item]],
                Id = 104,
                Count = 1
            }
        },
        [8] = {
            Index = 8,
            TargetMinutes = 65,
            Desc = [[5钻石]],
            Reward = {
                Type = [[Gem]],
                Count = 5
            }
        },
        [9] = {
            Index = 9,
            TargetMinutes = 75,
            Desc = [[双倍出售卡X1]],
            Reward = {
                Type = [[Item]],
                Id = 103,
                Count = 1
            }
        },
        [10] = {
            Index = 10,
            TargetMinutes = 90,
            Desc = [[30分钟力量卡X1]],
            Reward = {
                Type = [[Item]],
                Id = 106,
                Count = 1
            }
        }
    },
    MenuRetentionConfig = {
        TriggerMinutes = 5,
        Reward = {
            Type = [[Item]],
            Id = 107,
            Count = 2
        }
    }
}