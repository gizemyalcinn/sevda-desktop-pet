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

@onready var peck_bubble: Sprite2D = $PeckBubble
@onready var happy_bubble: Sprite2D = $HappyBubble
@onready var happy_bubble_right: Sprite2D = $HappyBubbleRight

@onready var pet_popup: PopupPanel = $PetPopup
@onready var menu_title: Label = $PetPopup/MarginContainer/VBoxContainer/MenuTitle

@onready var todo_button: Button = $PetPopup/MarginContainer/VBoxContainer/TodoButton
@onready var pomodoro_button: Button = $PetPopup/MarginContainer/VBoxContainer/PomodoroButton
@onready var water_button: Button = $PetPopup/MarginContainer/VBoxContainer/WaterButton
@onready var exit_button: Button = $PetPopup/MarginContainer/VBoxContainer/ExitButton

@onready var exit_panel: VBoxContainer = $PetPopup/MarginContainer/VBoxContainer/ExitPanel
@onready var exit_cancel_button: Button = $PetPopup/MarginContainer/VBoxContainer/ExitPanel/ExitControls/ExitCancelButton
@onready var exit_confirm_button: Button = $PetPopup/MarginContainer/VBoxContainer/ExitPanel/ExitControls/ExitConfirmButton

@onready var water_panel: VBoxContainer = $PetPopup/MarginContainer/VBoxContainer/WaterPanel
@onready var water_back_button: Button = $PetPopup/MarginContainer/VBoxContainer/WaterPanel/WaterBackButton

@onready var water_total: Label = $PetPopup/MarginContainer/VBoxContainer/WaterPanel/WaterTotal

@onready var water_200_button: Button = $PetPopup/MarginContainer/VBoxContainer/WaterPanel/PresetRow1/Water200Button
@onready var water_250_button: Button = $PetPopup/MarginContainer/VBoxContainer/WaterPanel/PresetRow1/Water250Button
@onready var water_330_button: Button = $PetPopup/MarginContainer/VBoxContainer/WaterPanel/PresetRow1/Water330Button

@onready var water_500_button: Button = $PetPopup/MarginContainer/VBoxContainer/WaterPanel/PresetRow2/Water500Button
@onready var water_400_button: Button = $PetPopup/MarginContainer/VBoxContainer/WaterPanel/PresetRow2/Water400Button
@onready var water_750_button: Button = $PetPopup/MarginContainer/VBoxContainer/WaterPanel/PresetRow2/Water750Button

@onready var custom_ml_input: LineEdit = $PetPopup/MarginContainer/VBoxContainer/WaterPanel/CustomWaterRow/CustomMlInput
@onready var custom_add_button: Button = $PetPopup/MarginContainer/VBoxContainer/WaterPanel/CustomWaterRow/CustomAddButton

@onready var remove_last_button: Button = $PetPopup/MarginContainer/VBoxContainer/WaterPanel/RemoveLastButton


@onready var pomodoro_panel: VBoxContainer = $PetPopup/MarginContainer/VBoxContainer/PomodoroPanel
@onready var pomodoro_back_button: Button = $PetPopup/MarginContainer/VBoxContainer/PomodoroPanel/PomodoroBottomRow/PomodoroBackButton

@onready var pomodoro_timer: Timer = $PomodoroTimer

@onready var pomodoro_timer_view: VBoxContainer = $PetPopup/MarginContainer/VBoxContainer/PomodoroPanel/PomodoroTimerView
@onready var pomodoro_phase_label: Label = $PetPopup/MarginContainer/VBoxContainer/PomodoroPanel/PomodoroTimerView/PomodoroPhaseLabel
@onready var pomodoro_time_label: Label = $PetPopup/MarginContainer/VBoxContainer/PomodoroPanel/PomodoroTimerView/PomodoroTimeLabel
@onready var pomodoro_skip_button: Button = $PetPopup/MarginContainer/VBoxContainer/PomodoroPanel/PomodoroTimerView/PomodoroSkipButton

@onready var focus_sevda: TextureRect = $PetPopup/MarginContainer/VBoxContainer/PomodoroPanel/PomodoroTimerView/FocusSevda
@onready var working_sevda: TextureRect = $PetPopup/MarginContainer/VBoxContainer/PomodoroPanel/PomodoroTimerView/WorkingSevda
@onready var break_sevda: TextureRect = $PetPopup/MarginContainer/VBoxContainer/PomodoroPanel/PomodoroTimerView/BreakSevda

