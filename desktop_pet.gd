extends Node2D


enum State {
	IDLE,
	MOVING,
	PECKING,
	SLEEPING,
	HAPPY
}


@onready var state_timer: Timer = $Timer
@onready var blink_timer: Timer = $BlinkTimer
@onready var sleep_timer: Timer = $SleepTimer

@onready var sevda: AnimatedSprite2D = $Sprite2D
@onready var sleep_z: AnimatedSprite2D = $SleepZ

@onready var peck_bubble: Sprite2D = $PeckBubble
@onready var happy_bubble: Sprite2D = $HappyBubble
@onready var happy_bubble_right: Sprite2D = $HappyBubbleRight

@onready var pet_popup: PopupPanel = $PetPopup
@onready var menu_title: Label = $PetPopup/MarginContainer/VBoxContainer/MenuTitle

@onready var music_button: Button = $PetPopup/MarginContainer/VBoxContainer/MusicButton
@onready var pomodoro_button: Button = $PetPopup/MarginContainer/VBoxContainer/PomodoroButton
@onready var water_button: Button = $PetPopup/MarginContainer/VBoxContainer/WaterButton

@onready var water_panel: VBoxContainer = $PetPopup/MarginContainer/VBoxContainer/WaterPanel
@onready var water_back_button: Button = $PetPopup/MarginContainer/VBoxContainer/WaterPanel/WaterBackButton

@onready var glass_count: Label = $PetPopup/MarginContainer/VBoxContainer/WaterPanel/GlassCount
@onready var minus_button: Button = $PetPopup/MarginContainer/VBoxContainer/WaterPanel/WaterControls/MinusButton
@onready var plus_button: Button = $PetPopup/MarginContainer/VBoxContainer/WaterPanel/WaterControls/PlusButton

var current_state: State = State.IDLE

var direction: float = -1.0
var window_x: float = 0.0

var usable_rect: Rect2i

var water_glasses: int = 0

func _ready() -> void:
	print("Sevda uyandı!")
	
	water_panel.visible = false
	
	update_water_count()

	# Popup ana 240x240 pencerenin içine sıkışmasın.
	get_viewport().gui_embed_subwindows = false

	pet_popup.hide()

	usable_rect = DisplayServer.screen_get_usable_rect()

	get_window().size = Vector2i(240, 240)

	var window_size := get_window().size

	get_window().position = Vector2i(
		usable_rect.position.x
		+ usable_rect.size.x
		- window_size.x
		- 5,

		usable_rect.position.y
		+ usable_rect.size.y
		- window_size.y
		- 5
	)

	window_x = float(get_window().position.x)

	peck_bubble.visible = false
	happy_bubble.visible = false
	happy_bubble_right.visible = false
	sleep_z.visible = false
	

	
	change_state(State.IDLE)


func change_state(new_state: State) -> void:
	current_state = new_state

	match current_state:

		State.IDLE:
			state_timer.stop()

			happy_bubble.visible = false
			happy_bubble_right.visible = false
			peck_bubble.visible = false

			sleep_z.visible = false
			sleep_z.stop()

			sevda.play("idle")

			start_blink_timer()
			start_sleep_timer()
			start_move_wait()


		State.MOVING:
			blink_timer.stop()
			sleep_timer.stop()

			sleep_z.visible = false
			sleep_z.stop()

			peck_bubble.visible = false
			happy_bubble.visible = false
			happy_bubble_right.visible = false

			sevda.flip_h = direction < 0
			sevda.play("walk")

			state_timer.wait_time = randf_range(4.0, 7.0)
			state_timer.start()


		State.PECKING:
			state_timer.stop()
			blink_timer.stop()
			sleep_timer.stop()

			sleep_z.visible = false
			sleep_z.stop()

			happy_bubble.visible = false
			happy_bubble_right.visible = false

			peck_bubble.visible = true
			hide_peck_bubble()

			sevda.play("pecking")


		State.SLEEPING:
			state_timer.stop()
			blink_timer.stop()
			sleep_timer.stop()

			peck_bubble.visible = false
			happy_bubble.visible = false
			happy_bubble_right.visible = false

			sevda.play("sleep")

			sleep_z.visible = true
			sleep_z.play("sleep_z")

		State.HAPPY:
			state_timer.stop()
			blink_timer.stop()
			sleep_timer.stop()

			sleep_z.visible = false
			sleep_z.stop()

			peck_bubble.visible = false

			happy_bubble.visible = false
			happy_bubble_right.visible = false

			# Sevda sağa bakıyorsa yeni sağ balon,
			# sola bakıyorsa eski HappyBubble gösterilir.
			if sevda.flip_h:
				happy_bubble.visible = true
			else:
				happy_bubble_right.visible = true

			sevda.play("happy")
			show_happy_reaction()


