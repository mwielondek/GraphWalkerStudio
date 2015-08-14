package main

import (
  // "io"
  "net/http"
  "golang.org/x/net/websocket"
  "log"
  "fmt"
  "encoding/json"
  "encoding/hex"
  crand "crypto/rand"
  "math/rand"
  "time"
  "os"
  "strconv"
  "strings"
)

const (
  // GW Commands
  ADDVERTEX = "addVertex"
  CHANGEVERTEX = "changeVertex"
  ADDEDGE = "addEdge"
  CHANGEEDGE = "changeEdge"
  START = "startRunning"
  NEXT = "getNextElement"
  STOP = "stopRunning"
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
  crand.Read(u)
  return hex.EncodeToString(u)
}

// Mock GraphWalker

func GWMockServer(ws *websocket.Conn) {
  d, _ := strconv.Atoi(os.Args[1])
  DELAY := time.Duration(d)
  logger := new(Logger)
  logger.Print("Connection from %s", ws.LocalAddr().String())
  elements := make([]string, 0)
  counter := 0
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
        // Generate id
        id := "v_"+randId()
        // Add element to array
        elements = append(elements, id)
        // Return element ID
        response = &Response{
          Requestid: req["requestId"].(string),
          Success: true,
          Body: map[string]string{"id": id},
        }
      case CHANGEVERTEX:
        // In the case of changing element name, check if
        // it starts with `v_`.
        props := req["properties"].(map[string]interface{})
        if props["name"] == nil || strings.HasPrefix(props["name"].(string), "v_") {
          response = &Response{
            Requestid: req["requestId"].(string),
            Success: true,
          }
        } else {
          response = &Response{
            Requestid: req["requestId"].(string),
            Success: false,
            Body: map[string]string{"error": "Bad name!"},
          }
        }
      case ADDEDGE:
        // Return element ID
        response = &Response{
          Requestid: req["requestId"].(string),
          Success: true,
          Body: map[string]string{"id": "e_"+randId()},
        }
      case CHANGEEDGE:
        // In the case of changing element name, check if
        // it starts with `v_`.
        props := req["properties"].(map[string]interface{})
        if props["name"] == nil || strings.HasPrefix(props["name"].(string), "e_") {
          response = &Response{
            Requestid: req["requestId"].(string),
            Success: true,
          }
        } else {
          response = &Response{
            Requestid: req["requestId"].(string),
            Success: false,
            Body: map[string]string{"error": "Bad name!"},
          }
        }
      case NEXT:
        if len(elements) == 0 {
          response = &Response{
            Requestid: req["requestId"].(string),
            Success: false,
            Body: map[string]string{"error": "Model is empty"},
          }
        } else if counter == len(elements) * 4 || counter == -1 {
          response = &Response{
            Requestid: req["requestId"].(string),
            Success: false,
            Body: map[string]string{"error": "Finished running"},
          }
        } else {
          response = &Response{
            Requestid: req["requestId"].(string),
            Success: true,
            // Return just a random element
            Body: map[string]string{"next": elements[rand.Intn(len(elements))]},
          }
          counter++
        }
      case START:
        counter = 0
        response = &Response{
          Requestid: req["requestId"].(string),
          Success: true,
        }
      case STOP:
        counter = -1
        response = &Response{
          Requestid: req["requestId"].(string),
          Success: true,
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
