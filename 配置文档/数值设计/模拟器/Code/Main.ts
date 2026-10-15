import configValues from "../Data/config.json";
import {
  Config,
  type CurveGroupValue,
  type NumberConfigValue,
  type RuntimeConfig,
} from "@game-simulator/framework";
import { ProjectCharts } from "./Charts";
import { Game } from "./Game";
import { State } from "./State";
import { ProjectWorkbenches } from "./Workbenches";

export type ConfigValues = {
  initialGold: NumberConfigValue;
  initialDiamonds: NumberConfigValue;
  sickleCurves: CurveGroupValue & { input: { max: number } };
  auraCurves: CurveGroupValue & { input: { max: number } };
  trainingSettlementsPerSecond: NumberConfigValue;
  dailyGiftDiamondAmount: NumberConfigValue;
  dailyLogicalHours: NumberConfigValue;
  weeklyCardCurves: CurveGroupValue;
  paidTrainingMultiplierCurves: CurveGroupValue;
  backpackExpansionCurves: CurveGroupValue & { input: { max: number } };
  rebirthCurves: CurveGroupValue & { input: { max: number } };
  rebirthFieldCurves: CurveGroupValue;
  levelCurves: CurveGroupValue & { input: { max: number } };
  stageCurves: CurveGroupValue;
  worldStageCount: NumberConfigValue;
  itemsUnlockedPerStage: NumberConfigValue;
  expectedStageDuration: NumberConfigValue;
  expectedEasyStageDuration: NumberConfigValue;
  estimatedItemAcquisitionDuration: NumberConfigValue;
  baseBackpackCapacity: NumberConfigValue;
};
export type ProjectConfig = RuntimeConfig<ConfigValues>;

const config = new Config(configValues as ConfigValues) as ProjectConfig;
const state = new State();
const game = new Game();
const charts = new ProjectCharts();
const workbenches = new ProjectWorkbenches();

export function createProject() {
  return { config, state, game, charts, workbenches };
}
