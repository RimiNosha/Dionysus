import sys
from basic_cutter import make_dmi, DmiEntry

doors = sys.argv[1:]
print(doors)

for door in doors:
    make_dmi(door, [
        DmiEntry("door", 78, 2),
        DmiEntry("door_anim", 0, 2, 19, True),
        DmiEntry("lights", 81, 2, 18, True),
        DmiEntry("lights-bolted", 156, 2, 6),
    ], (32, 32))
