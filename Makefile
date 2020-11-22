PACKAGE=ronoaldo
VERSION=1.0.0
LUCKY_LOOT=BP/loot_tables/blocks/lucky.json

build: clean $(LUCKY_LOOT)
	zip -r build/$(PACKAGE)-$(VERSION).mcaddon RP BP

clean:
	rm -vf build/* $(LUCKY_LOOT)

$(LUCKY_LOOT):
	echo '{ "pools": [ { "rolls": 1, "entries": [' > $(LUCKY_LOOT)
	cat minecraft.items.ids | while read item ; do \
		echo -n "  {\"type\": \"item\", \"name\": \"$$item\", " >> $(LUCKY_LOOT);\
		case $$item in \
			*diamond*) \
				echo '"weight": 10,' >> $(LUCKY_LOOT) ;\
				echo '    "functions": [ { "function": "set_count", "count": { "min": 1, "max": 1 } } ]' >> $(LUCKY_LOOT) ;;\
			*sword*|*helmet*|*chestplate*|*leggins*) \
				echo '"weight": 30,' >> $(LUCKY_LOOT) ;\
				echo '    "functions": [' >> $(LUCKY_LOOT) ;\
				echo '       { "function": "set_count", "count": { "min": 1, "max": 1 } } ,' >> $(LUCKY_LOOT) ;\
				echo '       { "function": "looting_enchant", "count": { "min": 1, "max": 9 } }' >> $(LUCKY_LOOT) ;\
				echo '    ]' >> $(LUCKY_LOOT) ;;\
			*carrot*|*apple*)\
				echo '"weight": 60,' >> $(LUCKY_LOOT) ;\
				echo '    "functions": [ { "function": "set_count", "count": { "min": 1, "max": 4 } } ]' >> $(LUCKY_LOOT) ;;\
			*) \
				echo '"weight": 20,' >> $(LUCKY_LOOT) ;\
				echo '    "functions": [ { "function": "set_count", "count": { "min": 1, "max": 4 } } ]' >> $(LUCKY_LOOT) ;;\
		esac; \
		echo '  },' >> $(LUCKY_LOOT) ;\
	done
	echo '  {"type": "empty", "weight": 0}' >> $(LUCKY_LOOT)
	echo "] } ] }" >> $(LUCKY_LOOT)
