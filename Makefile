image_tag=sengokyu/openldap:latest

build:
	docker build -t $(image_tag) --force-rm .

clean:
	docker rmi $(image_tag)
