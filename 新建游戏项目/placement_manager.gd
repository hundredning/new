extends Node3D

# --- 1. 配置参数 (在检查器里设置) ---

enum BuildMode { SINGLE, CONTINUOUS }

@export var building_templates: Array[PackedScene] = []
@export var building_modes: Array[BuildMode] = []
@export var segment_length: float = 2.0 
@export var ui_container: Control

# --- 2. 内部逻辑变量 ---

var current_index: int = 0
var current_mode = BuildMode.SINGLE
var is_holding: bool = false
var last_pos: Vector3 = Vector3.ZERO
var preview_ghost: Node3D = null
var storage_node: Node3D = null

func _ready():
	print("--- [园林系统] 启动成功，支持无限物体扩展 ---")
	
	storage_node = Node3D.new()
	storage_node.name = "PlacedBuildings"
	get_tree().current_scene.add_child.call_deferred(storage_node)
	
	if building_templates.size() > 0:
		_switch_to(0)

# 核心切换逻辑
func _switch_to(index: int):
	print(">>> [信号接收] 准备切换到物体索引: ", index)
	
	if index < 0 or index >= building_templates.size():
		print("!!! [错误] 列表里没有 Index ", index, "。请检查 PlacementManager 的模板列表数量。")
		return
		
	if building_templates[index] == null:
		print("!!! [错误] Index ", index, " 处没放文件。请把 .tscn 拖进去。")
		return

	current_index = index
	if index < building_modes.size():
		current_mode = building_modes[index]
	
	if preview_ghost: preview_ghost.queue_free()
	preview_ghost = building_templates[current_index].instantiate()
	add_child(preview_ghost)
	preview_ghost.visible = false
	_clear_collision(preview_ghost)
	
	var m_name = "单点" if current_mode == BuildMode.SINGLE else "连续"
	print(">>> [状态] 切换成功: ", preview_ghost.name, " | 模式: ", m_name)

func _clear_collision(n: Node):
	if n is CollisionObject3D: n.input_ray_pickable = false
	for c in n.get_children(): _clear_collision(c)

func _process(_delta):
	var is_god = _is_god_view()
	if ui_container: ui_container.visible = is_god
	if not is_god:
		if preview_ghost: preview_ghost.visible = false
		is_holding = false
		return
	_update_raycast()
	if current_mode == BuildMode.CONTINUOUS and is_holding:
		_smooth_fill()

func _input(event):
	if not _is_god_view(): return
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			is_holding = true
			if preview_ghost and preview_ghost.visible:
				if current_mode == BuildMode.SINGLE:
					_do_place(preview_ghost.global_position)
				else:
					last_pos = preview_ghost.global_position
					_do_place(last_pos)
		else:
			is_holding = false

func _update_raycast():
	if not preview_ghost: return
	var camera = get_viewport().get_camera_3d()
	if not camera: return
	var m_pos = get_viewport().get_mouse_position()
	var from = camera.project_ray_origin(m_pos)
	var to = from + camera.project_ray_normal(m_pos) * 1000
	var space = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(from, to)
	
	# ✅ 修复后的排除列表（无报错版）
	var excludes: Array[RID] = _get_collision_rids(preview_ghost)
	for b in storage_node.get_children():
		excludes += _get_collision_rids(b)
	query.exclude = excludes
	
	var result = space.intersect_ray(query)
	if result:
		preview_ghost.visible = true
		preview_ghost.global_position = result.position
		if is_holding and current_mode == BuildMode.CONTINUOUS:
			if result.position.distance_to(last_pos) > 0.1:
				preview_ghost.look_at(last_pos, Vector3.UP)
		else:
			preview_ghost.global_rotation = Vector3.ZERO
	else:
		preview_ghost.visible = false

func _smooth_fill():
	if not preview_ghost or not preview_ghost.visible: return
	var cur = preview_ghost.global_position
	var dist = cur.distance_to(last_pos)
	while dist >= segment_length:
		var dir = (cur - last_pos).normalized()
		var next = last_pos + dir * segment_length
		_do_place(next, last_pos)
		last_pos = next
		dist = cur.distance_to(last_pos)

func _do_place(pos: Vector3, look_target: Vector3 = Vector3.ZERO):
	var template = building_templates[current_index]
	var inst = template.instantiate()
	storage_node.add_child(inst)
	inst.global_position = pos
	if look_target != Vector3.ZERO:
		inst.look_at(look_target, Vector3.UP)
	else:
		inst.global_rotation = Vector3.ZERO

# --- 视角检测 (增加了安全保护) ---
func _is_god_view() -> bool:
	var cm = get_tree().current_scene.find_child("Cameramanager", true, false)
	if cm and "is_god_mode" in cm:
		return cm.is_god_mode
	return true

# --- 通用接口：一个函数支持无限个按钮 ---

# 方案 A：通用的带参数函数
func select_item(index: int):
	_switch_to(index)

# 方案 B：为了方便你之前的操作，保留几个快捷函数
func select_item_0(): _switch_to(0)
func select_item_1(): _switch_to(1)
func select_item_2(): _switch_to(2)
func select_item_3(): _switch_to(3)
func select_item_4(): _switch_to(4)
# 新增：获取节点下所有碰撞体的 RID（安全无报错）
func _get_collision_rids(node: Node) -> Array[RID]:
	var rids: Array[RID] = []
	if node is CollisionObject3D:
		rids.append(node.get_rid())
	# 递归遍历子节点，收集所有碰撞体RID
	for child in node.get_children():
		rids += _get_collision_rids(child)
	return rids
