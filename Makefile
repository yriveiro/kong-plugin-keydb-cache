BOLD=$$(tput -Tlinux bold)
RED=$$(tput -Tlinux setaf 1)
GREEN=$$(tput -Tlinux setaf 2)
YELLOW=$$(tput -Tlinux setaf 3)
CYAN=$$(tput -Tlinux setaf 6)
MAGENTA=$$(tput -Tlinux setaf 5)
BLUE=$$(tput -Tlinux setaf 4)
RESET=$$(tput -Tlinux sgr0)

# Message short cuts
GEAR=$(CYAN)$(BOLD) ⚙ $(RESET)
INFO=$(CYAN)$(BOLD) ℹ $(RESET)
ERROR=$(RED)$(BOLD) ✖ $(RESET)
DEBUG=$(BLUE)$(BOLD)  $(RESET)

PLATFORM:=linux/amd64

.EXPORT_ALL_VARIABLES:
DOCKER_BUILDKIT=1
BUILDKIT_PROGRESS=plain
DOCKER_DEFAULT_PLATFORM?=$(PLATFORM)

KONG_DATABASE=postgres
KONG_ADDR:=http://kong:8001

.PHONY: build-plugin
build-plugin:
	@echo "$(GEAR)- $(GREEN)Building docker image ...$(RESET)"
	@docker build -t kong-dev -f ./docker/Dockerfile .

.PHONY: kong-migration-database
kong-migration-database:
	@echo "$(GEAR)- $(GREEN)Start Kong migrations ...$(RESET)"
	@docker-compose --project-directory docker --profile database up -d

.PHONY: start
start: clean build-plugin
	@echo "$(GEAR)- $(GREEN)Start docker compose ...$(RESET)"
	@docker-compose --project-directory docker --profile dev up -d
	@docker logs -f docker-kong-1

.PHONY: clean
clean:
	@echo "$(GEAR)- $(GREEN)Reset docker compose ...$(RESET)"
	@docker-compose --project-directory docker --profile dev kill
	@docker-compose --project-directory docker --profile dev rm -f

.PHONY: nuke
nuke: clean
	@docker-compose --project-directory docker --profile database kill
	@docker volume rm docker_kong_data docker_kong_prefix_vol docker_kong_tmp_vol
	@docker network rm docker_kong-net

.PHONY: show-plugins
show-plugins:
	@echo "$(GEAR)- $(GREEN)Show installed plugins ...$(RESET)"
	@curl -s -X GET --url http://localhost:8001/services/echo-server/plugins/ | jq

.PHONY: deck-sync
deck-sync:
	@echo "$(GEAR)- $(GREEN)Deck Sync ...$(RESET)"
	@docker run --network docker_kong-net --rm -v $(PWD)/docker/config:/deck kong/deck gateway --kong-addr $(KONG_ADDR) sync

.PHONY: deck-validate
deck-validate:
	@echo "$(GEAR)- $(GREEN)Deck Validate ...$(RESET)"
	@docker run --network docker_kong-net --rm -v $(PWD)/docker/config:/deck kong/deck gateway --kong-addr $(KONG_ADDR) validate

.PHONY: deck-ping
deck-ping:
	@echo "$(GEAR)- $(GREEN)Deck Ping ...$(RESET)"
	@docker run --network docker_kong-net --rm -v $(PWD)/docker/config:/deck kong/deck gateway --kong-addr $(KONG_ADDR) ping

.PHONY: deck-diff
deck-diff:
	@echo "$(GEAR)- $(GREEN)Deck Diff ...$(RESET)"
	@docker run --network docker_kong-net --rm -v $(PWD)/docker/config:/deck kong/deck gateway --kong-addr $(KONG_ADDR) diff
