import {
  numberToText,
  sampleCurveGroupColumnFormula,
  WorkbenchSet,
} from "@game-simulator/framework";
import {
  calculateAuraValues,
  calculateSickleValues,
  calculateStageCombatValues,
} from "./Formulas";
import type { ProjectConfig } from "./Main";

export class ProjectWorkbenches extends WorkbenchSet {
  static WorkbenchNames = {
    workbenchSickleConfig: "镰刀配置",
    workbenchAuraConfig: "光环配置",
    workbenchDifficultyConfig: "难度配置工作台",
    workbenchStageHpConfig: "关卡血量配置",
  };

  private get projectConfig(): ProjectConfig {
    return this.config as ProjectConfig;
  }

  workbenchSickleConfig() {
    return {
      variable: "sickleId",
      rowLabel: "镰刀 ID",
      minRow: this.projectConfig.sickleCurves.input.min ?? 1,
      maxRow: this.projectConfig.sickleCurves.input.max,
      step: 1,
      editors: [
        {
          id: "sickle",
          label: "镰刀",
          configKey: "sickleCurves",
          columnKeys: ["expectedStageId", "expectedItemCount"],
        },
        {
          id: "stage",
          label: "关卡",
          configKey: "stageCurves",
          columnKeys: ["expectedRebirthCount", "expectedItemPrice"],
        },
        {
          id: "rebirth",
          label: "重生",
          configKey: "rebirthCurves",
          columnKeys: ["goldMultiplierReward"],
        },
      ],
      columns: [
        {
          id: "expectedStageId",
          label: "期望关卡",
          format: "integer" as const,
          configTarget: {
            configKey: "sickleCurves",
            columnKey: "expectedStageId",
          },
          sample: (sickleId: number) =>
            this.getSickleValues(sickleId).expectedStageId,
        },
        {
          id: "rebirthGoldMultiplier",
          label: "期望关卡对应重生倍率",
          format: "multiplier" as const,
          configTarget: {
            configKey: "rebirthCurves",
            columnKey: "goldMultiplierReward",
          },
          sample: (sickleId: number) =>
            this.getSickleValues(sickleId).rebirthGoldMultiplier,
        },
        {
          id: "expectedItemCount",
          label: "期望道具数量",
          format: "integer" as const,
          configTarget: {
            configKey: "stageCurves",
            columnKey: "expectedItemPrice",
          },
          sample: (sickleId: number) =>
            this.getSickleValues(sickleId).expectedItemCount,
        },
        {
          id: "purchasePrice",
          label: "镰刀价格",
          format: "text" as const,
          configTarget: {
            configKey: "sickleCurves",
            columnKey: "expectedItemCount",
          },
          sample: (sickleId: number) =>
            numberToText(this.getSickleValues(sickleId).purchasePrice),
        },
      ],
    };
  }

  workbenchAuraConfig() {
    return {
      variable: "auraId",
      rowLabel: "光环 ID",
      minRow: 1,
      maxRow: this.projectConfig.auraCurves.input.max,
      step: 1,
      editors: [
        {
          id: "aura",
          label: "光环",
          configKey: "auraCurves",
          columnKeys: ["expectedStageId", "expectedItemCount"],
        },
        {
          id: "stage",
          label: "关卡",
          configKey: "stageCurves",
          columnKeys: ["expectedRebirthCount", "expectedItemPrice"],
        },
        {
          id: "rebirth",
          label: "重生",
          configKey: "rebirthCurves",
          columnKeys: ["goldMultiplierReward"],
        },
      ],
      columns: [
        {
          id: "expectedStageId",
          label: "期望关卡",
          format: "integer" as const,
          configTarget: {
            configKey: "auraCurves",
            columnKey: "expectedStageId",
          },
          sample: (auraId: number) =>
            this.getAuraValues(auraId).expectedStageId,
        },
        {
          id: "rebirthGoldMultiplier",
          label: "期望关卡对应重生倍率",
          format: "multiplier" as const,
          configTarget: {
            configKey: "rebirthCurves",
            columnKey: "goldMultiplierReward",
          },
          sample: (auraId: number) =>
            this.getAuraValues(auraId).rebirthGoldMultiplier,
        },
        {
          id: "expectedItemCount",
          label: "期望拾取数量",
          format: "integer" as const,
          configTarget: {
            configKey: "auraCurves",
            columnKey: "expectedItemCount",
          },
          sample: (auraId: number) =>
            this.getAuraValues(auraId).expectedItemCount,
        },
        {
          id: "purchasePrice",
          label: "光环价格",
          format: "text" as const,
          configTarget: {
            configKey: "auraCurves",
            columnKey: "expectedItemCount",
          },
          sample: (auraId: number) =>
            numberToText(this.getAuraValues(auraId).purchasePrice),
        },
      ],
    };
  }

