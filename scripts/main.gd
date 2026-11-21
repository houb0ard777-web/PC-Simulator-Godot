extends Control

var money: float = 30000.0
var crypto: float = 0.0
var owned: Array[String] = []
var equipped: String = "RX 580"
var catalog: Array[Dictionary] = []
var info: Label
var list_box: VBoxContainer
var timer: Timer

func _ready() -> void:
    _create_catalog()
    _load_game()
    var bg := ColorRect.new()
    bg.color = Color(0.055, 0.075, 0.12)
    bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    add_child(bg)
    var scroll := ScrollContainer.new()
    scroll.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    add_child(scroll)
    list_box = VBoxContainer.new()
    list_box.add_theme_constant_override("separation", 12)
    scroll.add_child(list_box)
    info = Label.new()
    list_box.add_child(info)
    _button("Продать крипту (1 кр = 1000 ₽)", _sell_crypto)
    _button("Сохранить игру", _save_game)
    var heading := Label.new()
    heading.text = "МАГАЗИН ВИДЕОКАРТ — прототип"
    list_box.add_child(heading)
    for item in catalog:
        var card: Dictionary = item
        _button("%s — %d ₽" % [card.name, card.price], func(): _buy(card))
    timer = Timer.new()
    timer.wait_time = 1.0
    timer.autostart = true
    timer.timeout.connect(_tick)
    add_child(timer)
    _refresh()

func _button(caption: String, callback: Callable) -> void:
    var button := Button.new()
    button.text = caption
    button.custom_minimum_size = Vector2(330, 55)
    button.pressed.connect(callback)
    list_box.add_child(button)

func _create_catalog() -> void:
    var names: Array[String] = ["RX 580", "GTX 1050 Ti", "GTX 1060", "GTX 1070", "GTX 1080 Ti", "RTX 2060", "RTX 2070", "RTX 2080 Ti", "RTX 3060", "RTX 3070", "RTX 3080", "RTX 3090", "RTX 4060", "RTX 4070", "RTX 4080", "RTX 4090", "RTX 5060", "RTX 5070", "RTX 5080", "RTX 5090", "RTX BlackView 5090", "RX 6600", "RX 6700 XT", "RX 6800 XT", "RX 6900 XT", "RX 7600", "RX 7700 XT", "RX 7800 XT", "RX 7900 XTX", "RX 9070 XT"]
    for i in range(names.size()):
        catalog.append({"name": names[i], "price": 5000 + i * 7500, "rate": 0.002 + i * 0.003})

func _buy(card: Dictionary) -> void:
    if card.name in owned:
        equipped = card.name
    elif money >= card.price:
        money -= card.price
        owned.append(card.name)
        equipped = card.name
    _refresh()
    _save_game()

func _tick() -> void:
    for card in catalog:
        if card.name == equipped:
            crypto += card.rate
            break
    _refresh()

func _sell_crypto() -> void:
    money += crypto * 1000.0
    crypto = 0.0
    _refresh()
    _save_game()

func _refresh() -> void:
    info.text = "PC SIMULATOR\nДеньги: %.0f ₽\nКрипта: %.3f кр\nВидеокарта: %s\nКуплено: %d" % [money, crypto, equipped, owned.size()]

func _save_game() -> void:
    var f := FileAccess.open("user://save.json", FileAccess.WRITE)
    if f:
        f.store_string(JSON.stringify({"money": money, "crypto": crypto, "owned": owned, "equipped": equipped}))

func _load_game() -> void:
    if not FileAccess.file_exists("user://save.json"):
        return
    var f := FileAccess.open("user://save.json", FileAccess.READ)
    if f == null:
        return
    var parsed = JSON.parse_string(f.get_as_text())
    if parsed is Dictionary:
        money = float(parsed.get("money", money))
        crypto = float(parsed.get("crypto", crypto))
        equipped = str(parsed.get("equipped", equipped))
        for item in parsed.get("owned", []):
            owned.append(str(item))
