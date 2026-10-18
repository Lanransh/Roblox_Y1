import {
  type EditorRenderable,
  Game as BaseGame,
  numberToText,
  type SimulatorEditor,
  UIButton,
  UILabel,
  UIPanel,
} from "@game-simulator/framework";
import {
  type UpgradeMethod,
  CompleteRebirthRecoveryAction,
  PurchaseWeeklyCardAction,
  RebirthAction,
  SetAutoDiamondUpgradeAction,
  SetAutoModeAction,
  SwitchModeAction,
  UpgradeAuraAction,
  UpgradeBackpackAction,
  UpgradePaidTrainingMultiplierAction,
  UpgradeSickleAction,
} from "./Actions";
import { calculateItemSaleGold, calculateStageValues } from "./Formulas";
import type { ProjectConfig } from "./Main";
import type {
  AutoDiamondUpgradeTarget,
  GameMode,
  State,
  WeeklyCardType,
} from "./State";

type DueEquipmentUpgrade = {
  type: "sickle" | "aura";
  name: string;
  purchasePrice: number;
};

export class Game extends BaseGame<ProjectConfig, State> implements EditorRenderable {
  readonly UIRoot: UIPanel;
  private readonly sickleLevelLabel: UILabel;
  private readonly sickleMultiplierLabel: UILabel;
  private readonly sickleNextPriceLabel: UILabel;
  private readonly sickleUpgradeButton: UIButton;
  private readonly auraLevelLabel: UILabel;
  private readonly auraMultiplierLabel: UILabel;
  private readonly auraUpgradeButton: UIButton;
  private readonly levelValueLabel: UILabel;
  private readonly strengthValueLabel: UILabel;
  private readonly trainingValueLabel: UILabel;
  private readonly trainingPerSecondLabel: UILabel;
  private readonly goldSummaryLabel: UILabel;
  private readonly totalTrainingMultiplierLabel: UILabel;
  private readonly totalGoldMultiplierLabel: UILabel;
  private readonly totalBackpackCapacityLabel: UILabel;
  private readonly modeStatusLabel: UILabel;
  private readonly modeSwitchButton: UIButton;
  private readonly autoModeButton: UIButton;
  private readonly equipmentUnlockHintPanel: UIPanel;
  private readonly equipmentUnlockHintLabel: UILabel;
  private readonly challengeStageLabel: UILabel;
  private readonly challengeProgressLabel: UILabel;
  private readonly itemCountLabel: UILabel;
  private readonly challengeGoldLabel: UILabel;
  private readonly goldValueLabel: UILabel;
  private readonly rebirthSummaryLabel: UILabel;
  private readonly rebirthTrainingLabel: UILabel;
  private readonly rebirthGoldLabel: UILabel;
  private readonly rebirthCatchUpLabel: UILabel;
  private readonly rebirthFieldLabel: UILabel;
  private readonly rebirthButton: UIButton;
  private readonly paidMultiplierSummaryLabel: UILabel;
  private readonly paidTrainingMultiplierLabel: UILabel;
  private readonly paidTrainingDiamondButton: UIButton;
  private readonly paidTrainingPurchaseButton: UIButton;
  private readonly backpackExpansionLabel: UILabel;
  private readonly backpackDiamondButton: UIButton;
  private readonly backpackPurchaseButton: UIButton;
  private readonly smallWeeklyCardLabel: UILabel;
  private readonly smallWeeklyCardDetailsLabel: UILabel;
  private readonly smallWeeklyCardPurchaseButton: UIButton;
  private readonly largeWeeklyCardLabel: UILabel;
  private readonly largeWeeklyCardDetailsLabel: UILabel;
  private readonly largeWeeklyCardPurchaseButton: UIButton;
  // 配置工作台会替换顶层曲线值；状态键或相关配置值变化时缓存自动失效。
  private dueEquipmentUpgradeCache: {
    sickleCurves: ProjectConfig["sickleCurves"];
    auraCurves: ProjectConfig["auraCurves"];
    stageCurves: ProjectConfig["stageCurves"];
    rebirthCurves: ProjectConfig["rebirthCurves"];
    rebirthCount: number;
    sickleId: number;
    auraId: number;
    upgrades: DueEquipmentUpgrade[];
  } | null = null;
  private nextRebirthRequiredLevelCache: {
    rebirthCurves: ProjectConfig["rebirthCurves"];
    rebirthCount: number;
    requiredLevel: number;
  } | null = null;
  private autoPaidTrainingUpgradeBlockCache: {
    curves: ProjectConfig["paidTrainingMultiplierCurves"];
    diamonds: number;
    paidTrainingMultiplierId: number;
  } | null = null;
  private autoBackpackUpgradeBlockCache: {
    curves: ProjectConfig["backpackExpansionCurves"];
    diamonds: number;
    backpackExpansionLevel: number;
  } | null = null;

