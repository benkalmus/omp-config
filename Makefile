PACKAGES := pi

.PHONY: all stow unstow restow backup

all: stow

# --no-folding keeps ~/.omp/agent a real directory, so omp can write its
# databases and caches beside the stowed files.
stow: backup
	@for pkg in $(PACKAGES); do \
		echo "Stowing $$pkg..."; \
		stow -v -R --no-folding -t $(HOME) $$pkg; \
	done

# Back up only genuine collisions: a real file standing under real directories.
# Anything living under a symlink belongs to stow's subtree and is left alone.
backup:
	@for pkg in $(PACKAGES); do \
		( cd $$pkg && find . -mindepth 1 \( -type f -o -type l \) | sed 's|^\./||' | while IFS= read -r f; do \
			tgt="$(HOME)/$$f"; \
			d="$$tgt"; owned=0; \
			while [ "$$d" != "$(HOME)" ] && [ "$$d" != "/" ]; do \
				d=$$(dirname "$$d"); \
				if [ -L "$$d" ]; then owned=1; break; fi; \
			done; \
			if [ $$owned -eq 0 ] && [ -e "$$tgt" ] && [ ! -L "$$tgt" ]; then \
				suffix=".bak.$$(date +%Y%m%d%H%M%S)"; \
				echo "Collision on $$tgt, backing up to $$tgt$$suffix..."; \
				mv "$$tgt" "$$tgt$$suffix"; \
			fi; \
		done ); \
	done

unstow:
	@for pkg in $(PACKAGES); do \
		echo "Unstowing $$pkg..."; \
		stow -v -D --no-folding -t $(HOME) $$pkg; \
	done

restow: unstow stow
