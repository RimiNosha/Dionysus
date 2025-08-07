{% macro handle() %}
{# A cursed experiment, doesn't actually work atm. #}
<script>
	var rotate = function(elem) {
		function eventMoveHandler(event) {
			const rect = elem.getBoundingClientRect();
			var angle = Math.atan2(event.clientX - (rect.left + ((rect.right - rect.left) / 2)), -(event.clientY - (rect.top + ((rect.bottom - rect.top) / 2)))) * (180/Math.PI);
			elem.style.transform = `rotate(${angle}deg)`;
		}

		window.addEventListener('mousemove', eventMoveHandler, false);

		// this isn't particularly reliable... probably look into alternatives.
		window.addEventListener('mouseup', function () {
			window.removeEventListener('mousemove', eventMoveHandler, false);
		}, false);
	}
</script>
<div class="rotatable-handle" style="width:50px; height:50px">
	<div style="background-color: orange;width:50px; height:50px" onmousedown="rotate(this)" useredited="true"></div>
</div>
{% endmacro %}
