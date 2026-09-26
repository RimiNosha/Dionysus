from .basic_cutter import DmiEntry

DOOR_DMI_ENTRY_PRESET = [
    DmiEntry("door", 114, 2, flow_vertically=True),
    DmiEntry("door_open", 38, 2, flow_vertically=True),
    DmiEntry("door_anim_open", 0, 2, 19, True),
    DmiEntry("door_anim_close", 76, 2, 19, True),
    DmiEntry("lights", 152, 2, flow_vertically=True),
    DmiEntry("lights_open", 190, 2, flow_vertically=True),
    DmiEntry("lights_anim_open", 152, 2, 19, True),
    DmiEntry("lights_anim_close", 190, 2, 19, True),
    DmiEntry("lights_bolted", 266, 2, flow_vertically=True),
    DmiEntry("lights_denied_anim", 228, 2, 6, flow_vertically=True),
    DmiEntry("lights_emergency", 304, 2, flow_vertically=True),
    DmiEntry("panel", 456, 2, flow_vertically=True),
    DmiEntry("panel_open", 380, 2, flow_vertically=True),
    DmiEntry("panel_anim_open", 342, 2, 19),
    DmiEntry("panel_anim_close", 418, 2, 19),
]
