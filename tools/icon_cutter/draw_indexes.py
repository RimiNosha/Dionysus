# Debug utility in case anyone wants to update or add sprite templates using the basic cutter.

from PIL import Image, ImageDraw
import sys

files = sys.argv[1:]
print(files)

icon_size = (32, 32)

for file in files:
    img = Image.open(file)
    draw = ImageDraw.Draw(img)

    columns = int(img.width // icon_size[0])
    rows = int(img.height // icon_size[1])

    for x in range(0, columns):
        for y in range(0, rows):
            draw.text((x * icon_size[0], y * icon_size[1]), str((y * columns) + x), (255, 255, 255), stroke_width=2, stroke_fill=(0, 0, 0))

    img.save(file[:-4] + "_numbers.png", "png")