@onready var pomodoro_controls: HBoxContainer = $PetPopup/MarginContainer/VBoxContainer/PomodoroPanel/PomodoroTimerView/PomodoroControls
@onready var pomodoro_pause_button: Button = $PetPopup/MarginContainer/VBoxContainer/PomodoroPanel/PomodoroTimerView/PomodoroControls/PomodoroPauseButton
@onready var pomodoro_stop_button: Button = $PetPopup/MarginContainer/VBoxContainer/PomodoroPanel/PomodoroTimerView/PomodoroControls/PomodoroStopButton

@onready var pomodoro_sound: AudioStreamPlayer = $PomodoroSound
@onready var set_input: LineEdit = $PetPopup/MarginContainer/VBoxContainer/PomodoroPanel/PomodoroBottomRow/SetRow/SetInput
@onready var pomodoro_bottom_row: HBoxContainer = $PetPopup/MarginContainer/VBoxContainer/PomodoroPanel/PomodoroBottomRow


@onready var water_reminder_timer: Timer = $WaterReminderTimer
@onready var water_reminder_bubble: PanelContainer = $WaterReminderBubble
@onready var water_reminder_label: Label = $WaterReminderBubble/MarginContainer/WaterReminderLabel

@onready var water_reminder_left_marker: Marker2D = $WaterReminderLeftMarker
@onready var water_reminder_right_marker: Marker2D = $WaterReminderRightMarker

@onready var todo_panel: VBoxContainer = $PetPopup/MarginContainer/VBoxContainer/TodoPanel
@onready var todo_text_edit: TextEdit = $PetPopup/MarginContainer/VBoxContainer/TodoPanel/TodoTextEdit
@onready var todo_back_button: Button = $PetPopup/MarginContainer/VBoxContainer/TodoPanel/TodoBottomRow/TodoBackButton
@onready var todo_title_label: Label = $PetPopup/MarginContainer/VBoxContainer/TodoPanel/TodoTitleLabel
@onready var bullet_button: Button = $PetPopup/MarginContainer/VBoxContainer/TodoPanel/TodoToolbar/BulletButton

@export var work_done_sound: AudioStream
@export var break_done_sound: AudioStream


var current_state: State = State.IDLE

var direction: float = -1.0
var window_x: float = 0.0

var usable_rect: Rect2i


var water_ml: int = 0
var water_entries: Array[int] = []

const WATER_SAVE_PATH := "user://water_data.json"
const TODO_SAVE_PATH := "user://todo_data.json"


enum PomodoroState {
	NONE,
	PREPARE,
	WORK,
	BREAK
}


var pomodoro_state: PomodoroState = PomodoroState.NONE

var pomodoro_work_seconds: int = 0
var pomodoro_break_seconds: int = 0
var pomodoro_remaining_seconds: int = 0

var pomodoro_paused: bool = false
var pomodoro_total_sets: int = 1
var pomodoro_current_set: int = 1


const MAIN_POPUP_SIZE := Vector2i(320, 200)
const TODO_POPUP_SIZE := Vector2i(400, 450)

var water_reminder_messages: Array[String] = [
	"TIME FOR SOME WATER!",
	"HYDRATION CHECK!",
	"GO GRAB SOME WATER!",
	"DON'T FORGET TO DRINK!",
	"A LITTLE WATER BREAK?",
	"YOUR WATER IS WAITING!"
]


func _ready() -> void:
	print("Sevda uyandı!")

	exit_panel.visible = false
	pomodoro_panel.visible = false
	water_panel.visible = false
	
	todo_panel.visible = false
	load_todo_data()

	water_reminder_bubble.visible = false
	start_water_reminder_timer()

	load_water_data()
	update_water_total()

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

	change_state(State.IDLE)