  workbenchDifficultyConfig() {
    return {
      variable: "rebirthCount",
      rowLabel: "重生次数",
      minRow: this.projectConfig.rebirthCurves.input.min ?? 0,
      maxRow: this.projectConfig.rebirthCurves.input.max,
      step: 1,
      editors: [
        {
          id: "rebirthDifficulty",
          label: "重生难度",
          configKey: "rebirthCurves",
          columnKeys: ["requiredLevel", "catchUpMultiplier"],
        },
        {
          id: "levelCurve",
          label: "等级难度",
          configKey: "levelCurves",
          columnKeys: ["nextLevelExperience"],
        },
      ],
      columns: [
        {
          id: "levelRange",
          label: "等级范围",
          format: "text" as const,
          configTarget: {
            configKey: "rebirthCurves",
            columnKey: "requiredLevel",
          },
          sample: (rebirthCount: number) => {
            const { minLevel, maxLevel } =
              this.getDifficultyLevelRange(rebirthCount);
            return `${minLevel}–${maxLevel}`;
          },
        },
        {
          id: "levelDifficulty",
          label: "等级难度",
          description: "升过当前重生等级范围所需的累计训练值",
          format: "text" as const,
          configTarget: {
            configKey: "levelCurves",
            columnKey: "nextLevelExperience",
          },
          sample: (rebirthCount: number) => {
            const { minLevel, maxLevel } =
              this.getDifficultyLevelRange(rebirthCount);
            let totalExperience = 0;
            for (
              let level = minLevel;
              level <= maxLevel && level < this.projectConfig.levelCurves.input.max;
              level += 1
            ) {
              totalExperience += sampleCurveGroupColumnFormula(
                this.projectConfig.levelCurves,
                "nextLevelExperience",
                level,
              );
            }
            return numberToText(totalExperience);
          },
        },
        {
          id: "catchUpMultiplier",
          label: "追赶倍率",
          format: "multiplier" as const,
          configTarget: {
            configKey: "rebirthCurves",
            columnKey: "catchUpMultiplier",
          },
          sample: (rebirthCount: number) =>
            sampleCurveGroupColumnFormula(
              this.projectConfig.rebirthCurves,
              "catchUpMultiplier",
              rebirthCount,
            ),
        },
      ],
    };
  }

  workbenchStageHpConfig() {
    const display = this.projectConfig.stageCurves.editor?.display;
    const getValues = (stageId: number) => calculateStageCombatValues(
      this.projectConfig.stageCurves,
      this.projectConfig.levelCurves,
      stageId,
    );
    return {
      variable: "stageId",
      rowLabel: "关卡 ID",
      minRow: 1,
      maxRow: display?.kind === "curve" ? display.sampleRange?.max ?? 1 : 1,
      step: 1,
      editors: [
        {
          id: "stageHp",
          label: "关卡血量",
          configKey: "stageCurves",
          columnKeys: ["expectedRebirthCount", "grassLevel", "hpMultiplier"],
        },
        {
          id: "levelTraining",
          label: "等级训练需求",
          configKey: "levelCurves",
          columnKeys: ["nextLevelExperience"],
        },
      ],
      columns: [
        {
          id: "grassLevel",
          label: "期望等级",
          format: "integer" as const,
          configTarget: { configKey: "stageCurves", columnKey: "grassLevel" },
          sample: (stageId: number) => getValues(stageId).grassLevel,
        },
      ],
    };
  }

  private getDifficultyLevelRange(rebirthCount: number) {
    return {
      minLevel:
        rebirthCount === 0
          ? 1
          : this.getDifficultyRequiredLevel(rebirthCount - 1),
      maxLevel:
        rebirthCount === this.projectConfig.rebirthCurves.input.max
          ? this.projectConfig.levelCurves.input.max
          : this.getDifficultyRequiredLevel(rebirthCount) - 1,
    };
  }

  private getDifficultyRequiredLevel(rebirthCount: number): number {
    const requiredLevel = Math.max(
      1,
      Math.floor(
        sampleCurveGroupColumnFormula(
          this.projectConfig.rebirthCurves,
          "requiredLevel",
          rebirthCount,
        ),
      ),
    );
    return Math.min(
      requiredLevel,
      this.projectConfig.levelCurves.input.max,
    );
  }

  private getSickleValues(sickleId: number) {
    return calculateSickleValues(
      this.projectConfig.sickleCurves,
      this.projectConfig.stageCurves,
      this.projectConfig.rebirthCurves,
      sickleId,
    );
  }

  private getAuraValues(auraId: number) {
    return calculateAuraValues(
      this.projectConfig.auraCurves,
      this.projectConfig.stageCurves,
      this.projectConfig.rebirthCurves,
      auraId,
    );
  }
}
