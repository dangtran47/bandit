.PHONY: ssh

# Pattern rule to allow "make 1", "make 2", etc.
%:
	@$(MAKE) ssh level=$@

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
