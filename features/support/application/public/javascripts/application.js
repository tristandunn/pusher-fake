window.addEventListener("DOMContentLoaded", function() {
  // Create the client instance.
  Pusher.instance = new Pusher("API_KEY");

  // Force the connection to go unavailable after a single attempt.
  Pusher.instance.connection.connectionAttempts = 4;
}, false);
