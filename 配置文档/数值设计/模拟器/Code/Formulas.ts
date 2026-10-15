import {
  sampleCurveGroup,
  sampleCurveGroupColumnFormula,
  type CurveGroupValue,
} from "@game-simulator/framework";

export type LevelValues = {
  nextLevelExperience: number;
};

export type SickleValues = {
  purchasePrice: number;
  trainingValueMultiplier: number;
  expectedStageId: number;
  rebirthGoldMultiplier: number;
  expectedItemCount: number;
};

export type AuraValues = {
  multiplier: number;
  purchasePrice: number;
  expectedStageId: number;
  rebirthGoldMultiplier: number;
  expectedItemCount: number;
};

export type StageValues = {
  expectedRebirthCount: number;
  grassLevel: number;
  hpMultiplier: number;
  expectedItemPrice: number;
};

export type RebirthValues = {
  requiredLevel: number;
  trainingMultiplierReward: number;
  goldMultiplierReward: number;
  catchUpMultiplier: number;
};

export type RebirthFieldValues = {
  requiredRebirthCount: number;
  extraMultiplier: number;
};

export type RebirthFieldSelection = RebirthFieldValues & {
  id: number;
};

export type PaidMultiplierValues = {
  multiplier: number;
  diamondCost: number;
};

export type BackpackExpansionValues = {
  expansionPrice: number;
};

export type WeeklyCardValues = {
  miniCoinPrice: number;
  instantDiamonds: number;
  dailyDiamonds: number;
  purchaseDayDiamonds: number;
  equivalentDiamonds: number;
  totalDiamonds: number;
};

export const MAX_PAID_MULTIPLIER_ID = 11;
export const WEEKLY_CARD_REWARD_DAYS = 7;

/** 读取关卡配置的期望重生次数对应的金币倍率，用于装备定价。 */
function calculateEquipmentGoldMultiplier(
  rebirthCurves: CurveGroupValue,
  expectedRebirthCount: number,
): number {
  return calculateRebirthValues(rebirthCurves, expectedRebirthCount)
    .goldMultiplierReward;
}

/** 按镰刀 ID 采样配置；用期望关卡的期望重生金币倍率计算购买价格。 */
export function calculateSickleValues(
  sickleCurves: CurveGroupValue,
  stageCurves: CurveGroupValue,
  rebirthCurves: CurveGroupValue,
  sickleId: number,
): SickleValues {
  const values = sampleCurveGroup(sickleCurves, sickleId).values;
  const expectedStageId = Math.max(0, Math.floor(values.expectedStageId));
  const expectedItemCount = Math.max(0, Math.floor(values.expectedItemCount));
  const stageValues = calculateStageValues(stageCurves, expectedStageId);
  const expectedStageItemPrice = Math.max(0, stageValues.expectedItemPrice);
  const rebirthGoldMultiplier = calculateEquipmentGoldMultiplier(
    rebirthCurves,
    stageValues.expectedRebirthCount,
  );
  return {
    purchasePrice:
      expectedStageId === 0
        ? 0
        : Math.floor(
            expectedStageItemPrice *
              rebirthGoldMultiplier *
              expectedItemCount,
          ),
    trainingValueMultiplier: values.trainingValueMultiplier,
    expectedStageId,
    rebirthGoldMultiplier,
    expectedItemCount,
  };
}

