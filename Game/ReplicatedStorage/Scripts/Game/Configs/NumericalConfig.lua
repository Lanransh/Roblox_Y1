return {
  initialGold = 0,
  initialDiamonds = 50,
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
            kind = "constant",
            value = 1,
          },
          power = {
            kind = "linear",
            ranges = {
              {
                fromInput = 1,
                toInput = 27,
                fromValue = 1.1,
                toValue = 1,
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
          base = 5,
          multiplier = {
            kind = "constant",
            value = 1,
          },
          power = {
            kind = "linear",
            ranges = {
              {
                fromInput = 1,
                toInput = 8,
                fromValue = 1.6,
                toValue = 1.5,
              },
              {
                fromInput = 9,
                toInput = 12,
                fromValue = 1.47,
                toValue = 1.28,
              },
            },
          },
          rounding = "floor",
        },
      },
    },
  },
  trainingSettlementsPerSecond = 2,
  dailyGiftDiamondAmount = 25,
  dailyLogicalHours = 4,
  weeklyCardCurves = {
    input = {
      rounding = "floor",
    },
    columns = {
      {
        key = "miniCoinPrice",
        formula = {
          kind = "BaseExp",
          base = 0,
          multiplier = {
            kind = "linear",
            ranges = {
              {
                fromInput = 1,
                toInput = 1,
                fromValue = 18,
                toValue = 18,
              },
              {
                fromInput = 2,
                toInput = 2,
                fromValue = 68,
                toValue = 68,
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
                fromValue = 70,
                toValue = 70,
              },
              {
                fromInput = 2,
                toInput = 2,
                fromValue = 280,
                toValue = 280,
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
                fromValue = 30,
                toValue = 30,
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
                fromValue = 28,
                toValue = 28,
              },
              {
                fromInput = 2,
                toInput = 2,
                fromValue = 38,
                toValue = 38,
              },
              {
                fromInput = 3,
                toInput = 3,
                fromValue = 48,
                toValue = 48,
              },
              {
                fromInput = 4,
                toInput = 4,
                fromValue = 78,
                toValue = 78,
              },
              {
                fromInput = 5,
                toInput = 5,
                fromValue = 228,
                toValue = 228,
              },
              {
                fromInput = 6,
                toInput = 6,
                fromValue = 418,
                toValue = 418,
              },
              {
                fromInput = 7,
                toInput = 7,
                fromValue = 758,
                toValue = 758,
              },
              {
                fromInput = 8,
                toInput = 8,
                fromValue = 1498,
                toValue = 1498,
              },
              {
                fromInput = 9,
                toInput = 9,
                fromValue = 2688,
                toValue = 2688,
              },
              {
                fromInput = 10,
                toInput = 10,
                fromValue = 5688,
                toValue = 5688,
              },
              {
                fromInput = 11,
                toInput = 11,
                fromValue = 10288,
                toValue = 10288,
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
                toInput = 4,
                fromValue = 1,
                toValue = 1,
              },
              {
                fromInput = 5,
                toInput = 6,
                fromValue = 3.5,
                toValue = 3.5,
              },
              {
                fromInput = 7,
                toInput = 9,
                fromValue = 8,
                toValue = 8,
              },
              {
                fromInput = 10,
                toInput = 10,
                fromValue = 16,
                toValue = 16,
              },
              {
                fromInput = 11,
                toInput = 11,
                fromValue = 17,
                toValue = 17,
              },
              {
                fromInput = 14,
                toInput = 14,
                fromValue = 28,
                toValue = 28,
              },
              {
                fromInput = 17,
                toInput = 17,
                fromValue = 38,
                toValue = 38,
              },
              {
                fromInput = 19,
                toInput = 19,
                fromValue = 55,
                toValue = 55,
              },
              {
                fromInput = 21,
                toInput = 21,
                fromValue = 65,
                toValue = 65,
              },
              {
                fromInput = 22,
                toInput = 22,
                fromValue = 75,
                toValue = 75,
              },
              {
                fromInput = 23,
                toInput = 23,
                fromValue = 85,
                toValue = 85,
              },
              {
                fromInput = 25,
                toInput = 25,
                fromValue = 95,
                toValue = 95,
              },
              {
                fromInput = 33,
                toInput = 33,
                fromValue = 115,
                toValue = 115,
              },
              {
                fromInput = 35,
                toInput = 35,
                fromValue = 125,
                toValue = 125,
              },
              {
                fromInput = 37,
                toInput = 37,
                fromValue = 135,
                toValue = 135,
              },
              {
                fromInput = 38,
                toInput = 38,
                fromValue = 145,
                toValue = 145,
              },
              {
                fromInput = 42,
                toInput = 42,
                fromValue = 175,
                toValue = 175,
              },
              {
                fromInput = 43,
                toInput = 43,
                fromValue = 195,
                toValue = 195,
              },
              {
                fromInput = 44,
                toInput = 44,
                fromValue = 205,
                toValue = 205,
              },
              {
                fromInput = 45,
                toInput = 45,
                fromValue = 245,
                toValue = 245,
              },
              {
                fromInput = 50,
                toInput = 50,
                fromValue = 275,
                toValue = 275,
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
                fromValue = 3.5,
                toValue = 3.7,
              },
              {
                fromInput = 15,
                toInput = 29,
                fromValue = 3.7,
                toValue = 3.8,
              },
              {
                fromInput = 30,
                toInput = 44,
                fromValue = 3.8,
                toValue = 4.4,
              },
              {
                fromInput = 45,
                toInput = 59,
                fromValue = 4.4,
                toValue = 4.8,
              },
              {
                fromInput = 60,
                toInput = 74,
                fromValue = 4.9,
                toValue = 5,
              },
              {
                fromInput = 75,
                toInput = 89,
                fromValue = 5,
                toValue = 5.6,
              },
              {
                fromInput = 90,
                toInput = 104,
                fromValue = 5.5,
                toValue = 5.95,
              },
              {
                fromInput = 105,
                toInput = 119,
                fromValue = 5.95,
                toValue = 6.25,
              },
              {
                fromInput = 120,
                toInput = 134,
                fromValue = 6.25,
                toValue = 6.5,
              },
              {
                fromInput = 135,
                toInput = 149,
                fromValue = 6.5,
                toValue = 6.9,
              },
              {
                fromInput = 150,
                toInput = 164,
                fromValue = 6.9,
                toValue = 6.9,
              },
              {
                fromInput = 165,
                toInput = 179,
                fromValue = 6.9,
                toValue = 7.46,
              },
              {
                fromInput = 180,
                toInput = 194,
                fromValue = 7.46,
                toValue = 7.65,
              },
              {
                fromInput = 195,
                toInput = 209,
                fromValue = 7.65,
                toValue = 7.8,
              },
              {
                fromInput = 210,
                toInput = 224,
                fromValue = 7.8,
                toValue = 8.2,
              },
              {
                fromInput = 225,
                toInput = 239,
                fromValue = 8.2,
                toValue = 8.5,
              },
              {
                fromInput = 240,
                toInput = 254,
                fromValue = 8.5,
                toValue = 8.5,
              },
              {
                fromInput = 255,
                toInput = 269,
                fromValue = 8.5,
                toValue = 8.85,
              },
              {
                fromInput = 270,
                toInput = 284,
                fromValue = 8.85,
                toValue = 9.05,
              },
              {
                fromInput = 285,
                toInput = 299,
                fromValue = 9.05,
                toValue = 9.22,
              },
              {
                fromInput = 300,
                toInput = 314,
                fromValue = 9.22,
                toValue = 9.55,
              },
              {
                fromInput = 315,
                toInput = 329,
                fromValue = 9.55,
                toValue = 9.8,
              },
              {
                fromInput = 330,
                toInput = 344,
                fromValue = 9.8,
                toValue = 9.95,
              },
              {
                fromInput = 345,
                toInput = 359,
                fromValue = 9.95,
                toValue = 10.14,
              },
              {
                fromInput = 360,
                toInput = 374,
                fromValue = 10.14,
                toValue = 10.4,
              },
              {
                fromInput = 375,
                toInput = 389,
                fromValue = 10.4,
                toValue = 10,
              },
              {
                fromInput = 390,
                toInput = 404,
                fromValue = 10,
                toValue = 10.3,
              },
              {
                fromInput = 405,
                toInput = 419,
                fromValue = 10.3,
                toValue = 10.4,
              },
              {
                fromInput = 420,
                toInput = 434,
                fromValue = 10.4,
                toValue = 10.5,
              },
              {
                fromInput = 435,
                toInput = 449,
                fromValue = 10.5,
                toValue = 10.5,
              },
              {
                fromInput = 450,
                toInput = 464,
                fromValue = 10.5,
                toValue = 10.8,
              },
              {
                fromInput = 465,
                toInput = 479,
                fromValue = 10.8,
                toValue = 10.85,
              },
              {
                fromInput = 480,
                toInput = 494,
                fromValue = 10.85,
                toValue = 11,
              },
              {
                fromInput = 495,
                toInput = 509,
                fromValue = 11,
                toValue = 10.93,
              },
              {
                fromInput = 510,
                toInput = 524,
                fromValue = 10.93,
                toValue = 11.15,
              },
              {
                fromInput = 525,
                toInput = 539,
                fromValue = 11.15,
                toValue = 11.1,
              },
              {
                fromInput = 540,
                toInput = 554,
                fromValue = 11.1,
                toValue = 11.3,
              },
              {
                fromInput = 555,
                toInput = 569,
                fromValue = 11.3,
                toValue = 11.33,
              },
              {
                fromInput = 570,
                toInput = 584,
                fromValue = 11.33,
                toValue = 11.25,
              },
              {
                fromInput = 585,
                toInput = 599,
                fromValue = 11.25,
                toValue = 11.55,
              },
              {
                fromInput = 600,
                toInput = 614,
                fromValue = 11.55,
                toValue = 11.15,
              },
              {
                fromInput = 615,
                toInput = 629,
                fromValue = 11.15,
                toValue = 11.4,
              },
              {
                fromInput = 630,
                toInput = 644,
                fromValue = 11.4,
                toValue = 11.5,
              },
              {
                fromInput = 645,
                toInput = 659,
                fromValue = 11.5,
                toValue = 11.52,
              },
              {
                fromInput = 660,
                toInput = 674,
                fromValue = 11.52,
                toValue = 11.48,
              },
              {
                fromInput = 675,
                toInput = 689,
                fromValue = 11.48,
                toValue = 11.5,
              },
              {
                fromInput = 690,
                toInput = 704,
                fromValue = 11.5,
                toValue = 11.5,
              },
              {
                fromInput = 705,
                toInput = 719,
                fromValue = 11.5,
                toValue = 11.7,
              },
              {
                fromInput = 720,
                toInput = 734,
                fromValue = 11.7,
                toValue = 11.65,
              },
              {
                fromInput = 735,
                toInput = 749,
                fromValue = 11.65,
                toValue = 11.68,
              },
              {
                fromInput = 750,
                toInput = 764,
                fromValue = 11.68,
                toValue = 11.75,
              },
            },
          },
          rounding = "round",
        },
      },
      {
        key = "strength",
        formula = {
          kind = "BaseExp",
          base = 0,
          multiplier = {
            kind = "constant",
            value = 10,
          },
          power = {
            kind = "constant",
            value = 1.1,
          },
          rounding = "floor",
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
        key = "expectedStrength",
        input = {
          source = "column",
          key = "grassLevel",
        },
        formula = {
          kind = "BaseExp",
          base = 0,
          multiplier = {
            kind = "constant",
            value = 10,
          },
          power = {
            kind = "constant",
            value = 1.1,
          },
          rounding = "floor",
        },
      },
      {
        key = "grassHp",
        input = {
          source = "column",
          key = "expectedStrength",
        },
        formula = {
          kind = "Power",
          base = 0,
          multiplier = {
            kind = "constant",
            value = 2.99,
          },
          power = {
            kind = "constant",
            value = 1,
          },
          rounding = "floor",
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
  expectedStageDuration = 10,
  expectedEasyStageDuration = 5,
  estimatedItemAcquisitionDuration = 3,
  baseBackpackCapacity = 2,
}
