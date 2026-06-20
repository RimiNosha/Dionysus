import math
from PIL import Image, PngImagePlugin

class DmiEntry:
    def __init__(self, name: str, start_index: int, dirs: int = 1, frames: int = 1, dont_loop: bool = False, flow_vertically=False):
        super().__init__()
        self.name = name
        self.start_index = start_index
        self.dirs = dirs
        self.frames = frames
        self.sprite_locations = []
        self.dont_loop = dont_loop
        self.flow_vertically = flow_vertically

    def resolve_sprites(self, image_size: tuple[int, int], icon_size: tuple[int, int], silent = False):
        self.sprite_locations = []
        img_w, img_h = image_size
        icon_w, icon_h = icon_size
        sprites_per_row = img_w // icon_w
        if not silent:
            print("Resolving state " + self.name + "...")

        def add_entry(): # My OOB brain is screaming at this but I'm just gonna treat it like a macro :)
            if not self.flow_vertically:
                sprite_idx = self.start_index + direction * self.frames + frame
            else:
                sprite_idx = self.start_index + frame
            col = sprite_idx % sprites_per_row
            row = sprite_idx // sprites_per_row
            if self.flow_vertically:
                row += direction
            self.sprite_locations.append((col * icon_w, row * icon_h))

        for frame in range(self.frames):
            for direction in range(self.dirs):
                add_entry()
                if self.dirs == 2: # Dupe the sprite if we're not spriting all four directions for this entry
                    add_entry()

        if self.dirs == 2:
            self.dirs = 4

def make_dmi(file, dmi_icons: list[DmiEntry], icon_size, silent = False):

    # Never fucking trust the parser to handle multiline strings sensibly. Yes, indenting this "properly" breaks it. Don't do it.
    dmi_str = f"""# BEGIN DMI
version = 4.0
	width = {str(icon_size[0])}
	height = {str(icon_size[1])}"""

    image = Image.open(file, "r")

    all_locations = []
    for entry in dmi_icons:
        entry.resolve_sprites(image.size, icon_size, silent)
        all_locations.extend(entry.sprite_locations)

    total_images = len(all_locations)
    side = int(math.ceil(total_images ** 0.5))
    output_size = (side * icon_size[0], side * icon_size[1])

    out_image = Image.new("RGBA", output_size)
    current_index = 0

    for entry in dmi_icons:
        for loc in entry.sprite_locations:
            col = current_index % side
            row = current_index // side
            paste_loc = (col * icon_size[0], row * icon_size[1])

            sprite = image.crop((loc[0], loc[1], loc[0] + icon_size[0], loc[1] + icon_size[1]))
            out_image.paste(sprite, paste_loc)

            current_index += 1

        dmi_str += "\nstate = \"" + entry.name + "\""
        dmi_str += "\n	dirs = " + str(entry.dirs)
        dmi_str += "\n	frames = " + str(entry.frames)
        if entry.dont_loop:
            dmi_str += "\n	loop = 1"

    dmi_str += "\n# END DMI"

    png_info = PngImagePlugin.PngInfo()
    png_info.add_text("Description", dmi_str, zip=True)
    out_image.save(file[:-4] + ".dmi", "png", pnginfo=png_info)
