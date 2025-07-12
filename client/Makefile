
build:
	go mod tidy
	go build -o client ./...

run: build
	./client

clean:
	rm -f client
	rm *~
	rm *.log

flush:
	go clean -modcache