/** 按光环 ID 采样配置；根据期望关卡的道具单价、期望重生金币倍率和拾取数量计算购买价格。 */
export function calculateAuraValues(
  auraCurves: CurveGroupValue,
  stageCurves: CurveGroupValue,
  rebirthCurves: CurveGroupValue,
  auraId: number,
): AuraValues {
  if (auraId === 0) {
    return {
      multiplier: 1,
      purchasePrice: 0,
      expectedStageId: 0,
      rebirthGoldMultiplier: 1,
      expectedItemCount: 0,
    };
  }
  const values = sampleCurveGroup(auraCurves, auraId).values;
  const expectedStageId = Math.max(0, Math.floor(values.expectedStageId));
  const expectedItemCount = Math.max(0, Math.floor(values.expectedItemCount));
  const stageValues = calculateStageValues(stageCurves, expectedStageId);
  const expectedStageItemPrice = Math.max(0, stageValues.expectedItemPrice);
  const rebirthGoldMultiplier = calculateEquipmentGoldMultiplier(
    rebirthCurves,
    stageValues.expectedRebirthCount,
  );
  return {
    multiplier: values.multiplier,
    purchasePrice:
      expectedStageId === 0
        ? 0
        : Math.floor(
            expectedStageItemPrice *
              rebirthGoldMultiplier *
              expectedItemCount,
          ),
    expectedStageId,
    rebirthGoldMultiplier,
    expectedItemCount,
  };
}

/** 按当前等级采样升到下一级所需的训练值；升级只消耗经验进度。 */
export function calculateLevelValues(
  levelCurves: CurveGroupValue,
  level: number,
): LevelValues {
  const values = sampleCurveGroup(levelCurves, level).values;
  return {
    nextLevelExperience: values.nextLevelExperience,
  };
}

/** 计算等级力量：第 1 级至目标等级（包含目标等级）的升级需求之和，不含剩余训练值或重生次数。 */
export function calculateLevelStrength(
  levelCurves: CurveGroupValue,
  targetLevel: number,
): number {
  // 先校验目标等级；满级也包含该等级配置的升级需求。
  sampleCurveGroupColumnFormula(levelCurves, "nextLevelExperience", targetLevel);
  let total = 0;
  for (let level = levelCurves.input?.min ?? 1; level <= targetLevel; level += 1) {
    total += sampleCurveGroupColumnFormula(levelCurves, "nextLevelExperience", level);
  }
  return total;
}

/** 返回等级力量首次达到目标血量的最低等级；满级仍不足时返回 null，不采样上限外等级。 */
export function calculateOneHitKillLevel(
  levelCurves: CurveGroupValue & { input: { max: number } },
  grassHp: number,
): number | null {
  let strength = 0;
  for (
    let level = levelCurves.input.min ?? 1;
    level <= levelCurves.input.max;
    level += 1
  ) {
    strength += sampleCurveGroupColumnFormula(levelCurves, "nextLevelExperience", level);
    if (strength >= grassHp) {
      return level;
    }
  }
  return null;
}

/** 按关卡 ID 采样准入、血量基准等级、血量倍率与道具单价，供定价和难度计算使用。 */
export function calculateStageValues(
  stageCurves: CurveGroupValue,
  globalStageId: number,
): StageValues {
  const values = sampleCurveGroup(stageCurves, globalStageId).values;
  return {
    expectedRebirthCount: Math.max(0, Math.floor(values.expectedRebirthCount)),
    grassLevel: values.grassLevel,
    hpMultiplier: values.hpMultiplier,
    expectedItemPrice: values.expectedItemPrice,
  };
}

/** 用期望等级及之前各级的升级需求之和作为攻击力基准，再乘关卡血量倍率；起始关基准至少为 1。 */
export function calculateStageCombatValues(
  stageCurves: CurveGroupValue,
  levelCurves: CurveGroupValue,
  globalStageId: number,
) {
  const values = calculateStageValues(stageCurves, globalStageId);
  const expectedStrength = values.grassLevel <= 1
    ? 1
    : calculateLevelStrength(levelCurves, values.grassLevel);
  return {
    ...values,
    expectedStrength,
    grassHp: Math.max(1, Math.floor(values.hpMultiplier * expectedStrength)),
  };
}

/** 按重生次数采样下一次门槛或当前重生奖励倍率。 */
export function calculateRebirthValues(
  rebirthCurves: CurveGroupValue,
  rebirthCount: number,
): RebirthValues {
  const values = sampleCurveGroup(rebirthCurves, rebirthCount).values;
  return {
    requiredLevel: values.requiredLevel,
    trainingMultiplierReward: values.trainingMultiplierReward,
    goldMultiplierReward: values.goldMultiplierReward,
    catchUpMultiplier: values.catchUpMultiplier,
  };
}

