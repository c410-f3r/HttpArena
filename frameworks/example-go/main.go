package main

import (
	"fmt"
	"io"
	"net/http"
	"strconv"
)

func benchHandler(w http.ResponseWriter, r *http.Request) {
	sum := 0

	// Parse query parameters
	for _, v := range r.URL.Query() {
		for _, s := range v {
			if n, err := strconv.Atoi(s); err == nil {
				sum += n
			}
		}
	}

	// Parse body (plain number)
	if r.Body != nil {
		body, err := io.ReadAll(r.Body)
		if err == nil && len(body) > 0 {
			if n, err := strconv.Atoi(string(body)); err == nil {
				sum += n
			}
		}
	}

	w.Header().Set("Server", "go-net-http")
	w.Header().Set("Content-Type", "text/plain")
	fmt.Fprint(w, sum)
}

func main() {
	http.HandleFunc("/bench", benchHandler)
	http.ListenAndServe(":8080", nil)
}
