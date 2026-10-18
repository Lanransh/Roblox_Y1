import {
  type ActionSource,
  BaseAction,
  type MacroActionBlocker,
  type SimulatorEditor,
} from "@game-simulator/framework";
import type { ProjectConfig } from "./Main";
import {
  type AutoDiamondUpgradeTarget,
  type GameMode,
  State,
  type WeeklyCardType,
} from "./State";

type SwitchModePayload = {
  mode: GameMode;
};

type SetAutoModePayload = {
  enabled: boolean;
};

type SetAutoDiamondUpgradePayload = {
  target: AutoDiamondUpgradeTarget;
  enabled: boolean;
};

type ActionOptions = {
  id?: string;
  timestamp?: string;
  simulationTime?: number;
  source?: ActionSource;
};

type RebirthPayload = {
  previousLevel?: number;
  recoveryTargetLevel?: number;
  recoveryStartedAt?: number;
};

type CompleteRebirthRecoveryPayload = {
  targetLevel?: number;
  elapsedSeconds?: number;
};

type UpgradeSicklePayload = Record<string, never>;

type UpgradeAuraPayload = Record<string, never>;

type UpgradeBackpackPayload = {
  method: UpgradeMethod;
};

export type UpgradeMethod = "diamond" | "paid";

type UpgradePaidTrainingMultiplierPayload = {
  method: UpgradeMethod;
};

type PurchaseWeeklyCardPayload = {
  cardType: WeeklyCardType;
};

export class SwitchModeAction extends BaseAction<
  SwitchModePayload,
  State,
  ProjectConfig
> {
  constructor(mode: GameMode, options: ActionOptions = {}) {
    super({
      ...options,
      type: "switchMode",
      payload: { mode },
    });
  }

  Apply(): boolean {
    if (this.GetBlocker()) {
      return false;
    }

    this.state.switchMode(this.payload!.mode);
    return true;
  }

  GetBlocker(): MacroActionBlocker | null {
    if (this.state.mode === this.payload?.mode) {
      return { kind: "alreadyInMode", reason: "当前已经处于该模式。" };
    }
    if (
      this.payload?.mode === "challenge" &&
      this.state.getHighestChallengeStageId() <= 0
    ) {
      return {
        kind: "challengeRebirthTooLow",
        reason: `第 1 关需要完成 ${this.state.getTargetStageValues().expectedRebirthCount} 次重生。`,
      };
    }
    return null;
  }
}

BaseAction.register("switchMode", (value) => {
  const mode = value.payload?.mode === "challenge" ? "challenge" : "training";
  return new SwitchModeAction(mode, {
    id: value.id,
    timestamp: value.timestamp,
    simulationTime: value.simulationTime,
    source: value.source,
  });
});

export class SetAutoModeAction extends BaseAction<
  SetAutoModePayload,
  State,
  ProjectConfig
> {
  constructor(enabled: boolean, options: ActionOptions = {}) {
    super({
      ...options,
      type: "setAutoMode",
      payload: { enabled },
    });
  }

  Apply(): boolean {
    if (this.GetBlocker()) {
      return false;
    }

    this.state.setAutoModeEnabled(this.payload!.enabled);
    return true;
  }

  GetBlocker(): MacroActionBlocker | null {
    if (this.state.autoModeEnabled === this.payload?.enabled) {
      return { kind: "autoModeUnchanged", reason: "自动模式状态没有变化。" };
    }
    return null;
  }
}

BaseAction.register("setAutoMode", (value) => {
  return new SetAutoModeAction(value.payload?.enabled === true, {
    id: value.id,
    timestamp: value.timestamp,
    simulationTime: value.simulationTime,
    source: value.source,
  });
});

export class SetAutoDiamondUpgradeAction extends BaseAction<
  SetAutoDiamondUpgradePayload,
  State,
  ProjectConfig
