// TODO: Use user volume pref when that exists

function play_sound(sound) {
    if (sound == null || sound == undefined) {
        return;
    }
    if (!Array.isArray(sound)) {
        new Audio(sound).play(); // Maybe do precaching? Depends on how responsive the browser is.
    }
    else {
        new Audio(Math.floor(Math.random() * sound.length)).play();
    }
}