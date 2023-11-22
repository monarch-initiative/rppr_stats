
START_DATE=
END_DATE=
FIRST_RELEASE=
LAST_RELEASE=
ID=

ONTOLOGIES=mondo hp maxo
GRAINYHEAD_STATS=$(patsubst %, stats/grainyhead_%.md, $(ONTOLOGIES))
DIFF_STATS=$(patsubst %, stats/%_diff_summary.txt, $(ONTOLOGIES))

all: $(GRAINYHEAD_STATS) $(DIFF_STATS)

p1-rppr-2023:
	make START_DATE=2022-08-01 END_DATE=2023-05-31 all #This wont work now because we changed the makefile, see below

hpo-nar-2023:
	make START_DATE=2020-09-15 END_DATE=2023-09-07 FIRST_RELEASE=2020-10-12 LAST_RELEASE=2023-09-01 stats/grainyhead_hp.md stats/hp_diff.txt

stats/grainyhead_hp.md:
	mkdir -p stats/
	grainyhead -s hp metrics --from=$(START_DATE) --to=$(END_DATE) --team human-phenotype > $@

stats/grainyhead_maxo.md:
	mkdir -p stats/
	grainyhead -s maxo metrics --from=$(START_DATE) --to=$(END_DATE) --team monarch-ontology-team > $@

stats/grainyhead_mondo.md:
	mkdir -p stats/
	grainyhead -s mondo metrics --from=$(START_DATE) --to=$(END_DATE) --team monarch-ontology-team > $@

ontologies/latest_%.obo:
	mkdir -p ontologies/
	wget "http://purl.obolibrary.org/obo/$*.obo" -O $@

ontologies/mondo_%.obo:
	mkdir -p ontologies/
	wget "http://purl.obolibrary.org/obo/mondo/releases/$*/mondo-base.obo" -O $@

ontologies/hp_%.obo:
	mkdir -p ontologies/
	wget "http://purl.obolibrary.org/obo/hp/releases/$*/hp-base.obo" -O $@

ontologies/hp_2022-06-11.obo:
	mkdir -p ontologies/
	wget "https://raw.githubusercontent.com/obophenotype/human-phenotype-ontology/v2022-06-11/hp-base.obo" -O $@

ontologies/hp_2020-10-12.obo:
	mkdir -p ontologies/
	wget "https://raw.githubusercontent.com/obophenotype/human-phenotype-ontology/v2020-10-12/hp-base.obo" -O $@

ontologies/maxo_%.obo:
	mkdir -p ontologies/
	wget "http://purl.obolibrary.org/obo/maxo/releases/$*/maxo-base.obo" -O $@

stats/mondo_diff.txt:
	$(eval ID := mondo)
	mkdir -p stats/
	$(MAKE) ontologies/$(ID)_$(FIRST_RELEASE).obo ontologies/$(ID)_$(LAST_RELEASE).obo
	runoak -i simpleobo:ontologies/$(ID)_$(FIRST_RELEASE).obo diff -X simpleobo:ontologies/$(ID)_$(LAST_RELEASE).obo --statistics -o $@.yaml
	robot diff --left ontologies/$(ID)_$(FIRST_RELEASE).obo --right ontologies/$(ID)_$(LAST_RELEASE).obo -o $@
.PRECIOUS: stats/mondo_diff.txt

stats/maxo_diff.txt:
	$(eval ID := maxo)
	mkdir -p stats/
	$(MAKE) ontologies/$(ID)_$(FIRST_RELEASE).obo ontologies/$(ID)_$(LAST_RELEASE).obo
	runoak -i simpleobo:ontologies/$(ID)_$(FIRST_RELEASE).obo diff -X simpleobo:ontologies/$(ID)_$(LAST_RELEASE).obo --statistics -o $@.yaml
	robot diff --left ontologies/$(ID)_$(FIRST_RELEASE).obo --right ontologies/$(ID)_$(LAST_RELEASE).obo -o $@
.PRECIOUS: stats/maxo_diff.txt

stats/hp_diff.txt:
	$(eval ID := hp)
	mkdir -p stats/
	$(MAKE) ontologies/$(ID)_$(FIRST_RELEASE).obo ontologies/$(ID)_$(LAST_RELEASE).obo
	runoak -i simpleobo:ontologies/$(ID)_$(FIRST_RELEASE).obo diff -X simpleobo:ontologies/$(ID)_$(LAST_RELEASE).obo --statistics -o $@.yaml
	robot diff --left ontologies/$(ID)_$(FIRST_RELEASE).obo --right ontologies/$(ID)_$(LAST_RELEASE).obo -o $@
.PRECIOUS: stats/hp_diff.txt

stats/%_diff_summary.txt: stats/%_diff.txt
	echo "New Terms: " > $@
	grep "+ Declaration" $< | wc -l >> $@
	echo "New or updated definitions: " >> $@
	grep -E "[+] AnnotationAssertion.*IAO_0000115" $< | wc -l >> $@
	echo "New or updated synonyms: " >> $@
	grep -E "[+] AnnotationAssertion.*Synonym" $< | wc -l >> $@

stats/%_statistics_summary.txt: ontologies/latest_%.obo
	runoak -i simpleobo:ontologies/latest_$*.obo statistics --group-by-prefix > $@


### This is to generate stats on a by-user level, which is great for contribution measurement

stats/grh_by_user_%.md:
	mkdir -p stats/
	grainyhead -s $* metrics --from=$(START_DATE) --to=$(END_DATE) --selector 'user:*' > $@


mondo-paper-2023:
	$(MAKE) START_DATE=2020-01-01 END_DATE=2023-12-31 stats/grh_by_user_mondo.md