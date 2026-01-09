.PHONY: ssh add s a

# Pattern rule to allow "make 1", "make 2", etc.
# Also handles positional arguments for add command

ssh:
	@if [ -z "$(level)" ]; then \
		echo "Error: level parameter is required"; \
		echo "Usage: make ssh level=<level_number>"; \
		exit 1; \
	fi; \
	if [ "$(level)" = "0" ]; then \
		password="bandit0"; \
	else \
		prev_level=$$(($(level) - 1)); \
		if [ ! -f "$${prev_level}.md" ]; then \
			echo "Error: File $${prev_level}.md not found"; \
			exit 1; \
		fi; \
		password=$$(head -n 1 "$${prev_level}.md"); \
	fi; \
	echo "Connecting to bandit$(level)..."; \
	echo "Password: $$password"; \
	ssh bandit$(level)@bandit.labs.overthewire.org -p 2220

add:
	@password="$(filter-out add,$(MAKECMDGOALS))"; \
	if [ -z "$$password" ]; then \
		echo "Error: password parameter is required"; \
		echo "Usage: make add <password> [level]"; \
		echo "Examples:"; \
		echo "  make add mypassword"; \
		echo "  make add mypassword 5"; \
		exit 1; \
	fi; \
	set -- $$password; \
	actual_password="$$1"; \
	level="$$2"; \
	if [ -z "$$level" ]; then \
		highest_level=0; \
		for file in *.md; do \
			if [ -f "$$file" ]; then \
				filename=$$(basename "$$file" .md); \
				if [ "$$filename" -eq "$$filename" ] 2>/dev/null && [ "$$filename" -gt "$$highest_level" ]; then \
					highest_level=$$filename; \
				fi; \
			fi; \
		done 2>/dev/null; \
		next_level=$$((highest_level + 1)); \
	else \
		next_level=$$level; \
	fi; \
	if [ -f "$${next_level}.md" ]; then \
		echo "Warning: File $${next_level}.md already exists"; \
		read -p "Overwrite? (y/N): " confirm; \
		if [ "$$confirm" != "y" ] && [ "$$confirm" != "Y" ]; then \
			echo "Aborted"; \
			exit 1; \
		fi; \
	fi; \
	echo "$$actual_password" > "$${next_level}.md"; \
	echo "Created $${next_level}.md with password: $$actual_password"

# Shorthand commands
s:
	@$(MAKE) ssh level=$(level)

a:
	@args="$(filter-out a,$(MAKECMDGOALS))"; \
	if [ -z "$$args" ]; then \
		echo "Error: password parameter is required"; \
		echo "Usage: make a <password> [level]"; \
		exit 1; \
	fi; \
	$(MAKE) add $$args

# Catch-all rule to handle positional arguments for add command
%:
	@if [ "$@" != "ssh" ] && [ "$@" != "add" ] && [ "$@" != "s" ] && [ "$@" != "a" ]; then \
		if echo "$(MAKECMDGOALS)" | grep -q "^add \|^a "; then \
			exit 0; \
		else \
			$(MAKE) ssh level=$@; \
		fi; \
	fi
