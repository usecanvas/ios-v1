var Canvas = {};
window.Canvas = Canvas;

Canvas.connect = function(realtimeURL, accessToken, organizationID, canvasID) {
  var share = new ShareJSWrapper.default({
    accessToken: accessToken,
    canvasID: canvasID,
    realtimeURL: realtimeURL,
    orgID: organizationID
  });

  // Tell the client to connect to the ShareJS server.
  share.connect(function onConnect() {
    // Get the current content of the document.
    Canvas._sendMessage({
      "type": "snapshot",
      "content": share.content
    });

    // Handle an `insert` event from the server.
    share.on('insert', function onInsert(position, text) {
      console.log("Remote Insert:", {"location": position, "string": text});
      Canvas._sendMessage({
        "type": "operation",
        "operation": {
          "type": "insert",
          "location": position,
          "text": text
        }
      });
    });

    // Handle a `remove` event from the server.
    share.on('remove', function onRemove(position, length) {
      console.log("Remote Remove:", {"location": position, "length": length});
      Canvas._sendMessage({
        "type": "operation",
        "operation": {
          "type": "remove",
          "location": position,
          "length": length
        }
      });
    });
  });

  // Handle disconnect.
  share.on('disconnect', function onDisconnect(error) {
    console.log("Disconnect:", error);
    Canvas._sendMessage({
      "type": "disconnect",
      "message": error.message
    });
  });

  Canvas._share = share;
};

Canvas.insert = function(location, string) {
  console.log("Local Insert:", {"location": location, "string": string});
  Canvas._share.insert(location, string);
  return true;
};

Canvas.remove = function(location, length) {
  console.log("Local Remove:", {"location": location, "length": length});
  Canvas._share.remove(location, length);
  return true;
};

Canvas._sendMessage = function(message) {
  console.log(message);
  if (typeof window.webkit != "undefined" && typeof window.webkit.messageHandlers != "undefined") {
    window.webkit.messageHandlers.share.postMessage(message);
  }
};

window.onerror = function(errorMessage, url, lineNumber, columnNumber) {
  if (typeof window.webkit != "undefined" && typeof window.webkit.messageHandlers != "undefined") {
    window.webkit.messageHandlers.share.postMessage({
      "type": "error",
      "message": errorMessage,
      "line_number": lineNumber,
      "column_number": columnNumber
    });
  }
};
