extends Control

const ATLAS = preload("res://assets/ui_atlas.png")
const COIN = preload("res://assets/display/uang.png")
const SHOP_BUTTON = preload("res://assets/shop/shop_button.png")
const SHOP_BUTTON_PRESSED = preload("res://assets/shop/shop_button_pressed.png")
const CLOSE = preload("res://assets/shop/close.png")

const ITEMS := [
    {"id":"stok_bakso", "name":"BAKSO", "icon":"bakso.png", "price":50},
    {"id":"stok_sayur", "name":"SELADA", "icon":"sayur.png", "price":15},
    {"id":"stok_kecap", "name":"KECAP", "icon":"kecap.png", "price":40},
    {"id":"stok_saos", "name":"SAUS", "icon":"saos.png", "price":20},
    {"id":"stok_bihun", "name":"MIE", "icon":"bihun.png", "price":20},
    {"id":"stok_pangsit", "name":"PANGSIT GORENG", "icon":"pangsit.png", "price":100},
    {"id":"stok_pangsit_basah", "name":"PANGSIT BASAH", "icon":"pangsit_basah.png", "price":30}
]

var popup: Control
var overlay: ColorRect
var money_label: Label
var stock_labels: Array[Label] = []
var buy_buttons: Array[TextureButton] = []
var shop_button: TextureButton
var player: CharacterBody2D

func _ready() -> void:
    set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    mouse_filter = Control.MOUSE_FILTER_IGNORE
    player = get_parent().get_parent() as CharacterBody2D
    _build_shop_button()
    _build_popup()
    GameManager.money_changed.connect(_refresh)
    GameManager.stok_changed.connect(_refresh)
    _refresh()

func _atlas_region(rect: Rect2) -> AtlasTexture:
    var t := AtlasTexture.new()
    t.atlas = ATLAS
    t.region = rect
    return t

func _panel_texture(light: bool) -> AtlasTexture:
    return _atlas_region(Rect2(0, 32 if light else 64, 128, 32))

func _label(text_value: String, size: int, color: Color) -> Label:
    var l := Label.new()
    l.text = text_value
    l.add_theme_font_override("font", load("res://assets/Font/Peaberry Base/PeaberryBase.woff"))
    l.add_theme_font_size_override("font_size", size)
    l.add_theme_color_override("font_color", color)
    l.add_theme_constant_override("outline_size", 2)
    l.add_theme_color_override("font_outline_color", Color(0.08,0.07,0.12,0.75))
    return l

func _build_shop_button() -> void:
    shop_button = TextureButton.new()
    shop_button.name = "ShopButton"
    shop_button.texture_normal = SHOP_BUTTON
    shop_button.texture_hover = SHOP_BUTTON_PRESSED
    shop_button.texture_pressed = SHOP_BUTTON_PRESSED
    shop_button.ignore_texture_size = true
    shop_button.stretch_mode = TextureButton.STRETCH_KEEP_ASPECT_CENTERED
    shop_button.set_anchors_preset(Control.PRESET_TOP_RIGHT)
    shop_button.position = Vector2(-185, 18)
    shop_button.size = Vector2(160, 40)
    shop_button.mouse_filter = Control.MOUSE_FILTER_STOP
    shop_button.pressed.connect(_toggle_shop)
    add_child(shop_button)

    var text := _label("SHOP", 18, Color("#3b354b"))
    text.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    text.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    text.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
    text.mouse_filter = Control.MOUSE_FILTER_IGNORE
    shop_button.add_child(text)

func _build_popup() -> void:
    overlay = ColorRect.new()
    overlay.color = Color(0.05, 0.04, 0.07, 0.62)
    overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    overlay.visible = false
    overlay.mouse_filter = Control.MOUSE_FILTER_STOP
    add_child(overlay)

    popup = Control.new()
    popup.name = "ShopPopup"
    popup.set_anchors_preset(Control.PRESET_CENTER)
    popup.position = Vector2(-360, -245)
    popup.size = Vector2(720, 490)
    overlay.add_child(popup)

    var frame := NinePatchRect.new()
    frame.texture = _panel_texture(false)
    frame.patch_margin_left = 14
    frame.patch_margin_top = 14
    frame.patch_margin_right = 14
    frame.patch_margin_bottom = 14
    frame.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
    popup.add_child(frame)

    var header := NinePatchRect.new()
    header.texture = _panel_texture(true)
    header.patch_margin_left = 14
    header.patch_margin_top = 14
    header.patch_margin_right = 14
    header.patch_margin_bottom = 14
    header.position = Vector2(18, 18)
    header.size = Vector2(684, 72)
    header.mouse_filter = Control.MOUSE_FILTER_IGNORE
    popup.add_child(header)

    var title := _label("GEROBAK LEGENDS", 23, Color("#2f2d3d"))
    title.position = Vector2(22, 6)
    title.size = Vector2(350, 30)
    header.add_child(title)
    var subtitle := _label("TOKO BAHAN BAKSO", 13, Color("#57556a"))
    subtitle.position = Vector2(24, 37)
    subtitle.size = Vector2(280, 22)
    header.add_child(subtitle)

    var coin := TextureRect.new()
    coin.texture = COIN
    coin.position = Vector2(545, 23)
    coin.size = Vector2(24,24)
    coin.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
    coin.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
    header.add_child(coin)
    money_label = _label("0", 18, Color("#2f2d3d"))
    money_label.position = Vector2(574, 17)
    money_label.size = Vector2(75, 30)
    header.add_child(money_label)

    var close := TextureButton.new()
    close.texture_normal = CLOSE
    close.texture_hover = CLOSE
    close.texture_pressed = CLOSE
    close.ignore_texture_size = true
    close.stretch_mode = TextureButton.STRETCH_KEEP_ASPECT_CENTERED
    close.position = Vector2(650, 21)
    close.size = Vector2(28,28)
    close.pressed.connect(_close_shop)
    header.add_child(close)

    var tip := _label("BELI BAHAN UNTUK MASAK • +5 STOK", 12, Color("#dcd8e5"))
    tip.position = Vector2(24, 100)
    tip.size = Vector2(400, 24)
    popup.add_child(tip)

    for i in range(ITEMS.size()):
        _create_item(i)