  constructor() {
    super();
    this.UIRoot = new UIPanel({
      Name: "GameRoot",
      Width: 1112,
      Height: 888,
      BackgroundColor: "transparent",
      BorderColor: "transparent",
    });

    const titlePanel = new UIPanel(this.UIRoot, {
      Name: "BasicAttributesHeader",
      Y: 0,
      Width: 736,
      Height: 36,
      BackgroundColor: "#f8f9fc",
      BorderColor: "#e4e7ec",
    });
    new UIPanel(titlePanel, {
      Name: "BasicAttributesAccent",
      Width: 4,
      Height: 36,
      BackgroundColor: "#6172f3",
      BorderColor: "#6172f3",
    });
    const titleLabel = new UILabel(titlePanel, {
      Name: "BasicAttributesTitle",
      X: 16,
      Width: 704,
      Height: 36,
      Text: "<b>角色成长</b>",
      FontSize: 17,
      TextWrap: false,
      HorizontalAlign: "Left",
      TextColor: "#27315f",
    });
    titleLabel.RichText = true;

    const attributesPanel = new UIPanel(this.UIRoot, {
      Name: "BasicAttributesPanel",
      Y: 44,
      Width: 360,
      Height: 164,
      BackgroundColor: "#ffffff",
      BorderColor: "#e4e7ec",
    });

    const createRow = (
      name: string,
      title: string,
      y: number,
      showDivider: boolean,
    ): UILabel => {
      new UILabel(attributesPanel, {
        Name: `${name}Title`,
        X: 20,
        Y: y,
        Width: 120,
        Height: 32,
        Text: `${title}：`,
        FontSize: 15,
        TextWrap: false,
        HorizontalAlign: "Left",
        TextColor: "#475467",
      });
      if (showDivider) {
        new UIPanel(attributesPanel, {
          Name: `${name}Divider`,
          X: 20,
          Y: y + 31,
          Width: 320,
          Height: 1,
          BackgroundColor: "#eaecf0",
          BorderColor: "#eaecf0",
        });
      }
      const valueLabel = new UILabel(attributesPanel, {
        Name: `${name}Value`,
        X: 140,
        Y: y,
        Width: 200,
        Height: 32,
        FontSize: 16,
        TextWrap: false,
        HorizontalAlign: "Right",
        TextColor: "#101828",
      });
      valueLabel.RichText = true;
      return valueLabel;
    };

    this.levelValueLabel = createRow("Level", "等级", 2, true);
    this.strengthValueLabel = createRow("Strength", "力量", 42, true);
    this.trainingValueLabel = createRow("Training", "当前训练值", 82, true);
    this.trainingPerSecondLabel = createRow(
      "TrainingPerSecond",
      "每秒训练值",
      122,
      false,
    );

    const summaryPanel = new UIPanel(this.UIRoot, {
      Name: "CharacterSummaryPanel",
      X: 376,
      Y: 44,
      Width: 360,
      Height: 164,
      BackgroundColor: "#ffffff",
      BorderColor: "#e4e7ec",
    });
    const createSummaryRow = (
      name: string,
      title: string,
      y: number,
      showDivider: boolean,
    ): UILabel => {
      new UILabel(summaryPanel, {
        Name: `${name}Title`,
        X: 20,
        Y: y,
        Width: 140,
        Height: 32,
        Text: `${title}：`,
        FontSize: 15,
        TextWrap: false,
        HorizontalAlign: "Left",
        TextColor: "#475467",
      });
      if (showDivider) {
        new UIPanel(summaryPanel, {
          Name: `${name}Divider`,
          X: 20,
          Y: y + 31,
          Width: 320,
          Height: 1,
          BackgroundColor: "#eaecf0",
          BorderColor: "#eaecf0",
        });
      }
      const valueLabel = new UILabel(summaryPanel, {
        Name: `${name}Value`,
        X: 160,
        Y: y,
        Width: 180,
        Height: 32,
        FontSize: 16,
        TextWrap: false,
        HorizontalAlign: "Right",
        TextColor: "#101828",
      });
      valueLabel.RichText = true;
      return valueLabel;
    };

    this.goldSummaryLabel = createSummaryRow("GoldSummary", "金币数量", 2, true);
    this.totalTrainingMultiplierLabel = createSummaryRow(
      "TotalTrainingMultiplier",
      "总训练倍率",
      42,
      true,
    );
    this.totalGoldMultiplierLabel = createSummaryRow(
      "TotalGoldMultiplier",
      "总金币倍率",
      82,
      true,
    );
    this.totalBackpackCapacityLabel = createSummaryRow(
      "TotalBackpackCapacity",
      "总背包容量",
      122,
      false,
    );

    this.modeStatusLabel = new UILabel(this.UIRoot, {
      Name: "ModeStatusLabel",
      X: 20,
      Y: 432,
      Width: 300,
      Height: 32,
      FontSize: 16,
      TextWrap: false,
      HorizontalAlign: "Left",
    });
    this.modeStatusLabel.RichText = true;
    this.modeSwitchButton = new UIButton(this.UIRoot, {
      Name: "ModeSwitchButton",
      X: 20,
      Y: 476,
      Width: 170,
      Height: 44,
      FontSize: 16,
      TextWrap: false,
    });
    this.modeSwitchButton.OnClick = () =>
      this.switchMode(
        this.state.mode === "training" ? "challenge" : "training",
      );
    this.autoModeButton = new UIButton(this.UIRoot, {
      Name: "AutoModeButton",
      X: 202,
      Y: 476,
      Width: 190,
      Height: 44,
      FontSize: 16,
      TextWrap: false,
    });
    this.autoModeButton.OnClick = () =>
      this.setAutoMode(!this.state.autoModeEnabled);

    const challengeHeader = new UIPanel(this.UIRoot, {
      Name: "ChallengeHeader",
      X: 752,
      Y: 0,
      Width: 360,
      Height: 36,
      BackgroundColor: "#f8f9fc",
      BorderColor: "#e4e7ec",
    });
    new UIPanel(challengeHeader, {
      Name: "ChallengeAccent",
      Width: 4,
      Height: 36,
      BackgroundColor: "#12b76a",
      BorderColor: "#12b76a",
    });
    const challengeTitle = new UILabel(challengeHeader, {
      Name: "ChallengeTitle",
      X: 16,
      Width: 328,
      Height: 36,
      Text: "<b>闯关进度</b>",
      FontSize: 17,
      TextWrap: false,
      HorizontalAlign: "Left",
      TextColor: "#05603a",
    });
    challengeTitle.RichText = true;

    const challengePanel = new UIPanel(this.UIRoot, {
      Name: "ChallengePanel",
      X: 752,
      Y: 44,
      Width: 360,
      Height: 164,
      BackgroundColor: "#ffffff",
      BorderColor: "#e4e7ec",
    });
    const createChallengeRow = (
      name: string,
      title: string,
      y: number,
    ): UILabel => {
      new UILabel(challengePanel, {
        Name: `${name}Title`,
        X: 20,
        Y: y,
        Width: 90,
        Height: 32,
        Text: `${title}：`,
        FontSize: 14,
        TextWrap: false,
        HorizontalAlign: "Left",
        TextColor: "#475467",
      });
      const valueLabel = new UILabel(challengePanel, {
        Name: `${name}Value`,
        X: 110,
        Y: y,
        Width: 230,
        Height: 32,
        FontSize: 14,
        TextWrap: false,
        HorizontalAlign: "Right",
        TextColor: "#101828",
      });
      valueLabel.RichText = true;
      return valueLabel;
    };

    this.challengeStageLabel = createChallengeRow("ChallengeStage", "位置", 2);
    this.challengeProgressLabel = createChallengeRow(
      "ChallengeProgress",
      "进度",
      34,
    );
    this.itemCountLabel = createChallengeRow("ItemCount", "背包", 66);
    this.challengeGoldLabel = createChallengeRow(
      "ChallengeGold",
      "本轮金币",
      98,
    );
    this.goldValueLabel = createChallengeRow("Gold", "持有金币", 130);

    const rebirthHeader = new UIPanel(this.UIRoot, {
      Name: "RebirthHeader",
      X: 0,
      Y: 220,
      Width: 400,
      Height: 36,
      BackgroundColor: "#f8f9fc",
      BorderColor: "#e4e7ec",
    });
    new UIPanel(rebirthHeader, {
      Name: "RebirthAccent",
      Width: 4,
      Height: 36,
      BackgroundColor: "#7f56d9",
      BorderColor: "#7f56d9",
    });
    const rebirthTitle = new UILabel(rebirthHeader, {
      Name: "RebirthTitle",
      X: 16,
      Width: 368,
      Height: 36,
      Text: "<b>重生增益</b>",
      FontSize: 17,
      TextWrap: false,
      HorizontalAlign: "Left",
      TextColor: "#53389e",
    });
    rebirthTitle.RichText = true;

    const rebirthPanel = new UIPanel(this.UIRoot, {
      Name: "RebirthPanel",
      X: 0,
      Y: 264,
      Width: 400,
      Height: 168,
      BackgroundColor: "#ffffff",
      BorderColor: "#e4e7ec",
    });
    const createRebirthRow = (
      name: string,
      title: string,
      y: number,
    ): UILabel => {
      new UILabel(rebirthPanel, {
        Name: `${name}Title`,
        X: 20,
        Y: y,
        Width: 110,
        Height: 25,
        Text: `${title}：`,
        FontSize: 14,
        TextWrap: false,
        HorizontalAlign: "Left",
        TextColor: "#475467",
      });
      const valueLabel = new UILabel(rebirthPanel, {
        Name: `${name}Value`,
        X: 130,
        Y: y,
        Width: 250,
        Height: 25,
        FontSize: 14,
        TextWrap: false,
        HorizontalAlign: "Right",
        TextColor: "#101828",
      });
      valueLabel.RichText = true;
      return valueLabel;
    };

    this.rebirthSummaryLabel = createRebirthRow(
      "RebirthSummary",
      "重生次数",
      0,
    );
    this.rebirthTrainingLabel = createRebirthRow(
      "RebirthTraining",
      "训练倍率",
      25,
    );
    this.rebirthGoldLabel = createRebirthRow(
      "RebirthGold",
      "金币倍率",
      50,
    );
    this.rebirthCatchUpLabel = createRebirthRow(
      "RebirthCatchUp",
      "追赶倍率",
      75,
    );
    this.rebirthFieldLabel = createRebirthRow(
      "RebirthField",
      "场地倍率",
      100,
    );

    this.rebirthButton = new UIButton(rebirthPanel, {
      Name: "RebirthButton",
      X: 20,
      Y: 125,
      Width: 360,
      Height: 32,
      FontSize: 14,
      TextWrap: false,
    });
    this.rebirthButton.OnClick = ({ editor }) => this.rebirth(editor);

    const paidMultiplierHeader = new UIPanel(this.UIRoot, {
      Name: "PaidMultiplierHeader",
      X: 0,
      Y: 540,
      Width: 1112,
      Height: 36,
      BackgroundColor: "#fffaeb",
      BorderColor: "#e4e7ec",
    });
    new UIPanel(paidMultiplierHeader, {
      Name: "PaidMultiplierAccent",
      Width: 4,
      Height: 36,
      BackgroundColor: "#f79009",
      BorderColor: "#f79009",
    });
    this.paidMultiplierSummaryLabel = new UILabel(paidMultiplierHeader, {
      Name: "PaidMultiplierSummary",
      X: 16,
      Width: 1080,
      Height: 36,
      FontSize: 14,
      TextWrap: false,
      HorizontalAlign: "Left",
      TextColor: "#93370d",
    });
    this.paidMultiplierSummaryLabel.RichText = true;

    const createUpgradeCard = (
      name: string,
      title: string,
      x: number,
      onDiamond: () => void,
      onPaid: () => void,
    ) => {
      const panel = new UIPanel(this.UIRoot, {
        Name: `${name}Card`,
        X: x,
        Y: 584,
        Width: 360,
        Height: 100,
        BackgroundColor: "#ffffff",
        BorderColor: "#e4e7ec",
      });
      new UILabel(panel, {
        Name: `${name}Title`,
        X: 16,
        Y: 4,
        Width: 144,
        Height: 32,
        Text: title,
        FontSize: 14,
        TextWrap: false,
        HorizontalAlign: "Left",
        TextColor: "#475467",
      });
      const valueLabel = new UILabel(panel, {
        Name: `${name}Value`,
        X: 160,
        Y: 4,
        Width: 184,
        Height: 32,
        FontSize: 14,
        TextWrap: false,
        HorizontalAlign: "Right",
        TextColor: "#b54708",
      });
      valueLabel.RichText = true;

      const diamondButton = new UIButton(panel, {
        Name: `${name}DiamondButton`,
        X: 16,
        Y: 48,
        Width: 156,
        Height: 32,
        FontSize: 13,
        TextWrap: false,
      });
      diamondButton.OnClick = onDiamond;

      const purchaseButton = new UIButton(panel, {
        Name: `${name}PurchaseButton`,
        X: 188,
        Y: 48,
        Width: 156,
        Height: 32,
        Text: "付费提升",
        FontSize: 13,
        TextWrap: false,
      });
      purchaseButton.OnClick = onPaid;
      return { valueLabel, diamondButton, purchaseButton };
    };

    const paidTrainingCard = createUpgradeCard(
      "PaidTrainingMultiplier",
      "付费训练倍率",
      0,
      () => this.toggleAutoDiamondUpgrade("paidTrainingMultiplier"),
      () => this.upgradePaidTrainingMultiplier("paid"),
    );
    this.paidTrainingMultiplierLabel = paidTrainingCard.valueLabel;
    this.paidTrainingDiamondButton = paidTrainingCard.diamondButton;
    this.paidTrainingPurchaseButton = paidTrainingCard.purchaseButton;

    const backpackCard = createUpgradeCard(
      "BackpackExpansion",
      "背包扩容",
      376,
      () => this.toggleAutoDiamondUpgrade("backpack"),
      () => this.upgradeBackpack("paid"),
    );
    this.backpackExpansionLabel = backpackCard.valueLabel;
    this.backpackDiamondButton = backpackCard.diamondButton;
    this.backpackPurchaseButton = backpackCard.purchaseButton;

    const weeklyCardHeader = new UIPanel(this.UIRoot, {
      Name: "WeeklyCardHeader",
      X: 0,
      Y: 704,
      Width: 1112,
      Height: 36,
      BackgroundColor: "#fff6ed",
      BorderColor: "#e4e7ec",
    });
    new UIPanel(weeklyCardHeader, {
      Name: "WeeklyCardAccent",
      Width: 4,
      Height: 36,
      BackgroundColor: "#f79009",
      BorderColor: "#f79009",
    });
    const weeklyCardTitle = new UILabel(weeklyCardHeader, {
      Name: "WeeklyCardTitle",
      X: 16,
      Width: 1080,
      Height: 36,
      Text: "<b>周卡付费</b> · 购买当天领取立即奖励与第 1 天每日奖励",
      FontSize: 14,
      TextWrap: false,
      HorizontalAlign: "Left",
      TextColor: "#93370d",
    });
    weeklyCardTitle.RichText = true;

    const createWeeklyCard = (
      name: string,
      title: string,
      x: number,
      onPurchase: () => void,
    ) => {
      const panel = new UIPanel(this.UIRoot, {
        Name: `${name}Card`,
        X: x,
        Y: 748,
        Width: 360,
        Height: 120,
        BackgroundColor: "#ffffff",
        BorderColor: "#e4e7ec",
      });
      new UILabel(panel, {
        Name: `${name}Title`,
        X: 16,
        Y: 4,
        Width: 96,
        Height: 28,
        Text: title,
        FontSize: 14,
        TextWrap: false,
        HorizontalAlign: "Left",
        TextColor: "#475467",
      });
      const valueLabel = new UILabel(panel, {
        Name: `${name}Value`,
        X: 112,
        Y: 4,
        Width: 232,
        Height: 28,
        FontSize: 13,
        TextWrap: false,
        HorizontalAlign: "Right",
        TextColor: "#b54708",
      });
      valueLabel.RichText = true;
      const detailsLabel = new UILabel(panel, {
        Name: `${name}Details`,
        X: 16,
        Y: 32,
        Width: 328,
        Height: 28,
        FontSize: 12,
        TextWrap: false,
        HorizontalAlign: "Left",
        TextColor: "#667085",
      });
      const purchaseButton = new UIButton(panel, {
        Name: `${name}PurchaseButton`,
        X: 16,
        Y: 72,
        Width: 328,
        Height: 32,
        FontSize: 13,
        TextWrap: false,
      });
      purchaseButton.OnClick = onPurchase;
      return { valueLabel, detailsLabel, purchaseButton };
    };

    const smallWeeklyCard = createWeeklyCard(
      "SmallWeeklyCard",
      "小周卡",
      0,
      () => this.purchaseWeeklyCard("small"),
    );
    this.smallWeeklyCardLabel = smallWeeklyCard.valueLabel;
    this.smallWeeklyCardDetailsLabel = smallWeeklyCard.detailsLabel;
    this.smallWeeklyCardPurchaseButton = smallWeeklyCard.purchaseButton;

    const largeWeeklyCard = createWeeklyCard(
      "LargeWeeklyCard",
      "大周卡",
      376,
      () => this.purchaseWeeklyCard("large"),
    );
    this.largeWeeklyCardLabel = largeWeeklyCard.valueLabel;
    this.largeWeeklyCardDetailsLabel = largeWeeklyCard.detailsLabel;
    this.largeWeeklyCardPurchaseButton = largeWeeklyCard.purchaseButton;

    const auraHeader = new UIPanel(this.UIRoot, {
      Name: "AuraHeader",
      X: 412,
      Y: 220,
      Width: 400,
      Height: 36,
      BackgroundColor: "#f4f3ff",
      BorderColor: "#e4e7ec",
    });
    new UIPanel(auraHeader, {
      Name: "AuraAccent",
      Width: 4,
      Height: 36,
      BackgroundColor: "#875bf7",
      BorderColor: "#875bf7",
    });
    const auraTitle = new UILabel(auraHeader, {
      Name: "AuraTitle",
      X: 16,
      Width: 368,
      Height: 36,
      Text: "<b>光环成长</b>",
      FontSize: 17,
      TextWrap: false,
      HorizontalAlign: "Left",
      TextColor: "#5925dc",
    });
    auraTitle.RichText = true;

    const auraPanel = new UIPanel(this.UIRoot, {
      Name: "AuraPanel",
      X: 412,
      Y: 264,
      Width: 400,
      Height: 164,
      BackgroundColor: "#ffffff",
      BorderColor: "#e4e7ec",
    });
    new UILabel(auraPanel, {
      Name: "AuraLevelTitle",
      X: 20,
      Y: 8,
      Width: 110,
      Height: 40,
      Text: "当前等级：",
      FontSize: 15,
      TextWrap: false,
      HorizontalAlign: "Left",
      TextColor: "#475467",
    });
    this.auraLevelLabel = new UILabel(auraPanel, {
      Name: "AuraLevelValue",
      X: 130,
      Y: 8,
      Width: 250,
      Height: 40,
      FontSize: 16,
      TextWrap: false,
      HorizontalAlign: "Right",
      TextColor: "#101828",
    });
    this.auraLevelLabel.RichText = true;
    new UILabel(auraPanel, {
      Name: "AuraMultiplierTitle",
      X: 20,
      Y: 52,
      Width: 110,
      Height: 40,
      Text: "光环倍率：",
      FontSize: 15,
      TextWrap: false,
      HorizontalAlign: "Left",
      TextColor: "#475467",
    });
    this.auraMultiplierLabel = new UILabel(auraPanel, {
      Name: "AuraMultiplierValue",
      X: 130,
      Y: 52,
      Width: 250,
      Height: 40,
      FontSize: 16,
      TextWrap: false,
      HorizontalAlign: "Right",
      TextColor: "#5925dc",
    });
    this.auraMultiplierLabel.RichText = true;
    this.auraUpgradeButton = new UIButton(auraPanel, {
      Name: "AuraUpgradeButton",
      X: 20,
      Y: 108,
      Width: 360,
      Height: 36,
      FontSize: 14,
      TextWrap: false,
    });
    this.auraUpgradeButton.OnClick = () => this.upgradeAura();

    const sickleHeader = new UIPanel(this.UIRoot, {
      Name: "SickleHeader",
      X: 824,
      Y: 220,
      Width: 288,
      Height: 36,
      BackgroundColor: "#f8f9fc",
      BorderColor: "#e4e7ec",
    });
    new UIPanel(sickleHeader, {
      Name: "SickleAccent",
      Width: 4,
      Height: 36,
      BackgroundColor: "#6172f3",
      BorderColor: "#6172f3",
    });
    const sickleTitle = new UILabel(sickleHeader, {
      Name: "SickleTitle",
      X: 16,
      Width: 256,
      Height: 36,
      Text: "<b>镰刀成长</b>",
      FontSize: 17,
      TextWrap: false,
      HorizontalAlign: "Left",
      TextColor: "#27315f",
    });
    sickleTitle.RichText = true;

    const sicklePanel = new UIPanel(this.UIRoot, {
      Name: "SicklePanel",
      X: 824,
      Y: 264,
      Width: 288,
      Height: 208,
      BackgroundColor: "#ffffff",
      BorderColor: "#e4e7ec",
    });
    new UILabel(sicklePanel, {
      Name: "SickleLevelTitle",
      X: 20,
      Y: 8,
      Width: 110,
      Height: 32,
      Text: "当前等级：",
      FontSize: 15,
      TextWrap: false,
      HorizontalAlign: "Left",
      TextColor: "#475467",
    });
    this.sickleLevelLabel = new UILabel(sicklePanel, {
      Name: "SickleLevelValue",
      X: 130,
      Y: 8,
      Width: 138,
      Height: 32,
      FontSize: 16,
      TextWrap: false,
      HorizontalAlign: "Right",
      TextColor: "#101828",
    });
    this.sickleLevelLabel.RichText = true;
    new UILabel(sicklePanel, {
      Name: "SickleMultiplierTitle",
      X: 20,
      Y: 48,
      Width: 110,
      Height: 32,
      Text: "镰刀倍率：",
      FontSize: 15,
      TextWrap: false,
      HorizontalAlign: "Left",
      TextColor: "#475467",
    });
    this.sickleMultiplierLabel = new UILabel(sicklePanel, {
      Name: "SickleMultiplierValue",
      X: 130,
      Y: 48,
      Width: 138,
      Height: 32,
      FontSize: 16,
      TextWrap: false,
      HorizontalAlign: "Right",
      TextColor: "#445bd8",
    });
    this.sickleMultiplierLabel.RichText = true;
    new UILabel(sicklePanel, {
      Name: "SickleNextPriceTitle",
      X: 20,
      Y: 88,
      Width: 110,
      Height: 32,
      Text: "下一级价格：",
      FontSize: 15,
      TextWrap: false,
      HorizontalAlign: "Left",
      TextColor: "#475467",
    });
    this.sickleNextPriceLabel = new UILabel(sicklePanel, {
      Name: "SickleNextPriceValue",
      X: 130,
      Y: 88,
      Width: 138,
      Height: 32,
      FontSize: 16,
      TextWrap: false,
      HorizontalAlign: "Right",
      TextColor: "#b54708",
    });
    this.sickleNextPriceLabel.RichText = true;
    this.sickleUpgradeButton = new UIButton(sicklePanel, {
      Name: "SickleUpgradeButton",
      X: 20,
      Y: 152,
      Width: 248,
      Height: 36,
      FontSize: 14,
      TextWrap: false,
    });
    this.sickleUpgradeButton.OnClick = () => this.upgradeSickle();

    this.equipmentUnlockHintPanel = new UIPanel(this.UIRoot, {
      Name: "EquipmentUnlockHintPanel",
      X: 412,
      Y: 480,
      Width: 700,
      Height: 40,
      BackgroundColor: "#ecfdf3",
      BorderColor: "#abefc6",
    });
    new UIPanel(this.equipmentUnlockHintPanel, {
      Name: "EquipmentUnlockHintAccent",
      Width: 4,
      Height: 40,
      BackgroundColor: "#12b76a",
      BorderColor: "#12b76a",
    });
    this.equipmentUnlockHintLabel = new UILabel(this.equipmentUnlockHintPanel, {
      Name: "EquipmentUnlockHintLabel",
      X: 16,
      Width: 668,
      Height: 40,
      FontSize: 14,
      TextWrap: false,
      HorizontalAlign: "Left",
      TextColor: "#05603a",
    });
    this.equipmentUnlockHintLabel.RichText = true;

    this.UpdateUI();
  }