func change_state(new_state: State) -> void:
	current_state = new_state

	match current_state:

		State.IDLE:
			state_timer.stop()

			happy_bubble.visible = false
			happy_bubble_right.visible = false
			peck_bubble.visible = false

			sevda.play("idle")

			start_blink_timer()
			start_sleep_timer()
			start_move_wait()


		State.MOVING:
			blink_timer.stop()
			sleep_timer.stop()

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
			water_reminder_bubble.visible = false

			sevda.play("sleep")


		State.HAPPY:
			state_timer.stop()
			blink_timer.stop()
			sleep_timer.stop()

			peck_bubble.visible = false

			happy_bubble.visible = false
			happy_bubble_right.visible = false

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
		if randf() < 0.60:

			var min_x := float(usable_rect.position.x)

			var max_x := float(
				usable_rect.position.x
				+ usable_rect.size.x
				- get_window().size.x
			)

			if window_x >= max_x - 5.0:
				direction = -1.0

			elif window_x <= min_x + 5.0:
				direction = 1.0

			else:
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

	if not event is InputEventMouseButton:
		return

	if not event.pressed:
		return

	# SAĞ TIK
	if event.button_index == MOUSE_BUTTON_RIGHT:

		if current_state == State.SLEEPING:
			change_state(State.IDLE)

		var popup_size := MAIN_POPUP_SIZE

		# Eğer To Do ekranındaysak büyük boyutu koru.
		if todo_panel.visible:
			popup_size = TODO_POPUP_SIZE

		pet_popup.popup(
			Rect2i(
				get_window().position + Vector2i(-40, -210),
				popup_size
			)
		)

		return


	# SOL TIK
	if event.button_index == MOUSE_BUTTON_LEFT:

		if water_reminder_bubble.visible:
			return

		if current_state == State.SLEEPING:
			change_state(State.PECKING)

		elif current_state == State.IDLE:
			change_state(State.HAPPY)


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


# --------------------------------------------------
# WATER TRACKER
# --------------------------------------------------

func _on_water_button_pressed() -> void:
	menu_title.visible = false
	todo_button.visible = false
	pomodoro_button.visible = false
	water_button.visible = false
	exit_button.visible = false

	water_panel.visible = true


func _on_water_back_button_pressed() -> void:
	water_panel.visible = false

	menu_title.visible = true
	todo_button.visible = true
	pomodoro_button.visible = true
	water_button.visible = true
	exit_button.visible = true

	await get_tree().process_frame
	pet_popup.size = MAIN_POPUP_SIZE


func update_water_total() -> void:
	water_total.text = "TODAY: " + str(water_ml) + " ML"


func _on_water_200_button_pressed() -> void:
	add_water(200)


func _on_water_250_button_pressed() -> void:
	add_water(250)


func _on_water_330_button_pressed() -> void:
	add_water(330)


func _on_water_500_button_pressed() -> void:
	add_water(500)


func _on_water_400_button_pressed() -> void:
	add_water(400)


func _on_water_750_button_pressed() -> void:
	add_water(750)


func add_water(amount_ml: int) -> void:
	if amount_ml <= 0:
		return

	water_ml += amount_ml
	water_entries.append(amount_ml)

	update_water_total()
	save_water_data()


func _on_custom_add_button_pressed() -> void:
	var text_value := custom_ml_input.text.strip_edges()

	if not text_value.is_valid_int():
		return

	var amount_ml := int(text_value)

	if amount_ml <= 0:
		return

	add_water(amount_ml)

	custom_ml_input.clear()


func _on_remove_last_button_pressed() -> void:
	if water_entries.is_empty():
		return

	var last_amount: int = water_entries.pop_back()

	water_ml -= last_amount

	if water_ml < 0:
		water_ml = 0

	update_water_total()
	save_water_data()


func save_water_data() -> void:
	var data := {
		"date": Time.get_date_string_from_system(),
		"water_ml": water_ml,
		"entries": water_entries
	}

	var file := FileAccess.open(WATER_SAVE_PATH, FileAccess.WRITE)

	if file == null:
		print("Water data could not be saved.")
		return

	file.store_string(JSON.stringify(data))
	file.close()


func load_water_data() -> void:
	if not FileAccess.file_exists(WATER_SAVE_PATH):
		water_ml = 0
		water_entries.clear()
		return

	var file := FileAccess.open(WATER_SAVE_PATH, FileAccess.READ)

	if file == null:
		return

	var json_text := file.get_as_text()
	file.close()

	var data = JSON.parse_string(json_text)

	if typeof(data) != TYPE_DICTIONARY:
		water_ml = 0
		water_entries.clear()
		return

	var today := Time.get_date_string_from_system()
	var saved_date: String = str(data.get("date", ""))

	if saved_date != today:
		water_ml = 0
		water_entries.clear()
		save_water_data()
		return

	water_ml = int(data.get("water_ml", 0))

	water_entries.clear()

	var saved_entries = data.get("entries", [])

	for entry in saved_entries:
		water_entries.append(int(entry))


# --------------------------------------------------
# POMODORO
# --------------------------------------------------

