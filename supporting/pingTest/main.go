package main

import (
	"fmt"
	"io"
	"net/http"
)

func main() {
	http.HandleFunc("/hello/", HelloServer)
	http.HandleFunc("/greet/", GreetOtherServer)
	http.ListenAndServe(":80", nil)
}

func GreetOtherServer(w http.ResponseWriter, r *http.Request) {
	serverName := r.URL.Path[7:]

	client := &http.Client{}
	resp, err := client.Get(fmt.Sprintf("http://%s/", serverName))
	if err != nil {
		fmt.Fprintf(w, "server  %s returned an error: %v", serverName, err)
	}
	defer resp.Body.Close()
	body, err := io.ReadAll(resp.Body)
	fmt.Fprintf(w, "server %s says: %s", serverName, body)
}

func HelloServer(w http.ResponseWriter, r *http.Request) {
	fmt.Fprintf(w, "Hello, %s!", r.URL.Path[7:])
}
