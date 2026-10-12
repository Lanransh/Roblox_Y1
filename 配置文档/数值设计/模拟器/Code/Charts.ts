import { ChartSet, sampleCurveGroup } from "@game-simulator/framework";
import { calculateAuraValues, calculateSickleValues } from "./Formulas";
import type { ProjectConfig } from "./Main";

export class ProjectCharts extends ChartSet {
  static ChartNames = {
    chartSicklePriceAndEfficiency: "镰刀价格与效率",
    chartAuraPriceAndMultiplier: "光环价格与倍率",
    chartStageHpAndRecommendedAttack: "关卡血量与推荐攻击力",
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
    return {
      variable: "stageId",
      xLabel: "关卡 ID",
      yLabel: "数值",
      minX: 1,
      maxX: Math.max(1, this.projectConfig.sickleCurves.input.max - 1),
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
    return sampleCurveGroup(this.projectConfig.stageCurves, stageId).values;
  }
}