func _on_pomodoro_button_pressed() -> void:
	menu_title.visible = false
	todo_button.visible = false
	pomodoro_button.visible = false
	water_button.visible = false
	exit_button.visible = false

	water_panel.visible = false
	pomodoro_panel.visible = true


func _on_pomodoro_back_button_pressed() -> void:
	pomodoro_panel.visible = false

	menu_title.visible = true
	todo_button.visible = true
	pomodoro_button.visible = true
	water_button.visible = true
	exit_button.visible = true

	await get_tree().process_frame
	pet_popup.size = MAIN_POPUP_SIZE


func _on_pomodoro_25_button_pressed() -> void:
	start_pomodoro(25, 5)


func _on_pomodoro_30_button_pressed() -> void:
	start_pomodoro(30, 5)


func _on_pomodoro_50_button_pressed() -> void:
	start_pomodoro(50, 10)


func _on_pomodoro_60_button_pressed() -> void:
	start_pomodoro(60, 10)


func start_pomodoro(work_minutes: int, break_minutes: int) -> void:
	var set_text := set_input.text.strip_edges()

	if set_text.is_valid_int():
		pomodoro_total_sets = max(int(set_text), 1)
	else:
		pomodoro_total_sets = 1

	pomodoro_current_set = 1

	pomodoro_work_seconds = work_minutes * 60
	pomodoro_break_seconds = break_minutes * 60

	pomodoro_state = PomodoroState.PREPARE
	pomodoro_remaining_seconds = 5 * 60

	focus_sevda.visible = true
	working_sevda.visible = false
	break_sevda.visible = false

	pomodoro_skip_button.visible = true
	pomodoro_controls.visible = false
	pomodoro_paused = false

	show_pomodoro_timer_view()
	update_pomodoro_display()

	pomodoro_timer.start()


func show_pomodoro_timer_view() -> void:
	$PetPopup/MarginContainer/VBoxContainer/PomodoroPanel/PomodoroRow1.visible = false
	$PetPopup/MarginContainer/VBoxContainer/PomodoroPanel/PomodoroRow2.visible = false

	pomodoro_bottom_row.visible = false
	pomodoro_timer_view.visible = true


func update_pomodoro_display() -> void:
	var minutes := pomodoro_remaining_seconds / 60
	var seconds := pomodoro_remaining_seconds % 60

	pomodoro_time_label.text = "%02d:%02d" % [minutes, seconds]

	match pomodoro_state:
		PomodoroState.PREPARE:
			pomodoro_phase_label.text = "GET READY!"

		PomodoroState.WORK:
			pomodoro_phase_label.text = "WORKING TIME!  " + str(pomodoro_current_set) + "/" + str(pomodoro_total_sets)

		PomodoroState.BREAK:
			pomodoro_phase_label.text = "BREAK TIME!  " + str(pomodoro_current_set) + "/" + str(pomodoro_total_sets)


func _on_pomodoro_timer_timeout() -> void:
	if pomodoro_state == PomodoroState.NONE:
		return

	pomodoro_remaining_seconds -= 1

	if pomodoro_remaining_seconds <= 0:

		if pomodoro_state == PomodoroState.PREPARE:
			start_work_phase()
			return

		elif pomodoro_state == PomodoroState.WORK:
			play_work_done_sound()

			if pomodoro_current_set >= pomodoro_total_sets:
				finish_pomodoro_cycle()
				return

			start_break_phase()
			return

		elif pomodoro_state == PomodoroState.BREAK:
			play_break_done_sound()

			pomodoro_current_set += 1
			start_work_phase()
			return

	update_pomodoro_display()


func _on_pomodoro_skip_button_pressed() -> void:
	if pomodoro_state == PomodoroState.PREPARE:
		start_work_phase()


func start_work_phase() -> void:
	pomodoro_state = PomodoroState.WORK
	pomodoro_remaining_seconds = pomodoro_work_seconds
	pomodoro_paused = false

	focus_sevda.visible = false
	working_sevda.visible = true
	break_sevda.visible = false

	pomodoro_skip_button.visible = false
	pomodoro_controls.visible = true
	pomodoro_pause_button.text = "PAUSE"

	update_pomodoro_display()

	if pomodoro_timer.is_stopped():
		pomodoro_timer.start()


