extends Node2D

enum State {
	IDLE,
	MOVING,
	PECKING,
	SLEEPING,
	LOOKING,
	FOLLOW_MOUSE
}

@onready var state_timer: Timer = $Timer
@onready var blink_timer: Timer = $BlinkTimer
@onready var sevda: AnimatedSprite2D = $Sprite2D
@onready var sleep_z: AnimatedSprite2D = $SleepZ
@onready var sleep_timer: Timer = $SleepTimer

var current_state: State = State.IDLE
var direction: float = 1.0
var window_x: float
var screen_size: Vector2i


func _ready() -> void:
	print("Sevda uyandı!")

	get_window().position = Vector2i(500, 300)
	window_x = float(get_window().position.x)
	screen_size = DisplayServer.screen_get_size()

	change_state(State.IDLE)


func change_state(new_state: State) -> void:
	current_state = new_state

	match current_state:
		State.IDLE:
			sleep_z.visible = false
			sleep_z.stop()

			sevda.play("idle")

			start_blink_timer()
			start_sleep_timer()


		State.MOVING:
			if randf() < 0.5:
				direction = -1.0
			else:
				direction = 1.0

			state_timer.wait_time = 4.0
			state_timer.start()


		State.PECKING:
			blink_timer.stop()
			sleep_timer.stop()

			sleep_z.visible = false
			sleep_z.stop()

			sevda.play("pecking")


		State.SLEEPING:
			blink_timer.stop()
			sleep_timer.stop()

			sevda.play("sleep")

			sleep_z.visible = true
			sleep_z.play("sleep_z")


		State.LOOKING:
			pass

		State.FOLLOW_MOUSE:
			pass


func start_blink_timer() -> void:
	blink_timer.wait_time = randf_range(3.0, 7.0)
	blink_timer.start()


func _process(delta: float) -> void:
	if current_state != State.MOVING:
		return

	window_x += 100.0 * direction * delta

	var window_position := get_window().position
	window_position.x = int(window_x)

	var max_x := screen_size.x - get_window().size.x

	if window_position.x >= max_x:
		window_position.x = max_x
		window_x = float(max_x)
		direction = -1.0

	elif window_position.x <= 0:
		window_position.x = 0
		window_x = 0.0
		direction = 1.0

	get_window().position = window_position


func _on_blink_timer_timeout() -> void:
	if current_state == State.IDLE:
		sevda.play("blink")

	start_blink_timer()
		
func start_sleep_timer() -> void:
	sleep_timer.wait_time = randf_range(5.0, 8.0)
	sleep_timer.start()


func _on_sleep_timer_timeout() -> void:
	if current_state == State.IDLE:
		change_state(State.SLEEPING)


func _on_click_area_input_event(
	viewport: Node,
	event: InputEvent,
	shape_idx: int
) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			if current_state == State.SLEEPING:
				change_state(State.PECKING)


func _on_sprite_2d_animation_finished() -> void:
	if sevda.animation == "blink" and current_state == State.IDLE:
		sevda.play("idle")

	elif sevda.animation == "pecking" and current_state == State.PECKING:
		change_state(State.IDLE)
