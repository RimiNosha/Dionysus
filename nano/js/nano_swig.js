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
