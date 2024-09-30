.PHONY: serve build pdf clean

serve:
	mkdocs serve

build:
	mkdocs build

clean:
	rm -rf site
	rm -f acp_terraform_guide.pdf