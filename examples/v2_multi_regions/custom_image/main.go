package main

import (
	"fmt"
	"log"
	"net/http"
	"os"
)

func main() {
	http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		if r.URL.Path == "/healthcheck" {
			healthHandler(w, r)
			return
		}
		
		w.Header().Set("Content-Type", "text/html")
		fmt.Fprintf(w, `
			<div style="text-align:center; padding-top:50px; font-family:sans-serif;">
				<h1>Hello Cloud Run!</h1>
				<p>Path: %s</p>
			</div>
		`, r.URL.Path)
	})

	http.HandleFunc("/healthcheck", healthHandler)

	port := os.Getenv("PORT")
	if port == "" {
		port = "8080"
	}

	log.Printf("Listening on port %s", port)
	if err := http.ListenAndServe(":"+port, nil); err != nil {
		log.Fatal(err)
	}
}

func healthHandler(w http.ResponseWriter, r *http.Request) {
	w.WriteHeader(http.StatusOK)
	fmt.Fprint(w, "OK")
}
