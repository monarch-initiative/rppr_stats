
START_DATE_P1=2022-08-01
END_DATE_P1=2023-05-31
START_DATE_HPO=2022-07-01
END_DATE_HPO=2023-06-30

ONTOLOGIES=mondo hp maxo
GRAINYHEAD_STATS=$(patsubst %, stats/grainyhead_%.md, $(ONTOLOGIES))
DIFF_STATS=$(patsubst %, stats/%_diff_summary.txt, $(ONTOLOGIES))

all: $(GRAINYHEAD_STATS) $(DIFF_STATS)

stats/grainyhead_hp.md:
	mkdir -p stats/
	grainyhead -s hp metrics --from=$(START_DATE_HPO) --to=$(END_DATE_HPO) --team human-phenotype > $@

stats/grainyhead_maxo.md:
	mkdir -p stats/
	grainyhead -s maxo metrics --from=$(START_DATE_HPO) --to=$(END_DATE_HPO) --team monarch-ontology-team > $@

stats/grainyhead_mondo.md:
	mkdir -p stats/
	grainyhead -s mondo metrics --from=$(START_DATE_P1) --to=$(END_DATE_P1) --team monarch-ontology-team > $@

ontologies/mondo_%.obo:
	mkdir -p ontologies/
	wget "http://purl.obolibrary.org/obo/mondo/releases/$*/mondo-base.obo" -O $@

ontologies/hp_%.obo:
	mkdir -p ontologies/
	wget "http://purl.obolibrary.org/obo/hp/releases/$*/hp-base.obo" -O $@

ontologies/hp_2022-06-11.obo:
	mkdir -p ontologies/
	wget "https://raw.githubusercontent.com/obophenotype/human-phenotype-ontology/v2022-06-11/hp-base.obo" -O $@

ontologies/maxo_%.obo:
	mkdir -p ontologies/
	wget "http://purl.obolibrary.org/obo/maxo/releases/$*/maxo-base.obo" -O $@

stats/mondo_diff.txt:
	$(eval START := 2022-08-01)
	$(eval END := 2023-03-01)
	$(eval ID := mondo)
	make ontologies/$(ID)_$(START).obo ontologies/$(ID)_$(END).obo
	#runoak -i simpleobo:ontologies/$(ID)_$(START).obo diff -X simpleobo:ontologies/$(ID)_$(END).obo -o $@.yaml --statistics
	robot diff --left ontologies/$(ID)_$(START).obo --right ontologies/$(ID)_$(END).obo -o $@
.PRECIOUS: stats/mondo_diff.txt

stats/maxo_diff.txt:
	mkdir -p stats/
	$(eval START := 2022-06-24)
	$(eval END := 2023-03-09)
	$(eval ID := maxo)
	make ontologies/$(ID)_$(START).obo ontologies/$(ID)_$(END).obo
	#runoak -i simpleobo:ontologies/$(ID)_$(START).obo diff -X simpleobo:ontologies/$(ID)_$(END).obo --statistics -o $@.yaml
	robot diff --left ontologies/$(ID)_$(START).obo --right ontologies/$(ID)_$(END).obo -o $@
.PRECIOUS: stats/maxo_diff.txt

stats/hp_diff.txt:
	mkdir -p stats/
	$(eval START := 2022-06-11)
	$(eval END := 2023-01-27)
	$(eval ID := hp)
	make ontologies/$(ID)_$(START).obo ontologies/$(ID)_$(END).obo
	#runoak -i simpleobo:ontologies/$(ID)_$(START).obo diff -X simpleobo:ontologies/$(ID)_$(END).obo --statistics -o $@.yaml
	robot diff --left ontologies/$(ID)_$(START).obo --right ontologies/$(ID)_$(END).obo -o $@
.PRECIOUS: stats/hp_diff.txt

stats/%_diff_summary.txt: stats/%_diff.txt
	echo "New Terms: " > $@
	grep "+ Declaration" $< | wc -l >> $@
	echo "New or updated definitions: " >> $@
	grep -E "[+] AnnotationAssertion.*IAO_0000115" $< | wc -l >> $@
	echo "New or updated synonyms: " >> $@
	grep -E "[+] AnnotationAssertion.*Synonym" $< | wc -l >> $@

https://github.com/obophenotype/human-phenotype-ontology/releases/download/v2023-03-01/hp-base.obo
