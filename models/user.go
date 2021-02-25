package models

import (
	"fmt"
	"database/sql"
	u "hello-api/utils"
)

// User : base structure
type User struct {
	UserId      uint   `json:"user_id"`
	FirstName   string `json:"first_name"`
	LastName    string `json:"last_name"`
}

// Validate : Validate the program structure from the request body
func (user *User) Validate() (string, bool) {

	// test for invalid conditions
	if (user.FirstName == "") || (user.LastName == "") {
		return "Please include both first and First and Last Names", false
	}

	// no exception conditions; return true
	return "valid", true
}

// Create : create a user function
func (user *User) Create() map[string]interface{} {

	if resp, ok := user.Validate(); !ok {
		return u.Message(false, resp)
	}

	err := db.
		QueryRow(
			"INSERT into public.users (first_name, last_name) VALUES ($1, $2) RETURNING user_id",
			user.FirstName,
			user.LastName).
		Scan(&user.UserId)

	if user.UserId <= 0 || err != nil {
		return u.Message(false, "Failed to create user, connection error.")
	}
	resp := u.Message(true, "success")
	resp["user"] = user
	return resp
}

// Retrieve : retrieve a user function
func GetUserById(userID uint) map[string]interface{} {

	user := User{}

	err := db.QueryRow("SELECT * from public.users WHERE user_id=$1", userID).
		Scan(&user.UserId, &user.FirstName, &user.LastName)

	if err != nil {
		if err == sql.ErrNoRows {
			return u.Message(false, "User not found")
		}
		fmt.Println("error: ", err)
		return u.Message(false, "Connection error. Please retry")
	}

	resp := u.Message(true, "User found")
	resp["user"] = user
	return resp
}


// TODO:

// Update : update a user function


// TODO:

// Delete : delete a user function