PACKAGE=ronoaldo
VERSION=1.0.0
LUCKY_LOOT=BP/loot_tables/blocks/lucky.json
LUCKY_LOOT_CSV=BP/loot_tables/blocks/lucky.csv

build: clean $(LUCKY_LOOT)
	zip -r build/$(PACKAGE)-$(VERSION).mcaddon RP BP

clean:
	rm -vf build/* $(LUCKY_LOOT)

$(LUCKY_LOOT): $(LUCKY_LOOT_CSV)
	echo '{ "pools": [ { "rolls": 2, "entries": [' > $(LUCKY_LOOT)
	cat $(LUCKY_LOOT_CSV) | tr ',' ' ' | grep -v ^category | while read cat name chance perc ; do\
		echo "Item $$name/ $$cat with drop $$chance";\
		echo "  {\"type\": \"item\", \"name\": \"$$name\", \"weight\": $$chance, " >> $(LUCKY_LOOT);\
		case $$name in \
			*diamond*) \
				echo '   "functions": [ { "function": "set_count", "count": { "min": 1, "max": 1 } } ]' >> $(LUCKY_LOOT) ;;\
			*sword*|*helmet*|*chestplate*|*leggins*) \
				echo '   "functions": [' >> $(LUCKY_LOOT) ;\
				echo '     { "function": "set_count", "count": { "min": 1, "max": 1 } } ,' >> $(LUCKY_LOOT) ;\
				echo '     { "function": "enchant_randomly" }' >> $(LUCKY_LOOT) ;\
				echo '   ]' >> $(LUCKY_LOOT) ;;\
			*carrot*|*apple*)\
				echo '   "functions": [ { "function": "set_count", "count": { "min": 2, "max": 4 } } ]' >> $(LUCKY_LOOT) ;;\
			*) \
				echo '   "functions": [ { "function": "set_count", "count": { "min": 1, "max": 4 } } ]' >> $(LUCKY_LOOT) ;;\
		esac; \
		echo '  },' >> $(LUCKY_LOOT) ;\
	done
	echo '  {"type": "empty", "weight": 1}' >> $(LUCKY_LOOT)
	echo "] } ] }" >> $(LUCKY_LOOT)
