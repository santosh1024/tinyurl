<%@ page import="org.javastack.tinyurl.Config" %>
<%@ page import="org.javastack.mapexpression.InvalidExpression" %>
<%@ page import="java.io.IOException" %>
<%
String cfgBaseURL = null;
try {
    Config cfg = new Config(System.getProperty(Config.PROP_CONFIG, Config.DEF_CONFIG_FILE));
    cfgBaseURL = cfg.get("base.url");
} catch (IOException | InvalidExpression e) {
    // Use default base URL if config cannot be loaded
}
String shortBaseURL;
String qrBaseURL;
if ((cfgBaseURL != null) && !cfgBaseURL.isEmpty()) {
    if (!cfgBaseURL.endsWith("/")) {
        cfgBaseURL = cfgBaseURL + "/";
    }
    shortBaseURL = cfgBaseURL;
    if (shortBaseURL.endsWith("/r/")) {
        qrBaseURL = shortBaseURL.substring(0, shortBaseURL.length() - 3) + "/q/";
    } else {
        qrBaseURL = shortBaseURL.replaceAll("/r/?$", "/q/");
        if (qrBaseURL.equals(shortBaseURL)) {
            qrBaseURL = shortBaseURL + "../q/";
        }
    }
} else {
    String scheme = request.getHeader("X-Forwarded-Proto");
    if ((scheme == null) || scheme.isEmpty()) {
        scheme = request.getScheme();
    }
    String host = request.getHeader("X-Forwarded-Host");
    if ((host == null) || host.isEmpty()) {
        host = request.getHeader("Host");
    }
    if ((host == null) || host.isEmpty()) {
        host = request.getServerName();
    }
    int port = request.getServerPort();
    String forwardedPort = request.getHeader("X-Forwarded-Port");
    if ((forwardedPort != null) && !forwardedPort.isEmpty()) {
        try {
            port = Integer.parseInt(forwardedPort);
        } catch (NumberFormatException e) {
        }
    }
    StringBuilder base = new StringBuilder();
    base.append(scheme).append("://").append(host);
    if (!host.contains(":") && !("http".equalsIgnoreCase(scheme) && port == 80)
            && !("https".equalsIgnoreCase(scheme) && (port == 443 || port == 80))) {
        base.append(':').append(port);
    }
    String context = request.getContextPath();
    if (context == null) {
        context = "";
    }
    if (!context.endsWith("/")) {
        context = context + "/";
    }
    base.append(context);
    shortBaseURL = base.toString() + "r/";
    qrBaseURL = base.toString() + "q/";
}
%>
<!DOCTYPE HTML>
<html lang="en">
<head>
<meta charset="UTF-8" />
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>TinyURL Studio</title>
<link rel="stylesheet" href="styles.css">
</head>
<body>
<div class="page">
	<nav>
		<div class="brand"><span>↪</span> TinyURL Studio</div>
		<div class="menu">
			<a href="#">Features</a>
			<a href="#">QR</a>
			<a href="#">Support</a>
		</div>
	</nav>

	<div class="hero">
		<div class="hero-copy">
			<h1>The fastest way to shorten links and generate QR codes.</h1>
			<p>Beautifully designed link generation for your apps, landing pages, and quick sharing. Generate a public link, preview a QR, and copy the share-ready path instantly.</p>
			<div class="cta-group">
				<button class="cta-button" type="button" onclick="t.request()">Generate your link</button>
			</div>
			<div class="widgets">
				<div class="widget-card">
					<h3>Instant QR</h3>
					<p>Create a scannable QR code for every short link.</p>
				</div>
				<div class="widget-card">
					<h3>Minimal Output</h3>
					<p>Share only the short path for cleaner links.</p>
				</div>
			</div>
		</div>

		<div class="hero-visual">
			<div class="hero-art">
				<div class="shape"></div>
			</div>
		</div>
	</div>

	<div class="form-panel">
		<div class="form-grid">
			<label for="url">Long URL</label>
			<input type="text" id="url" placeholder="https://example.com/your/long/link" />
		</div>
		<button type="button" onclick="t.request()">Generate Short Link</button>
		<div class="output">
			<div class="form-row">
				<label for="response">Short URL</label>
				<div class="output-row">
					<input type="text" id="response" readonly />
					<button class="copy-button" type="button" onclick="t.copy()">Copy</button>
				</div>
			</div>
			<div class="link">&nbsp;</div>
			<div class="copy-status" id="copyStatus">The public host is hidden from the displayed path.</div>
		</div>
		<div class="small-note">Tip: Use the displayed link path to keep sharing clean and simple.</div>
	</div>

	<div class="panel">
		<h2 class="panel-title">QR Code Preview</h2>
		<div class="qr">&nbsp;</div>
	</div>

	<p class="footer">The app works best when your local ngrok tunnel is open. Once generated, your short path will redirect to the original destination instantly.</p>
</div>

<script src="https://code.jquery.com/jquery-3.5.0.min.js" integrity="sha384-LVoNJ6yst/aLxKvxwp6s2GAabqPczfWh6xzm38S/YtjUyZ+3aTKOnD/OJVGYLZDl" crossorigin="anonymous"></script>
<script>
	var shortBaseURL = "<%= shortBaseURL %>";
	var qrBaseURL = "<%= qrBaseURL %>";
</script>
<script src="main.js"></script>
</body>
</html>

