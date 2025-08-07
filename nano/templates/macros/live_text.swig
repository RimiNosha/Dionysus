{% macro live_text(id, value, act, act_data) %}
	<input type="text" id="{{ id }}" value="{{ value }}" onkeyup="Byond.sendMessage('{{ act }}', {{ act_data }})" onkeydown="Byond.sendMessage('{{ act }}', {{ act_data }})">
{% endmacro %}
