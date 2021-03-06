import std.stdio;
import vibe.d;

import sockjs.sockjs;

void logRequest(HTTPServerRequest req, HTTPServerResponse res)
{
	writefln("url: '%s' peer: '%s' method: '%s'", req.requestURL, req.peer, req.method);
}

static this()
{
	SockJS.Options opt = {
		heartbeat_delay : 4_000,
		prefix : "/echo/"
	};

	auto sjs = SockJS.createServer(opt);

	sjs.onConnection = (Connection conn) {
		writefln("new conn: %s", conn.remoteAddress);

		conn.onData = (string message) {

			writefln("msg: %s", message);

			conn.write(message);
		};

		conn.onClose = () {
			writefln("closed conn: %s", conn.remoteAddress);
		};
	};

	auto router = new URLRouter;
		router
		.any("/index.html", vibe.http.fileserver.serveStaticFile("index.html",new HTTPFileServerSettings()))
		.any("*", &logRequest)
		.any("*", &sjs.handleRequest);
	
	auto settings = new HTTPServerSettings;
	settings.port = 8989;
	listenHTTP(settings, router);
}