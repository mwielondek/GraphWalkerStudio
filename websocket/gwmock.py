import sys
from SimpleWebSocketServer import WebSocket, SimpleWebSocketServer

DEFAULT_PORT = 9999

class Mock(WebSocket):

    def sendMessage(self, message):
        print "Sent response: %s" % message
        super(Mock, self).sendMessage(message)

    def handleMessage(self):
        print "Received message: %s" % self.data
        self.sendMessage(self.data)

    def handleConnected(self):
        print "Connection opened"

    def handleClose(self):
        print "Connection closed"

def main():
    try:
        port = int(sys.argv[1])
    except:
        port = DEFAULT_PORT

    server = SimpleWebSocketServer('localhost', port, Mock)
    try:
        server.serveforever()
    except KeyboardInterrupt:
        print "Shutting down server.."
        server.close()


if __name__ == '__main__':
    main()
