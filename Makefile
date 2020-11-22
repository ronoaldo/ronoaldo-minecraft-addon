PACKAGE=ronoaldo
VERSION=1.0.0
LUKY_LOOT=BP/loot_tables/blocks/lucky_block.json

build: clean $(LUKY_LOOT)
	zip -r build/$(PACKAGE)-$(VERSION).mcaddon RP BP

clean:
	rm -vf build/* $(LUKY_LOOT)

$(LUKY_LOOT):
	echo '{ "pools": [ { "rolls": 1, "entries": [' > $(LUKY_LOOT)
	cat minecraft.items.ids | while read item ; do \
		echo -n "  {\"type\": \"item\", \"name\": \"$$item\", " >> $(LUKY_LOOT);  \
		case $$item in \
			*diamond*)                                echo '"weight":  1,' >> $(LUKY_LOOT) ;;\
			*sword*|*helmet*|*chestplate*|*leggins*)  echo '"weight": 20,' >> $(LUKY_LOOT) ;;\
			*ore*|*apple*)                            echo '"weight": 12,' >> $(LUKY_LOOT) ;;\
			*)                                        echo '"weight":  9,' >> $(LUKY_LOOT) ;;\
		esac; \
		echo '    "functions": [ { "function": "set_count", "count": { "min": 1, "max": 1 } } ]' >> $(LUKY_LOOT) ; \
		echo '  },' >> $(LUKY_LOOT) ; \
	done
	echo '  {"type": "empty", "weight": 1}' >> $(LUKY_LOOT)
	echo "] } ] }" >> $(LUKY_LOOT)