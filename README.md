Curriculum Vitae
================

Fonts
-----
- English
  - [Charis SIL](https://fonts.google.com/specimen/Charis+SIL)
  - [Lato](https://fonts.google.com/specimen/Lato)
- Korean
  - [KoPubWorld](https://www.kopus.org/biz-electronic-font2/)
- Monospace
  - D2Coding


Compilation
------------

### HTML
<!-- For html build, use the following command:

```make4ht -u -l CV.tex "mathjax" -d html -b html_build```

For cleaning up the build, use the following command:

```make4ht -m clean CV.tex``` -->
run `build_html.sh`

#### pdf2htmlEX

[Docker](https://github.com/pdf2htmlEX/pdf2htmlEX/wiki/Download-Docker-Image)를 사용할 것

```
alias pdf2htmlEX='docker run -ti --rm -v "`pwd`":/pdf -w /pdf pdf2htmlex/pdf2htmlex:0.18.8.rc2-master-20200820-alpine-3.12.0-x86_64'
pdf2htmlEX --zoom 1.3 CV.pdf
```

### LaTeX

- VSCode의 `LaTeX Workshop`에서 실행 (Magic comment로 미리 입력해두었음)
- Clean Up!
  - `latexmk -c`
