<div id='uiLayout'>
	<div id='uiContent'>
		{% block content %}
		<div class="notice-red">
			<p>Targeted template didn't override the content block! Pester a coder!</p>
			<p>Template: {{ template }}</p>
		</div>
		{% endblock %}
	</div>
</div>
