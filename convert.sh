%%bash
pip install -U notebook-as-pdf
pip install weasyprint
pyppeteer-install
jupyter-nbconvert --to html symforce.ipynb
weasyprint symforce-exploration.html symforce-2D-example.pdf