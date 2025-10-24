package main

import (
	"log/slog"
	"net/http"
	"os"

	"connectrpc.com/grpchealth"
	"connectrpc.com/grpcreflect"
	"github.com/quiz-arena-net/quiz-registry/gen/quiz_arena/quiz_registry/v1/quiz_registryv1connect"
	"golang.org/x/net/http2"
	"golang.org/x/net/http2/h2c"
)

func main() {
	mux := http.NewServeMux()

	mux.Handle(grpchealth.NewHandler(
		grpchealth.NewStaticChecker(
			quiz_registryv1connect.QuizRegistryServiceName,
		),
	))
	mux.Handle(grpcreflect.NewHandlerV1(
		grpcreflect.NewStaticReflector(
			grpchealth.HealthV1ServiceName,
			quiz_registryv1connect.QuizRegistryServiceName,
		),
	))
	mux.Handle(grpcreflect.NewHandlerV1Alpha(
		grpcreflect.NewStaticReflector(
			grpchealth.HealthV1ServiceName,
			quiz_registryv1connect.QuizRegistryServiceName,
		),
	))

	addr := ":50051"

	slog.Info("starting server", "addr", addr)
	if err := http.ListenAndServe(
		addr,
		h2c.NewHandler(mux, &http2.Server{}),
	); err != nil {
		slog.Error("listen and serve failed", "err", err)
		os.Exit(1)
	}
}
