<div id="uiHeaderContent">{% block header_content %} {% endblock %}</div>
<div id="uiTitleWrapper">
  <div id="uiStatusIcon" class="icon24 uiStatusGood"></div>
  <div id="uiTitleText">{{ config.title }}</div>
  <div id="uiTitleFluff"></div>
</div>
<div id="uiContent">
  {% block content %}
  <div class="notice-red">
    <p>Targeted template didn't override the content block! Pester a coder!</p>
    <p>Template: {{ template }}</p>
  </div>
  {% endblock %}
</div>