  BuildEditorUI(): void {
    this.UpdateUI();
  }

  advanceOneSecond(): void {
    if (this.state.isRebirthRecoveryComplete()) {
      this.consumeAction(
        new CompleteRebirthRecoveryAction(this.UIRoot.getEditor()),
        ["已回到上一次重生要求等级。"],
      );
    }

    this.advanceAutoDiamondUpgrades();

    if (!this.state.autoModeEnabled) {
      return;
    }

    let dueEquipmentUpgrades: DueEquipmentUpgrade[];
    while (true) {
      dueEquipmentUpgrades = this.getDueEquipmentUpgrades();
      let affordableUpgrade: DueEquipmentUpgrade | undefined;
      for (const upgrade of dueEquipmentUpgrades) {
        if (
          !(this.state.gold < upgrade.purchasePrice) &&
          (!affordableUpgrade ||
            upgrade.purchasePrice < affordableUpgrade.purchasePrice)
        ) {
          affordableUpgrade = upgrade;
        }
      }
      if (!affordableUpgrade) {
        break;
      }
      const action =
        affordableUpgrade.type === "sickle"
          ? new UpgradeSickleAction()
          : new UpgradeAuraAction();
      if (
        !this.consumeAction(action, [
          `自动购买下一等级${affordableUpgrade.name}。`,
        ])
      ) {
        break;
      }
    }

    if (
      this.state.rebirthCount < this.config.rebirthCurves.input.max &&
      !(this.state.level < this.getNextRebirthRequiredLevel())
    ) {
      this.consumeAction(new RebirthAction(this.UIRoot.getEditor()), [
        "自动执行重生。",
      ]);
      return;
    }

    if (dueEquipmentUpgrades.length > 0) {
      this.switchModeAutomatically("challenge");
      return;
    }

    this.switchModeAutomatically("training");
  }

