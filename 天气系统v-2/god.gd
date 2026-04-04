extends Camera3D

# 相机基础参数
@export var move_speed: float = 30
@export var rotate_speed: float = 0.5
@export var zoom_speed: float = 2.0
@export var min_height: float = 0.1  # 最低高度=0.1，绝不穿地
@export var max_height: float = 50


# ✅ 新增：250×250 建造区范围限制（中心原点，半长125）
@export var range_min_x: float = -125.0
@export var range_max_x: float = 125.0
@export var range_min_z: float = -125.0
@export var range_max_z: float = 125.0

var pivot: Vector3 = Vector3.ZERO
var mouse_delta: Vector2 = Vector2.ZERO

# 控制锁
var can_control: bool = false

func _ready() -> void:
	pivot = global_position


func _input(event: InputEvent) -> void:
	# 未解锁不响应输入
	if not can_control:
		return 
		
	if event is InputEventMouseMotion:
		mouse_delta = event.relative

func _process(delta: float) -> void:
	# 未解锁不执行逻辑
	if not can_control:
		return
		
	if not get_parent().is_god_mode:
		mouse_delta = Vector2.ZERO
		return
	
	move_camera(delta)
	rotate_camera()
	zoom_camera()
	mouse_delta = Vector2.ZERO

# 解锁控制
func enable_control():
	can_control = true

# WASD平移 + 250×250范围限制
func move_camera(delta: float) -> void:
	var input = Vector2(
		Input.get_axis("move_left", "move_right"),
		Input.get_axis("move_forward", "move_backward")
	)
	if input.length() > 0:
		input = input.normalized()
		pivot += global_transform.basis.x * input.x * move_speed * delta
		pivot += global_transform.basis.z * input.y * move_speed * delta

	# ✅ 核心：限制相机在250×250范围内 + 不低于地平面
	pivot.x = clamp(pivot.x, range_min_x, range_max_x)
	pivot.z = clamp(pivot.z, range_min_z, range_max_z)
	pivot.y = clamp(pivot.y, min_height, max_height)
	
	# 应用最终位置
	global_position = pivot

# 右键旋转
func rotate_camera() -> void:
	if Input.is_action_pressed("camera_rotate"):
		rotate_y(-mouse_delta.x * rotate_speed * 0.01)
		var new_x = rotation.x + mouse_delta.y * rotate_speed * 0.01
		rotation.x = clamp(new_x, deg_to_rad(-80), deg_to_rad(-10))

# 滚轮缩放（高度控制）
func zoom_camera() -> void:
	var zoom = Input.get_axis("zoomout", "zoomin")
	
	if zoom != 0:
		var new_height = global_position.y - zoom * zoom_speed
		# ✅ 双重保障：高度绝不低于地平面
		global_position.y = clamp(new_height, min_height, max_height)
		pivot = global_position
