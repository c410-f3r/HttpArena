package main

import (
	"strconv"

	"github.com/valyala/fasthttp"
)

func benchHandler(ctx *fasthttp.RequestCtx) {
	sum := 0

	ctx.QueryArgs().VisitAll(func(key, value []byte) {
		if n, err := strconv.Atoi(string(value)); err == nil {
			sum += n
		}
	})

	body := ctx.PostBody()
	if len(body) > 0 {
		if n, err := strconv.Atoi(string(body)); err == nil {
			sum += n
		}
	}

	ctx.Response.Header.Set("Server", "go-fasthttp")
	ctx.SetContentType("text/plain")
	ctx.SetBodyString(strconv.Itoa(sum))
}

func main() {
	server := &fasthttp.Server{
		Handler: benchHandler,
	}
	server.ListenAndServe(":8080")
}