/** 重生后尚未追回本次重生要求等级时返回配置追赶倍率，否则返回 1。 */
export function calculateRebirthCatchUpMultiplier(
  completedRebirthCount: number,
  level: number,
  previousRebirthRequiredLevel: number,
  catchUpMultiplier: number,
): number {
  return completedRebirthCount > 0 && level < previousRebirthRequiredLevel
    ? catchUpMultiplier
    : 1;
}

/** 场地门槛按 ID 递增，查找到首个未解锁场地并返回最高已解锁场地；未解锁时 ID 为 0、倍率为 1。 */
export function calculateRebirthFieldSelection(
  rebirthFieldCurves: CurveGroupValue,
  rebirthCount: number,
): RebirthFieldSelection {
  let selection: RebirthFieldSelection = {
    id: 0,
    requiredRebirthCount: 0,
    extraMultiplier: 1,
  };

  for (let id = 1; ; id += 1) {
    const values = calculateRebirthFieldValues(rebirthFieldCurves, id);
    if (values.requiredRebirthCount > rebirthCount) {
      return selection;
    }
    selection = { id, ...values };
  }
}

/** 按场地 ID 采样该场地的重生次数要求与训练额外倍率。 */
export function calculateRebirthFieldValues(
  rebirthFieldCurves: CurveGroupValue,
  rebirthFieldId: number,
): RebirthFieldValues {
  const values = sampleCurveGroup(rebirthFieldCurves, rebirthFieldId).values;
  return {
    requiredRebirthCount: values.requiredRebirthCount,
    extraMultiplier: values.extraMultiplier,
  };
}

/** 按付费训练倍率档位 ID 采样当前倍率和升到该档所需钻石。 */
export function calculatePaidMultiplierValues(
  paidMultiplierCurves: CurveGroupValue,
  paidMultiplierId: number,
): PaidMultiplierValues {
  const values = sampleCurveGroup(
    paidMultiplierCurves,
    paidMultiplierId,
  ).values;
  return {
    multiplier: values.multiplier,
    diamondCost: Math.max(0, Math.floor(values.diamondCost)),
  };
}

/** 按目标扩容等级采样背包扩容所需的钻石价格。 */
export function calculateBackpackExpansionValues(
  backpackExpansionCurves: CurveGroupValue,
  expansionLevel: number,
): BackpackExpansionValues {
  const values = sampleCurveGroup(
    backpackExpansionCurves,
    expansionLevel,
  ).values;
  return {
    expansionPrice: Math.max(0, Math.floor(values.expansionPrice)),
  };
}

/** 按周卡档位采样价格与钻石奖励，并计算购买当天和完整 7 天的总奖励。 */
export function calculateWeeklyCardValues(
  weeklyCardCurves: CurveGroupValue,
  cardId: number,
): WeeklyCardValues {
  const values = sampleCurveGroup(weeklyCardCurves, cardId).values;
  const instantDiamonds = Math.max(0, Math.floor(values.instantDiamonds));
  const dailyDiamonds = Math.max(0, Math.floor(values.dailyDiamonds));
  return {
    miniCoinPrice: Math.max(0, Math.floor(values.miniCoinPrice)),
    instantDiamonds,
    dailyDiamonds,
    purchaseDayDiamonds: instantDiamonds + dailyDiamonds,
    equivalentDiamonds: Math.max(0, Math.floor(values.miniCoinPrice)) * 8,
    totalDiamonds:
      instantDiamonds + dailyDiamonds * WEEKLY_CARD_REWARD_DAYS,
  };
}

/** 将道具数量、末关单价和重生倍率相乘，返回返家出售所得整数金币。 */
export function calculateItemSaleGold(
  itemCount: number,
  expectedItemPrice: number,
  rebirthGoldMultiplier: number,
): number {
  return Math.floor(
    Math.max(0, Math.floor(itemCount)) *
      Math.max(0, expectedItemPrice) *
      Math.max(0, rebirthGoldMultiplier),
  );
}
