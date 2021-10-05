package main

import (
	"fmt"
	"log"
	"net/http"
)

func handler(w http.ResponseWriter, r *http.Request) {
	fmt.Fprintf(w, "App1 is running")
}

func main() {
	http.HandleFunc("/", handler)
	log.Printf("App1 listening 9080")
	log.Fatal(http.ListenAndServe(":9080", nil))
}
