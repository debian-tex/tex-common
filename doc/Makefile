DESTDIR=/usr/share/doc/tex-common

CLEANFILES=Debian-TeX-Policy.txt Debian-TeX-Policy.html Debian-TeX-Policy.tpt

all: policy-txt policy-html policy-pdf

policy-txt: Debian-TeX-Policy.sgml  version.ent
	debiandoc2text Debian-TeX-Policy.sgml

policy-html: Debian-TeX-Policy.sgml  version.ent
	debiandoc2html Debian-TeX-Policy.sgml

policy-pdf: Debian-TeX-Policy.pdf

Debian-TeX-Policy.pdf: Debian-TeX-Policy.sgml  version.ent tex-sed
	debiandoc2latexpdf -s ./tex-sed Debian-TeX-Policy.sgml

install:
	install -d $(DESTDIR)
	cp Debian-TeX-Policy.txt $(DESTDIR)/
	cp Debian-TeX-Policy.pdf $(DESTDIR)/
	cp -R Debian-TeX-Policy.html $(DESTDIR)/

clean:
	-rm -r $(CLEANFILES)

allclean: clean
	-rm  Debian-TeX-Policy.pdf
