import { State as BaseState } from "@game-simulator/framework";
import {
  calculateAuraValues,
  calculateBackpackExpansionValues,
  calculateItemSaleGold,
  calculateLevelValues,
  calculatePaidMultiplierValues,
  calculateRebirthCatchUpMultiplier,
  calculateRebirthFieldSelection,
  calculateRebirthValues,
  calculateSickleValues,
  calculateStageValues,
  calculateWeeklyCardValues,
  MAX_PAID_MULTIPLIER_ID,
  WEEKLY_CARD_REWARD_DAYS,
} from "./Formulas";
import type { ProjectConfig } from "./Main";

export type GameMode = "training" | "challenge";
export type ChallengePhase = "outbound" | "gathering";
export type WeeklyCardType = "small" | "large";
export type AutoDiamondUpgradeTarget =
  | "paidTrainingMultiplier"
  | "backpack";

export type StateValues = {
  mode: GameMode;
  autoModeEnabled: boolean;
  gold: number;
  sickleId: number;
  auraId: number;
  rebirthCount: number;
  level: number;
  trainingValue: number;
  strength: number;
  rebirthRecoveryTargetLevel: number | null;
  rebirthRecoveryStartedAt: number | null;
  diamonds: number;
  diamondGiftElapsedSeconds: number;
  smallWeeklyCardRemainingRewards: number;
  smallWeeklyCardElapsedSeconds: number;
  largeWeeklyCardRemainingRewards: number;
  largeWeeklyCardElapsedSeconds: number;
  paidTrainingMultiplierId: number;
  autoPaidTrainingUpgradeEnabled: boolean;
  backpackExpansionLevel: number;
  autoBackpackUpgradeEnabled: boolean;
  challengeWorld: number;
  challengeStage: number;
  challengePhase: ChallengePhase;
  challengeElapsedSeconds: number;
  itemCount: number;
};

type TrainingMultiplierFactorCache = {
  sickleCurves: ProjectConfig["sickleCurves"];
  auraCurves: ProjectConfig["auraCurves"];
  stageCurves: ProjectConfig["stageCurves"];
  rebirthCurves: ProjectConfig["rebirthCurves"];
  rebirthFieldCurves: ProjectConfig["rebirthFieldCurves"];
  paidTrainingMultiplierCurves: ProjectConfig["paidTrainingMultiplierCurves"];
  mode: GameMode;
  sickleId: number;
  auraId: number;
  rebirthCount: number;
  paidTrainingMultiplierId: number;
  prefix: number;
  rebirthRequiredLevel: number;
  rebirthCatchUpMultiplier: number;
  rebirthFieldMultiplier: number;
  paidTrainingMultiplier: number;
};

type HighestChallengeStageCache = {
  stageCurves: ProjectConfig["stageCurves"];
  rebirthCount: number;
  stageId: number;
};

// WeakMap 缓存不会写入 State，也不会触发运行时只读视图的修改保护。
const trainingMultiplierFactorCache = new WeakMap<
  object,
  TrainingMultiplierFactorCache
>();
const highestChallengeStageCache = new WeakMap<
  object,
  HighestChallengeStageCache
>();

export class State extends BaseState<StateValues> {
  mode: GameMode;
  autoModeEnabled: boolean;
  gold: number;
  sickleId: number;
  auraId: number;
  rebirthCount: number;
  level: number;
  trainingValue: number;
  strength: number;
  rebirthRecoveryTargetLevel: number | null;
  rebirthRecoveryStartedAt: number | null;
  diamonds: number;
  diamondGiftElapsedSeconds: number;
  smallWeeklyCardRemainingRewards: number;
  smallWeeklyCardElapsedSeconds: number;
  largeWeeklyCardRemainingRewards: number;
  largeWeeklyCardElapsedSeconds: number;
  paidTrainingMultiplierId: number;
  autoPaidTrainingUpgradeEnabled: boolean;
  backpackExpansionLevel: number;
  autoBackpackUpgradeEnabled: boolean;
  challengeWorld: number;
  challengeStage: number;
  challengePhase: ChallengePhase;
  challengeElapsedSeconds: number;
  itemCount: number;

