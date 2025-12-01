// ugh, I hate how much js this requires
// Also the code here is an ugly fucking abomination

let trackingElement = null;
let lastDegrees = null;

let propertySchema = {
    label: null,
    value: null, // Number/String/Whatever
    label_class: null, // String to a valid css class for the label to use //noimpl
    position: null, // In degrees
    color: null, // In css-friendly form. Usually you want to use hex //noimpl
    notch_class: null, // String to a valid css class for the notch to use //noimpl
    dial_class: null, // String to a valid css class for the dial to use when this value is selected //noimpl
}

$("document").ready(() => {
    $(".dial").mousedown((event) => {
        if (event.target instanceof Element) {
            let element = event.target;
            while (element != null) {
                if (element.className.split(" ").indexOf("dial") != -1) {
                    trackingElement = element;
                    return;
                }
                element = element.parentElement;
            }
        }
    });
    for (const dial of $(".dial")) {
        const values = JSON.parse(dial.getAttribute("nano_keys")); // The dial will "snap" to these values
        const minRotation = Number.parseInt(dial.getAttribute("nano_minRotation")) || 0;
        const maxRotation = Number.parseInt(dial.getAttribute("nano_maxRotation")) || 360;
        const key = dial.getAttribute("nano_key");
        if (key === undefined || key === null) {
            dial.style.transform = `rotate(${minRotation}deg)`
        }
        else {
            const rotation = getRotation(minRotation, maxRotation, key, values);
            dial.style.transform = `rotate(${rotation}deg)`;
            dial["nano_currentRotation"] = rotation;
        }

        // And now place labels. I hate this.

        for (const key of Object.keys(values)) {
            let label;
            // Now... values can be either an array of any primitive, or a map of display strings to values, or a map of display strings to their advanced properties.
            if (Array.isArray(values)) { // Primitive array
                label = values[key];
            }
            else {
                label = key;
            }
            const parentElement = dial.parentElement;
            if (parentElement instanceof Element) {
                const box = parentElement.getBoundingClientRect();
                const rotation = getRotation(minRotation, maxRotation, key, values);
                const labelElement = document.createElement("div");
                labelElement.className = "dial-label";
                labelElement.innerText = label;
                labelElement.style.transform = `translate(${box.width / 4.3}px, ${-box.height / 2.5}px) rotate(${rotation}deg) translateY(${box.width / 2.2}px) rotate(-${rotation}deg)`;
                parentElement.appendChild(labelElement);

                const notch = document.createElement("div"); // this one didn't make the small indie game called minceraft
                notch.className = "notch";
                // AAAA MAKE IT STOP
                notch.style.transform = `translate(${box.width / 3.8}px, ${-box.height / 3.3}px) rotate(${rotation}deg) translateY(${box.width / 3}px)`
                parentElement.appendChild(notch);
            }
        }
    }
});

let getRotation = function (minRotation, maxRotation, key, values) {
    let rotation;
    const keys = Object.keys(values);
    // Now... values can be either an array of any primitive, or a map of display strings to values, or a map of display strings to their advanced properties.
    if (Array.isArray(values)) { // Primitive array
        rotation = calcRotation(minRotation, maxRotation, Number.parseInt(key), values.length);
    }
    else if (values[key] instanceof Object) { // Map of properties
        rotation = values[key].position ? values[key].position : calcRotation(minRotation, maxRotation, keys.indexOf(key), keys.length);
    }
    else { // Map of values... probably.
        rotation = calcRotation(minRotation, maxRotation, keys.indexOf(key), keys.length);
    }
    return rotation;
}

let calcRotation = function (minRotation, maxRotation, position, positions) {
    const flatMax = maxRotation - minRotation;
    const parts = flatMax / (positions - 1);
    return (parts * position) + minRotation;
}

window.addEventListener("mouseup", (event) => {
    trackingElement = null;
    lastDegrees = null;
});
window.addEventListener("mousemove", (event) => {
    if (trackingElement == null) {
        return
    }

    let value = trackingElement.getAttribute("nano_key");
    let currentDegree = trackingElement["nano_currentRotation"] || 0;
    const maxRotation = Number.parseInt(trackingElement.getAttribute("nano_maxRotation")) || 360;
    const minRotation = Number.parseInt(trackingElement.getAttribute("nano_minRotation")) || 0;
    let box = trackingElement.parentElement.getBoundingClientRect(); // Use parent cause rotating that shit moves the bounding box around.
    let elemX = box.left + (box.width / 2) + window.scrollX
    let elemY = box.top + (box.height / 2) + window.scrollY;

    let mouseDegrees = Math.atan2(elemX - event.pageX, elemY - event.pageY) * 180 / Math.PI + 180;

    if (lastDegrees == null) {
        lastDegrees = mouseDegrees;
        return;
    }

    let mouseMovement;
    currentDegree += mouseMovement = Math.max(Math.min(lastDegrees - mouseDegrees, 5), -5); // A cheap hack to stop jumping dials, but one that works

    if (currentDegree > maxRotation) {
        currentDegree = maxRotation;
    }
    else if (currentDegree < minRotation) {
        currentDegree = minRotation;
    }

    const values = JSON.parse(trackingElement.getAttribute("nano_keys"));
    const valueKeys = Object.keys(values); // This works for every supported setup, so this is safe
    const valueSize = (maxRotation - minRotation) / (valueKeys.length - 1);

    for (let key of valueKeys) {
        const valuePos = getRotation(minRotation, maxRotation, key, values);
        const snapSize = Math.min(Math.max(valueSize / 3, 3), 15);
        if ((currentDegree) > valuePos - snapSize && (currentDegree) < valuePos + snapSize) {
            if (key === value) {
                currentDegree -= mouseMovement / 2;
                continue;
            }
            currentDegree = valuePos;
            value = key;
            const sound = trackingElement.getAttribute("nano_sound");
            play_sound(sound[0] === "[" ? JSON.parse(sound) : sound);
        }
    }

    trackingElement.style.transform = `rotate(${currentDegree}deg)`;
    trackingElement["nano_currentRotation"] = currentDegree;
    lastDegrees = mouseDegrees;
    trackingElement.setAttribute("nano_key", value);
});
