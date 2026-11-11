return {
  initialGold = 0,
  initialDiamonds = 35,
  sickleCurves = {
    input = {
      rounding = "floor",
      min = 1,
      max = 53,
    },
    columns = {
      {
        key = "trainingValueMultiplier",
        formula = {
          kind = "Power",
          base = 0,
          multiplier = {
            kind = "constant",
            value = 1,
          },
          power = {
            kind = "linear",
            ranges = {
              {
                fromInput = 1,
                toInput = 26,
                fromValue = 5,
                toValue = 12,
              },
              {
                fromInput = 27,
                toInput = 40,
                fromValue = 12,
                toValue = 13,
              },
            },
          },
          rounding = "ceil",
        },
      },
      {
        key = "expectedStageId",
        formula = {
          kind = "Power",
          base = -1,
          multiplier = {
            kind = "constant",
            value = 1,
          },
          power = {
            kind = "constant",
            value = 1,
          },
          rounding = "floor",
        },
      },
      {
        key = "expectedItemCount",
        formula = {
          kind = "Power",
          base = 3,
          multiplier = {
            kind = "linear",
            ranges = {
              {
                fromInput = 1,
                toInput = 9,
                fromValue = 0,
                toValue = 0,
              },
              {
                fromInput = 10,
                toInput = 16,
                fromValue = 1,
                toValue = 3,
              },
              {
                fromInput = 17,
                toInput = 27,
                fromValue = 4,
                toValue = 27,
              },
              {
                fromInput = 28,
                toInput = 53,
                fromValue = 1,
                toValue = 1,
              },
            },
          },
          power = {
            kind = "linear",
            ranges = {
              {
                fromInput = 1,
                toInput = 27,
                fromValue = 0,
                toValue = 0,
              },
              {
                fromInput = 28,
                toInput = 40,
                fromValue = 1,
                toValue = 0.9,
              },
            },
          },
          rounding = "floor",
        },
      },
    },
  },
  auraCurves = {
    input = {
      rounding = "floor",
      min = 1,
      max = 17,
    },
    columns = {
      {
        key = "multiplier",
        formula = {
          kind = "Power",
          base = 0.5,
          multiplier = {
            kind = "linear",
            ranges = {
              {
                fromInput = 1,
                toInput = 8,
                fromValue = 1,
                toValue = 1,
              },
              {
                fromInput = 9,
                toInput = 12,
                fromValue = 1,
                toValue = 1.6,
              },
            },
          },
          power = {
            kind = "constant",
            value = 1,
          },
          rounding = "none",
        },
      },
      {
        key = "expectedStageId",
        formula = {
          kind = "Power",
          base = 0,
          multiplier = {
            kind = "linear",
            ranges = {
              {
                fromInput = 1,
                toInput = 12,
                fromValue = 3,
                toValue = 3,
              },
              {
                fromInput = 13,
                toInput = 17,
                fromValue = 40,
                toValue = 52,
              },
            },
          },
          power = {
            kind = "linear",
            ranges = {
              {
                fromInput = 1,
                toInput = 12,
                fromValue = 1,
                toValue = 1,
              },
              {
                fromInput = 13,
                toInput = 17,
                fromValue = 0,
                toValue = 0,
              },
            },
          },
          rounding = "floor",
        },
      },
      {
        key = "expectedItemCount",
        formula = {
          kind = "Power",
          base = 0,
          multiplier = {
            kind = "linear",
            ranges = {
              {
                fromInput = 1,
                toInput = 2,
                fromValue = 3,
                toValue = 3,
              },
              {
                fromInput = 3,
                toInput = 5,
                fromValue = 4,
                toValue = 6,
              },
              {
                fromInput = 6,
                toInput = 12,
                fromValue = 7,
                toValue = 14,
              },
              {
                fromInput = 13,
                toInput = 17,
                fromValue = 18,
                toValue = 42,
              },
            },
          },
          power = {
            kind = "constant",
            value = 0,
          },
          rounding = "floor",
        },
      },
    },
  },
  trainingSettlementsPerSecond = 1,
  dailyGiftDiamondAmount = 28,
  dailyLogicalHours = 4,
  weeklyCardCurves = {
    input = {
      rounding = "floor",
    },
    columns = {
      {
        key = "robuxPrice",
        formula = {
          kind = "BaseExp",
          base = 0,
          multiplier = {
            kind = "linear",
            ranges = {
              {
                fromInput = 1,
                toInput = 1,
                fromValue = 28,
                toValue = 28,
              },
              {
                fromInput = 2,
                toInput = 2,
                fromValue = 88,
                toValue = 88,
              },
            },
          },
          power = {
            kind = "constant",
            value = 1,
          },
          rounding = "floor",
        },
      },
      {
        key = "instantDiamonds",
        formula = {
          kind = "BaseExp",
          base = 0,
          multiplier = {
            kind = "linear",
            ranges = {
              {
                fromInput = 1,
                toInput = 1,
                fromValue = 65,
                toValue = 65,
              },
              {
                fromInput = 2,
                toInput = 2,
                fromValue = 120,
                toValue = 120,
              },
            },
          },
          power = {
            kind = "constant",
            value = 1,
          },
          rounding = "floor",
        },
      },
      {
        key = "dailyDiamonds",
        formula = {
          kind = "BaseExp",
          base = 0,
          multiplier = {
            kind = "linear",
            ranges = {
              {
                fromInput = 1,
                toInput = 1,
                fromValue = 53,
                toValue = 53,
              },
              {
                fromInput = 2,
                toInput = 2,
                fromValue = 190,
                toValue = 190,
              },
            },
          },
          power = {
            kind = "constant",
            value = 1,
          },
          rounding = "floor",
        },
      },
    },
  },
  paidTrainingMultiplierCurves = {
    input = {
      rounding = "floor",
    },
    columns = {
      {
        key = "multiplier",
        formula = {
          kind = "BaseExp",
          base = 0,
          multiplier = {
            kind = "constant",
            value = 1,
          },
          power = {
            kind = "constant",
            value = 2,
          },
          rounding = "none",
        },
      },
      {
        key = "diamondCost",
        formula = {
          kind = "BaseExp",
          base = 0,
          multiplier = {
            kind = "linear",
            ranges = {
              {
                fromInput = 0,
                toInput = 0,
                fromValue = 0,
                toValue = 0,
              },
              {
                fromInput = 1,
                toInput = 1,
                fromValue = 35,
                toValue = 35,
              },
              {
                fromInput = 2,
                toInput = 2,
                fromValue = 48,
                toValue = 48,
              },
              {
                fromInput = 3,
                toInput = 3,
                fromValue = 60,
                toValue = 60,
              },
              {
                fromInput = 4,
                toInput = 4,
                fromValue = 98,
                toValue = 98,
              },
              {
                fromInput = 5,
                toInput = 5,
                fromValue = 288,
                toValue = 288,
              },
              {
                fromInput = 6,
                toInput = 6,
                fromValue = 588,
                toValue = 588,
              },
              {
                fromInput = 7,
                toInput = 7,
                fromValue = 1188,
                toValue = 1188,
              },
              {
                fromInput = 8,
                toInput = 8,
                fromValue = 2688,
                toValue = 2688,
              },
              {
                fromInput = 9,
                toInput = 9,
                fromValue = 5688,
                toValue = 5688,
              },
              {
                fromInput = 10,
                toInput = 10,
                fromValue = 12888,
                toValue = 12888,
              },
              {
                fromInput = 11,
                toInput = 11,
                fromValue = 28888,
                toValue = 28888,
              },
            },
          },
          power = {
            kind = "constant",
            value = 1,
          },
          rounding = "floor",
        },
      },
    },
  },
  backpackExpansionCurves = {
    input = {
      rounding = "floor",
      min = 1,
      max = 3,
    },
    columns = {
      {
        key = "expansionPrice",
        formula = {
          kind = "BaseExp",
          base = 0,
          multiplier = {
            kind = "linear",
            ranges = {
              {
                fromInput = 1,
                toInput = 1,
                fromValue = 52,
                toValue = 52,
              },
              {
                fromInput = 2,
                toInput = 2,
                fromValue = 368,
                toValue = 368,
              },
              {
                fromInput = 3,
                toInput = 3,
                fromValue = 688,
                toValue = 688,
              },
            },
          },
          power = {
            kind = "constant",
            value = 1,
          },
          rounding = "floor",
        },
      },
    },
  },
  rebirthCurves = {
    input = {
      rounding = "floor",
      min = 0,
      max = 51,
    },
    columns = {
      {
        key = "requiredLevel",
        formula = {
          kind = "Power",
          base = 15,
          multiplier = {
            kind = "constant",
            value = 15,
          },
          power = {
            kind = "constant",
            value = 1,
          },
          rounding = "floor",
        },
      },
      {
        key = "trainingMultiplierReward",
        formula = {
          kind = "Power",
          base = 1,
          multiplier = {
            kind = "constant",
            value = 2,
          },
          power = {
            kind = "constant",
            value = 1,
          },
          rounding = "none",
        },
      },
      {
        key = "goldMultiplierReward",
        formula = {
          kind = "Power",
          base = 1,
          multiplier = {
            kind = "constant",
            value = 2,
          },
          power = {
            kind = "constant",
            value = 1,
          },
          rounding = "none",
        },
      },
      {
        key = "catchUpMultiplier",
        formula = {
          kind = "Power",
          base = 1,
          multiplier = {
            kind = "linear",
            ranges = {
              {
                fromInput = 0,
                toInput = 1,
                fromValue = 1,
                toValue = 1,
              },
              {
                fromInput = 2,
                toInput = 6,
                fromValue = 2,
                toValue = 2,
              },
              {
                fromInput = 7,
                toInput = 13,
                fromValue = 3,
                toValue = 3,
              },
              {
                fromInput = 14,
                toInput = 16,
                fromValue = 4,
                toValue = 4,
              },
              {
                fromInput = 17,
                toInput = 18,
                fromValue = 5,
                toValue = 5,
              },
              {
                fromInput = 19,
                toInput = 19,
                fromValue = 6,
                toValue = 6,
              },
              {
                fromInput = 20,
                toInput = 22,
                fromValue = 15,
                toValue = 15,
              },
              {
                fromInput = 23,
                toInput = 24,
                fromValue = 25,
                toValue = 25,
              },
              {
                fromInput = 25,
                toInput = 25,
                fromValue = 35,
                toValue = 35,
              },
              {
                fromInput = 28,
                toInput = 28,
                fromValue = 55,
                toValue = 55,
              },
              {
                fromInput = 29,
                toInput = 29,
                fromValue = 65,
                toValue = 65,
              },
              {
                fromInput = 32,
                toInput = 32,
                fromValue = 80,
                toValue = 80,
              },
              {
                fromInput = 34,
                toInput = 34,
                fromValue = 85,
                toValue = 85,
              },
              {
                fromInput = 35,
                toInput = 35,
                fromValue = 95,
                toValue = 95,
              },
            },
          },
          power = {
            kind = "constant",
            value = 1,
          },
          rounding = "ceil",
        },
      },
    },
  },
  rebirthFieldCurves = {
    input = {
      rounding = "floor",
    },
    columns = {
      {
        key = "requiredRebirthCount",
        formula = {
          kind = "Power",
          base = 0,
          multiplier = {
            kind = "constant",
            value = 3,
          },
          power = {
            kind = "constant",
            value = 1,
          },
          rounding = "floor",
        },
      },
      {
        key = "extraMultiplier",
        formula = {
          kind = "Power",
          base = 1,
          multiplier = {
            kind = "constant",
            value = 1,
          },
          power = {
            kind = "constant",
            value = 1.8,
          },
          rounding = "ceil",
        },
      },
    },
  },
  levelCurves = {
    input = {
      rounding = "floor",
      min = 1,
      max = 780,
    },
    columns = {
      {
        key = "nextLevelExperience",
        formula = {
          kind = "Power",
          base = 0,
          multiplier = {
            kind = "constant",
            value = 1,
          },
          power = {
            kind = "linear",
            ranges = {
              {
                fromInput = 1,
                toInput = 14,
                fromValue = 2.5,
                toValue = 2.8,
              },
              {
                fromInput = 15,
                toInput = 29,
                fromValue = 2.8,
                toValue = 3.1,
              },
              {
                fromInput = 30,
                toInput = 44,
                fromValue = 3.1,
                toValue = 3.4,
              },
              {
                fromInput = 45,
                toInput = 59,
                fromValue = 3.4,
                toValue = 4.1,
              },
              {
                fromInput = 60,
                toInput = 74,
                fromValue = 4.1,
                toValue = 4.3,
              },
              {
                fromInput = 75,
                toInput = 89,
                fromValue = 4.3,
                toValue = 4.6,
              },
              {
                fromInput = 90,
                toInput = 104,
                fromValue = 4.6,
                toValue = 5.1,
              },
              {
                fromInput = 105,
                toInput = 119,
                fromValue = 5.1,
                toValue = 5.4,
              },
              {
                fromInput = 120,
                toInput = 134,
                fromValue = 5.4,
                toValue = 5.5,
              },
              {
                fromInput = 135,
                toInput = 149,
                fromValue = 5.5,
                toValue = 5.9,
              },
              {
                fromInput = 150,
                toInput = 164,
                fromValue = 5.9,
                toValue = 6.4,
              },
              {
                fromInput = 165,
                toInput = 179,
                fromValue = 6.4,
                toValue = 6.6,
              },
              {
                fromInput = 180,
                toInput = 194,
                fromValue = 6.6,
                toValue = 7,
              },
              {
                fromInput = 195,
                toInput = 209,
                fromValue = 7,
                toValue = 7.2,
              },
              {
                fromInput = 210,
                toInput = 224,
                fromValue = 7.2,
                toValue = 7.6,
              },
              {
                fromInput = 225,
                toInput = 239,
                fromValue = 7.6,
                toValue = 7.95,
              },
              {
                fromInput = 240,
                toInput = 254,
                fromValue = 7.95,
                toValue = 8,
              },
              {
                fromInput = 255,
                toInput = 269,
                fromValue = 8,
                toValue = 8.4,
              },
              {
                fromInput = 270,
                toInput = 284,
                fromValue = 8.35,
                toValue = 8.55,
              },
              {
                fromInput = 285,
                toInput = 299,
                fromValue = 8.55,
                toValue = 8.8,
              },
              {
                fromInput = 300,
                toInput = 314,
                fromValue = 8.8,
                toValue = 9.1,
              },
              {
                fromInput = 315,
                toInput = 329,
                fromValue = 9.1,
                toValue = 9.35,
              },
              {
                fromInput = 330,
                toInput = 344,
                fromValue = 9.35,
                toValue = 9.45,
              },
              {
                fromInput = 345,
                toInput = 359,
                fromValue = 9.45,
                toValue = 9.75,
              },
              {
                fromInput = 360,
                toInput = 374,
                fromValue = 9.75,
                toValue = 10,
              },
              {
                fromInput = 375,
                toInput = 389,
                fromValue = 10,
                toValue = 10,
              },
              {
                fromInput = 390,
                toInput = 404,
                fromValue = 10,
                toValue = 10.25,
              },
              {
                fromInput = 405,
                toInput = 419,
                fromValue = 10.25,
                toValue = 10.27,
              },
              {
                fromInput = 420,
                toInput = 434,
                fromValue = 10.27,
                toValue = 10.27,
              },
              {
                fromInput = 435,
                toInput = 449,
                fromValue = 10.27,
                toValue = 10.5,
              },
              {
                fromInput = 450,
                toInput = 464,
                fromValue = 10.5,
                toValue = 10.55,
              },
              {
                fromInput = 465,
                toInput = 479,
                fromValue = 10.55,
                toValue = 10.6,
              },
              {
                fromInput = 480,
                toInput = 494,
                fromValue = 10.6,
                toValue = 10.78,
              },
              {
                fromInput = 495,
                toInput = 509,
                fromValue = 10.78,
                toValue = 10.95,
              },
              {
                fromInput = 510,
                toInput = 524,
                fromValue = 10.95,
                toValue = 10.98,
              },
              {
                fromInput = 525,
                toInput = 539,
                fromValue = 10.98,
                toValue = 11.05,
              },
              {
                fromInput = 540,
                toInput = 554,
                fromValue = 11.05,
                toValue = 11.15,
              },
              {
                fromInput = 555,
                toInput = 569,
                fromValue = 11.15,
                toValue = 11.19,
              },
              {
                fromInput = 570,
                toInput = 584,
                fromValue = 11.19,
                toValue = 11.32,
              },
            },
          },
          rounding = "round",
        },
      },
      {
        key = "attackPower",
        formula = {
          kind = "BaseExp",
          base = 0,
          multiplier = {
            kind = "constant",
            value = 0.8874078169240217,
          },
          power = {
            kind = "constant",
            value = 1.1268776101908264,
          },
          rounding = "none",
        },
      },
    },
  },
  stageCurves = {
    input = {
      rounding = "floor",
    },
    columns = {
      {
        key = "expectedRebirthCount",
        formula = {
          kind = "Power",
          base = -1,
          multiplier = {
            kind = "constant",
            value = 1,
          },
          power = {
            kind = "constant",
            value = 1,
          },
          rounding = "floor",
        },
      },
      {
        key = "grassLevel",
        input = {
          source = "column",
          key = "expectedRebirthCount",
        },
        formula = {
          kind = "Power",
          base = 0,
          multiplier = {
            kind = "linear",
            ranges = {
              {
                fromInput = 1,
                toInput = 1,
                fromValue = 15,
                toValue = 15,
              },
            },
          },
          power = {
            kind = "linear",
            ranges = {
              {
                fromInput = 1,
                toInput = 1,
                fromValue = 1,
                toValue = 1,
              },
            },
          },
          rounding = "floor",
        },
      },
      {
        key = "hpMultiplier",
        formula = {
          kind = "Power",
          base = 0,
          multiplier = {
            kind = "constant",
            value = 2.99,
          },
          power = {
            kind = "constant",
            value = 0,
          },
          rounding = "none",
        },
      },
      {
        key = "expectedItemPrice",
        formula = {
          kind = "BaseExp",
          base = 0,
          multiplier = {
            kind = "constant",
            value = 1,
          },
          power = {
            kind = "constant",
            value = 5,
          },
          rounding = "floor",
        },
      },
    },
  },
  worldStageCount = 13,
  itemsUnlockedPerStage = 3,
  expectedStageDuration = 10,
  expectedEasyStageDuration = 5,
  estimatedItemAcquisitionDuration = 3,
  baseBackpackCapacity = 3,
}
