PACKAGE=ronoaldo
VERSION=1.3.0

LUCKY_LOOT_CSV=BP/loot_tables/blocks/lucky.csv
LUCKY_LOOT=BP/loot_tables/blocks/lucky.json
TEST_LOOT=BP/loot_tables/blocks/test.json

build: clean $(LUCKY_LOOT)
	zip -qr build/$(PACKAGE)-$(VERSION).mcaddon RP BP

clean:
	rm -vf build/* $(LUCKY_LOOT) $(TEST_LOOT)

$(LUCKY_LOOT): $(LUCKY_LOOT_CSV) $(TEST_LOOT)
	echo '{ "pools": [ { "rolls": 2, "entries": [' > $(LUCKY_LOOT)
	cat $(LUCKY_LOOT_CSV) | tr ',' ' ' | grep -v ^category | while read cat name chance perc ; do\
		echo "  {\"type\": \"item\", \"name\": \"$$name\", \"weight\": $$chance, " >> $(LUCKY_LOOT);\
		case $$name in \
			*sword*|*helmet*|*chestplate*|*leggins*) \
				echo '   "functions": [' >> $(LUCKY_LOOT) ;\
				echo '     { "function": "set_count", "count": { "min": 1, "max": 1 } } ,' >> $(LUCKY_LOOT) ;\
				echo '     { "function": "enchant_randomly" }' >> $(LUCKY_LOOT) ;\
				echo '   ]' >> $(LUCKY_LOOT) ;;\
			*) \
				echo '   "functions": [ { "function": "set_count", "count": { "min": 1, "max": 4 } } ]' >> $(LUCKY_LOOT) ;;\
		esac; \
		echo '  },' >> $(LUCKY_LOOT) ;\
	done
	echo '  {"type": "empty", "weight": 1}' >> $(LUCKY_LOOT)
	echo "] } ] }" >> $(LUCKY_LOOT)

$(TEST_LOOT):
	echo '{ "pools": [ ' > $(TEST_LOOT)
	cat $(LUCKY_LOOT_CSV) | tr ',' ' ' | grep -v ^category | while read cat name chance perc ; do\
		echo " { \"rolls\": 1, \"entries\": [ { \"type\": \"item\", \"name\": \"$$name\" } ] }, " >> $(TEST_LOOT) ;\
	done
	echo ' { "rolls": 1, "entries": [ { "type": "item", "name": "rono:lucky" } ] },' >> $(TEST_LOOT)
	echo ' { "rolls": 1, "entries": [ { "type": "item", "name": "rono:test" } ] }' >> $(TEST_LOOT)
	echo "] }" >> $(TEST_LOOT)

TERMUX_DIR  := /data/data/com.termux/files/home/storage/shared/games/com.mojang
TERMUX_USER := user
TERMUX_PORT := 8022
TERMUX_HOST := 192.168.15.16

push-to-termux: build
	rsync -avz BP/ -e "ssh -p $(TERMUX_PORT)" $(TERMUX_USER)@$(TERMUX_HOST):$(TERMUX_DIR)/development_behavior_packs/BP/
	rsync -avz RP/ -e "ssh -p $(TERMUX_PORT)" $(TERMUX_USER)@$(TERMUX_HOST):$(TERMUX_DIR)/development_resource_packs/RP/
