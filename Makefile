# **************************************************************************** #
#                              Inception Makefile                              #
# **************************************************************************** #

USER = $(shell whoami)
DATA_PATH = /home/$(USER)/data
DOCKER_COMPOSE = docker compose
COMPOSE_FILE = srcs/docker-compose.yml

# Default target
.PHONY: all
all: setup up

# Create required data directories for volumes
.PHONY: setup
setup:
	@echo "Creating volume directories..."
	@mkdir -p $(DATA_PATH)/mariadb
	@mkdir -p $(DATA_PATH)/wordpress

# Build and run containers
.PHONY: up
up:
	@echo "Starting services with Docker Compose..."
	@$(DOCKER_COMPOSE) -f $(COMPOSE_FILE) up -d --build

# Stop and remove containers, networks (keeps volumes)
.PHONY: down
down:
	@echo "Stopping services..."
	@$(DOCKER_COMPOSE) -f $(COMPOSE_FILE) down

# Stop and remove everything including volumes
.PHONY: fclean
fclean: down
	@echo "Removing volumes..."
	@rm -rf $(DATA_PATH)/mariadb
	@rm -rf $(DATA_PATH)/wordpress
	@docker volume prune -f
	@docker system prune -af

# Rebuild everything from scratch
.PHONY: re
re: fclean all

# Show logs
.PHONY: logs
logs:
	@$(DOCKER_COMPOSE) -f $(COMPOSE_FILE) logs -f
