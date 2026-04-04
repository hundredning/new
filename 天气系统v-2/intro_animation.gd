extends Control

@onready var blur_mask = $BlurMask
@onready var title_video = $TitleVideo 

var blur_material: ShaderMaterial
signal intro_finished

func _ready():
	self.visible = true
	blur_material = blur_mask.material as ShaderMaterial
	
	# 初始状态：最强水墨模糊，视频完全透明
	blur_material.set_shader_parameter("blur_strength", 1.0)
	title_video.modulate.a = 0.0 
	
	play_intro()

func play_intro():
	var tween = create_tween()
	
	# 1. 保持最强水墨模糊 2 秒
	tween.tween_interval(2.0)
	
	# 2. 视频淡入（1秒）的同时，触发视频开始播放
	tween.tween_callback(title_video.play)
	tween.tween_property(title_video, "modulate:a", 1.0, 1.0)
	
	# 3. 【重点】等待视频播放完毕（这里填你的视频真实秒数）
	tween.tween_interval(7.0)
	
	# 4. 水墨模糊逐渐消失，画面变清晰（3秒）
	tween.tween_method(_update_blur, 1.0, 0.0, 1.0)
	
	# 5. 视频文字淡出（2秒）
	tween.tween_property(title_video, "modulate:a", 0.0, 0.5)
	
	# 6. 结束动画并解锁玩家控制
	tween.tween_callback(_finish_intro)

# === 下面是提取出来的纯净回调函数，防止报错 ===

func _update_blur(value: float):
	if blur_material:
		blur_material.set_shader_parameter("blur_strength", value)

func _finish_intro():
	self.visible = false
	intro_finished.emit()