  constructor() {
    super();
    this.mode = "training";
    this.autoModeEnabled = true;
    this.gold = this.projectConfig.initialGold;
    this.sickleId = 1;
    this.auraId = 0;
    this.rebirthCount = 0;
    this.level = 1;
    this.trainingValue = 0;
    this.strength = this.getLevelValues().strength;
    this.rebirthRecoveryTargetLevel = null;
    this.rebirthRecoveryStartedAt = null;
    this.diamonds = this.projectConfig.initialDiamonds;
    this.diamondGiftElapsedSeconds = 0;
    this.smallWeeklyCardRemainingRewards = 0;
    this.smallWeeklyCardElapsedSeconds = 0;
    this.largeWeeklyCardRemainingRewards = 0;
    this.largeWeeklyCardElapsedSeconds = 0;
    this.paidTrainingMultiplierId = 0;
    this.autoPaidTrainingUpgradeEnabled = true;
    this.backpackExpansionLevel = 0;
    this.autoBackpackUpgradeEnabled = false;
    this.challengeWorld = 1;
    this.challengeStage = 1;
    this.challengePhase = "outbound";
    this.challengeElapsedSeconds = 0;
    this.itemCount = 0;
  }

  getSummary(): string {
    return `${this.mode === "training" ? "训练" : "闯关"}模式 | 自动${this.autoModeEnabled ? "开" : "关"} | 重生 ${this.rebirthCount} 次 | 回级 ${this.rebirthRecoveryTargetLevel === null ? "-" : `${this.level}/${this.rebirthRecoveryTargetLevel}`} | 金币 ${this.gold} | 光环 ${this.auraId} 级 | 钻石 ${this.diamonds} | 钻石自动 ${this.autoPaidTrainingUpgradeEnabled ? "倍率" : "-"}/${this.autoBackpackUpgradeEnabled ? "背包" : "-"} | 周卡余次 ${this.smallWeeklyCardRemainingRewards}/${this.largeWeeklyCardRemainingRewards} | 等级 ${this.level} | 力量 ${this.strength} | 道具 ${this.itemCount}/${this.getBackpackCapacity()}`;
  }

  get summary(): string {
    return this.getSummary();
  }

  getFieldDisplayNames(): Record<string, string> {
    return {
      mode: "模式",
      autoModeEnabled: "自动模式",
      gold: "金币",
      sickleId: "镰刀ID",
      auraId: "光环ID",
      rebirthCount: "重生次数",
      level: "等级",
      trainingValue: "训练值",
      strength: "力量",
      rebirthRecoveryTargetLevel: "上次重生要求的最大等级",
      rebirthRecoveryStartedAt: "重生回级计时起点",
      diamonds: "钻石",
      diamondGiftElapsedSeconds: "本轮钻石赠送已累计秒数",
      smallWeeklyCardRemainingRewards: "小周卡剩余每日奖励次数",
      smallWeeklyCardElapsedSeconds: "小周卡本轮已累计秒数",
      largeWeeklyCardRemainingRewards: "大周卡剩余每日奖励次数",
      largeWeeklyCardElapsedSeconds: "大周卡本轮已累计秒数",
      paidTrainingMultiplierId: "付费训练倍率档位",
      autoPaidTrainingUpgradeEnabled: "付费训练倍率钻石自动升级",
      backpackExpansionLevel: "背包扩容等级",
      autoBackpackUpgradeEnabled: "背包钻石自动扩容",
      challengeWorld: "闯关世界",
      challengeStage: "世界内关卡",
      challengePhase: "闯关阶段",
      challengeElapsedSeconds: "当前阶段已用时间",
      itemCount: "道具数量",
    };
  }

  toJSON(): StateValues {
    return {
      mode: this.mode,
      autoModeEnabled: this.autoModeEnabled,
      gold: this.gold,
      sickleId: this.sickleId,
      auraId: this.auraId,
      rebirthCount: this.rebirthCount,
      level: this.level,
      trainingValue: this.trainingValue,
      strength: this.strength,
      rebirthRecoveryTargetLevel: this.rebirthRecoveryTargetLevel,
      rebirthRecoveryStartedAt: this.rebirthRecoveryStartedAt,
      diamonds: this.diamonds,
      diamondGiftElapsedSeconds: this.diamondGiftElapsedSeconds,
      smallWeeklyCardRemainingRewards: this.smallWeeklyCardRemainingRewards,
      smallWeeklyCardElapsedSeconds: this.smallWeeklyCardElapsedSeconds,
      largeWeeklyCardRemainingRewards: this.largeWeeklyCardRemainingRewards,
      largeWeeklyCardElapsedSeconds: this.largeWeeklyCardElapsedSeconds,
      paidTrainingMultiplierId: this.paidTrainingMultiplierId,
      autoPaidTrainingUpgradeEnabled: this.autoPaidTrainingUpgradeEnabled,
      backpackExpansionLevel: this.backpackExpansionLevel,
      autoBackpackUpgradeEnabled: this.autoBackpackUpgradeEnabled,
      challengeWorld: this.challengeWorld,
      challengeStage: this.challengeStage,
      challengePhase: this.challengePhase,
      challengeElapsedSeconds: this.challengeElapsedSeconds,
      itemCount: this.itemCount,
    };
  }