  UpdateUI(): void {
    const required = this.state.getNextLevelExperience();
    const trainingPerSecond =
      this.state.getTrainingValuePerSettlement() *
      this.config.trainingSettlementsPerSecond;
    const currentSickle = this.state.getSickleValues();
    const nextSickle = this.state.getNextSickleValues();
    const sickleBlocked =
      this.getActionBlocker(new UpgradeSickleAction()) !== null;
    this.sickleLevelLabel.Text = `<b>${numberToText(this.state.sickleId)} 级</b>`;
    this.sickleMultiplierLabel.Text = `<b>×${numberToText(currentSickle.trainingValueMultiplier)}</b>`;
    this.sickleNextPriceLabel.Text = this.state.isSickleMaxed()
      ? `<span color="#98a2b3">已达最高级</span>`
      : `<b>${numberToText(nextSickle.purchasePrice)} 金币</b>`;
    this.sickleUpgradeButton.Text = this.state.isSickleMaxed()
      ? "已达最高级"
      : "升级镰刀";
    this.sickleUpgradeButton.Disabled = sickleBlocked;
    this.sickleUpgradeButton.ButtonColor = sickleBlocked
      ? "#eef2f6"
      : "#445bd8";
    this.sickleUpgradeButton.TextColor = sickleBlocked
      ? "#98a2b3"
      : "#ffffff";
    const currentAura = this.state.getAuraValues();
    const auraBlocked =
      this.getActionBlocker(new UpgradeAuraAction()) !== null;
    this.auraLevelLabel.Text = this.state.auraId === 0
      ? "<b>未解锁</b>"
      : `<b>${numberToText(this.state.auraId)} 级</b>`;
    this.auraMultiplierLabel.Text = `<b>×${numberToText(currentAura.multiplier)}</b>`;
    this.auraUpgradeButton.Text = this.state.isAuraMaxed()
      ? "已达最高级"
      : `${this.state.auraId === 0 ? "解锁" : "升级"}光环（${numberToText(this.state.getNextAuraValues().purchasePrice)} 金币）`;
    this.auraUpgradeButton.Disabled = auraBlocked;
    this.auraUpgradeButton.ButtonColor = auraBlocked ? "#eef2f6" : "#875bf7";
    this.auraUpgradeButton.TextColor = auraBlocked ? "#98a2b3" : "#ffffff";
    const availableEquipmentTargets = this.getDueEquipmentUpgrades();
    this.equipmentUnlockHintPanel.Visible =
      availableEquipmentTargets.length > 0;
    if (availableEquipmentTargets.length > 0) {
      const targetText = availableEquipmentTargets
        .map(({ name }) => name)
        .join("、");
      this.equipmentUnlockHintLabel.Text =
        `<b>当前重生阶段还有未解锁的${targetText}</b>` +
        ` · 建议闯关刷金币`;
    }
    this.levelValueLabel.Text =
      `<span color="#445bd8"><b>${numberToText(this.state.level)}</b></span>`;
    this.strengthValueLabel.Text = `<b>${numberToText(this.state.strength)}</b>`;
    this.trainingValueLabel.Text =
      `<b>${numberToText(this.state.trainingValue)}</b>` +
      `<span color="#98a2b3"> / ${numberToText(required)}</span>`;
    this.trainingPerSecondLabel.Text =
      `<span color="#027a48"><b>+${numberToText(trainingPerSecond)}</b> / 秒</span>` +
      (this.state.mode === "challenge"
        ? `<span color="#98a2b3"> · 闯关不享受场地加成</span>`
        : "");
    this.goldSummaryLabel.Text =
      `<span color="#b54708"><b>${numberToText(this.state.gold)}</b></span>`;
    this.totalTrainingMultiplierLabel.Text =
      `<span color="#027a48"><b>×${numberToText(this.state.getTotalTrainingMultiplier())}</b></span>`;
    this.totalGoldMultiplierLabel.Text =
      `<span color="#b54708"><b>×${numberToText(this.state.getTotalGoldMultiplier())}</b></span>`;
    this.totalBackpackCapacityLabel.Text =
      `<span color="#445bd8"><b>${numberToText(this.state.getBackpackCapacity())} 格</b></span>`;

    const isTrainingMode = this.state.mode === "training";
    const modeSwitchAction = new SwitchModeAction(
      isTrainingMode ? "challenge" : "training",
    );
    const modeSwitchBlocked = this.getActionBlocker(modeSwitchAction) !== null;
    this.modeStatusLabel.Text = `<b>当前模式：${isTrainingMode ? "训练模式" : "闯关模式"}</b>`;
    this.modeStatusLabel.TextColor = isTrainingMode ? "#27315f" : "#05603a";
    this.modeSwitchButton.Text = this.state.autoModeEnabled
      ? "自动模式管理中"
      : modeSwitchBlocked
        ? `完成 ${numberToText(this.state.getTargetStageValues().expectedRebirthCount)} 次重生后可闯关`
        : isTrainingMode
          ? "切换到闯关模式"
          : "切换到训练模式";
    this.modeSwitchButton.Disabled =
      this.state.autoModeEnabled || modeSwitchBlocked;
    this.modeSwitchButton.ButtonColor = this.modeSwitchButton.Disabled
      ? "#eef2f6"
      : isTrainingMode
        ? "#039855"
        : "#445bd8";
    this.modeSwitchButton.TextColor = this.modeSwitchButton.Disabled
      ? "#98a2b3"
      : "#ffffff";
    this.autoModeButton.Text = this.state.autoModeEnabled
      ? "关闭自动模式"
      : "开启自动模式";
    this.autoModeButton.ButtonColor = this.state.autoModeEnabled
      ? "#039855"
      : "#667085";
    this.autoModeButton.TextColor = "#ffffff";

    const lastStage = this.state.getChallengeLastStage();
    const targetStageValues = this.state.getTargetStageValues();
    if (this.state.mode === "training") {
      this.challengeStageLabel.Text =
        `<b>世界 ${numberToText(this.state.getChallengeWorld())}</b>` +
        ` · 第 1/${numberToText(lastStage)} 关（待开始）`;
      this.challengeProgressLabel.Text =
        `<span color="#98a2b3">切换到闯关模式后自动开始</span>`;
    } else {
      const stageValues = this.state.getCurrentStageValues();
      const phaseName =
        this.state.challengePhase === "outbound"
          ? this.state.strength >= stageValues.grassHp
            ? "轻松闯关"
            : "普通闯关"
          : "获取道具";
      this.challengeStageLabel.Text =
        `<b>世界 ${numberToText(this.state.challengeWorld)}</b>` +
        ` · 第 ${numberToText(this.state.challengeStage)}/${numberToText(lastStage)} 关`;
      this.challengeProgressLabel.Text =
        `<b>${phaseName}</b>` +
        ` · ${numberToText(this.state.challengeElapsedSeconds)}/${numberToText(this.state.getCurrentPhaseDuration())} 秒`;
    }
    this.itemCountLabel.Text =
      `<b>${numberToText(this.state.itemCount)}/${numberToText(this.state.getBackpackCapacity())}</b>` +
      `<span color="#98a2b3"> · 末关单价 ${numberToText(targetStageValues.expectedItemPrice)}</span>`;
    const challengeGold = calculateItemSaleGold(
      this.state.getBackpackCapacity(),
      targetStageValues.expectedItemPrice,
      this.state.getTotalGoldMultiplier(),
    );
    this.challengeGoldLabel.Text =
      `<span color="#027a48"><b>+${numberToText(challengeGold)}</b> / 轮</span>`;
    this.goldValueLabel.Text = `<span color="#b54708"><b>${numberToText(this.state.gold)}</b></span>`;

    const rebirthValues = this.state.getCurrentRebirthValues();
    const nextRebirthValues = this.state.getNextRebirthValues();
    const rebirthBlocked = this.getActionBlocker(new RebirthAction()) !== null;
    this.rebirthSummaryLabel.Text = `<b>${numberToText(this.state.rebirthCount)} 次</b>`;
    this.rebirthTrainingLabel.Text =
      `<span color="#6941c6"><b>×${numberToText(rebirthValues.trainingMultiplierReward)}</b></span>`;
    this.rebirthGoldLabel.Text =
      `<span color="#b54708"><b>×${numberToText(rebirthValues.goldMultiplierReward)}</b></span>`;
    this.rebirthCatchUpLabel.Text =
      `<span color="#027a48"><b>×${numberToText(this.state.getCurrentRebirthCatchUpMultiplier())}</b></span>` +
      `<span color="#98a2b3"> · 最高 ×${numberToText(rebirthValues.catchUpMultiplier)}</span>`;
    this.rebirthFieldLabel.Text =
      `<span color="#6941c6"><b>×${numberToText(this.state.getCurrentRebirthField().extraMultiplier)}</b></span>` +
      `<span color="#98a2b3"> · 仅训练生效</span>`;
    this.rebirthButton.Text = this.state.rebirthCount >= this.config.rebirthCurves.input.max
      ? "已达到重生次数上限"
      : rebirthBlocked
      ? `达到 ${numberToText(nextRebirthValues.requiredLevel)} 级后可重生`
      : `立即重生（要求 ${numberToText(nextRebirthValues.requiredLevel)} 级）`;
    this.rebirthButton.Disabled = rebirthBlocked;
    this.rebirthButton.ButtonColor = rebirthBlocked ? "#eef2f6" : "#7f56d9";
    this.rebirthButton.TextColor = rebirthBlocked ? "#98a2b3" : "#ffffff";

    const giftCountdown = this.formatDuration(
      this.state.getDiamondGiftRemainingSeconds(),
    );
    this.paidMultiplierSummaryLabel.Text =
      `<b>付费系统</b> · 训练倍率封顶 ×128` +
      ` · 钻石 <b>${numberToText(this.state.diamonds)}</b>` +
      ` · ${giftCountdown} 后赠送 ${numberToText(Math.max(0, Math.floor(this.config.dailyGiftDiamondAmount)))}`;
    this.updatePaidMultiplierCard(
      this.paidTrainingMultiplierLabel,
      this.paidTrainingDiamondButton,
      this.paidTrainingPurchaseButton,
    );
    this.updateBackpackExpansionCard();
    this.updateWeeklyCard(
      "small",
      this.smallWeeklyCardLabel,
      this.smallWeeklyCardDetailsLabel,
      this.smallWeeklyCardPurchaseButton,
    );
    this.updateWeeklyCard(
      "large",
      this.largeWeeklyCardLabel,
      this.largeWeeklyCardDetailsLabel,
      this.largeWeeklyCardPurchaseButton,
    );
  }

