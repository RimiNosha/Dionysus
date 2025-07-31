import PIL.Image
import sys
import pathlib
import PIL.PngImagePlugin

# Some lazy code inbound - RimiNosha

if len(sys.argv) < 2:
    print("You need to supple an image via argument (or drop it on the script)")
    sys.exit(0)

template = PIL.Image.open("template.dmi", formats=["png"])
tiles = PIL.Image.open(sys.argv[1])
tileA = PIL.Image.new("RGBA", (16, 16), (0, 0, 0, 0))
tileA.paste(tiles)
tileB = PIL.Image.new("RGBA", (16, 16), (0, 0, 0, 0))
tileB.paste(tiles, (-16, 0))
newImage = PIL.Image.new("RGBA", (96, 96), (0, 0, 0, 0))

pngInfo = PIL.PngImagePlugin.PngInfo()
pngInfo.add_text("Description", template.info["Description"], zip=True)

# tileA.save("tilea.png", "png") # Debug
# tileB.save("tileb.png", "png") # Debug

tiles = {"a": tileA, "b": tileB}

locToLayout = {
    (0, 0): ["a", "a", "a", "a"],
    (1, 0): ["a", "a", "a", "b"],
    (2, 0): ["b", "a", "a", "a"],
    (0, 1): ["a", "b", "a", "a"],
    (1, 1): ["a", "a", "b", "a"],
    (2, 1): ["a", "a", "a", "b"],
    (0, 2): ["b", "a", "a", "a"],
    (1, 2): ["a", "b", "a", "a"],
    (2, 2): ["a", "a", "b", "a"],
}

for yLoc in range(3):
    for xLoc in range(3):
        floor = PIL.Image.new("RGBA", (96, 96), (0, 0, 0, 0))

        tileStrs = locToLayout[(xLoc, yLoc)]

        floor.paste(tiles[tileStrs[0]])
        floor.paste(tiles[tileStrs[1]], (16, 0))
        floor.paste(tiles[tileStrs[2]], (0, 16))
        floor.paste(tiles[tileStrs[3]], (16, 16))

        newImage.paste(floor, (xLoc * 32, yLoc * 32))

newImage.save(pathlib.Path(sys.argv[1]).stem + ".dmi", "png", pnginfo=pngInfo)

tiles = {"a": tileB, "b": tileA}

for yLoc in range(3):
    for xLoc in range(3):
        floor = PIL.Image.new("RGBA", (96, 96), (0, 0, 0, 0))

        tileStrs = locToLayout[(xLoc, yLoc)]

        floor.paste(tiles[tileStrs[0]])
        floor.paste(tiles[tileStrs[1]], (16, 0))
        floor.paste(tiles[tileStrs[2]], (0, 16))
        floor.paste(tiles[tileStrs[3]], (16, 16))

        newImage.paste(floor, (xLoc * 32, yLoc * 32))

newImage.save(pathlib.Path(sys.argv[1]).stem + "_inverted.dmi", "png", pnginfo=pngInfo)
print(template.info["Description"])
