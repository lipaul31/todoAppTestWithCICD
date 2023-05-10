DOCKER_USER = lipaul31
APP_NAME = todo
GIT_SHA = $(shell git rev-parse HEAD)

dev:
	docker compose -f docker-compose-dev.yml --profile dev up --remove-orphans -d --build

down:
	docker compose -f docker-compose-dev.yml --profile all down --timeout 2

test:
	docker compose -f docker-compose-dev.yml --profile test up --remove-orphans -d --build

all:
	docker compose -f docker-compose-dev.yml --profile all up --remove-orphans -d --build

test_single:
	docker compose -f docker-compose-dev.yml --profile test -f docker-compose-test-single.yml up --remove-orphans -d --build
	docker compose -f docker-compose-dev.yml exec -T frontend-test npm test -- --watchAll=false
	docker compose -f docker-compose-dev.yml exec -T api-test npm test -- --watchAll=false
	docker compose -f docker-compose-dev.yml --profile test -f docker-compose-test-single.yml down --timeout 2

clean:
	docker compose -f docker-compose-dev.yml --profile all down --volumes

build:
	docker build -t $(DOCKER_USER)/$(APP_NAME)-api -t $(DOCKER_USER)/$(APP_NAME)-api:$(GIT_SHA) api; \
	docker push $(DOCKER_USER)/$(APP_NAME)-api; \
	docker push $(DOCKER_USER)/$(APP_NAME)-api:$(GIT_SHA); \
	docker build -t $(DOCKER_USER)/$(APP_NAME)-frontend -t $(DOCKER_USER)/$(APP_NAME)-frontend:$(GIT_SHA) frontend
	docker push $(DOCKER_USER)/$(APP_NAME)-frontend
	docker push $(DOCKER_USER)/$(APP_NAME)-frontend:$(GIT_SHA)

deploy:
	kubectl apply -f k8s
	kubectl set image deployment/api-deployment api=$(DOCKER_USER)/$(APP_NAME)-api:$(GIT_SHA)
	kubectl set image deployment/frontend-deployment frontend=$(DOCKER_USER)/$(APP_NAME)-frontend:$(GIT_SHA)