  switchMode(mode: GameMode): void {
    const action = new SwitchModeAction(mode);
    if (this.getActionBlocker(action)) {
      this.UpdateUI();
      return;
    }

    if (this.consumeAction(action, [`切换到${mode === "training" ? "训练" : "闯关"}模式。`])) {
      this.UpdateUI();
    }
  }

  setAutoMode(enabled: boolean): void {
    const action = new SetAutoModeAction(enabled);
    if (this.getActionBlocker(action)) {
      this.UpdateUI();
      return;
    }

    if (
      this.consumeAction(action, [
        `${enabled ? "开启" : "关闭"}自动模式。`,
      ])
    ) {
      if (enabled) {
        this.advanceOneSecond();
      }
      this.UpdateUI();
    }
  }

  rebirth(editor: SimulatorEditor): void {
    const action = new RebirthAction(editor);
    if (this.getActionBlocker(action)) {
      this.UpdateUI();
      return;
    }

    if (this.consumeAction(action, ["执行重生。"])) {
      this.UpdateUI();
    }
  }

  upgradeSickle(): void {
    const action = new UpgradeSickleAction();
    if (this.getActionBlocker(action)) {
      this.UpdateUI();
      return;
    }

    if (this.consumeAction(action, ["购买下一等级镰刀。"])) {
      this.UpdateUI();
    }
  }

