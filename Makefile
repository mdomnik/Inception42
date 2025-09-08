# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    Makefile                                           :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: mdomnik <mdomnik@student.42berlin.de>      +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2025/09/07 15:29:33 by mdomnik           #+#    #+#              #
#    Updated: 2025/09/08 14:17:59 by mdomnik          ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

SHELL := /bin/bash

COMPOSE_FILE := srcs/docker-compose.yml
ENV_FILE     := srcs/.env

DATA_DIR     := /home/mdomnik/data
DB_DIR       := $(DATA_DIR)/mariadb
WP_DIR       := $(DATA_DIR)/wordpress

COMPOSE      := docker compose -p srcs --env-file $(ENV_FILE) -f $(COMPOSE_FILE)

.PHONY: all
all: up

.PHONY: prepare
prepare:
	@echo ">> Ensuring host data directories exist under $(DATA_DIR)"
	mkdir -p "$(DB_DIR)" "$(WP_DIR)"
	@echo ">> Parent directory perms set to 755 (subdirs left untouched)"
	- chmod 755 "$(DATA_DIR)" || true

.PHONY: up
up: prepare
	$(COMPOSE) up -d --build

.PHONY: build
build:
	$(COMPOSE) build

.PHONY: start
start:
	$(COMPOSE) start

.PHONY: stop
stop:
	$(COMPOSE) stop

.PHONY: restart
restart:
	$(COMPOSE) restart

.PHONY: down
down:
	$(COMPOSE) down

.PHONY: clean
clean:
	$(COMPOSE) down -v

.PHONY: fclean
fclean: clean
	@echo ">> Removing host data directories under $(DATA_DIR)"
	sudo rm -rf "$(DB_DIR)" "$(WP_DIR)"

.PHONY: re
re: fclean up

.PHONY: ps
ps:
	$(COMPOSE) ps

.PHONY: logs
logs:
	$(COMPOSE) logs -f

.PHONY: logs-svc
logs-svc:
	@if [ -z "$(S)" ]; then echo "Usage: make logs-svc S=<service>"; exit 1; fi
	$(COMPOSE) logs -f $(S)

.PHONY: sh
sh:
	@if [ -z "$(S)" ]; then echo "Usage: make sh S=<service>"; exit 1; fi
	$(COMPOSE) exec $(S) bash || $(COMPOSE) exec $(S) sh

.PHONY: info
info:
	@echo "================ Inception — Info ================"
	@echo "WordPress URL: https://$$(grep -E '^DOMAIN_NAME=' $(ENV_FILE) | cut -d= -f2 || echo localhost)"
	@echo "Nginx listens: 443 (TLS)"
	@echo "Data dir     : $(DATA_DIR)"
	@echo "MariaDB data : $(DB_DIR)"
	@echo "WP files     : $(WP_DIR)"
	@echo "=================================================="

.PHONY: remind-hosts
remind-hosts:
	@echo ">> Reminder: map DOMAIN_NAME from $(ENV_FILE) to your VM IP in /etc/hosts"
	@echo "   Example: 192.168.56.10  mdomnik.42.fr"
