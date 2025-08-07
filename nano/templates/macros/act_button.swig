{% macro act_button(label, icon, act, act_data, enabled) %}
<div
	class="link hasIcon link {% if !enabled %}disabled{% endif %}"
	href="?"
	{% if enabled %}
	onclick="Byond.sendMessage('{{ act }}', {{ act_data }})"
	{% endif %}
	>
	{% if icon %}
		<div class="uiLinkPendingIcon"></div>
		<div class="uiIcon16 icon-{{ icon }}"></div>
	{% endif %}
	{{ label }}
</div>
{% endmacro %}