  upgradeAura(): void {
    const action = new UpgradeAuraAction();
    if (this.getActionBlocker(action)) {
      this.UpdateUI();
      return;
    }

    if (this.consumeAction(action, ["购买下一等级光环。"])) {
      this.UpdateUI();
    }
  }

  upgradePaidTrainingMultiplier(method: UpgradeMethod): void {
    const action = new UpgradePaidTrainingMultiplierAction(method);
    if (this.getActionBlocker(action)) {
      this.UpdateUI();
      return;
    }

    const methodName = method === "diamond" ? "钻石" : "付费";
    if (this.consumeAction(action, [`使用${methodName}提升训练倍率。`])) {
      this.UpdateUI();
    }
  }

  toggleAutoDiamondUpgrade(target: AutoDiamondUpgradeTarget): void {
    const enabled =
      target === "paidTrainingMultiplier"
        ? !this.state.autoPaidTrainingUpgradeEnabled
        : !this.state.autoBackpackUpgradeEnabled;
    const action = new SetAutoDiamondUpgradeAction(target, enabled);
    if (this.getActionBlocker(action)) {
      this.UpdateUI();
      return;
    }

    const targetName =
      target === "paidTrainingMultiplier" ? "付费训练倍率" : "背包扩容";
    if (
      this.consumeAction(action, [
        `${enabled ? "开启" : "关闭"}${targetName}钻石自动升级。`,
      ])
    ) {
      this.UpdateUI();
    }
  }

