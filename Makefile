.PHONY: ssh add s a n cm

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
	if [ "$$password" = "SSHKEY" ]; then \
		prev_level=$$(($(level) - 1)); \
		keyfile="$${prev_level}.sshkey.private"; \
		if [ ! -f "$$keyfile" ]; then \
			echo "Error: SSH key file $$keyfile not found"; \
			exit 1; \
		fi; \
		echo "Using SSH key: $$keyfile"; \
		ssh -i "$$keyfile" bandit$(level)@bandit.labs.overthewire.org -p 2220; \
	else \
		echo "Password: $$password"; \
		ssh bandit$(level)@bandit.labs.overthewire.org -p 2220; \
	fi

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

n:
	@highest_level=0; \
	for file in *.md; do \
		if [ -f "$$file" ]; then \
			filename=$$(basename "$$file" .md); \
			if [ "$$filename" -eq "$$filename" ] 2>/dev/null && [ "$$filename" -gt "$$highest_level" ]; then \
				highest_level=$$filename; \
			fi; \
		fi; \
	done 2>/dev/null; \
	newest_level=$$((highest_level + 1)); \
	echo "Starting newest level: $$newest_level"; \
	$(MAKE) ssh level=$$newest_level

cm:
	@git add *.md
	@msg=$$(git diff --cached --name-only | grep -E '^[0-9]+\.md$$' | sed 's/\.md$$//' | sort -n | tr '\n' ' ' | sed 's/ *$$//'); \
	if [ -z "$$msg" ]; then \
		echo "No numbered .md files to commit"; \
		exit 1; \
	fi; \
	git commit -m "$$msg"

# Catch-all rule to handle positional arguments for add command
%:
	@if [ "$@" != "ssh" ] && [ "$@" != "add" ] && [ "$@" != "s" ] && [ "$@" != "a" ] && [ "$@" != "n" ] && [ "$@" != "cm" ]; then \
		if echo "$(MAKECMDGOALS)" | grep -q "^add \|^a "; then \
			exit 0; \
		else \
			$(MAKE) ssh level=$@; \
		fi; \
	fi
