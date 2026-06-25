var postTiny = "tiny";
var t = {
	request: function() {
		var url = $('#url').val().trim();
		if (!url) {
			$('#response').val('Enter a valid URL');
			return;
		}
		$.ajax(postTiny, {
			type: 'POST',
			data: { url: url }
		}).done(function(response) {
			t.update(response.id, response.short_url);
		}).fail(function(jqXHR, textStatus) {
			$('#response').val('Failed: ' + textStatus + ' ' + jqXHR.status);
			t.setStatus('Unable to generate short URL.');
		});
	},
	update: function(id, short_url) {
		var shorted = short_url || (shortBaseURL + id);
		var display = shorted.replace(/^https?:\/\/[^\/]+/i, '');
		var pathMatch = display.match(/(\/r\/.+|\/q\/.+)/i);
		if (pathMatch) {
			display = pathMatch[0];
		}
		if (!display.startsWith('/')) {
			display = '/' + display;
		}
		var visible = t.shortenPath(display);
		var qrImg = qrBaseURL + id + '?size=150';
		$('#response').val(visible);
		$('.link').html('<a href="' + shorted + '" target="_blank" rel="noopener">' + visible + '</a>');
		$('.qr').html('<img src="' + qrImg + '" alt="QR code">');
		t.setStatus('Short path output restored; host and context hidden.');
	},
	shortenPath: function(path) {
		var maxLength = 42;
		if (path.length <= maxLength) {
			return path;
		}
		return path.slice(0, 20) + '...' + path.slice(-19);
	},
	copy: function() {
		var visiblePath = $('#response').val();
		if (!visiblePath) {
			t.setStatus('Nothing to copy yet. Generate a link first.');
			return;
		}
		var fullUrl = $('.link a').attr('href') || shortBaseURL + visiblePath;
		if (navigator.clipboard && navigator.clipboard.writeText) {
			navigator.clipboard.writeText(fullUrl).then(function() {
				t.setStatus('Short URL copied to clipboard.');
			}, function() {
				t.setStatus('Copy failed. Please copy manually.');
			});
		} else {
			var textarea = document.createElement('textarea');
			textarea.value = fullUrl;
			document.body.appendChild(textarea);
			textarea.select();
			try {
				document.execCommand('copy');
				t.setStatus('Short URL copied to clipboard.');
			} catch (e) {
				t.setStatus('Copy not supported on this browser.');
			}
			document.body.removeChild(textarea);
		}
	},
	setStatus: function(message) {
		$('#copyStatus').text(message);
	}
};