  upgradeBackpack(method: UpgradeMethod): void {
    const action = new UpgradeBackpackAction(method);
    if (this.getActionBlocker(action)) {
      this.UpdateUI();
      return;
    }

    const methodName = method === "diamond" ? "钻石" : "付费";
    if (this.consumeAction(action, [`使用${methodName}扩容背包。`])) {
      this.UpdateUI();
    }
  }

  purchaseWeeklyCard(cardType: WeeklyCardType): void {
    const action = new PurchaseWeeklyCardAction(cardType);
    if (this.getActionBlocker(action)) {
      this.UpdateUI();
      return;
    }

    const cardName = cardType === "small" ? "小周卡" : "大周卡";
    if (this.consumeAction(action, [`购买${cardName}。`])) {
      this.UpdateUI();
    }
  }

  private getDueEquipmentUpgrades(): DueEquipmentUpgrade[] {
    const config = this.config;
    const cached = this.dueEquipmentUpgradeCache;
    if (
      cached &&
      cached.sickleCurves === config.sickleCurves &&
      cached.auraCurves === config.auraCurves &&
      cached.stageCurves === config.stageCurves &&
      cached.rebirthCurves === config.rebirthCurves &&
      cached.rebirthCount === this.state.rebirthCount &&
      cached.sickleId === this.state.sickleId &&
      cached.auraId === this.state.auraId
    ) {
      return cached.upgrades;
    }

    const upgrades: DueEquipmentUpgrade[] = [];

    if (!this.state.isSickleMaxed()) {
      const nextSickle = this.state.getNextSickleValues();
      const expectedRebirthCount = calculateStageValues(
        config.stageCurves,
        nextSickle.expectedStageId,
      ).expectedRebirthCount;
      if (expectedRebirthCount <= this.state.rebirthCount) {
        upgrades.push({
          type: "sickle",
          name: "镰刀",
          purchasePrice: nextSickle.purchasePrice,
        });
      }
    }

    if (!this.state.isAuraMaxed()) {
      const nextAura = this.state.getNextAuraValues();
      const expectedRebirthCount = calculateStageValues(
        config.stageCurves,
        nextAura.expectedStageId,
      ).expectedRebirthCount;
      if (expectedRebirthCount <= this.state.rebirthCount) {
        upgrades.push({
          type: "aura",
          name: "光环",
          purchasePrice: nextAura.purchasePrice,
        });
      }
    }

    this.dueEquipmentUpgradeCache = {
      sickleCurves: config.sickleCurves,
      auraCurves: config.auraCurves,
      stageCurves: config.stageCurves,
      rebirthCurves: config.rebirthCurves,
      rebirthCount: this.state.rebirthCount,
      sickleId: this.state.sickleId,
      auraId: this.state.auraId,
      upgrades,
    };
    return upgrades;
  }

  private getNextRebirthRequiredLevel(): number {
    const config = this.config;
    const cached = this.nextRebirthRequiredLevelCache;
    if (
      cached?.rebirthCurves === config.rebirthCurves &&
      cached.rebirthCount === this.state.rebirthCount
    ) {
      return cached.requiredLevel;
    }

    const requiredLevel = this.state.getNextRebirthValues().requiredLevel;
    this.nextRebirthRequiredLevelCache = {
      rebirthCurves: config.rebirthCurves,
      rebirthCount: this.state.rebirthCount,
      requiredLevel,
    };
    return requiredLevel;
  }

  private advanceAutoDiamondUpgrades(): void {
    while (
      this.state.autoPaidTrainingUpgradeEnabled &&
      !this.state.isPaidTrainingMultiplierMaxed()
    ) {
      const action = this.getAutoPaidTrainingUpgradeAction();
      if (!action) {
        break;
      }
      if (
        !this.consumeAction(action, ["自动使用钻石提升付费训练倍率。"])
      ) {
        break;
      }
    }

    while (
      this.state.autoBackpackUpgradeEnabled &&
      !this.state.isBackpackExpansionMaxed()
    ) {
      const action = this.getAutoBackpackUpgradeAction();
      if (!action) {
        break;
      }
      if (!this.consumeAction(action, ["自动使用钻石扩容背包。"])) {
        break;
      }
    }
  }

