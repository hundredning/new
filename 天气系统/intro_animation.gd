extends Control

@onready var blur_mask = $BlurMask
@onready var title = $TitleLabel

# 拿到 Shader 参数
var blur_material: ShaderMaterial

signal intro_finished

func _ready():
	self.visible = true
	blur_material = blur_mask.material as ShaderMaterial
	
	# 初始状态：最强模糊，文字隐藏
	blur_material.set_shader_parameter("blur_strength", 1.0)
	title.modulate.a = 0.0
	
	play_intro()

func play_intro():
	var tween = create_tween()
	
	# 1. 先保持最强水墨模糊 2 秒（让玩家看一眼水墨效果）
	tween.tween_interval(2.0)
	
	# 2. 文字淡入（1秒）
	tween.tween_property(title, "modulate:a", 1.0, 1.0)
	
	# 3. 保持文字显示 2.5 秒
	tween.tween_interval(2.5)
	
	# 4. 【核心】水墨模糊逐渐消失，画面变清晰（3秒）
	# blur_strength 从 1.0 变到 0.0
	tween.tween_method(
		func(v): blur_material.set_shader_parameter("blur_strength", v),
		1.0,  # 起始值：最模糊
		0.0,  # 结束值：最清晰
		3.0   # 耗时：3秒
	)
	
	# 5. 文字淡出（2秒）
	tween.tween_property(title, "modulate:a", 0.0, 2.0)
	
	# 6. 结束
	tween.tween_callback(func():
		self.visible = false
		intro_finished.emit()
	)
