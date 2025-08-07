{% import "macros/live_text.swig" as lt %}
{% import "macros/act_button.swig" as ab %}
{% import "macros/rotatable_handle.swig" as rh %}
{% import "macros/bar.swig" as bar %}
{% extends "layout_default.swig" %}

{% block content %}
<h3>Tank Status</h3>
<div class="item">
	<div class="itemLabel">
		Tank Label:
	</div>
	<div class="itemContent">
		{{ lt.live_text("label", data.name, "act/relabel", "{name: $(this).val()}") }}
	</div>
</div>

<div class="item">
	<div class="itemLabel">
		Tank Pressure:
	</div>
	<div class="itemContent">
		{{ data.tankPressure }} kPa
	</div>
</div>

<div class="item">
	<div class="itemLabel">
		Port Status:
	</div>
	<div class="itemContent">
		{{ data.portConnected ? '<span class="good">Connected</span>' : '<span class="average">Disconnected</span>' }}
	</div>
</div>

<h3>Holding Tank Status</h3>
{% if data.hasHoldingTank %}
	<div class="item">
		<div class="itemLabel">
			Tank Label:
		</div>
		<div class="itemContent">
			<div style="float: left; width: 180px;">{{ data.holdingTank.name }}</div> {{ helper.link('Eject', 'eject', {'remove_tank' : 1}) }}
		</div>
	</div>

	<div class="item">
		<div class="itemLabel">
			Tank Pressure:
		</div>
		<div class="itemContent">
			{{ data.holdingTank.tankPressure }} kPa
		</div>
	</div>
{% else %}
	<div class="item"><span class="average"><i>No holding tank inserted.</i></span></div>
	<div class="item">&nbsp;</div>
{% endif %}


<h3>Release Valve Status</h3>
<div class="item">
	<div class="itemLabel">
		Release Pressure:
	</div>
	<div class="itemContent">
		{{ bar.percentage(data.releasePressure, data.minReleasePressure, data.maxReleasePressure) }}
		<div style="clear: both; padding-top: 4px;">
			{{ ab.act_button('-', null, "pressure", "{pressure_adj: -1000}", data.releasePressure > data.minReleasePressure) }}
			{{ ab.act_button('-', null, "pressure", "{pressure_adj: -100}", data.releasePressure > data.minReleasePressure) }}
			{{ ab.act_button('-', null, "pressure", "{pressure_adj: -10}", data.releasePressure > data.minReleasePressure) }}
			{{ ab.act_button('-', null, "pressure", "{pressure_adj: -1}", data.releasePressure > data.minReleasePressure) }}
			<div style="float: left; width: 80px; text-align: center;">&nbsp;{{ data.releasePressure }} kPa&nbsp;</div>
			{{ ab.act_button('+', null, "pressure", "{pressure_adj: 1}", data.releasePressure < data.maxReleasePressure) }}
			{{ ab.act_button('+', null, "pressure", "{pressure_adj: 10}", data.releasePressure < data.maxReleasePressure) }}
			{{ ab.act_button('+', null, "pressure", "{pressure_adj: 100}", data.releasePressure < data.maxReleasePressure) }}
			{{ ab.act_button('+', null, "pressure", "{pressure_adj: 1000}", data.releasePressure < data.maxReleasePressure) }}
		</div>
	</div>
</div>

<div class="item">
	<div class="itemLabel">
		Release Valve:
	</div>
	<div class="itemContent">
		{{ ab.act_button("Open", "unlocked", "valve", "{}", !data.valveOpen) }}
		{{ ab.act_button('Close', 'locked', 'valve', "{}", data.valveOpen) }}
	</div>
</div>

{% endblock %}
