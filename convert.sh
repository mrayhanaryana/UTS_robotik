%%bash
pip install -U notebook-as-pdf
pip install weasyprint
pyppeteer-install
jupyter-nbconvert --to html ./kodingan/symforce.ipynb
weasyprint ./kodingan/symforce.html ./kodingan/symforce.pdf