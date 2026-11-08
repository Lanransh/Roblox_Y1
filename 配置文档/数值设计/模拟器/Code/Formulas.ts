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
  robuxPrice: number;
  instantDiamonds: number;
  dailyDiamonds: number;
  purchaseDayDiamonds: number;
  equivalentDiamonds: number;
  totalDiamonds: number;
};

// 暂时限制为第 7 档，即 ×128；保留更高档配置供后续恢复。
export const MAX_PAID_MULTIPLIER_ID = 7;
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

const levelTrainingThresholds = new WeakMap<CurveGroupValue, number[]>();

/** 计算刚达到目标等级所需的累计训练值；只累加此前各级需求，不含目标等级自身需求。 */
export function calculateLevelStrength(
  levelCurves: CurveGroupValue,
  targetLevel: number,
): number {
  // 校验合法等级；按配置对象缓存累计门槛，供状态和等级图表复用。
  sampleCurveGroupColumnFormula(levelCurves, "nextLevelExperience", targetLevel);
  const minLevel = levelCurves.input?.min ?? 1;
  let thresholds = levelTrainingThresholds.get(levelCurves);
  if (!thresholds) {
    thresholds = [0];
    levelTrainingThresholds.set(levelCurves, thresholds);
  }
  while (thresholds.length <= targetLevel - minLevel) {
    const required = sampleCurveGroupColumnFormula(
      levelCurves, "nextLevelExperience", minLevel + thresholds.length - 1,
    );
    thresholds.push(thresholds[thresholds.length - 1] + required);
  }
  return thresholds[targetLevel - minLevel];
}

/** 根据累计训练值反查已达到的最高等级；等于门槛时升级，搜索不超过等级上限。 */
export function calculateTrainingLevel(
  levelCurves: CurveGroupValue & { input: { max: number } },
  trainingValue: number,
): number {
  let low = levelCurves.input.min ?? 1;
  let high = levelCurves.input.max;
  while (low < high) {
    const middle = Math.ceil((low + high) / 2);
    if (trainingValue >= calculateLevelStrength(levelCurves, middle)) {
      low = middle;
    } else {
      high = middle - 1;
    }
  }
  return low;
}

/** 按整数等级采样独立攻击力曲线；与该等级的升级经验需求无关。 */
export function calculateLevelAttack(
  levelCurves: CurveGroupValue,
  level: number,
): number {
  return sampleCurveGroupColumnFormula(levelCurves, "attackPower", level);
}

/** 用累计训练值确定等级与级内进度，在本级和下级攻击力间线性插值；满级不再采样下一级。 */
export function calculateTrainingAttack(
  levelCurves: CurveGroupValue & { input: { max: number } },
  trainingValue: number,
): number {
  const level = calculateTrainingLevel(levelCurves, trainingValue);
  const attack = calculateLevelAttack(levelCurves, level);
  if (level >= levelCurves.input.max) {
    return attack;
  }
  const threshold = calculateLevelStrength(levelCurves, level);
  const nextThreshold = calculateLevelStrength(levelCurves, level + 1);
  const progress = (trainingValue - threshold) / (nextThreshold - threshold);
  return attack + (calculateLevelAttack(levelCurves, level + 1) - attack) * progress;
}

/** 反查基础攻击力刚达到目标血量时所属的等级（可在级内达到）；超过满级攻击力时返回 null。 */
export function calculateOneHitKillLevel(
  levelCurves: CurveGroupValue & { input: { max: number } },
  grassHp: number,
): number | null {
  if (grassHp > calculateLevelAttack(levelCurves, levelCurves.input.max)) {
    return null;
  }
  let low = levelCurves.input.min ?? 1;
  let high = levelCurves.input.max;
  while (low < high) {
    const middle = Math.ceil((low + high) / 2);
    if (calculateLevelAttack(levelCurves, middle) <= grassHp) {
      low = middle;
    } else {
      high = middle - 1;
    }
  }
  return low;
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

/** 用期望等级的独立攻击力乘关卡血量倍率；期望等级不大于 1 的起始关沿用力量 1。 */
export function calculateStageCombatValues(
  stageCurves: CurveGroupValue,
  levelCurves: CurveGroupValue,
  globalStageId: number,
) {
  const values = calculateStageValues(stageCurves, globalStageId);
  const expectedStrength = values.grassLevel <= 1
    ? 1
    : calculateLevelAttack(levelCurves, values.grassLevel);
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

/** 按周卡档位采样 Robux 标价与奖励，计算当天、完整 7 天奖励及按基础兑换比例折算的钻石。 */
export function calculateWeeklyCardValues(
  weeklyCardCurves: CurveGroupValue,
  cardId: number,
): WeeklyCardValues {
  const values = sampleCurveGroup(weeklyCardCurves, cardId).values;
  const instantDiamonds = Math.max(0, Math.floor(values.instantDiamonds));
  const dailyDiamonds = Math.max(0, Math.floor(values.dailyDiamonds));
  return {
    robuxPrice: Math.max(0, Math.floor(values.robuxPrice)),
    instantDiamonds,
    dailyDiamonds,
    purchaseDayDiamonds: instantDiamonds + dailyDiamonds,
    equivalentDiamonds: Math.max(0, Math.floor(values.robuxPrice)) * 10,
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
