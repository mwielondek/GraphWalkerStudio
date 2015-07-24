package main

import (
  // "io"
  "net/http"
  "golang.org/x/net/websocket"
  "log"
  "fmt"
  "encoding/json"
  "encoding/hex"
  "crypto/rand"
)

const (
  ADDVERTEX = "addVertex"
)

type Response struct {
  Requestid string `json:"request-id"`
  Command string `json:"command"`
  Success bool `json:"success"`
  Id string `json:"id"`
}

// Custom logger with prefix
type Logger struct {
  Prefix string
}

func (l *Logger) SetPrefix(s string) {
  l.Prefix = s
}

func (l Logger) Print(format string, a ...interface{}) {
  str := fmt.Sprintf(format, a...)
  log.Printf("%s%s\n", l.Prefix, str)
}

func randId() string {
  u := make([]byte, 3)
  rand.Read(u)
  return hex.EncodeToString(u)
}

// Mock GraphWalker

func GWMockServer(ws *websocket.Conn) {
  logger := new(Logger)
  logger.Print("Connection from %s", ws.LocalAddr().String())
  var request interface{}
  var response *Response

  for {
    // Receive request
    err := websocket.JSON.Receive(ws, &request)
    if err != nil {
      break // EOF
    }
    req := request.(map[string]interface{})
    logger.SetPrefix("* ")
    m, _ := json.Marshal(request)
    logger.Print("Received message: %s", m)

    // Prepare response
    response = nil
    logger.SetPrefix("* .. ")
    switch req["command"] {
      case ADDVERTEX:
        response = &Response{
          Requestid: req["request-id"].(string),
          Command: ADDVERTEX,
          Success: true,
          Id: "v_"+randId(),
        }
      default:
        logger.Print("Unknown command %s", req["command"])
    }
    if (response != nil) {
      m, _ := json.Marshal(response)
      logger.Print("Sent response: %s", m)
      websocket.JSON.Send(ws, response)
      response = nil
    }
  }

  logger.Print("Closed connection from %s", ws.LocalAddr().String())
}


// Serve
func main() {
  http.Handle("/", websocket.Handler(GWMockServer))
  err := http.ListenAndServe(":9999", nil)
  log.Print("Listening on :9999")
  if err != nil {
    panic("ListenAndServe: " + err.Error())
  }
}
