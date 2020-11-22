PACKAGE=ronoaldo
VERSION=1.0.0

build: clean
	zip -r build/$(PACKAGE)-$(VERSION).mcaddon RP BP

clean:
	rm -vf build/*
