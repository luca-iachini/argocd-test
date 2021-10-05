package main

import (
	"fmt"
	"log"
	"net/http"
)

func handler(w http.ResponseWriter, r *http.Request) {
	fmt.Fprintf(w, "App2 is running")
}

func main() {
	http.HandleFunc("/", handler)
	log.Printf("App2 listening 9081")
	log.Fatal(http.ListenAndServe(":9081", nil))
}