  loadJSON(values: StateValues): void {
    this.mode = values.mode;
    this.autoModeEnabled = values.autoModeEnabled ?? true;
    this.gold = values.gold ?? this.projectConfig.initialGold;
    this.sickleId = values.sickleId ?? 1;
    this.auraId = values.auraId ?? 0;
    this.rebirthCount = values.rebirthCount ?? 0;
    this.level = values.level;
    this.trainingValue = values.trainingValue;
    this.strength = values.strength;
    this.rebirthRecoveryTargetLevel = values.rebirthRecoveryTargetLevel ?? null;
    this.rebirthRecoveryStartedAt = values.rebirthRecoveryStartedAt ?? null;
    this.diamonds = values.diamonds ?? this.projectConfig.initialDiamonds;
    this.diamondGiftElapsedSeconds = values.diamondGiftElapsedSeconds ?? 0;
    this.smallWeeklyCardRemainingRewards = Math.min(
      WEEKLY_CARD_REWARD_DAYS - 1,
      Math.max(0, Math.floor(values.smallWeeklyCardRemainingRewards ?? 0)),
    );
    this.smallWeeklyCardElapsedSeconds = Math.max(
      0,
      Math.floor(values.smallWeeklyCardElapsedSeconds ?? 0),
    );
    this.largeWeeklyCardRemainingRewards = Math.min(
      WEEKLY_CARD_REWARD_DAYS - 1,
      Math.max(0, Math.floor(values.largeWeeklyCardRemainingRewards ?? 0)),
    );
    this.largeWeeklyCardElapsedSeconds = Math.max(
      0,
      Math.floor(values.largeWeeklyCardElapsedSeconds ?? 0),
    );
    this.paidTrainingMultiplierId = Math.min(
      MAX_PAID_MULTIPLIER_ID,
      Math.max(0, Math.floor(values.paidTrainingMultiplierId ?? 0)),
    );
    this.autoPaidTrainingUpgradeEnabled =
      values.autoPaidTrainingUpgradeEnabled === true;
    this.backpackExpansionLevel = values.backpackExpansionLevel ?? 0;
    this.autoBackpackUpgradeEnabled =
      values.autoBackpackUpgradeEnabled === true;
    this.challengeWorld = values.challengeWorld;
    this.challengeStage = values.challengeStage;
    this.challengePhase = values.challengePhase;
    this.challengeElapsedSeconds = values.challengeElapsedSeconds;
    this.itemCount = values.itemCount;
  }

  getNextLevelExperience(): number {
    return this.getLevelValues().nextLevelExperience;
  }

  getTrainingValuePerSettlement(): number {
    return this.getTotalTrainingMultiplier();
  }