> {
  constructor(
    target: AutoDiamondUpgradeTarget,
    enabled: boolean,
    options: ActionOptions = {},
  ) {
    super({
      ...options,
      type: "setAutoDiamondUpgrade",
      payload: { target, enabled },
    });
  }

  Apply(): boolean {
    if (this.GetBlocker()) {
      return false;
    }

    this.state.setAutoDiamondUpgradeEnabled(
      this.payload!.target,
      this.payload!.enabled,
    );
    return true;
  }

  GetBlocker(): MacroActionBlocker | null {
    const { target, enabled } = this.payload!;
    if (
      enabled &&
      target === "paidTrainingMultiplier" &&
      this.state.isPaidTrainingMultiplierMaxed()
    ) {
      return {
        kind: "paidMultiplierMaxed",
        reason: "付费训练倍率已达到最高档。",
      };
    }
    if (
      enabled &&
      target === "backpack" &&
      this.state.isBackpackExpansionMaxed()
    ) {
      return {
        kind: "backpackExpansionMaxed",
        reason: "背包已达到扩容上限。",
      };
    }

    const current =
      target === "paidTrainingMultiplier"
        ? this.state.autoPaidTrainingUpgradeEnabled
        : this.state.autoBackpackUpgradeEnabled;
    if (current === enabled) {
      return {
        kind: "autoDiamondUpgradeUnchanged",
        reason: "钻石自动升级状态没有变化。",
      };
    }
    return null;
  }
}

BaseAction.register("setAutoDiamondUpgrade", (value) => {
  const target =
    value.payload?.target === "backpack"
      ? "backpack"
      : "paidTrainingMultiplier";
  return new SetAutoDiamondUpgradeAction(
    target,
    value.payload?.enabled === true,
    {
      id: value.id,
      timestamp: value.timestamp,
      simulationTime: value.simulationTime,
      source: value.source,
    },
  );
});

export class RebirthAction extends BaseAction<
  RebirthPayload,
  State,
  ProjectConfig
> {
  private readonly editor: SimulatorEditor | null;

  constructor(
    editor: SimulatorEditor | null = null,
    options: ActionOptions = {},
  ) {
    super({
      ...options,
      type: "rebirth",
      payload: {},
    });
    this.editor = editor;
  }

  Apply(): boolean {
    if (this.GetBlocker()) {
      return false;
    }

    const previousLevel = this.state.level;
    const recoveryTargetLevel =
      this.state.getNextRebirthValues().requiredLevel;
    const targetRebirthCount = this.state.rebirthCount + 1;
    if (this.editor) {
      this.editor.addRewindPoint("重生");
      this.editor.addRewindPointMessage(
        "重生",
        `第 ${targetRebirthCount} 次重生前：等级 ${previousLevel}`,
      );
    }
    this.state.applyRebirth(recoveryTargetLevel, this.currentTick);
    this.setPayload({
      previousLevel,
      recoveryTargetLevel,
      recoveryStartedAt: this.currentTick,
    });
    return true;
  }

  GetBlocker(): MacroActionBlocker | null {
    if (this.state.rebirthCount >= this.config.rebirthCurves.input.max) {
      return {
        kind: "rebirthLimitReached",
        reason: "已达到重生次数上限。",
      };
    }
    const requiredLevel = this.state.getNextRebirthValues().requiredLevel;
    if (this.state.level < requiredLevel) {
      return {
        kind: "rebirthLevelTooLow",
        reason: `重生需要达到 ${requiredLevel} 级。`,
      };
    }
    return null;
  }
}

BaseAction.register("rebirth", (value) => {
  return new RebirthAction(null, {
    id: value.id,
    timestamp: value.timestamp,
    simulationTime: value.simulationTime,
    source: value.source,
  });
});

export class CompleteRebirthRecoveryAction extends BaseAction<
  CompleteRebirthRecoveryPayload,
  State,
  ProjectConfig
