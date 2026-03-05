FROM ubuntu:24.04 AS build
RUN apt-get update && apt-get install -y gcc make liburing-dev
WORKDIR /app

# Copy ringzero library source (provided via build context)
COPY include/ include/
COPY src/ src/

# Copy bench handler
COPY main.c .

# Build ringzero library objects
RUN for f in src/lib/*.c; do \
      gcc -O2 -Wall -march=native -pthread -Iinclude -c "$f" -o "$(basename "$f" .c).o"; \
    done

# Build bench server
RUN gcc -O2 -Wall -march=native -pthread -Iinclude -c main.c -o main.o
RUN gcc -o server main.o acceptor.o connection.o engine.o listener.o reactor.o -luring -lpthread

FROM ubuntu:24.04
RUN apt-get update && apt-get install -y liburing2 && rm -rf /var/lib/apt/lists/*
COPY --from=build /app/server /server
EXPOSE 8080
CMD ["/server", "12"]