  getTotalTrainingMultiplier(): number {
    const config = this.projectConfig;
    let factors = trainingMultiplierFactorCache.get(this);
    if (
      !factors ||
      factors.sickleCurves !== config.sickleCurves ||
      factors.auraCurves !== config.auraCurves ||
      factors.stageCurves !== config.stageCurves ||
      factors.rebirthCurves !== config.rebirthCurves ||
      factors.rebirthFieldCurves !== config.rebirthFieldCurves ||
      factors.paidTrainingMultiplierCurves !==
        config.paidTrainingMultiplierCurves ||
      factors.mode !== this.mode ||
      factors.sickleId !== this.sickleId ||
      factors.auraId !== this.auraId ||
      factors.rebirthCount !== this.rebirthCount ||
      factors.paidTrainingMultiplierId !== this.paidTrainingMultiplierId
    ) {
      const sickleTrainingValue =
        this.getSickleValues().trainingValueMultiplier;
      const auraMultiplier = this.getAuraValues().multiplier;
      const rebirthValues = this.getCurrentRebirthValues();
      factors = {
        sickleCurves: config.sickleCurves,
        auraCurves: config.auraCurves,
        stageCurves: config.stageCurves,
        rebirthCurves: config.rebirthCurves,
        rebirthFieldCurves: config.rebirthFieldCurves,
        paidTrainingMultiplierCurves:
          config.paidTrainingMultiplierCurves,
        mode: this.mode,
        sickleId: this.sickleId,
        auraId: this.auraId,
        rebirthCount: this.rebirthCount,
        paidTrainingMultiplierId: this.paidTrainingMultiplierId,
        prefix:
          sickleTrainingValue *
          auraMultiplier *
          rebirthValues.trainingMultiplierReward,
        rebirthRequiredLevel: this.getPreviousRebirthRequiredLevel(),
        rebirthCatchUpMultiplier: rebirthValues.catchUpMultiplier,
        rebirthFieldMultiplier:
          this.mode === "training"
            ? this.getCurrentRebirthField().extraMultiplier
            : 1,
        paidTrainingMultiplier:
          this.getPaidTrainingMultiplierValues().multiplier,
      };
      trainingMultiplierFactorCache.set(this, factors);
    }

    const catchUpMultiplier = calculateRebirthCatchUpMultiplier(
      this.rebirthCount,
      this.level,
      factors.rebirthRequiredLevel,
      factors.rebirthCatchUpMultiplier,
    );
    return (
      factors.prefix *
      catchUpMultiplier *
      factors.rebirthFieldMultiplier *
      factors.paidTrainingMultiplier
    );
  }

  getTotalGoldMultiplier(): number {
    return this.getCurrentRebirthValues().goldMultiplierReward;
  }

  getSickleValues(id = this.sickleId) {
    return calculateSickleValues(
      this.projectConfig.sickleCurves,
      this.projectConfig.stageCurves,
      this.projectConfig.rebirthCurves,
      id,
    );
  }

  getNextSickleValues() {
    return this.getSickleValues(
      Math.min(this.getMaxSickleId(), this.sickleId + 1),
    );
  }

  isSickleMaxed(): boolean {
    return this.sickleId >= this.getMaxSickleId();
  }

  applySickleUpgrade(purchasePrice: number): void {
    this.gold -= purchasePrice;
    this.sickleId += 1;
  }

  getAuraValues(id = this.auraId) {
    return calculateAuraValues(
      this.projectConfig.auraCurves,
      this.projectConfig.stageCurves,
      this.projectConfig.rebirthCurves,
      id,
    );
  }

  getNextAuraValues() {
    return this.getAuraValues(this.auraId + 1);
  }

  isAuraMaxed(): boolean {
    return this.auraId >= this.projectConfig.auraCurves.input.max;
  }

  applyAuraUpgrade(purchasePrice: number): void {
    this.gold -= purchasePrice;
    this.auraId += 1;
  }

  getPaidTrainingMultiplierValues(id = this.paidTrainingMultiplierId) {
    return calculatePaidMultiplierValues(
      this.projectConfig.paidTrainingMultiplierCurves,
      id,
    );
  }

  getNextPaidTrainingMultiplierValues() {
    return this.getPaidTrainingMultiplierValues(
      Math.min(MAX_PAID_MULTIPLIER_ID, this.paidTrainingMultiplierId + 1),
    );
  }

  isPaidTrainingMultiplierMaxed(): boolean {
    return this.paidTrainingMultiplierId >= MAX_PAID_MULTIPLIER_ID;
  }

  applyPaidTrainingMultiplierUpgrade(diamondCost: number): void {
    this.diamonds -= diamondCost;
    this.paidTrainingMultiplierId += 1;
    if (this.isPaidTrainingMultiplierMaxed()) {
      this.autoPaidTrainingUpgradeEnabled = false;
    }
  }

  setAutoDiamondUpgradeEnabled(
    target: AutoDiamondUpgradeTarget,
    enabled: boolean,
  ): void {
    if (target === "paidTrainingMultiplier") {
      this.autoPaidTrainingUpgradeEnabled = enabled;
      return;
    }
    this.autoBackpackUpgradeEnabled = enabled;
  }

  getDiamondGiftRemainingSeconds(): number {
    return Math.max(
      0,
      this.getDiamondGiftIntervalSeconds() - this.diamondGiftElapsedSeconds,
    );
  }

