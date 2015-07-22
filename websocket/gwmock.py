#!/usr/bin/python

import sys, json, random, time
from SimpleWebSocketServer import WebSocket, SimpleWebSocketServer

DEFAULT_PORT = 9999

class Mock(WebSocket):

    def sendMessage(self, message):
        print "Sent response: %s" % message
        super(Mock, self).sendMessage(message)

    def handleMessage(self):
        print "Received message: %s" % self.data

        try:
            request = json.loads(self.data)

            # Prepare mock response
            response = {}
            # response type always the same as request type
            response['type'] = request['type']

            if request['type'] == "ADDVERTEX":
                if not request.get('forcefail'):
                    response['success'] = True
                    # generate random ID
                    response['id'] = ("v_%x" % random.randint(0x0, 0xFFFFF))
                else:
                    response['success'] = False
                    response['msg'] = 'Failed to create Vertex'

            # simulate delay
            time.sleep(float(sys.argv[1])/1000);
            self.sendMessage(json.dumps(response))
        except Exception as e:
            print "Couldn't decipher request: %s" % e

    def handleConnected(self):
        print "Connection opened"

    def handleClose(self):
        print "Connection closed"

def main():
    if len(sys.argv) < 2:
        print "Usage: %s %s" % (sys.argv[0], '<simulated time delay in ms> [port]')
        sys.exit(1)
    try:
        port = int(sys.argv[2])
    except:
        port = DEFAULT_PORT

    server = SimpleWebSocketServer('localhost', port, Mock)
    try:
        server.serveforever()
    except KeyboardInterrupt:
        print "Shutting down server.."
        server.close()
        sys.exit(0)


if __name__ == '__main__':
    main()