> {
  private readonly editor: SimulatorEditor | null;

  constructor(
    editor: SimulatorEditor | null = null,
    options: ActionOptions = {},
  ) {
    super({
      ...options,
      type: "completeRebirthRecovery",
      payload: {},
    });
    this.editor = editor;
  }

  Apply(): boolean {
    if (this.GetBlocker()) {
      return false;
    }

    const recovery = this.state.completeRebirthRecovery(this.currentTick);
    if (!recovery) {
      return false;
    }
    if (this.editor) {
      this.editor.addRewindPoint("回到重生最大等级");
      this.editor.addRewindPointMessage(
        "回到重生最大等级",
        `<span color="#175cd3" font-size="16"><b>用时 ${recovery.elapsedSeconds} 秒</b></span><br>` +
          `<span color="#667085" font-size="13">回到 ${recovery.targetLevel} 级</span>`,
      );
    }
    this.setPayload(recovery);
    return true;
  }

  GetBlocker(): MacroActionBlocker | null {
    if (!this.state.isRebirthRecoveryComplete()) {
      return {
        kind: "rebirthRecoveryIncomplete",
        reason: "尚未回到上次重生要求的最大等级。",
      };
    }
    return null;
  }
}

BaseAction.register("completeRebirthRecovery", (value) => {
  return new CompleteRebirthRecoveryAction(null, {
    id: value.id,
    timestamp: value.timestamp,
    simulationTime: value.simulationTime,
    source: value.source,
  });
});

export class UpgradeSickleAction extends BaseAction<
  UpgradeSicklePayload,
  State,
  ProjectConfig
> {
  constructor(options: ActionOptions = {}) {
    super({
      ...options,
      type: "upgradeSickle",
      payload: {},
    });
  }

  Apply(): boolean {
    if (this.GetBlocker()) {
      return false;
    }

    this.state.applySickleUpgrade(
      this.state.getNextSickleValues().purchasePrice,
    );
    return true;
  }

  GetBlocker(): MacroActionBlocker | null {
    if (this.state.isSickleMaxed()) {
      return { kind: "sickleMaxed", reason: "镰刀已达到最高等级。" };
    }

    const { purchasePrice } = this.state.getNextSickleValues();
    if (this.state.gold < purchasePrice) {
      return {
        kind: "goldInsufficient",
        reason: `升级镰刀需要 ${purchasePrice} 金币，当前只有 ${this.state.gold}。`,
      };
    }
    return null;
  }
}

BaseAction.register("upgradeSickle", (value) => {
  return new UpgradeSickleAction({
    id: value.id,
    timestamp: value.timestamp,
    simulationTime: value.simulationTime,
    source: value.source,
  });
});

export class UpgradeAuraAction extends BaseAction<
  UpgradeAuraPayload,
  State,
  ProjectConfig
> {
  constructor(options: ActionOptions = {}) {
    super({
      ...options,
      type: "upgradeAura",
      payload: {},
    });
  }

  Apply(): boolean {
    if (this.GetBlocker()) {
      return false;
    }

    this.state.applyAuraUpgrade(this.state.getNextAuraValues().purchasePrice);
    return true;
  }

  GetBlocker(): MacroActionBlocker | null {
    if (this.state.isAuraMaxed()) {
      return { kind: "auraMaxed", reason: "光环已达到最高等级。" };
    }

    const { purchasePrice } = this.state.getNextAuraValues();
    if (this.state.gold < purchasePrice) {
      return {
        kind: "goldInsufficient",
        reason: `升级光环需要 ${purchasePrice} 金币，当前只有 ${this.state.gold}。`,
      };
    }
    return null;
  }
}

BaseAction.register("upgradeAura", (value) => {
  return new UpgradeAuraAction({
    id: value.id,
    timestamp: value.timestamp,
    simulationTime: value.simulationTime,
    source: value.source,
  });
});

export class UpgradePaidTrainingMultiplierAction extends BaseAction<
  UpgradePaidTrainingMultiplierPayload,
  State,
  ProjectConfig
