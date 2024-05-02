extends Node2D

@onready var cam: PhantomCamera2D = $cam;

class CombatUnit:
  var char: BattleChar;
  var path_follow: PathFollow2D;
  var path: Path2D;
  var unit_data: CombatUnitData.Data;
  var health_bar: ProgressBar;
  func _init(char, path_follow, path, health_bar):
    self.char = char;
    self.path_follow = path_follow;
    self.path = path;
    self.health_bar = health_bar;

@onready var player = CombatUnit.new($path_left/path_follow/battle_char, $path_left/path_follow, $path_left, $CanvasLayer/player_info/margin/healthbar);
@onready var npc = CombatUnit.new($path_right/path_follow/battle_char, $path_right/path_follow, $path_right, $CanvasLayer/npc_info/margin/healthbar);
@onready var path_parry_marker: Path2D = $path_parry_marker;
@onready var path_parry_marker_path_follow: PathFollow2D = $path_parry_marker/path_follow;

@export var is_player_turn = true;

var parry_attempted = false;
var parry_attempted_ratio = 0.0;
var min_parry_ratio = 0.65;
var max_parry_ratio = 1;
var player_init_position = Vector2(2, 0);
var npc_init_position = Vector2(1020, 0);
var attack_position_offset = Vector2(175, 0);

# Called when the node enters the scene tree for the first time.
func _ready():
  player.unit_data = CombatUnitData.entries[CombatUnitData.Type.DUAL_HYBRID];
  npc.unit_data = CombatUnitData.entries[CombatUnitData.Type.TWO_HANDED_AXER];
  player.char.update_sprite_texture(player.unit_data.sprite_path);
  npc.char.update_sprite_texture(npc.unit_data.sprite_path);
  player.char.to_player();
  player.char.idle();
  npc.char.idle();
  var player_path_points: Array[Vector2] = player.unit_data.get_path_points.call(player_init_position, npc_init_position - attack_position_offset)
  player.path.curve.clear_points();
  for i in range(player_path_points.size() - 1, -1, -1):
    var point = player_path_points[i];
    player.path.curve.add_point(point);
  var npc_path_points: Array[Vector2] = npc.unit_data.get_path_points.call(player_init_position + attack_position_offset, npc_init_position)
  npc.path.curve.clear_points();
  for point in npc_path_points:
    npc.path.curve.add_point(point);
    path_parry_marker.curve.add_point(point);
  path_parry_marker_path_follow.progress_ratio = (min_parry_ratio + max_parry_ratio) / 2;
  path_parry_marker.visible = false;
  _update_unit_ui_info(player);
  _update_unit_ui_info(npc);

func _update_unit_ui_info(combat_unit: CombatUnit):
  combat_unit.health_bar.value = (combat_unit.char.health / combat_unit.char.MAX_HEALTH) * 100;

func full_round(attacker: CombatUnit, defender: CombatUnit):
  await attack_sequence(attacker, defender);
  is_player_turn = !is_player_turn;
  await attack_sequence(defender, attacker);

  # NOTE: in this func: is_player_turn actually means its enemy turn
func attack_sequence(attacker: CombatUnit, defender: CombatUnit):
  path_parry_marker.visible = is_player_turn;
  attacker.char.preatk();
  defender.char.readied();
  var tween = create_tween();
  tween.tween_property(attacker.path_follow, "progress_ratio", 1, 1).set_trans(Tween.TRANS_EXPO);
  await tween.finished;
  attacker.char.postatk();
  var damage_taker = defender;
  if is_player_turn:
    if parry_attempted and parry_attempted_ratio >= min_parry_ratio and parry_attempted_ratio <= max_parry_ratio:
      damage_taker = attacker;
      defender.char.postatk();
  damage_taker.char.take_damage(1);
  _update_unit_ui_info(damage_taker);
  path_parry_marker.visible = false;
  # HACK: to let the postatk frame show for a second
  tween = create_tween();
  tween.tween_property(attacker.path_follow, "progress_ratio", 1, 1);
  await tween.finished;
  attacker.char.idle();
  defender.char.idle();
  tween = create_tween();
  tween.tween_property(attacker.path_follow, "progress_ratio", 0, 1).set_trans(Tween.TRANS_CUBIC);
  return await tween.finished;

func _on_attack_pressed():
  if is_player_turn and player.path_follow.progress_ratio == 0 and npc.path_follow.progress_ratio == 0:
    is_player_turn = !is_player_turn;
    parry_attempted = false;
    parry_attempted_ratio = 0.0;
    full_round(player, npc);
  elif !parry_attempted:
    parry_attempted = true;
    parry_attempted_ratio = npc.path_follow.progress_ratio;
