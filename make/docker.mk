DOCKER_COMPOSE_EXEC := docker-compose exec -T
DOCKER_WARNING_INSIDE := You are inside the Docker container!
DOCKER_PROJECT_ROOT := /app

PHONY += down
down: ## Tear down the environment
ifeq ($(RUN_ON),host)
	$(call warn,$(DOCKER_WARNING_INSIDE))
else
	$(call step,Tear down the environment...)
	@docker-compose down -v --remove-orphans
endif

PHONY += stop
stop: ## Stop the environment
ifeq ($(RUN_ON),host)
	$(call warn,$(DOCKER_WARNING_INSIDE))
else
	$(call step,Stop the container(s)...)
	@docker-compose stop
endif

PHONY += up
up: ## Launch the environment
ifeq ($(RUN_ON),host)
	$(call warn,$(DOCKER_WARNING_INSIDE))
else
	$(call step,Start up the container(s)...)
	@docker-compose up -d --remove-orphans
endif

PHONY += docker-test
docker-test: ## Run docker targets on Docker and host
	$(call step,Test docker_run_cmd on $(RUN_ON))
	$(call docker_run_cmd,pwd && echo \$$PATH)

PHONY += shell
shell: ## Login to CLI container
ifeq ($(RUN_ON),host)
	$(call warn,$(DOCKER_WARNING_INSIDE))
else
	@docker-compose exec -u ${CLI_USER} ${CLI_SERVICE} ${CLI_SHELL}
endif

PHONY += versions
versions: ## Show software versions inside the Drupal container
	$(call step,Software versions on ${RUN_ON}:)
	$(call docker_run_cmd,php -v && echo " ")
	$(call composer_on_${RUN_ON}, --version && echo " ")
	$(call drush_on_${RUN_ON},--version)
	$(call docker_run_cmd,echo 'NPM version: '|tr '\n' ' ' && npm --version)
	$(call docker_run_cmd,echo 'Yarn version: '|tr '\n' ' ' && yarn --version)

ifeq ($(RUN_ON),docker)
define docker_run_cmd
	@${DOCKER_COMPOSE_EXEC} -u ${CLI_USER} ${CLI_SERVICE} ${CLI_SHELL} -c "$(1)"
endef
else
define docker_run_cmd
	@$(1)
endef
endif