> {
  constructor(method: UpgradeMethod, options: ActionOptions = {}) {
    super({
      ...options,
      type: "upgradePaidTrainingMultiplier",
      payload: { method },
    });
  }

  Apply(): boolean {
    if (this.GetBlocker()) {
      return false;
    }

    const diamondCost =
      this.payload!.method === "diamond"
        ? this.state.getNextPaidTrainingMultiplierValues().diamondCost
        : 0;
    this.state.applyPaidTrainingMultiplierUpgrade(diamondCost);
    return true;
  }

  GetBlocker(): MacroActionBlocker | null {
    if (this.state.isPaidTrainingMultiplierMaxed()) {
      return {
        kind: "paidMultiplierMaxed",
        reason: "付费训练倍率已达到暂时上限 ×128。",
      };
    }

    if (this.payload!.method === "diamond") {
      const { diamondCost } = this.state.getNextPaidTrainingMultiplierValues();
      if (this.state.diamonds < diamondCost) {
        return {
          kind: "diamondsInsufficient",
          reason: `提升训练倍率需要 ${diamondCost} 钻石，当前只有 ${this.state.diamonds}。`,
        };
      }
    }
    return null;
  }
}

BaseAction.register("upgradePaidTrainingMultiplier", (value) => {
  const method = value.payload?.method === "paid" ? "paid" : "diamond";
  return new UpgradePaidTrainingMultiplierAction(method, {
    id: value.id,
    timestamp: value.timestamp,
    simulationTime: value.simulationTime,
    source: value.source,
  });
});

export class UpgradeBackpackAction extends BaseAction<
  UpgradeBackpackPayload,
  State,
  ProjectConfig
> {
  constructor(
    method: UpgradeMethod,
    options: ActionOptions = {},
  ) {
    super({
      ...options,
      type: "upgradeBackpack",
      payload: { method },
    });
  }

  Apply(): boolean {
    if (this.GetBlocker()) {
      return false;
    }

    const expansionPrice =
      this.payload!.method === "diamond"
        ? this.state.getNextBackpackExpansionValues().expansionPrice
        : 0;
    this.state.applyBackpackExpansion(expansionPrice);
    return true;
  }

  GetBlocker(): MacroActionBlocker | null {
    if (this.state.isBackpackExpansionMaxed()) {
      return { kind: "backpackExpansionMaxed", reason: "背包已达到扩容上限。" };
    }

    if (this.payload!.method === "diamond") {
      const { expansionPrice } = this.state.getNextBackpackExpansionValues();
      if (this.state.diamonds < expansionPrice) {
        return {
          kind: "diamondsInsufficient",
          reason: `扩容需要 ${expansionPrice} 钻石，当前只有 ${this.state.diamonds}。`,
        };
      }
    }
    return null;
  }
}

BaseAction.register("upgradeBackpack", (value) => {
  const method = value.payload?.method === "paid" ? "paid" : "diamond";
  return new UpgradeBackpackAction(method, {
    id: value.id,
    timestamp: value.timestamp,
    simulationTime: value.simulationTime,
    source: value.source,
  });
});

export class PurchaseWeeklyCardAction extends BaseAction<
  PurchaseWeeklyCardPayload,
  State,
  ProjectConfig
> {
  constructor(cardType: WeeklyCardType, options: ActionOptions = {}) {
    super({
      ...options,
      type: "purchaseWeeklyCard",
      payload: { cardType },
    });
  }

  Apply(): boolean {
    if (this.GetBlocker()) {
      return false;
    }

    this.state.applyWeeklyCardPurchase(this.payload!.cardType);
    return true;
  }

  GetBlocker(): MacroActionBlocker | null {
    if (this.state.isWeeklyCardActive(this.payload!.cardType)) {
      return {
        kind: "weeklyCardActive",
        reason: `${this.payload!.cardType === "small" ? "小" : "大"}周卡仍在生效中。`,
      };
    }
    return null;
  }
}

BaseAction.register("purchaseWeeklyCard", (value) => {
  const cardType = value.payload?.cardType === "large" ? "large" : "small";
  return new PurchaseWeeklyCardAction(cardType, {
    id: value.id,
    timestamp: value.timestamp,
    simulationTime: value.simulationTime,
    source: value.source,
  });
});
