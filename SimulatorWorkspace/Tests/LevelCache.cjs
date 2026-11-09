// 在工作区运行：node Tests/LevelCache.cjs
const assert = require("node:assert/strict");
const fs = require("node:fs");
const path = require("node:path");
const vm = require("node:vm");

const root = path.resolve(__dirname, "..");
const framework = path.resolve(root, JSON.parse(fs.readFileSync(path.join(root, "tsconfig.json"), "utf8"))
  .compilerOptions.paths["@game-simulator/framework"][0]);
const esbuild = require(path.join(framework, "../node_modules/esbuild"));
const source = 'export * from "./Formulas"; export { State } from "./State";' +
  'export { sampleCurveGroupColumnFormula } from "@game-simulator/framework";';
const built = esbuild.buildSync({
  stdin: { contents: source, loader: "ts", resolveDir: path.join(root, "Code") },
  bundle: true, format: "cjs", platform: "node", write: false,
  alias: { "@game-simulator/framework": framework },
});
const context = { module: { exports: {} }, exports: {}, require, console, performance, setTimeout, clearTimeout };
vm.runInNewContext(built.outputFiles[0].text, context);
const api = context.module.exports;
const original = JSON.parse(fs.readFileSync(path.join(root, "Data/config.json"), "utf8")).levelCurves;
const sample = api.sampleCurveGroupColumnFormula;
let checks = 0;
function same(actual, expected) { assert.equal(actual, expected); checks++; }
function outcome(fn) {
  try { return { value: fn() }; } catch (error) { return { error: error.message }; }
}
function checkAgainstFresh(curves) {
  const fresh = structuredClone(curves);
  for (const name of ["calculateLevelStrength", "calculateLevelAttack"]) {
    for (const level of [1, 2, 20, 100, 780, 0, 781, 1.5, NaN, Infinity]) {
      assert.deepEqual(outcome(() => api[name](curves, level)), outcome(() => api[name](fresh, level)));
      checks++;
    }
  }
}

// 独立按级累加经验并采样攻击力，验证全部等级及升级边界。
const thresholds = [0];
for (let level = 1; level < original.input.max; level++) {
  thresholds.push(thresholds.at(-1) + sample(original, "nextLevelExperience", level));
}
for (let level = 1; level <= original.input.max; level++) {
  same(api.calculateLevelStrength(original, level), thresholds[level - 1]);
  same(api.calculateLevelAttack(original, level), sample(original, "attackPower", level));
  for (const value of [Math.max(0, thresholds[level - 1] - 0.1), thresholds[level - 1], thresholds[level - 1] + 0.1]) {
    let expectedLevel = 1;
    while (expectedLevel < original.input.max && value >= thresholds[expectedLevel]) expectedLevel++;
    same(api.calculateTrainingLevel(original, value), expectedLevel);
    const attack = sample(original, "attackPower", expectedLevel);
    const progress = expectedLevel === original.input.max ? 0 :
      (value - thresholds[expectedLevel - 1]) / (thresholds[expectedLevel] - thresholds[expectedLevel - 1]);
    const expectedAttack = expectedLevel === original.input.max ? attack :
      attack + (sample(original, "attackPower", expectedLevel + 1) - attack) * progress;
    same(api.calculateTrainingAttack(original, value), expectedAttack);
  }
}

// 先填充缓存，再在原对象上编辑公式、嵌套区间及输入约束。
const edited = structuredClone(original);
checkAgainstFresh(edited);
edited.columns.find(column => column.key === "attackPower").formula.base += 5;
checkAgainstFresh(edited);
edited.columns.find(column => column.key === "nextLevelExperience").formula.power.ranges[0].fromValue += 0.1;
checkAgainstFresh(edited);
edited.input.max = 10;
checkAgainstFresh(edited);
edited.input.min = 2;
checkAgainstFresh(edited);
edited.input.rounding = "ceil";
checkAgainstFresh(edited);
edited.columns = edited.columns.filter(column => column.key !== "attackPower");
checkAgainstFresh(edited);
checkAgainstFresh(structuredClone(original));

// 经过 State 的关卡缓存，验证原地修改公式后实际读取的血量与单价。
const data = JSON.parse(fs.readFileSync(path.join(root, "Data/config.json"), "utf8"));
const config = Object.fromEntries(Object.entries(data).map(([key, value]) =>
  [key, value.kind === "number" ? value.value : value]));
// 仅隔离编辑器配置绑定，实际调用 State 的方法及缓存，不启动模拟器。
const state = Object.create(api.State.prototype);
Object.defineProperty(state, "config", { value: config });
state.challengeWorld = 1;
state.challengeStage = 5;
state.rebirthCount = 0;
function checkStateStages() {
  for (const [values, stageId] of [
    [state.getCurrentStageValues(), state.getCurrentGlobalStageId()],
    [state.getTargetStageValues(), Math.max(1, state.getHighestChallengeStageId())],
  ]) {
    assert.deepEqual(values, api.calculateStageCombatValues(config.stageCurves, config.levelCurves, stageId));
    checks++;
  }
}
checkStateStages();
const oldHp = state.getCurrentStageValues().grassHp;
config.levelCurves.columns.find(column => column.key === "attackPower").formula.base += 5;
checkStateStages();
assert.notEqual(state.getCurrentStageValues().grassHp, oldHp);
config.stageCurves.columns.find(column => column.key === "hpMultiplier").formula.base += 2;
checkStateStages();
config.stageCurves.columns.find(column => column.key === "expectedItemPrice").formula.base += 10;
checkStateStages();
config.levelCurves = structuredClone(original);
config.stageCurves = structuredClone(data.stageCurves);
checkStateStages();
// 已缓存的关卡也必须在降低等级上限后重新触发越界校验。
config.levelCurves.input.max = 10;
assert.throws(() => state.getCurrentStageValues(), /Curve.input.max/);
checks++;

// 最高可挑战关卡必须随原地编辑准入公式、输入约束和显示关卡范围刷新。
config.stageCurves = structuredClone(data.stageCurves);
const admission = config.stageCurves.columns.find(column => column.key === "expectedRebirthCount");
admission.formula = {
  kind: "Power", base: 0,
  multiplier: { kind: "constant", value: 0 },
  power: { kind: "constant", value: 1 },
  rounding: "floor",
};
config.stageCurves.editor.display.sampleRange.max = 3;
same(state.getHighestChallengeStageId(), 3);
admission.formula.base = 100;
same(state.getHighestChallengeStageId(), 0);
state.rebirthCount = 100;
same(state.getHighestChallengeStageId(), 3);
config.stageCurves.editor.display.sampleRange.max = 7;
same(state.getHighestChallengeStageId(), 7);
config.stageCurves.editor.display.sampleRange.max = 2;
same(state.getHighestChallengeStageId(), 2);
config.stageCurves.input.max = 1;
assert.throws(() => state.getHighestChallengeStageId(), /Curve.input.max/);
checks++;
config.stageCurves.input.max = 7;
same(state.getHighestChallengeStageId(), 2);
admission.formula.base = 0;
state.rebirthCount = 0;
same(state.getHighestChallengeStageId(), 2);
console.log(`Passed ${checks} checks.`);
