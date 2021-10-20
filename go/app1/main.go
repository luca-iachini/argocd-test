package main

import (
	"fmt"
	"log"
	"net/http"
)

func hello(w http.ResponseWriter, r *http.Request) {
	fmt.Fprintf(w, "App1 greetings!")
}

func health(w http.ResponseWriter, r *http.Request) {
	fmt.Fprintf(w, "ok")
}

func main() {
	http.HandleFunc("/", hello)
	http.HandleFunc("/healthz", health)
	log.Printf("App1 listening 8080")
	log.Fatal(http.ListenAndServe(":8080", nil))
}
