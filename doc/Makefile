DESTDIR = /usr/share/doc/tex-common

CLEANFILES = Debian-TeX-Policy.txt Debian-TeX-Policy.html Debian-TeX-Policy.tpt TeX-on-Debian.txt TeX-on-Debian.html TeX-on-Debian.tpt

all: policy-txt policy-html policy-pdf tex-on-debian-txt tex-on-debian-html tex-on-debian-pdf

policy-txt: Debian-TeX-Policy.sgml version.ent
	debiandoc2text Debian-TeX-Policy.sgml

policy-html: Debian-TeX-Policy.sgml version.ent
	debiandoc2html Debian-TeX-Policy.sgml

policy-pdf: Debian-TeX-Policy.pdf

Debian-TeX-Policy.pdf: Debian-TeX-Policy.sgml version.ent tex-sed
	debiandoc2latexpdf -s ./tex-sed Debian-TeX-Policy.sgml

tex-on-debian-txt: TeX-on-Debian.sgml
	debiandoc2text TeX-on-Debian.sgml

tex-on-debian-html: TeX-on-Debian.html
tex-on-debian-pdf: TeX-on-Debian.pdf

TeX-on-Debian.html: TeX-on-Debian.sgml
	debiandoc2html TeX-on-Debian.sgml

TeX-on-Debian.pdf: TeX-on-Debian.sgml tex-sed
	debiandoc2latexpdf -s ./tex-sed TeX-on-Debian.sgml


install:
	install -d $(DESTDIR)
	cp Debian-TeX-Policy.txt $(DESTDIR)/
	cp Debian-TeX-Policy.pdf $(DESTDIR)/
	cp -R Debian-TeX-Policy.html $(DESTDIR)/
	cp TeX-on-Debian.txt $(DESTDIR)/
	cp TeX-on-Debian.pdf $(DESTDIR)/
	cp -R TeX-on-Debian.html $(DESTDIR)/

clean:
	-rm -r $(CLEANFILES)

allclean: clean
	-rm  Debian-TeX-Policy.pdf
	-rm  TeX-on-Debian.pdf

.PHONY: all install clean allclean \
        policy-txt policy-html policy-pdf \
        tex-on-debian-txt tex-on-debian-html tex-on-debian-pdf
