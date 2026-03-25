extends Node3D


@onready var blur = $GameUI/IntroAnimation/BlurMask
@onready var blur_material = blur.material

@onready var intro_anim = $GameUI/IntroAnimation
@onready var pause_menu = $GameUI/PauseMenu
# ✅ 加上 Cameramanager/ 前缀
@onready var player = $Cameramanager/CharacterBody3D
# ✅ 新增：拿到 Manager 和 God 相机的引用
@onready var camera_manager = $Cameramanager
@onready var god_cam = $Cameramanager/God

func _ready() -> void:
	# ✅ 核心：让开场动画结束时，触发 _on_intro_finished 函数
	intro_anim.intro_finished.connect(_on_intro_finished)

func _process(delta: float) -> void:
	pass

func _on_intro_finished() -> void:
	# 1. 解锁第一人称玩家
	if player and player.has_method("enable_control"):
		player.enable_control() 
	
	# 2. 解锁上帝相机
	if god_cam and god_cam.has_method("enable_control"):
		god_cam.enable_control()
		
	# 3. 解锁相机切换功能
	if camera_manager and camera_manager.has_method("enable_control"):
		camera_manager.enable_control()
		
	# 4. 解锁 ESC 菜单
	if pause_menu:
		pause_menu.can_pause = true
		


#


func select_item() -> void:
	pass # Replace with function body.