  getWeeklyCardValues(cardType: WeeklyCardType) {
    return calculateWeeklyCardValues(
      this.projectConfig.weeklyCardCurves,
      cardType === "small" ? 1 : 2,
    );
  }

  getWeeklyCardRemainingRewards(cardType: WeeklyCardType): number {
    return cardType === "small"
      ? this.smallWeeklyCardRemainingRewards
      : this.largeWeeklyCardRemainingRewards;
  }

  getWeeklyCardRewardRemainingSeconds(cardType: WeeklyCardType): number {
    if (this.getWeeklyCardRemainingRewards(cardType) <= 0) {
      return 0;
    }
    const elapsedSeconds =
      cardType === "small"
        ? this.smallWeeklyCardElapsedSeconds
        : this.largeWeeklyCardElapsedSeconds;
    return Math.max(0, this.getLogicalDaySeconds() - elapsedSeconds);
  }

  isWeeklyCardActive(cardType: WeeklyCardType): boolean {
    return this.getWeeklyCardRemainingRewards(cardType) > 0;
  }

  applyWeeklyCardPurchase(cardType: WeeklyCardType): void {
    const { purchaseDayDiamonds } = this.getWeeklyCardValues(cardType);
    this.diamonds += purchaseDayDiamonds;
    this.setWeeklyCardProgress(cardType, WEEKLY_CARD_REWARD_DAYS - 1, 0);
  }

  getCurrentRebirthValues() {
    return calculateRebirthValues(
      this.projectConfig.rebirthCurves,
      this.rebirthCount,
    );
  }

  getNextRebirthValues() {
    return this.getCurrentRebirthValues();
  }

  private getPreviousRebirthRequiredLevel(): number {
    return calculateRebirthValues(
      this.projectConfig.rebirthCurves,
      Math.max(0, this.rebirthCount - 1),
    ).requiredLevel;
  }

  getCurrentRebirthCatchUpMultiplier(): number {
    const rebirthValues = this.getCurrentRebirthValues();
    return calculateRebirthCatchUpMultiplier(
      this.rebirthCount,
      this.level,
      this.getPreviousRebirthRequiredLevel(),
      rebirthValues.catchUpMultiplier,
    );
  }

  getCurrentRebirthField() {
    return calculateRebirthFieldSelection(
      this.projectConfig.rebirthFieldCurves,
      this.rebirthCount,
    );
  }

  applyRebirth(recoveryTargetLevel: number, recoveryStartedAt: number): void {
    this.rebirthRecoveryTargetLevel = recoveryTargetLevel;
    this.rebirthRecoveryStartedAt = recoveryStartedAt;
    this.rebirthCount += 1;
    this.level = 1;
    this.trainingValue = 0;
    this.strength = this.getLevelValues().strength;
    this.mode = "training";
  }

  isRebirthRecoveryComplete(): boolean {
    return (
      this.rebirthRecoveryTargetLevel !== null &&
      this.rebirthRecoveryStartedAt !== null &&
      this.level >= this.rebirthRecoveryTargetLevel
    );
  }

  completeRebirthRecovery(
    completedAt: number,
  ): { targetLevel: number; elapsedSeconds: number } | null {
    if (!this.isRebirthRecoveryComplete()) {
      return null;
    }

    const targetLevel = this.rebirthRecoveryTargetLevel!;
    const elapsedSeconds = Math.max(
      0,
      Math.floor(completedAt - this.rebirthRecoveryStartedAt!),
    );
    this.rebirthRecoveryTargetLevel = null;
    this.rebirthRecoveryStartedAt = null;
    return { targetLevel, elapsedSeconds };
  }

  getWorldStageCount(): number {
    return Math.max(1, Math.floor(this.projectConfig.worldStageCount));
  }

  getStageCount(): number {
    const display = this.projectConfig.stageCurves.editor?.display;
    const maxStageId =
      display?.kind === "curve" ? display.sampleRange?.max : undefined;
    return Math.max(1, Math.floor(maxStageId ?? 1));
  }

