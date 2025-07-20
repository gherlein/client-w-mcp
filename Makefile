.PHONY: docker-run
docker-run:
	docker run -it --rm -v $(PWD):/workspace claude-dev-env
