var __uncompTemplateData__ = new Object();

swig.setDefaults({
	loader: {
		resolve: function (a, b) {
			return a;
		},
		load: function (a) {
			return __uncompTemplateData__[a];
		},
	},
});

function setupTemplating(templates) {
	__uncompTemplateData__ = templates;
	$(document).trigger("templatesLoaded");
}
