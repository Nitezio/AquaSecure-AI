const { WebSocketServer } = require("ws");

const port = Number(process.env.PORT || 3001);
const wss = new WebSocketServer({ port });

wss.on("connection", (socket) => {
  socket.send(JSON.stringify({ type: "status", message: "telemetry-streamer-connected" }));
});
