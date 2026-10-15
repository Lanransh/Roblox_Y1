import { ChartSet } from "@game-simulator/framework";
import {
  calculateAuraValues,
  calculateLevelStrength,
  calculateLevelValues,
  calculateOneHitKillLevel,
  calculateSickleValues,
  calculateStageCombatValues,
} from "./Formulas";
import type { ProjectConfig } from "./Main";

export class ProjectCharts extends ChartSet {
  static ChartNames = {
    chartSicklePriceAndEfficiency: "镰刀价格与效率",
    chartAuraPriceAndMultiplier: "光环价格与倍率",
    chartStageHpAndRecommendedAttack: "关卡血量与推荐攻击力",
    chartLevelTrainingAndStrength: "等级训练需求与力量",
  };

  private get projectConfig(): ProjectConfig {
    return this.config as ProjectConfig;
  }

  chartSicklePriceAndEfficiency() {
    return {
      variable: "sickleId",
      xLabel: "镰刀 ID",
      yLabel: "数值",
      minX: this.projectConfig.sickleCurves.input.min ?? 1,
      maxX: this.projectConfig.sickleCurves.input.max,
      step: 1,
      series: [
        {
          id: "purchasePrice",
          label: "价格",
          sample: (sickleId: number) =>
            this.getSickleValues(sickleId).purchasePrice,
        },
        {
          id: "trainingValueMultiplier",
          label: "训练效率",
          sample: (sickleId: number) =>
            this.getSickleValues(sickleId).trainingValueMultiplier,
        },
      ],
    };
  }

  chartAuraPriceAndMultiplier() {
    return {
      variable: "auraId",
      xLabel: "光环 ID",
      yLabel: "数值",
      minX: 1,
      maxX: this.projectConfig.auraCurves.input.max,
      step: 1,
      series: [
        {
          id: "purchasePrice",
          label: "价格（金币）",
          sample: (auraId: number) => this.getAuraValues(auraId).purchasePrice,
        },
        {
          id: "multiplier",
          label: "倍率",
          sample: (auraId: number) => this.getAuraValues(auraId).multiplier,
        },
      ],
    };
  }

  chartStageHpAndRecommendedAttack() {
    const display = this.projectConfig.stageCurves.editor?.display;
    return {
      variable: "stageId",
      xLabel: "关卡 ID",
      yLabel: "数值",
      minX: 1,
      maxX: display?.kind === "curve" ? display.sampleRange?.max ?? 1 : 1,
      step: 1,
      series: [
        {
          id: "grassHp",
          label: "草的血量",
          sample: (stageId: number) => this.getStageValues(stageId).grassHp,
        },
        {
          id: "expectedStrength",
          label: "推荐攻击力",
          sample: (stageId: number) =>
            this.getStageValues(stageId).expectedStrength,
        },
        {
          id: "oneHitKillLevel",
          label: "一击必杀等级",
          sample: (stageId: number) => {
            const level = calculateOneHitKillLevel(
              this.projectConfig.levelCurves,
              this.getStageValues(stageId).grassHp,
            );
            if (level === null) {
              throw new Error("满级仍无法一击必杀");
            }
            return level;
          },
        },
        {
          id: "expectedLevel",
          label: "关卡期望等级",
          sample: (stageId: number) => this.getStageValues(stageId).grassLevel,
        },
      ],
    };
  }

  chartLevelTrainingAndStrength() {
    return {
      variable: "level",
      xLabel: "等级",
      yLabel: "训练值 / 力量",
      minX: this.projectConfig.levelCurves.input.min ?? 1,
      maxX: this.projectConfig.levelCurves.input.max,
      step: 1,
      series: [
        {
          id: "nextLevelExperience",
          label: "升到下一级所需训练值",
          sample: (level: number) => level === this.projectConfig.levelCurves.input.max
            ? 0
            : calculateLevelValues(this.projectConfig.levelCurves, level).nextLevelExperience,
        },
        {
          id: "strength",
          label: "当前等级及之前升级需求之和",
          sample: (level: number) =>
            calculateLevelStrength(this.projectConfig.levelCurves, level),
        },
      ],
    };
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

  private getStageValues(stageId: number) {
    return calculateStageCombatValues(
      this.projectConfig.stageCurves,
      this.projectConfig.levelCurves,
      stageId,
    );
  }
}
