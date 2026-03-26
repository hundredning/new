extends Node3D

# 绑定节点
@export var god_cam: Camera3D
@export var fps_controller: CharacterBody3D

# 初始视角
@export var is_god_mode: bool = true

# ==============================================
# 【双存储变量】同时记住两个视角的位置+朝向
# ==============================================
# 第一人称 存储
var saved_fps_pos: Vector3 = Vector3.ZERO
var saved_fps_rot: Vector3 = Vector3.ZERO
# 上帝视角 存储
var saved_god_pos: Vector3 = Vector3.ZERO
var saved_god_rot: Vector3 = Vector3.ZERO

# ✅ 新增：控制锁
var can_control: bool = false

func _ready():
	# 游戏启动时：记录初始位置（防止第一次切换无数据）
	
		saved_god_pos = god_cam.global_position
		saved_god_rot = god_cam.global_rotation


func _input(event: InputEvent) -> void:
	# ✅ 新增：没解锁时，不允许按键切换视角
	if not can_control:
		return
		
	if Input.is_action_just_pressed("switch_view"):
		switch_view_mode()

# ✅ 新增：用于解锁的函数
func enable_control():
	can_control = true

func switch_view_mode() -> void:
	is_god_mode = !is_god_mode

	if is_god_mode:
		# ==============================================
		# 切回上帝视角：保存FPS → 恢复上帝
		# ==============================================
		saved_fps_pos = fps_controller.global_position
		saved_fps_rot = fps_controller.global_rotation

		god_cam.global_position = saved_god_pos
		god_cam.global_rotation = saved_god_rot
		god_cam.current = true
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	else:
		# ==============================================
		# 切回第一人称：保存上帝 → 恢复FPS
		# ==============================================
		saved_god_pos = god_cam.global_position
		saved_god_rot = god_cam.global_rotation

		fps_controller.global_position = saved_fps_pos
		fps_controller.global_rotation = saved_fps_rot
		fps_controller.get_node("Camera3D").current = true
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

	await get_tree().create_timer(0.1).timeout

func _process(delta: float) -> void:
	god_cam.current = is_god_mode
	fps_controller.get_node("Camera3D").current = !is_god_mode
