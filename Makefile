# Packate name and setup 
PACKAGE = ronoaldo
VERSION:= $(shell cat VERSION.txt)

# Generated files
LUCKY_LOOT_CSV=BP/loot_tables/rono/lucky.odds.csv
LUCKY_LOOT=BP/loot_tables/rono/lucky.loot.json

# Used for TERMUX only
TERMUX_DIR  := /data/data/com.termux/files/home/storage/shared/games/com.mojang
TERMUX_USER := user
TERMUX_PORT := 8022
TERMUX_HOST := 192.168.15.16

## help: show this help menu
help:
	@grep "^##" Makefile | sed -e 's/## //' -e 's/:/\n\t/g'

## build: clean up the data and build the .mcaddon file
build: clean $(LUCKY_LOOT)
	zip -qr build/$(PACKAGE)-$(VERSION).mcaddon RP BP

## clean: removes any generated file, including the computed loot tables and addon files
clean:
	rm -vf build/* $(LUCKY_LOOT) $(TEST_LOOT)

## BP/loot_tables/rono/lucky.loot.json: assembles lucky block loot tables
$(LUCKY_LOOT): $(LUCKY_LOOT_CSV) $(TEST_LOOT)
	echo '{ "pools": [ { "rolls": 1, "entries": [' > $(LUCKY_LOOT)
	cat $(LUCKY_LOOT_CSV) | tr ',' ' ' | grep -v ^category | while read cat name chance perc ; do\
		echo "  {\"type\": \"item\", \"name\": \"$$name\", \"weight\": $$chance, " >> $(LUCKY_LOOT);\
		case $$name in \
			*sword*|*helmet*|*chestplate*|*leggins*) \
				echo '   "functions": [' >> $(LUCKY_LOOT) ;\
				echo '     { "function": "set_count", "count": { "min": 1, "max": 1 } } ,' >> $(LUCKY_LOOT) ;\
				echo '     { "function": "enchant_randomly" }' >> $(LUCKY_LOOT) ;\
				echo '   ]' >> $(LUCKY_LOOT) ;;\
			*) \
				echo '   "functions": [ { "function": "set_count", "count": { "min": 1, "max": 1 } } ]' >> $(LUCKY_LOOT) ;;\
		esac; \
		echo '  },' >> $(LUCKY_LOOT) ;\
	done
	cat  BP/loot_tables/rono/mobs.loot.json_fragment >> $(LUCKY_LOOT) 
	echo '  {"type": "empty", "weight": 1}' >> $(LUCKY_LOOT)
	echo "] } ] }" >> $(LUCKY_LOOT)


## push-to-termux: helper to test the plugin sending data to the android device via Termux app sshd
push-to-termux: build
	rsync -avz BP/ -e "ssh -p $(TERMUX_PORT)" $(TERMUX_USER)@$(TERMUX_HOST):$(TERMUX_DIR)/development_behavior_packs/BP/
	rsync -avz RP/ -e "ssh -p $(TERMUX_PORT)" $(TERMUX_USER)@$(TERMUX_HOST):$(TERMUX_DIR)/development_resource_packs/RP/

## bump-version: increments and commits the VERSION.txt file
bump-version:
	cat VERSION.txt | tr '.' ' ' | (read major minor build ;\
	build=$$(( build+1 )) ;\
	sed -e "s/.[0-9]\+$$/.$$build/" -i VERSION.txt ;\
	for m in RP/manifest.json BP/manifest.json; do\
		sed -e "s;\"version\": \[.*;\"version\": [$$major, $$minor, $$build],;g" -i $$m ;\
	done)
	git add VERSION.txt */manifest.json
	git VERSION.txt commit -m "Bump version to $$(cat VERSION.txt)"

## release: perform all steps to release the current workspace as a new version
release: bump-version
	make build
	(printf "# Changelog for $$(cat VERSION.txt)\n\n" ;\
	 git log --format="* %s" $$(git describe --tags --abbrev=0)..HEAD |\
	 grep -v "Bump version" || true) > /tmp/changes.txt
	cat /tmp/changes.txt
	git push
	VERSION=$$(cat VERSION.txt) ;\
	gh release create $$VERSION build/ronoaldo-$$VERSION.mcaddon \
		--draft --prerelease --target $$(git rev-parse HEAD) \
		--title "Release $$VERSION" --notes-file /tmp/changes.txt
