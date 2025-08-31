document.addEventListener("mousedown", (e) => {
	let elem = document.createElement("div");
	elem.className = "clickEffect";
	let body = document.querySelector("body");
	body.appendChild(elem);
	elem.style.left = e.pageX + "px";
	elem.style.top = e.pageY + "px";
	window.setTimeout(function () {
		body.removeChild(elem);
	}, 200);
});
