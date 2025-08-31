{% macro act_button(label, icon, act, act_data, enabled) %}
<div
	class="link hasIcon link {% if !enabled %}disabled{% endif %}"
	href="?"
	{% if enabled %}
	onclick="Byond.sendMessage('act/{{ act }}', {{ act_data }})"
	{% endif %}
	>
	{% if icon %}
		<div class="uiLinkPendingIcon"></div>
		<div class="uiIcon16 icon-{{ icon }}"></div>
	{% endif %}
	{{ label }}
</div>
{% endmacro %}

{% macro pwr_button(act, act_data, state, enabled) %}
<label class="switch" {% if enabled %}onmouseup="Byond.sendMessage('act/{{act}}', {{act_data}})"{% endif %} onclick="event.preventDefault()"><input type="checkbox" {% if state %}checked{% endif %}/>
    <div class="switch-button">
        <div class="switch-light"></div>
        <div class="switch-dots"></div>
        <div class="switch-characters"></div>
        <div class="switch-shine"></div>
        <div class="switch-shadow"></div>
    </div>
</label>
{% endmacro %}
