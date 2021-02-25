package main

import (
	u "hello-api/utils"
	"hello-api/models"
	"hello-api/controllers"
	"fmt"
	"time"
	"os"
	"net/http"
	"github.com/gorilla/mux"
)

func customHello(w http.ResponseWriter, r *http.Request){
	timestamp := time.Now().Format(time.RFC3339)
	resp := map[string]interface{}{
		"message": "hello world",
		"timestamp": timestamp,
	}
	u.Response(w, resp)
}

func main() {

	router := mux.NewRouter()

	// ROUTES

	// Hello entrypoint
	router.HandleFunc("/", customHello)
	// Create a new user
	router.HandleFunc("/api/users", controllers.CreateUser).Methods("POST")
	// Get a user by its unique id
	router.HandleFunc("/api/users/{userId}", controllers.GetUserById).Methods("GET")

	// HANDLER
	port := os.Getenv("PORT")
	if port == "" { port = "8080" }
	fmt.Println("Listening on port: " + port)
	err := http.ListenAndServe(":"+port, router)
	if err != nil {
		fmt.Print(err)
	}

	// open conection to db
	defer models.InitDB()
}