package main

import (
	"log"
	"os"
	"os/signal"
	"ppp_mangage/auxiliary" // 使用模块路径导入
	"ppp_mangage/ppp"       // 使用模块路径导入
)

var LOG_ERROR *log.Logger = auxiliary.LOG_ERROR()
var LOG_INFO *log.Logger = log.New(os.Stdout, "[INFO]", log.LstdFlags)

func AddShutdownApplicationEventHandler(signo os.Signal, shutdown func()) {
	stoped := make(chan os.Signal, 1)
	signal.Notify(stoped, signo)

	go func() {
		<-stoped
		shutdown()
	}()
}

func ListenAndServe() bool {
	ppp, err := ppp.NewManagedServer()
	if err != nil {
		LOG_ERROR.Println("Failed to create managed server:", err)
		return false
	}

	LOG_INFO.Println("Managed server created successfully")
	LOG_INFO.Println("Application started. Press Ctrl+C to shut down.")

	shutdown_eh := func() {
		if !ppp.IsDisposed() {
			LOG_INFO.Println("Application is shutting down...")
			ppp.Dispose()
		}
	}

	AddShutdownApplicationEventHandler(os.Kill, shutdown_eh)
	AddShutdownApplicationEventHandler(os.Interrupt, shutdown_eh)

	err = ppp.ListenAndServe()
	if err != nil {
		LOG_ERROR.Printf("Server failed to start: %v\n", err)
		return false
	}

	LOG_INFO.Println("Server is running")
	return true
}

func main() {
	ListenAndServe()
}
