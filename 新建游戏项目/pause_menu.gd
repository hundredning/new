extends Control

@onready var blur = $BlurMask
@onready var blur_material = blur.material

# ✅ 新增：菜单锁（开场动画期间不允许暂停）
var can_pause: bool = false

func _ready():
	visible = false
	# 确保暂停菜单在游戏暂停时依然可以运行
	process_mode = Node.PROCESS_MODE_ALWAYS

# ========================
# 🎮 监听 ESC 按键
# ========================
func _input(event: InputEvent) -> void:
	# ✅ 新增：如果还没解锁暂停权限，无视 ESC
	if not can_pause:
		return 
		
	if event.is_action_pressed("ui_cancel"):
		if visible:
			close_menu()
		else:
			open_menu()
		get_viewport().set_input_as_handled()

# ========================
# 🎮 打开 / 关闭菜单
# ========================
func open_menu():
	visible = true
	get_tree().paused = true
	# 打开菜单时显示鼠标（必须）
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	# 修复：模糊动画从0→5（正确效果）
	blur_material.set("shader_parameter/strength", 0.0)
	var tween = create_tween()
	tween.tween_property(blur_material, "shader_parameter/strength", 5.0, 0.5)

func close_menu():
	# 修复：模糊动画从5→0
	var tween = create_tween()
	tween.tween_property(blur_material, "shader_parameter/strength", 0.0, 0.5)

	tween.tween_callback(func():
		visible = false
		get_tree().paused = false
		
		# 🚫 删掉这行！就是它锁住了鼠标：Input.mouse_mode = Input.MOUSE_MODE_CAPTURED 
		
		var player = get_tree().current_scene.get_node_or_null("Cameramanager/CharacterBody3D")
		if player and player.has_method("enable_control"):
			player.enable_control()
	)

# ========================
# 💾 存档系统（先简单版）
# ========================
func save_game():
	var data = {
		"player_pos": Vector3(0,0,0)
	}
	var file = FileAccess.open("user://save.json", FileAccess.WRITE)
	file.store_string(JSON.stringify(data))
	file.close()

# ========================
# 🔘 按钮功能
# ========================
# 🟢 新建
func _on_button_1_new_pressed():
	print("已加载")
	save_game()
	get_tree().paused = false
	get_tree().change_scene_to_file("res://NewScene.tscn")

# 🟡 旧存档
func _on_button_2_load_pressed():
	print("打开存档界面（以后做）")

# 🔴 保存并退出
func _on_button_3_quit_pressed():
	save_game()
	get_tree().quit()
