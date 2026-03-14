package main

import (
	"context"
	"fmt"
	"net"
	"runtime"

	"google.golang.org/grpc"

	pb "grpc-go/proto"
)

type server struct {
	pb.UnimplementedBenchmarkServiceServer
}

func (s *server) GetSum(_ context.Context, req *pb.SumRequest) (*pb.SumReply, error) {
	return &pb.SumReply{Result: req.A + req.B}, nil
}

func main() {
	runtime.GOMAXPROCS(runtime.NumCPU())

	lis, err := net.Listen("tcp", ":8080")
	if err != nil {
		panic(err)
	}

	s := grpc.NewServer()
	pb.RegisterBenchmarkServiceServer(s, &server{})

	fmt.Println("Application started.")
	if err := s.Serve(lis); err != nil {
		panic(err)
	}
}
