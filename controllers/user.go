package controllers

import (
	u "hello-api/utils"
	"hello-api/models"
	"encoding/json"
	"net/http"
	"github.com/gorilla/mux"
	"strconv"
)

// CreateUser : creates a user
var CreateUser = func(w http.ResponseWriter, r *http.Request) {

	user := &models.User{}

	// parse request
	err := json.NewDecoder(r.Body).Decode(user)
	if err != nil {
		http.Error(w, "Error while decoding request", http.StatusBadRequest)
		return
	}

	resp := user.Create()
	if resp["success"].(bool) != true {
		http.Error(w, resp["message"].(string), http.StatusBadRequest)
		return
	}
	u.Response(w, resp)
}

// GetUserById : gets a specific user by unique identifier
var GetUserById = func(w http.ResponseWriter, r *http.Request) {

	vars := mux.Vars(r)
	userIdParam := vars["userId"]

	// Convert to uint
	userId, err := strconv.ParseUint(userIdParam, 10, 32)
	if err != nil {
		http.Error(w, "userId Error. Invalid uint", http.StatusBadRequest)
		return
	}

	resp := models.GetUserById(uint(userId))
	u.Response(w, resp)
}