func _process(delta: float) -> void:
	if current_state != State.MOVING:
		return

	var min_x := float(usable_rect.position.x)

	var max_x := float(
		usable_rect.position.x
		+ usable_rect.size.x
		- get_window().size.x
	)

	window_x += 100.0 * direction * delta

	if window_x <= min_x:
		window_x = min_x
		direction = 1.0

	elif window_x >= max_x:
		window_x = max_x
		direction = -1.0

	sevda.flip_h = direction < 0

	var window_position := get_window().position
	window_position.x = roundi(window_x)

	get_window().position = window_position


func start_blink_timer() -> void:
	blink_timer.wait_time = randf_range(3.0, 7.0)
	blink_timer.start()


func _on_blink_timer_timeout() -> void:
	if current_state == State.IDLE:
		sevda.play("blink")

	start_blink_timer()


func start_sleep_timer() -> void:
	sleep_timer.wait_time = randf_range(45.0, 90.0)
	sleep_timer.start()


func _on_sleep_timer_timeout() -> void:
	if current_state == State.IDLE:
		change_state(State.SLEEPING)


func start_move_wait() -> void:
	await get_tree().create_timer(randf_range(15.0, 30.0)).timeout

	if current_state == State.IDLE:
		if randf() < 0.55:

			if randf() < 0.5:
				direction = -1.0
			else:
				direction = 1.0

			change_state(State.MOVING)


func _on_timer_timeout() -> void:
	if current_state == State.MOVING:
		change_state(State.IDLE)


func _on_click_area_input_event(
	_viewport: Node,
	event: InputEvent,
	_shape_idx: int
) -> void:

	if event is InputEventMouseButton:

		# SOL TIK
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:

			if current_state == State.SLEEPING:
				change_state(State.PECKING)

			elif current_state == State.IDLE:
				change_state(State.HAPPY)


		# SAĞ TIK
		elif event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:

			var popup_size := Vector2i(320, 200)

			pet_popup.popup(
				Rect2i(
					get_window().position + Vector2i(-40, -210),
					popup_size
	)
)
			
func _on_sprite_2d_animation_finished() -> void:

	if sevda.animation == "blink" and current_state == State.IDLE:
		sevda.play("idle")

	elif sevda.animation == "pecking" and current_state == State.PECKING:
		change_state(State.IDLE)


func hide_peck_bubble() -> void:
	await get_tree().create_timer(0.65).timeout

	if current_state == State.PECKING:
		peck_bubble.visible = false


func show_happy_reaction() -> void:
	await get_tree().create_timer(0.2).timeout

	if current_state == State.HAPPY:
		change_state(State.IDLE)


func _on_menu_title_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			pet_popup.start_drag()


func _on_water_button_pressed() -> void:
	menu_title.visible = false
	music_button.visible = false
	pomodoro_button.visible = false
	water_button.visible = false

	water_panel.visible = true


func _on_water_back_button_pressed() -> void:
	water_panel.visible = false

	menu_title.visible = true
	music_button.visible = true
	pomodoro_button.visible = true
	water_button.visible = true


func _on_plus_button_pressed() -> void:
	water_glasses += 1
	update_water_count()


func _on_minus_button_pressed() -> void:
	if water_glasses > 0:
		water_glasses -= 1

	update_water_count()

func update_water_count() -> void:
	if water_glasses == 1:
		glass_count.text = "1 GLASS"
	else:
		glass_count.text = str(water_glasses) + " GLASSES"
