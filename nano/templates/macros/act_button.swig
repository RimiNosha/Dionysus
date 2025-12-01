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

{% macro pwr_button(act, act_data, state, enabled, color) %}
<label class="switch {% if color %}elem-color-{{ color }}{% endif %} componentFrame" {% if enabled %}onmouseup="Byond.sendMessage('act/{{act}}', {{act_data}})"{% endif %} onclick="event.preventDefault()"><input type="checkbox" {% if state %}checked{% endif %}/>
    <div class="switch-button">
        <div class="switch-light"></div>
        <div class="switch-dots"></div>
        <div class="switch-characters"></div>
        <div class="switch-shine"></div>
        <div class="switch-shadow"></div>
    </div>
</label>
{% endmacro %}

{% macro fancy_button(label, act, act_data, can_be_lit, lit, enabled, color) %}
<div class="componentFrame fancy-button {% if color %}elem-color-{{ color }}{% endif %} {% if can_be_lit && lit %}fancy-button-lit{% endif %}">
  <button class="fancy-button-pushable {% if can_be_lit && lit %}fancy-button-lit{% endif %}" {% if enabled %}onmouseup="Byond.sendMessage('act/{{act}}', {{act_data}})"{% else %}disabled{% endif %}>
    <div class="fancy-button-edge"></div>
    <div class="fancy-button-light"></div>
    <div class="fancy-button-dots"></div>
    <div class="fancy-button-front"><div class="fancy-button-text">{{ label }}</div></div>
  </button>
</div>
{% endmacro %}
