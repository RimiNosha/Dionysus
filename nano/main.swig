<!-- NOT A TEMPLATE! -->
<!DOCTYPE html>
<html>
	<meta http-equiv="Content-Type" content="text/html; charset='utf-8'">
	<head>
		<meta http-equiv="X-UA-Compatible" content="IE=edge">
		<style>
			/* Inlined cause errors could happen at any time. */
			#onerror {
				display: none;
				position: absolute;
				top: 0;
				left: 0;
				right: 0;
				bottom: 0;
				padding: 12px;
				font-size: 12px;
				font-family: Consolas, monospace;
				color: #ffffff;
				background-color: #0000dd;
				z-index: 1000;
				overflow: hidden;
			}

			.errored {
				display: block !important;
			}

			#onerrorLogo {
				text-align: center;
				display: inline-block;
				text-align: left;
				font-size: 10px;
				line-height: 12px;
				position: relative;
				top: 0;
				left: 0;
				white-space: pre;
			}

			#onerrorStacktrace {
				padding-top: 1rem;
				white-space: pre-wrap;
				word-break: break-all;
			}

			.blinkingCursor {
				width: 1rem;
				animation: blink-animation 1.5s steps(1) infinite;
			}

			@keyframes blink-animation {
				0%, 100% {
					opacity: 1;
				}
				50% {
					opacity: 0;
				}
			}
		</style>
		<script>
			var __uncompTemplateData__ = {}
			var __byond_window_id__ = "{{:window_id}}";
			var __byond_window_handler_ref__ = "{{:window_handler_ref}}";
			window.onerror = function(_, _, _, _, e) {
				document.getElementById("onerror").className = "errored";
				document.getElementById("onerrorStacktrace").innerText = e.stack.replace(/https?:\/\/127\.0\.0\.1:[0-9]*?\//g, "/");
				window.onerror = function() {} // Don't catch further errors, otherwise copy paste will be a pain in the ass
				try {
					Byond.winset(__byond_window_id__, { "can-resize": true, size: "500x500", "can-close": true, "titlebar": true }) // Make it (potentially) bigger and then make it so people can resize it for easier reading
					Byond.sendMessage("act/crashed", {})
				}
				catch (e) {
					console.log("byond ded")
					// Shit's fucked mate
				}
			}
		</script>
		{{:head_content}}

		<script type='text/javascript'>
			function receiveUpdateData(jsonString) {
				// We need both jQuery and NanoStateManager to be able to recieve data
				// At the moment any data received before those libraries are loaded will be lost
				if (typeof NanoStateManager != 'undefined' && typeof jQuery != 'undefined')
				{
					try {
						NanoStateManager.receiveUpdateData(jsonString);
					}
					catch(e) {
						reportError(e);
					}
				}
				else
				{
					reportError(
						new Error(
							"browser.recieveUpdateData failed due to jQuery or NanoStateManager being unavailiable",
						),
					);
				}
			}

			function nanoUIInit() {
				setupGlobalEvents();
				setupHotKeys();

				$.when(
					$.ajax({
						url: "{{:templates_file}}",
						cache: false,
						dataType: "json",
					}),
				)
					.done(function (allTemplates) {
						__uncompTemplateData__ = allTemplates;
						NanoStateManager.init("{{:template}}", {{:initial_data_json}});
					})
					.fail(function () {
						reportError(new Error("Failed to locate or parse templates file."));
					});
			}
		</script>
	</head>
	<body scroll=auto data-url-parameters='{{:url_parameters_json}}' onload="nanoUIInit()">
		<div id='uiLayout'>
			<div id='uiContent'>
				<div id='uiLoadingNotice'>Initiating...</div>
			</div>
		</div>
		<noscript>
			<div id='uiNoScript'>
				<h2>JAVASCRIPT REQUIRED</h2>
				<p>Your Edge's Javascript is disabled (or broken).<br/>
				Enable Javascript and then open this UI again.</p>
			</div>
		</noscript>
		<div id="onerror">
			<div id="onerrorLogo"><!--
 _  _               _   _ ___
| \| |__ _ _ _  ___| | | |_ _|
| .` / _` | ' \/ _ \ |_| || |
|_|\_\__,_|_||_\___/\___/|___|
--> _____ _    _      _   ___   ___  ___    ___            __           _ _
|_   _| |_ (_)_ _ | |_|   \ / _ \/ __| / __| ___ __ _ / _|__ _ _  _| | |_
  | | | ' \| | ' \| / / |) | (_) \__ \ \__ \/ -_) _` |  _/ _` | || | |  _|
  |_| |_||_|_|_||_|_\_\___/ \___/|___/ |___/\___\__, |_| \__,_|\_,_|_|\__|
                                                |___/
Time to go make a coffee.<span class="blinkingCursor">_</span>
			</div>
			<div id="onerrorStacktrace"></div>
		</div>
	</body>
</html>
