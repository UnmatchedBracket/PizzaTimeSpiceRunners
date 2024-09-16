.PHONY: build run buildrun dualrun builddualrun releasebuild

build:
	rm -f build.pk3
	cd src; zip -r9 ../build.pk3 *

buildslim:
	rm -f build.pk3
	cd src; zip -r9 ../build.pk3 * -x "Music/*" -x "Maps/*"

buildassets:
	rm -f PTSRLargeAssets.pk3
	cd src; zip -r9 ../PTSRLargeAssets.pk3 Music/* Maps/*

run:
	cd ~/.srb2/; ./lsdl2srb2 $(SRB2OPT) -file $(CURDIR)/build.pk3

buildrun: build run
buildslimrun: buildslim run

dualrun:
	cd ~/.srb2/; ./lsdl2srb2 $(SRB2OPT) -server -file $(CURDIR)/build.pk3 & ./lsdl2srb2 $(SRB2OPT) -connect localhost -file $(CURDIR)/build.pk3

builddualrun: build dualrun

releasebuild: build
	cp build.pk3 L_PizzaTimeDeluxe-v$(shell read -p "Version (e.g. 1.2.1): " ver && echo $$ver).pk3