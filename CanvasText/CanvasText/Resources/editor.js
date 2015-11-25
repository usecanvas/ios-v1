var Canvas = {};
window.Canvas = Canvas;

Canvas.connect = function(host, accessToken, collectionID, canvasID) {
  const socket = new WebSocket(host);
  socket._onopen = socket.onopen;
  socket.onopen = function() {
    socket.send('auth-token:' + accessToken);
    socket._onopen.apply(socket, arguments);
  };
  this._socket = socket;

  this._connection = new sharejs.Connection(this._socket);
  this._doc = this._connection.get(collectionID, canvasID);

  this._doc.subscribe();
  this._doc.whenReady(onDocReady);

  function onDocReady() {
    Canvas._sendMessage({
      "snapshot": Canvas._doc.snapshot
    });

    Canvas._context = this.createContext();
    Canvas._context.onInsert = onInsert;
    Canvas._context.onRemove = onDelete;
  }

  function onInsert(position, text) {
    console.log("Remote Insert:", {"location": position, "string": text});
    Canvas._sendMessage({
      "op": {
        "type": "insert",
        "location": position,
        "text": text
      }
    });
  }

  function onDelete(position, length) {
    console.log("Remote Remove:", {"location": position, "length": length});
    Canvas._sendMessage({
      "op": {
        "type": "remove",
        "location": position,
        "length": length
      }
    });
  }
};

Canvas.insert = function(location, string) {
  console.log("Local Insert:", {"location": location, "string": string});
  Canvas._context.insert(location, string);
  return true;
};

Canvas.remove = function(location, length) {
  console.log("Local Remove:", {"location": location, "length": length});
  Canvas._context.remove(location, length);
  return true;
};

Canvas._sendMessage = function(message) {
  console.log(message);
  if (typeof window.webkit != "undefined" && typeof window.webkit.messageHandlers != "undefined") {
    window.webkit.messageHandlers.share.postMessage(message);
  }
};
