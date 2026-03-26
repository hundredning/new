extends CanvasLayer

@onready var sun = $"../DirectionalLight3D"
@onready var env = $"../WorldEnvironment"
@onready var rain_particles = $"../GPUParticles3D"

var is_raining: bool = false

func _ready() -> void:
	# 游戏刚开始默认不下雨
	if rain_particles:
		rain_particles.emitting = false

# === 1. 简单的跟随相机（高度Y你可以自己微调） ===
func _process(_delta: float) -> void:
	if is_raining and rain_particles:
		var active_cam = get_viewport().get_camera_3d()
		if active_cam:
			rain_particles.global_position.x = active_cam.global_position.x
			rain_particles.global_position.z = active_cam.global_position.z
			# 高度就用你最初觉得舒服的高度，比如相机往上加个 10 或 15 米
			rain_particles.global_position.y = active_cam.global_position.y + 15.0 

# === 2. 纯粹的按键控制 ===
func _on_weather_button_pressed() -> void:
	is_raining = !is_raining
	var tween = create_tween()
	tween.set_parallel(true) 
	
	if is_raining:
		# 直接开启你原本完好的雨！加上 restart 踹引擎一脚防止它卡死
		rain_particles.emitting = true
		rain_particles.restart() 
		
		# 光线变暗
		tween.tween_property(sun, "light_energy", 0.05, 2.0) 
		tween.tween_property(env.environment, "background_energy_multiplier", 0.3, 2.0)
	else:
		# 关雨，光线恢复
		rain_particles.emitting = false
		tween.tween_property(sun, "light_energy", 1.0, 2.0)
		tween.tween_property(env.environment, "background_energy_multiplier", 1.0, 2.0)
