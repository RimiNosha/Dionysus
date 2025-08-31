{% import "macros/act_button.swig" as ab %}
{% import "macros/bar.swig" as bar %}
{% extends "layout_default.swig" %}

{% block content %}
{% if data.chemHacked %}
{{ ab.act_button("Eject Beaker", "eject", "ejectBeaker", "{}", data.beaker) }}
{% endif %}
{{ ab.act_button("Eject Cell", "eject", "eject", "{}", data.hasPowercell && data.open) }}
<div style="position: absolute; top: 40px; right: 10px">
{{ ab.pwr_button("power", "{}", data.on, data.hasPowercell) }}
</div>
<br>
<p>Cell:</p>
{{ bar.percentage(data.powerLevel, 0, 100, null, true) }}

<p>Current Temperature:</p>
<div style="color: {{ helper.ternary(helper.abs(targetTemp - data.currentTemp) > 50, 'red', helper.ternary(helper.abs(data.targetTemp - data.currentTemp) > 20, 'yellow', 'green')) }}">{{ data.currentTemp }}°C</div>
<p>Mode:</p>
{{ ab.act_button("Auto", "thermometer-half", "mode", "{'mode': 'auto'}", data.mode != "auto") }}
{{ ab.act_button("Heat", "fire-alt", "mode", "{'mode': 'heat'}", data.mode != "heat") }}
{{ ab.act_button("Cool", "fan", "mode", "{'mode': 'cool'}", data.mode != "cool") }}
{% endblock %}