func _create_item(index: int) -> void:
    var item: Dictionary = ITEMS[index]
    var col := index % 2
    var row := index / 2
    var x := 20.0 + col * 342.0
    var y := 132.0 + row * 76.0

    # keep a lone item in the final row centered instead of stuck on the left,
    # so the grid always looks tidy even with an odd number of items
    var is_last_alone := index == ITEMS.size() - 1 and ITEMS.size() % 2 == 1
    if is_last_alone:
        x = 191.0

    var card := NinePatchRect.new()
    card.texture = _panel_texture(true)
    card.patch_margin_left = 10
    card.patch_margin_top = 10
    card.patch_margin_right = 10
    card.patch_margin_bottom = 10
    card.position = Vector2(x,y)
    card.size = Vector2(326,66)
    card.mouse_filter = Control.MOUSE_FILTER_IGNORE
    popup.add_child(card)

    var icon := TextureRect.new()
    icon.texture = load("res://assets/shop/" + item["icon"])
    icon.position = Vector2(12,10)
    icon.size = Vector2(46,46)
    icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
    icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
    icon.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
    icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
    card.add_child(icon)

    var name_size := 14 if String(item["name"]).length() <= 8 else 11
    var name := _label(item["name"], name_size, Color("#363346"))
    name.position = Vector2(68,8)
    name.size = Vector2(115,22)
    name.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
    card.add_child(name)

    var stock := _label("STOK 0", 11, Color("#5b5869"))
    stock.position = Vector2(68,34)
    stock.size = Vector2(110,18)
    stock_labels.append(stock)
    card.add_child(stock)

    var coin := TextureRect.new()
    coin.texture = COIN
    coin.position = Vector2(182,30)
    coin.size = Vector2(18,18)
    coin.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
    coin.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
    coin.mouse_filter = Control.MOUSE_FILTER_IGNORE
    card.add_child(coin)

    var price := _label(str(item["price"]), 12, Color("#454054"))
    price.position = Vector2(204,29)
    price.size = Vector2(40,20)
    card.add_child(price)

    var buy := TextureButton.new()
    buy.texture_normal = SHOP_BUTTON
    buy.texture_hover = SHOP_BUTTON_PRESSED
    buy.texture_pressed = SHOP_BUTTON_PRESSED
    buy.ignore_texture_size = true
    buy.stretch_mode = TextureButton.STRETCH_KEEP_ASPECT_CENTERED
    buy.position = Vector2(244,16)
    buy.size = Vector2(70,34)
    buy.mouse_filter = Control.MOUSE_FILTER_STOP
    buy.pressed.connect(_buy.bind(index))
    card.add_child(buy)
    buy_buttons.append(buy)

    var buy_text := _label("BELI", 11, Color("#3b354b"))
    buy_text.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    buy_text.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    buy_text.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
    buy_text.mouse_filter = Control.MOUSE_FILTER_IGNORE
    buy.add_child(buy_text)

func _toggle_shop() -> void:
    overlay.visible = not overlay.visible
    if player:
        player.set_physics_process(not overlay.visible)
    if overlay.visible:
        _refresh()

func _close_shop() -> void:
    overlay.visible = false
    if player:
        player.set_physics_process(true)

func _buy(index: int) -> void:
    var item: Dictionary = ITEMS[index]
    if GameManager.spend_money(float(item["price"])):
        GameManager.tambah_stok(item["id"], 5)
        _refresh()

func _refresh(_value = null) -> void:
    if not is_instance_valid(money_label):
        return
    money_label.text = str(int(GameManager.money))
    for i in range(stock_labels.size()):
        var item: Dictionary = ITEMS[i]
        stock_labels[i].text = "STOK %d" % int(GameManager.bahan.get(item["id"], 0))
        buy_buttons[i].disabled = GameManager.money < float(item["price"])