func _on_pomodoro_pause_button_pressed() -> void:
	if pomodoro_state == PomodoroState.NONE:
		return

	pomodoro_paused = not pomodoro_paused

	if pomodoro_paused:
		pomodoro_timer.stop()
		pomodoro_pause_button.text = "RESUME"

	else:
		pomodoro_timer.start()
		pomodoro_pause_button.text = "PAUSE"


func _on_pomodoro_stop_button_pressed() -> void:
	pomodoro_timer.stop()

	pomodoro_state = PomodoroState.NONE
	pomodoro_remaining_seconds = 0
	pomodoro_paused = false

	focus_sevda.visible = false
	working_sevda.visible = false
	break_sevda.visible = false
	pomodoro_timer_view.visible = false

	$PetPopup/MarginContainer/VBoxContainer/PomodoroPanel/PomodoroRow1.visible = true
	$PetPopup/MarginContainer/VBoxContainer/PomodoroPanel/PomodoroRow2.visible = true
	pomodoro_bottom_row.visible = true

	await get_tree().process_frame
	pet_popup.size = MAIN_POPUP_SIZE


func start_break_phase() -> void:
	pomodoro_state = PomodoroState.BREAK
	pomodoro_remaining_seconds = pomodoro_break_seconds
	pomodoro_paused = false

	focus_sevda.visible = false
	working_sevda.visible = false
	break_sevda.visible = true

	pomodoro_skip_button.visible = false
	pomodoro_controls.visible = true
	pomodoro_pause_button.text = "PAUSE"

	update_pomodoro_display()

	if pomodoro_timer.is_stopped():
		pomodoro_timer.start()


func finish_pomodoro_cycle() -> void:
	pomodoro_timer.stop()

	pomodoro_state = PomodoroState.NONE
	pomodoro_remaining_seconds = 0
	pomodoro_paused = false

	focus_sevda.visible = false
	working_sevda.visible = false
	break_sevda.visible = false

	pomodoro_skip_button.visible = false
	pomodoro_controls.visible = false
	pomodoro_timer_view.visible = false

	$PetPopup/MarginContainer/VBoxContainer/PomodoroPanel/PomodoroRow1.visible = true
	$PetPopup/MarginContainer/VBoxContainer/PomodoroPanel/PomodoroRow2.visible = true
	pomodoro_bottom_row.visible = true

	await get_tree().process_frame
	pet_popup.size = MAIN_POPUP_SIZE


func play_work_done_sound() -> void:
	if work_done_sound == null:
		print("HATA: work_done_sound boş!")
		return

	pomodoro_sound.stream = work_done_sound
	pomodoro_sound.play()


func play_break_done_sound() -> void:
	if break_done_sound == null:
		print("HATA: break_done_sound boş!")
		return

	pomodoro_sound.stream = break_done_sound
	pomodoro_sound.play()


# --------------------------------------------------
# EXIT
# --------------------------------------------------

func _on_exit_button_pressed() -> void:
	menu_title.visible = false
	todo_button.visible = false
	pomodoro_button.visible = false
	water_button.visible = false
	exit_button.visible = false

	water_panel.visible = false
	pomodoro_panel.visible = false

	exit_panel.visible = true


func _on_exit_cancel_button_pressed() -> void:
	exit_panel.visible = false

	menu_title.visible = true
	todo_button.visible = true
	pomodoro_button.visible = true
	water_button.visible = true
	exit_button.visible = true

	await get_tree().process_frame
	pet_popup.size = MAIN_POPUP_SIZE


func _on_exit_confirm_button_pressed() -> void:
	get_tree().quit()


# --------------------------------------------------
# WATER REMINDER
# --------------------------------------------------

func start_water_reminder_timer() -> void:
	water_reminder_timer.wait_time = randf_range(
		35.0 * 60.0,
		75.0 * 60.0
	)

	water_reminder_timer.start()


func _on_water_reminder_timer_timeout() -> void:
	if current_state == State.SLEEPING:
		start_water_reminder_timer()
		return

	show_water_reminder()


func show_water_reminder() -> void:
	if current_state == State.SLEEPING:
		start_water_reminder_timer()
		return

	if water_reminder_messages.is_empty():
		return

	water_reminder_label.text = water_reminder_messages.pick_random()
	water_reminder_bubble.visible = true

	await get_tree().process_frame

	var marker_pos: Vector2

	if sevda.flip_h:
		marker_pos = water_reminder_left_marker.global_position
	else:
		marker_pos = water_reminder_right_marker.global_position

	water_reminder_bubble.global_position = Vector2(
		marker_pos.x - water_reminder_bubble.size.x / 2.0,
		marker_pos.y - water_reminder_bubble.size.y - 15.0
	)

	hide_water_reminder_later()


