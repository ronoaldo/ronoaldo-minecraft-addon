PACKAGE=ronoaldo
VERSION=1.2.0

LUCKY_LOOT_CSV=BP/loot_tables/blocks/lucky.csv
LUCKY_LOOT=BP/loot_tables/blocks/lucky.json
TEST_LOOT=BP/loot_tables/blocks/test.json

build: clean $(LUCKY_LOOT)
	zip -r build/$(PACKAGE)-$(VERSION).mcaddon RP BP

clean:
	rm -vf build/* $(LUCKY_LOOT) $(TEST_LOOT)

$(LUCKY_LOOT): $(LUCKY_LOOT_CSV) $(TEST_LOOT)
	echo '{ "pools": [ { "rolls": 2, "entries": [' > $(LUCKY_LOOT)
	cat $(LUCKY_LOOT_CSV) | tr ',' ' ' | grep -v ^category | while read cat name chance perc ; do\
		echo "Item $$name/ $$cat with drop $$chance";\
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
	echo ' { "rolls": 1, "entries": [ { "type": "item", "name": "rono:lucky" } ] }' >> $(TEST_LOOT)
	echo ' { "rolls": 1, "entries": [ { "type": "item", "name": "rono:test" } ] }' >> $(TEST_LOOT)
	echo "] }" >> $(TEST_LOOT)