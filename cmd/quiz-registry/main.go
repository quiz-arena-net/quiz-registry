package main

import (
	"log/slog"
	"net/http"
	"os"

	"connectrpc.com/grpchealth"
	"connectrpc.com/grpcreflect"
	"github.com/caarlos0/env/v11"
	"github.com/quiz-arena-net/quiz-registry/gen/quiz_arena/quiz_registry/v1/quiz_registryv1connect"
	"golang.org/x/net/http2"
	"golang.org/x/net/http2/h2c"
)

type config struct {
	ServerAddr string `env:"SERVER_ADDRESS,required"`
}

func main() {
	cfg, err := env.ParseAs[config]()
	if err != nil {
		slog.Error("failed to parse environment variables", slog.Any("error", err))
		os.Exit(1)
	}

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

	slog.Info("starting server", slog.String("addr", cfg.ServerAddr))
	if err := http.ListenAndServe(
		cfg.ServerAddr,
		h2c.NewHandler(mux, &http2.Server{}),
	); err != nil {
		slog.Error("listen and serve failed", "err", err)
		os.Exit(1)
	}
}
