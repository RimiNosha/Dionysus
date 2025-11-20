import os.path
import sys

from sass_embedded import compile_directory
from pathlib import Path

print("Compiling " + os.path.realpath("../nano/scss"))
compile_directory(Path("../nano/scss"), dest=Path("../nano/css"), embed_sourcemap=True, style="expanded" if os.getenv("DEBUG") else "compressed")
