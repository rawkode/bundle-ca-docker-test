.PHONY: generate-ca generate-server build-fail build-success test

generate-ca:
	cd ca &&  cfssl genkey csr.json && cfssl genkey -initca csr.json | cfssljson -bare ca

generate-server:
	cd server && cfssl gencert -ca=../ca/ca.pem -ca-key=../ca/ca-key.pem -profile=server server.json | cfssljson -bare server

build-fail:
	docker image build --tag tls:fail --target fail .


build-success:
	docker image build --tag tls:success --target success .


test: build-fail build-success
	@docker container run --name fail -p 8080:80 -d tls:fail
	@echo -e "\n\n ---- Attempting to curl WITHOUT insecure ON FAIL TAG ---- \n\n"
	@docker container run --rm --link fail:example.net --entrypoint=bash tls:fail "-c" -- "curl https://example.net || true"

	@echo -e "\n\n ---- Attempting to curl WITH insecure ON FAIL TAG ---- \n\n"
	@docker container run --rm --link fail:example.net --entrypoint=bash tls:fail "-c" -- "curl -k https://example.net || true"

	@echo -e "\n\n ---- Attempting to curl WITHOUT insecure ON SUCCESS TAG ---- \n\n"
	@docker container run --rm --link fail:example.net --entrypoint=bash tls:success "-c" -- "curl https://example.net"

	@docker container rm -f fail