func hide_water_reminder_later() -> void:
	await get_tree().create_timer(5.0).timeout

	water_reminder_bubble.visible = false

	start_water_reminder_timer()
	
func _on_todo_button_pressed() -> void:
	menu_title.visible = false
	todo_button.visible = false
	pomodoro_button.visible = false
	water_button.visible = false
	exit_button.visible = false

	water_panel.visible = false
	pomodoro_panel.visible = false
	exit_panel.visible = false

	load_todo_data()

	todo_panel.visible = true

	await get_tree().process_frame

	pet_popup.size = TODO_POPUP_SIZE

	await get_tree().process_frame

	# Popup ekranın dışına taşmasın.
	var screen_rect := DisplayServer.screen_get_usable_rect()

	var popup_x := clampi(
		pet_popup.position.x,
		screen_rect.position.x,
		screen_rect.position.x + screen_rect.size.x - pet_popup.size.x
	)

	var popup_y := clampi(
		pet_popup.position.y,
		screen_rect.position.y,
		screen_rect.position.y + screen_rect.size.y - pet_popup.size.y
	)

	pet_popup.position = Vector2i(popup_x, popup_y)

	todo_text_edit.grab_focus()

	var last_line := todo_text_edit.get_line_count() - 1
	todo_text_edit.set_caret_line(last_line)
	todo_text_edit.set_caret_column(
		todo_text_edit.get_line(last_line).length()
	)
	
	
func save_todo_data() -> void:
	var data := {
		"text": todo_text_edit.text
	}

	var file := FileAccess.open(TODO_SAVE_PATH, FileAccess.WRITE)

	if file == null:
		print("Todo data could not be saved.")
		return

	file.store_string(JSON.stringify(data))
	file.close()
	
func load_todo_data() -> void:
	if not FileAccess.file_exists(TODO_SAVE_PATH):
		todo_text_edit.text = ""
		return

	var file := FileAccess.open(TODO_SAVE_PATH, FileAccess.READ)

	if file == null:
		return

	var json_text := file.get_as_text()
	file.close()

	var data = JSON.parse_string(json_text)

	if typeof(data) != TYPE_DICTIONARY:
		todo_text_edit.text = ""
		return

	todo_text_edit.text = str(data.get("text", ""))

func _on_todo_back_button_pressed() -> void:
	save_todo_data()

	todo_panel.visible = false

	menu_title.visible = true
	todo_button.visible = true
	pomodoro_button.visible = true
	water_button.visible = true
	exit_button.visible = true

	await get_tree().process_frame
	pet_popup.size = MAIN_POPUP_SIZE


func _on_todo_title_label_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			pet_popup.start_drag()

func _on_todo_save_button_pressed() -> void:
	save_todo_data()

	todo_panel.visible = false

	menu_title.visible = true
	todo_button.visible = true
	pomodoro_button.visible = true
	water_button.visible = true
	exit_button.visible = true

	await get_tree().process_frame
	pet_popup.size = MAIN_POPUP_SIZE


func _on_pet_popup_popup_hide() -> void:
	if todo_panel.visible:
		save_todo_data()


func _on_bullet_button_pressed() -> void:
	var line := todo_text_edit.get_caret_line()
	var line_text := todo_text_edit.get_line(line)

	if line_text.begins_with("• "):
		line_text = line_text.trim_prefix("• ")
	else:
		line_text = "• " + line_text

	todo_text_edit.set_line(line, line_text)

	todo_text_edit.set_caret_column(line_text.length())
	todo_text_edit.grab_focus()


func _on_todo_text_edit_gui_input(event: InputEvent) -> void:
	if not event is InputEventKey:
		return

	if not event.pressed:
		return

	if event.keycode != KEY_ENTER and event.keycode != KEY_KP_ENTER:
		return

	var line := todo_text_edit.get_caret_line()
	var line_text := todo_text_edit.get_line(line)

	if not line_text.begins_with("• "):
		return

	# Sadece "• " varsa liste modundan çık
	if line_text.strip_edges() == "•":
		todo_text_edit.set_line(line, "")
		todo_text_edit.insert_text_at_caret("\n")
	else:
		# Yeni bullet satırı
		todo_text_edit.insert_text_at_caret("\n• ")

	todo_text_edit.accept_event()
