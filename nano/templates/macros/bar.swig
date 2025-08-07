{% macro percentage(value, min, max, text, percentage_in_bar) %}
<div class="displayBar">
  <div
    class="displayBarFill"
    style="width: {{ helper.percentage(value, min, max) }}%"
  >{% if percentage_in_bar %}
	{{ helper.round(helper.percentage(value, min, max)) }}%
  {% endif %}</div>
  <div class="displayBarText">{{ text }}</div>
</div>
{{ value }}<br>{{min}}<br>{{max}}
{% endmacro %}
