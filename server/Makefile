build:
	go mod tidy
	go build -o server ./...

clean:
	rm -f server
	rm *~
	rm *.log


run: build
	./server

flush:
	go clean -modcache