package main

import (
	"context"
	"fmt"
	"net/http"
	"os"
	"os/signal"
	"syscall"
	"time"

	"github.com/gin-gonic/gin"
	"github.com/sirupsen/logrus"
)

var (
	log = logrus.New()
	version = "dev"
	buildTime = "unknown"
)

func main() {
	// Configure logging
	log.SetFormatter(&logrus.JSONFormatter{})
	log.SetOutput(os.Stdout)
	
	// Set log level based on environment
	if os.Getenv("LOG_LEVEL") != "" {
		level, err := logrus.ParseLevel(os.Getenv("LOG_LEVEL"))
		if err == nil {
			log.SetLevel(level)
		}
	}

	log.WithFields(logrus.Fields{
		"version":   version,
		"buildTime": buildTime,
	}).Info("Starting application")

	// Create Gin router
	router := gin.New()
	router.Use(gin.Recovery())
	router.Use(gin.Logger())

	// Health check endpoint
	router.GET("/health", func(c *gin.Context) {
		c.JSON(http.StatusOK, gin.H{
			"status":    "healthy",
			"timestamp": time.Now().UTC(),
			"version":   version,
		})
	})

	// Root endpoint
	router.GET("/", func(c *gin.Context) {
		c.JSON(http.StatusOK, gin.H{
			"message":   "Hello from ${app_name}!",
			"version":   version,
			"timestamp": time.Now().UTC(),
		})
	})

	// Version endpoint
	router.GET("/version", func(c *gin.Context) {
		c.JSON(http.StatusOK, gin.H{
			"version":   version,
			"buildTime": buildTime,
		})
	})

	// Metrics endpoint (placeholder for Prometheus metrics)
	router.GET("/metrics", func(c *gin.Context) {
		c.JSON(http.StatusOK, gin.H{
			"uptime": time.Since(time.Now()).String(),
		})
	})

	// Get port from environment or use default
	port := os.Getenv("PORT")
	if port == "" {
		port = "8080"
	}

	// Create server
	srv := &http.Server{
		Addr:    ":" + port,
		Handler: router,
	}

	// Start server in a goroutine
	go func() {
		log.WithField("port", port).Info("Starting HTTP server")
		if err := srv.ListenAndServe(); err != nil && err != http.ErrServerClosed {
			log.WithError(err).Fatal("Failed to start server")
		}
	}()

	// Wait for interrupt signal to gracefully shutdown the server
	quit := make(chan os.Signal, 1)
	signal.Notify(quit, syscall.SIGINT, syscall.SIGTERM)
	<-quit

	log.Info("Shutting down server...")

	// Create a deadline for server shutdown
	ctx, cancel := context.WithTimeout(context.Background(), 30*time.Second)
	defer cancel()

	// Attempt graceful shutdown
	if err := srv.Shutdown(ctx); err != nil {
		log.WithError(err).Fatal("Server forced to shutdown")
	}

	log.Info("Server exited")
} 