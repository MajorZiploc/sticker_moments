extends Node

class CombatUnit:
  var battle_char: BattleChar;
  var path_follow: PathFollow2D;
  var path: Path2D;
  var unit_data: CombatUnitData.Data;
  var health_bar: TextureProgressBar;
  var name: Label;
  var bust: TextureRect;
  var is_player: bool;
  func _init(char_, path_follow_, path_, health_bar_, name_, bust_):
    self.battle_char = char_;
    self.path_follow = path_follow_;
    self.path = path_;
    self.health_bar = health_bar_;
    self.name = name_;
    self.bust = bust_;
    self.is_player = false;

enum QTEMode {
  TOUCH,
  BUTTON,
  TOUCH_AND_BUTTON,
}

enum PlayerChoicesMenuPopupItem {
  ATTACK,
  INVENTORY,
}

enum PlayerInventoryItemType {
  PARALYZED,
  POSION,
  STRENGTH,
}

class Background:
  var lg_clouds: Array[Sprite2D];
  var md_clouds: Array[Sprite2D];
  var sm_clouds: Array[Sprite2D];
  func _init(lg_clouds_: Array[Sprite2D], md_clouds_: Array[Sprite2D], sm_clouds_: Array[Sprite2D]):
    self.lg_clouds = lg_clouds_;
    self.md_clouds = md_clouds_;
    self.sm_clouds = sm_clouds_;

class QTEItem:
  var key: String;
  var box: BoxContainer;
  var button: TextureButton;
  var is_button_event: bool;
  var is_touch_event: bool;
  func _init(key_, box_, button_, is_button_event_, is_touch_event_):
    self.key = key_;
    self.box = box_;
    self.button = button_;
    self.is_button_event = is_button_event_;
    self.is_touch_event = is_touch_event_;

class QTEItemMetaData:
  var normal: Texture;
  var qte_modes: Array;
  func _init(normal_: Texture, qte_modes_):
    self.normal = normal_;
    self.qte_modes = qte_modes_;
