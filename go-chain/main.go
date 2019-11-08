package main

import (
	"encoding/json"
	"io"
	"log"
	"net/http"
	"os"
	"time"

	"github.com/davecgh/go-spew/spew"
	"github.com/gorilla/mux"
	"github.com/joho/godotenv"
)

type Message struct {
	BPM int
}

func run() error {
	handler := makeMuxRouter()
	httpAddr := os.Getenv("ADDR")
	log.Println("Listening on", os.Getenv("ADDR"))
	
	s := &http.Server{
		Addr:           ":" + httpAddr,
		Handler:        handler,
		ReadTimeout:    10 * time.Second,
		WriteTimeout:   10 * time.Second,
		MaxHeaderBytes: 1 << 20,
	}
	
	if err := s.ListenAndServe(); err != nil {
		return err
	}
	
	return nil
}

func makeMuxRouter() http.Handler {
	muxRouter := mux.NewRouter()

	muxRouter.HandleFunc("/", handleGetBlockchain).Methods("GET")
	muxRouter.HandleFunc("/", handleWriteBlock).Methods("POST")

	return muxRouter
}

func handleGetBlockchain(w http.ResponseWriter, r *http.Request) {
	bytes, err := json.MarshalIndent(Blockchain, "", " ")

	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}

	_, _ = io.WriteString(w, string(bytes))
}

func handleWriteBlock(w http.ResponseWriter, r *http.Request) {
	var m Message

	decoder := json.NewDecoder(r.Body)
	if err := decoder.Decode(&m); err != nil {
		respondWithJson(w, http.StatusBadRequest, r.Body)
		return
	}

	defer r.Body.Close()

	newBlock, err := generateBlock(Blockchain[len(Blockchain) - 1], m.BPM)
	if err != nil {
		respondWithJson(w, http.StatusInternalServerError, m)
		return
	}

	if isValidBlock(newBlock, Blockchain[len(Blockchain) - 1]) {
		newBlockchain := append(Blockchain, newBlock)
		replaceChain(newBlockchain)
		spew.Dump(Blockchain)
	}

	respondWithJson(w, http.StatusCreated, newBlock)
}

func respondWithJson(w http.ResponseWriter, code int, payload interface{}) {
	response, err := json.MarshalIndent(payload, "", " ")
	if err != nil {
		w.WriteHeader(http.StatusInternalServerError)
		_, _ = w.Write([]byte("HTTP 500: Internal server error"))
		return
	}

	w.WriteHeader(code)
	_, _ = w.Write(response)
}

func main() {
	err := godotenv.Load()
	if err != nil {
		log.Fatal(err)
	}

	go func() {
		t := time.Now()
		genesisBlock := Block{0, t.String(), 0, "", ""}
		spew.Dump(genesisBlock)
		Blockchain = append(Blockchain, genesisBlock)
	}()

	log.Fatal(run())
}