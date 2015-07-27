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
  "time"
  "os"
  "strconv"
)

const (
  // GW Commands
  ADDVERTEX = "addVertex"
)

type Response struct {
  Requestid string `json:"requestId"`
  Success bool `json:"success"`
  Body interface{} `json:"body"`
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
  d, _ := strconv.Atoi(os.Args[1])
  DELAY := time.Duration(d)
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
          Requestid: req["requestId"].(string),
          Success: true,
          Body: map[string]string{"id": "v_"+randId()},
        }
      default:
        logger.Print("Unknown command %s", req["command"])
    }
    if (response != nil) {
      m, _ := json.Marshal(response)
      time.Sleep(DELAY * time.Millisecond)
      logger.Print("Sent response: %s", m)
      websocket.JSON.Send(ws, response)
      response = nil
    }
  }

  logger.Print("Closed connection from %s", ws.LocalAddr().String())
}


// Serve
func main() {
  if len(os.Args) < 2 {
    fmt.Printf("Usage: %s <SIMULATED DELAY TIME IN MS>\n", os.Args[0])
    os.Exit(1)
  }
  http.Handle("/", websocket.Handler(GWMockServer))
  err := http.ListenAndServe(":9999", nil)
  log.Print("Listening on :9999")
  if err != nil {
    panic("ListenAndServe: " + err.Error())
  }
}