  getHighestChallengeStageId(): number {
    const config = this.projectConfig;
    const cached = highestChallengeStageCache.get(this);
    if (
      cached?.stageCurves === config.stageCurves &&
      cached.rebirthCount === this.rebirthCount
    ) {
      return cached.stageId;
    }

    for (let stageId = this.getStageCount(); stageId >= 1; stageId -= 1) {
      const { expectedRebirthCount } = calculateStageValues(
        config.stageCurves,
        stageId,
      );
      if (this.rebirthCount >= expectedRebirthCount) {
        highestChallengeStageCache.set(this, {
          stageCurves: config.stageCurves,
          rebirthCount: this.rebirthCount,
          stageId,
        });
        return stageId;
      }
    }
    highestChallengeStageCache.set(this, {
      stageCurves: config.stageCurves,
      rebirthCount: this.rebirthCount,
      stageId: 0,
    });
    return 0;
  }

  getChallengeWorld(): number {
    const targetStageId = Math.max(1, this.getHighestChallengeStageId());
    return Math.ceil(targetStageId / this.getWorldStageCount());
  }

  getChallengeLastStage(): number {
    const targetStageId = Math.max(1, this.getHighestChallengeStageId());
    return ((targetStageId - 1) % this.getWorldStageCount()) + 1;
  }

  getCurrentGlobalStageId(): number {
    return (
      (this.challengeWorld - 1) * this.getWorldStageCount() +
      this.challengeStage
    );
  }

  getCurrentStageValues() {
    return calculateStageValues(
      this.projectConfig.stageCurves,
      this.getCurrentGlobalStageId(),
    );
  }

  getTargetStageValues() {
    return calculateStageValues(
      this.projectConfig.stageCurves,
      Math.max(1, this.getHighestChallengeStageId()),
    );
  }

  getBackpackCapacity(): number {
    return (
      Math.max(1, Math.floor(this.projectConfig.baseBackpackCapacity)) +
      this.backpackExpansionLevel
    );
  }

  getMaxBackpackExpansionCount(): number {
    return this.projectConfig.backpackExpansionCurves.input.max;
  }

  getNextBackpackExpansionValues() {
    return calculateBackpackExpansionValues(
      this.projectConfig.backpackExpansionCurves,
      Math.min(
        this.getMaxBackpackExpansionCount(),
        this.backpackExpansionLevel + 1,
      ),
    );
  }

  isBackpackExpansionMaxed(): boolean {
    return this.backpackExpansionLevel >= this.getMaxBackpackExpansionCount();
  }

  applyBackpackExpansion(expansionPrice: number): void {
    this.diamonds -= expansionPrice;
    this.backpackExpansionLevel += 1;
    if (this.isBackpackExpansionMaxed()) {
      this.autoBackpackUpgradeEnabled = false;
    }
  }

  getCurrentPhaseDuration(): number {
    if (this.challengePhase === "gathering") {
      return this.toTickDuration(
        this.projectConfig.estimatedItemAcquisitionDuration,
      );
    }
    const { grassHp } = this.getCurrentStageValues();
    const duration =
      this.strength >= grassHp
        ? this.projectConfig.expectedEasyStageDuration
        : this.projectConfig.expectedStageDuration;
    return this.toTickDuration(duration);
  }

  switchMode(mode: GameMode): void {
    this.mode = mode;
    if (mode === "challenge") {
      this.startChallengeRun();
    }
  }

  advanceOneSecond(): void {
    this.advanceDiamondGiftOneSecond();
    this.advanceWeeklyCardOneSecond("small");
    this.advanceWeeklyCardOneSecond("large");

    for (
      let settlement = 0;
      settlement < this.projectConfig.trainingSettlementsPerSecond;
      settlement += 1
    ) {
      this.trainingValue += this.getTrainingValuePerSettlement();
      this.applyAutomaticLevelUps();
    }

    if (this.mode === "challenge") {
      this.advanceChallengeOneSecond();
    }
  }

  setAutoModeEnabled(enabled: boolean): void {
    this.autoModeEnabled = enabled;
  }

  private advanceChallengeOneSecond(): void {
    const targetStageId = this.getHighestChallengeStageId();
    if (targetStageId <= 0) {
      this.mode = "training";
      return;
    }
    const targetWorld = Math.ceil(targetStageId / this.getWorldStageCount());
    if (this.challengeWorld !== targetWorld) {
      this.startChallengeRun();
      return;
    }
    if (this.getCurrentGlobalStageId() > targetStageId) {
      this.startChallengeRun();
      return;
    }

    this.challengeElapsedSeconds += 1;
    if (this.challengeElapsedSeconds < this.getCurrentPhaseDuration()) {
      return;
    }

    this.challengeElapsedSeconds = 0;
    if (this.challengePhase === "outbound") {
      if (this.challengeStage < this.getChallengeLastStage()) {
        this.challengeStage += 1;
      } else {
        this.challengePhase = "gathering";
      }
      return;
    }

    if (this.challengePhase === "gathering") {
      this.itemCount += 1;
      if (this.itemCount >= this.getBackpackCapacity()) {
        const { expectedItemPrice } = this.getTargetStageValues();
        const { goldMultiplierReward } = this.getCurrentRebirthValues();
        this.gold += calculateItemSaleGold(
          this.itemCount,
          expectedItemPrice,
          goldMultiplierReward,
        );
        this.itemCount = 0;
        this.startChallengeRun();
      }
      return;
    }
  }

