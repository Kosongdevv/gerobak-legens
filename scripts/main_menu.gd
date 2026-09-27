extends Control

const ATLAS = preload("res://assets/ui_atlas.png")
const FONT = preload("res://assets/Font/Peaberry Base/PeaberryBase.woff")

signal save_reset

func _ready() -> void:
    _build_menu()

func _atlas_region(rect: Rect2) -> AtlasTexture:
    var t := AtlasTexture.new()
    t.atlas = ATLAS
    t.region = rect
    return t

func _panel(light: bool, pos: Vector2, size: Vector2) -> NinePatchRect:
    var p := NinePatchRect.new()
    p.texture = _atlas_region(Rect2(0, 32 if light else 64, 128, 32))
    p.patch_margin_left = 14
    p.patch_margin_top = 14
    p.patch_margin_right = 14
    p.patch_margin_bottom = 14
    p.position = pos
    p.size = size
    return p

func _label(value: String, size: int, color: Color) -> Label:
    var l := Label.new()
    l.text = value
    l.add_theme_font_override("font", FONT)
    l.add_theme_font_size_override("font_size", size)
    l.add_theme_color_override("font_color", color)
    l.add_theme_constant_override("outline_size", 3)
    l.add_theme_color_override("font_outline_color", Color(0.10,0.06,0.06,0.75))
    return l

func _build_menu() -> void:
    # Keep the original scene nodes hidden; this only upgrades the presentation.
    for child in get_children():
        child.visible = false

    var bg := ColorRect.new()
    bg.color = Color("#8f4c49")
    bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
    add_child(bg)

    var shade := ColorRect.new()
    shade.color = Color(0.08,0.05,0.05,0.24)
    shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    shade.mouse_filter = Control.MOUSE_FILTER_IGNORE
    add_child(shade)

    # --- Title block: full-width anchors so it always stays centered on any
    # screen size / aspect ratio (no more hardcoded 1157px width). ---
    var title := _label("GEROBAK LEGENDS", 48, Color("#fff1d6"))
    title.anchor_left = 0.0
    title.anchor_right = 1.0
    title.anchor_top = 0.0
    title.anchor_bottom = 0.0
    title.offset_left = 0
    title.offset_right = 0
    title.offset_top = 54
    title.offset_bottom = 54 + 64
    title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    title.autowrap_mode = TextServer.AUTOWRAP_OFF
    title.clip_text = false
    add_child(title)

    var subtitle := _label("WARUNG BAKSO PIXEL", 18, Color("#f4d8bd"))
    subtitle.anchor_left = 0.0
    subtitle.anchor_right = 1.0
    subtitle.anchor_top = 0.0
    subtitle.anchor_bottom = 0.0
    subtitle.offset_left = 0
    subtitle.offset_right = 0
    subtitle.offset_top = 126
    subtitle.offset_bottom = 126 + 32
    subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    add_child(subtitle)

    # --- Menu panel: anchored to the exact screen center point, so it never
    # drifts to one side regardless of resolution. ---
    var panel_size := Vector2(394, 270)
    var menu_panel := _panel(false, Vector2.ZERO, panel_size)
    menu_panel.set_anchors_preset(Control.PRESET_CENTER)
    menu_panel.position = Vector2(-panel_size.x/2.0, -panel_size.y/2.0 + 30)
    add_child(menu_panel)

    var menu_title := _label("MENU UTAMA", 22, Color("#ece8f1"))
    menu_title.position=Vector2(0,18); menu_title.size=Vector2(394,34); menu_title.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER; menu_panel.add_child(menu_title)

    _make_button(menu_panel, "MULAI JUALAN", Vector2(48,72), _on_play_pressed)
    _make_button(menu_panel, "RESET DATA", Vector2(48,132), _on_resetbutoon_pressed)
    _make_button(menu_panel, "KELUAR", Vector2(48,192), _on_quit_pressed)

    var hint := _label("PC: WASD / ARROW  •  HP: D-PAD", 12, Color("#f0d7ca"))
    hint.anchor_left = 0.0
    hint.anchor_right = 1.0
    hint.anchor_top = 1.0
    hint.anchor_bottom = 1.0
    hint.offset_left = 0
    hint.offset_right = 0
    hint.offset_top = -50
    hint.offset_bottom = -26
    hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    add_child(hint)

func _make_button(parent: Control, text_value: String, pos: Vector2, action: Callable) -> void:
    var b := TextureButton.new()
    # NOTE: hover used to point at a 32x32 icon region from the atlas instead
    # of the full button panel, which made the button visually collapse into
    # a tiny square right before a click. Both states now use the same
    # full-width panel art, and a small tween handles the "press" feedback
    # instead of relying on texture swapping.
    b.texture_normal = _atlas_region(Rect2(0,32,128,32))
    b.texture_hover = _atlas_region(Rect2(0,32,128,32))
    b.texture_pressed = _atlas_region(Rect2(0,64,128,32))
    b.ignore_texture_size = true
    b.stretch_mode = TextureButton.STRETCH_KEEP_ASPECT_CENTERED
    b.position = pos
    b.size = Vector2(298,48)
    b.pivot_offset = b.size / 2.0
    b.pressed.connect(action)
    parent.add_child(b)

    var l := _label(text_value, 16, Color("#343142"))
    l.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    l.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
    l.vertical_alignment=VERTICAL_ALIGNMENT_CENTER
    l.mouse_filter=Control.MOUSE_FILTER_IGNORE
    b.add_child(l)

    # Gentle, deliberate press animation: scales down slightly on press and
    # springs back on release/hover-out. Runs from the button's own center
    # (pivot_offset above) so it never looks like it's jumping sideways.
    b.button_down.connect(func():
        var t := create_tween()
        t.tween_property(b, "scale", Vector2(0.92, 0.92), 0.06).set_trans(Tween.TRANS_SINE)
    )
    b.button_up.connect(func():
        var t := create_tween()
        t.tween_property(b, "scale", Vector2(1.0, 1.0), 0.12).set_trans(Tween.TRANS_BACK)
    )

func _on_quit_pressed() -> void:
    get_tree().quit()

func _on_play_pressed() -> void:
    get_tree().change_scene_to_file("res://scenes/game.tscn")

func _on_resetbutoon_pressed() -> void:
    reset_save()

func reset_save() -> void:
    _delete_save_file()
    _reset_game_state()
    save_reset.emit()

func _delete_save_file() -> void:
    if FileAccess.file_exists(GameManager.SAVE_PATH):
        var dir := DirAccess.open("user://")
        if dir:
            dir.remove(GameManager.SAVE_PATH.get_file())

func _reset_game_state() -> void:
    GameManager.money = 0.0
    GameManager.current_level = 1
    for key in GameManager.bahan.keys():
        GameManager.bahan[key] = 0
    for key in GameManager.bakso.keys():
        GameManager.bakso[key] = 0
    GameManager.save_game()
