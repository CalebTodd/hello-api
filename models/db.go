package models

import (
	"fmt"
	"os"
	"database/sql"
	"github.com/joho/godotenv"
	_ "github.com/lib/pq"
)

var db *sql.DB

func init() {

	// overload values via env vars
	username := os.Getenv("DB_USER")
	password := os.Getenv("DB_PASSWORD")
	dbName := os.Getenv("DB_NAME")
	dbHost := os.Getenv("DB_HOST")

	if username == "" || password == "" || dbName == "" || dbHost == "" {
		fmt.Println("No environment overides provided, using .env configs")
		config := godotenv.Load()
		if config != nil {
			fmt.Println("Unable to load .env configuration")
			panic(config)
		}

		username = os.Getenv("DB_USER")
		password = os.Getenv("DB_PASSWORD")
		dbName = os.Getenv("DB_NAME")
		dbHost = os.Getenv("DB_HOST")
	}

	dbURI := fmt.Sprintf("host=%s user=%s dbname=%s sslmode=disable password=%s", dbHost, username, dbName, password)

	fmt.Println(dbURI)

	conn, err := sql.Open("postgres", dbURI)
	if err != nil {
		fmt.Print(err)
	}

	err = conn.Ping()
	if err != nil {
		panic(err)
	}

	db = conn

	migrateDB(db)
}

// dbInit : initialization of db connection
func InitDB() *sql.DB {
	return db
}

// ensure the db has the table we're writing to; poor man's migration
func migrateDB(db *sql.DB) bool {

	// check if the table exists
	res, err := db.Query(`CREATE TABLE IF NOT EXISTS public.users (user_id SERIAL PRIMARY KEY, first_name VARCHAR(35) NOT NULL, last_name VARCHAR(35) NOT NULL)`)
	if err != nil {
		panic(err)
	}
	defer res.Close()
	fmt.Println("Database up-to-date")

	return true
}