  private getAutoPaidTrainingUpgradeAction(): UpgradePaidTrainingMultiplierAction | null {
    const curves = this.config.paidTrainingMultiplierCurves;
    const cached = this.autoPaidTrainingUpgradeBlockCache;
    if (
      cached?.curves === curves &&
      cached.diamonds === this.state.diamonds &&
      cached.paidTrainingMultiplierId ===
        this.state.paidTrainingMultiplierId
    ) {
      return null;
    }

    const action = new UpgradePaidTrainingMultiplierAction("diamond");
    if (this.getActionBlocker(action)) {
      this.autoPaidTrainingUpgradeBlockCache = {
        curves,
        diamonds: this.state.diamonds,
        paidTrainingMultiplierId: this.state.paidTrainingMultiplierId,
      };
      return null;
    }
    return action;
  }

  private getAutoBackpackUpgradeAction(): UpgradeBackpackAction | null {
    const curves = this.config.backpackExpansionCurves;
    const cached = this.autoBackpackUpgradeBlockCache;
    if (
      cached?.curves === curves &&
      cached.diamonds === this.state.diamonds &&
      cached.backpackExpansionLevel === this.state.backpackExpansionLevel
    ) {
      return null;
    }

    const action = new UpgradeBackpackAction("diamond");
    if (this.getActionBlocker(action)) {
      this.autoBackpackUpgradeBlockCache = {
        curves,
        diamonds: this.state.diamonds,
        backpackExpansionLevel: this.state.backpackExpansionLevel,
      };
      return null;
    }
    return action;
  }

  private switchModeAutomatically(mode: GameMode): void {
    if (this.state.mode === mode) {
      return;
    }
    this.consumeAction(new SwitchModeAction(mode), [
      `自动切换到${mode === "training" ? "训练" : "闯关"}模式。`,
    ]);
  }

  private updatePaidMultiplierCard(
    valueLabel: UILabel,
    diamondButton: UIButton,
    purchaseButton: UIButton,
  ): void {
    const current = this.state.getPaidTrainingMultiplierValues();
    const next = this.state.getNextPaidTrainingMultiplierValues();
    const maxed = this.state.isPaidTrainingMultiplierMaxed();
    const paidBlocked =
      this.getActionBlocker(new UpgradePaidTrainingMultiplierAction("paid")) !==
      null;

    valueLabel.Text =
      `<b>档位 ${numberToText(this.state.paidTrainingMultiplierId)} · ×${numberToText(current.multiplier)}</b>` +
      ` · 钻石自动${this.state.autoPaidTrainingUpgradeEnabled ? "开" : "关"}`;
    diamondButton.Text = maxed
      ? "已封顶 ×128"
      : `自动${this.state.autoPaidTrainingUpgradeEnabled ? "开" : "关"}（${numberToText(next.diamondCost)} 钻）`;
    diamondButton.Disabled = maxed;
    diamondButton.ButtonColor = maxed
      ? "#eef2f6"
      : this.state.autoPaidTrainingUpgradeEnabled
        ? "#12b76a"
        : "#f79009";
    diamondButton.TextColor = maxed ? "#98a2b3" : "#ffffff";
    purchaseButton.Text = maxed
      ? "已封顶 ×128"
      : "付费提升";
    purchaseButton.Disabled = paidBlocked;
    purchaseButton.ButtonColor = paidBlocked ? "#eef2f6" : "#b54708";
    purchaseButton.TextColor = paidBlocked ? "#98a2b3" : "#ffffff";
  }

  private updateBackpackExpansionCard(): void {
    const next = this.state.getNextBackpackExpansionValues();
    const maxed = this.state.isBackpackExpansionMaxed();
    const paidBlocked =
      this.getActionBlocker(new UpgradeBackpackAction("paid")) !== null;

    this.backpackExpansionLabel.Text =
      `<b>等级 ${numberToText(this.state.backpackExpansionLevel)}/${numberToText(this.state.getMaxBackpackExpansionCount())}` +
      ` · ${numberToText(this.state.getBackpackCapacity())} 格</b>` +
      ` · 钻石自动${this.state.autoBackpackUpgradeEnabled ? "开" : "关"}`;
    this.backpackDiamondButton.Text = maxed
      ? "已达扩容上限"
      : `自动${this.state.autoBackpackUpgradeEnabled ? "开" : "关"}（${numberToText(next.expansionPrice)} 钻）`;
    this.backpackDiamondButton.Disabled = maxed;
    this.backpackDiamondButton.ButtonColor = maxed
      ? "#eef2f6"
      : this.state.autoBackpackUpgradeEnabled
        ? "#12b76a"
        : "#f79009";
    this.backpackDiamondButton.TextColor = maxed ? "#98a2b3" : "#ffffff";
    this.backpackPurchaseButton.Text = maxed
      ? "已达扩容上限"
      : "付费扩容";
    this.backpackPurchaseButton.Disabled = paidBlocked;
    this.backpackPurchaseButton.ButtonColor = paidBlocked
      ? "#eef2f6"
      : "#b54708";
    this.backpackPurchaseButton.TextColor = paidBlocked
      ? "#98a2b3"
      : "#ffffff";
  }

  private updateWeeklyCard(
    cardType: WeeklyCardType,
    valueLabel: UILabel,
    detailsLabel: UILabel,
    purchaseButton: UIButton,
  ): void {
    const values = this.state.getWeeklyCardValues(cardType);
    const remainingRewards =
      this.state.getWeeklyCardRemainingRewards(cardType);
    const blocked =
      this.getActionBlocker(new PurchaseWeeklyCardAction(cardType)) !== null;

    valueLabel.Text = remainingRewards > 0
      ? `<b>剩余 ${numberToText(remainingRewards)} 次 · ${this.formatDuration(this.state.getWeeklyCardRewardRemainingSeconds(cardType))}</b>`
      : "<b>未生效</b>";
    detailsLabel.Text =
      `立即${numberToText(values.instantDiamonds)} · 每日${numberToText(values.dailyDiamonds)}` +
      ` · 同价值≈${numberToText(values.equivalentDiamonds)} · 7天${numberToText(values.totalDiamonds)}钻`;
    purchaseButton.Text = blocked
      ? "周卡生效中"
      : `${numberToText(values.miniCoinPrice)}迷你币购买（当天 ${numberToText(values.purchaseDayDiamonds)}钻）`;
    purchaseButton.Disabled = blocked;
    purchaseButton.ButtonColor = blocked ? "#eef2f6" : "#b54708";
    purchaseButton.TextColor = blocked ? "#98a2b3" : "#ffffff";
  }

  private formatDuration(totalSeconds: number): string {
    const hours = Math.floor(totalSeconds / 3600);
    const minutes = Math.floor((totalSeconds % 3600) / 60);
    const seconds = Math.floor(totalSeconds % 60);
    return [hours, minutes, seconds]
      .map((value) => value.toString().padStart(2, "0"))
      .join(":");
  }
}
