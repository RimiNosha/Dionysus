## NanoUI V2

###### Not really official, but whatever. I might eventually think of a better name.

## Why not TGUI?

Simple. There are FAR too many parts for anyone to reliably downstream without a shitton of wasted maintainer time, and while it may have some very nice creature comforts for UI makers, it's not worth it if it requires at least one entire maintainer dedicated to making sure we don't fall cripplingly behind TG.

The Inferno > React move was plenty enough evidence of the above.

And while it'd be nice to pin to a specific version of TGUI, it'd end up as a messy pile of hacks that barely hold together after enough time, and maintainers would eventually forget how most of it works, thanks to said moving parts.

So that's why I'm dunking significant time initially into upgrading NanoUI, as it's a framework that's simple enough to be understood by anyone with basic byond and html+css+js knowledge, and with these upgrades, it'll be powerful enough to actually do everything TGUI could do.

## NanoUI Static Files

These never change while the game is running, and reloading of these files is not supported while the server is live.

## Templates

These use the [swig](https://node-swig.github.io/swig-templates/) templating language.

Despite its name, it doesn't actually require node, which is very useful.

Swig uses almost the same syntax as nunjucks, which has a relatively competent extension for VSCode. The standard swig extension is borderline unusable.

If you're not getting syntax highlighting even though you have the extension, click on the `plain text` (or whatever language it is) button on the bottom right, and set the file association for `.swig` to be `nunjucks`.