  private startChallengeRun(): void {
    this.challengeWorld = this.getChallengeWorld();
    this.challengeStage = 1;
    this.challengePhase = "outbound";
    this.challengeElapsedSeconds = 0;
    this.itemCount = 0;
  }

  private advanceDiamondGiftOneSecond(): void {
    const intervalSeconds = this.getDiamondGiftIntervalSeconds();
    this.diamondGiftElapsedSeconds += 1;
    const giftCount = Math.floor(
      this.diamondGiftElapsedSeconds / intervalSeconds,
    );
    if (giftCount <= 0) {
      return;
    }

    const giftAmount = Math.max(
      0,
      Math.floor(this.projectConfig.dailyGiftDiamondAmount),
    );
    this.diamonds += giftCount * giftAmount;
    this.diamondGiftElapsedSeconds %= intervalSeconds;
  }

  private advanceWeeklyCardOneSecond(cardType: WeeklyCardType): void {
    const remainingRewards = this.getWeeklyCardRemainingRewards(cardType);
    if (remainingRewards <= 0) {
      return;
    }

    const elapsedSeconds =
      (cardType === "small"
        ? this.smallWeeklyCardElapsedSeconds
        : this.largeWeeklyCardElapsedSeconds) + 1;
    const intervalSeconds = this.getLogicalDaySeconds();
    const rewardCount = Math.min(
      remainingRewards,
      Math.floor(elapsedSeconds / intervalSeconds),
    );
    if (rewardCount <= 0) {
      this.setWeeklyCardProgress(cardType, remainingRewards, elapsedSeconds);
      return;
    }

    this.diamonds +=
      rewardCount * this.getWeeklyCardValues(cardType).dailyDiamonds;
    const nextRemainingRewards = remainingRewards - rewardCount;
    this.setWeeklyCardProgress(
      cardType,
      nextRemainingRewards,
      nextRemainingRewards > 0
        ? elapsedSeconds - rewardCount * intervalSeconds
        : 0,
    );
  }

  private getDiamondGiftIntervalSeconds(): number {
    return this.getLogicalDaySeconds();
  }

  private getLogicalDaySeconds(): number {
    return Math.max(
      1,
      Math.ceil(this.projectConfig.dailyLogicalHours * 60 * 60),
    );
  }

  private setWeeklyCardProgress(
    cardType: WeeklyCardType,
    remainingRewards: number,
    elapsedSeconds: number,
  ): void {
    if (cardType === "small") {
      this.smallWeeklyCardRemainingRewards = remainingRewards;
      this.smallWeeklyCardElapsedSeconds = elapsedSeconds;
      return;
    }
    this.largeWeeklyCardRemainingRewards = remainingRewards;
    this.largeWeeklyCardElapsedSeconds = elapsedSeconds;
  }

  private getMaxSickleId(): number {
    return this.projectConfig.sickleCurves.input.max;
  }

  private toTickDuration(duration: number): number {
    return Math.max(1, Math.ceil(duration));
  }

  private applyAutomaticLevelUps(): void {
    if (this.level >= this.projectConfig.levelCurves.input.max) {
      return;
    }

    let levelValues = this.getLevelValues();
    while (this.level < this.projectConfig.levelCurves.input.max) {
      const required = levelValues.nextLevelExperience;
      if (this.trainingValue < required) {
        break;
      }

      this.trainingValue -= required;
      this.level += 1;
      levelValues = this.getLevelValues();
      this.strength = levelValues.strength;
    }
  }

  private getLevelValues() {
    return calculateLevelValues(this.projectConfig.levelCurves, this.level);
  }

  private get projectConfig(): ProjectConfig {
    return this.config as ProjectConfig;
  }
}
