// Kiểu sách bài giải, dùng chung cho 12 tập ET4070.
#let accent = black
#let warn = black
#let soft = white
#let green = black
#let ok = black
#let ackc = black
#let book(body) = {
  set page(paper: "a4", margin: (x: 2.2cm, top: 2.1cm, bottom: 2cm),
    header: none, footer: context align(center, text(10pt, counter(page).display())))
  set text(font: ("Palatino Linotype", "Libertinus Serif"), size: 11pt, lang: "vi", fill: black)
  show math.equation: set text(font: "New Computer Modern Math")
  set par(justify: true, leading: 1em, spacing: 1.3em, first-line-indent: 0pt)
  set list(spacing: 0.75em, indent: 0pt, body-indent: 0.7em)
  set enum(spacing: 0.75em, indent: 0pt, body-indent: 0.7em)
  set table(stroke: 0.4pt + black, inset: (x: 5pt, y: 6pt), fill: none)
  show table: it => block(breakable: false, above: 10pt, below: 10pt, { set text(10pt); it })
  show table.cell.where(y: 0): set text(weight: "bold")
  show heading: it => block(sticky: true,
    above: if it.level == 1 { 16pt } else { 12pt }, below: 7pt,
    text(size: if it.level == 1 { 13pt } else if it.level == 2 { 11.5pt } else { 11pt }, weight: "bold", it.body))
  show math.equation.where(block: true): set block(above: 5pt, below: 5pt)
  body
}
#let box-note(title, color, body) = block(width: 100%, above: 14pt, below: 11pt)[
  #block(sticky: true, below: 6pt)[*#title.*]
  #body
]
#let khuon(body) = box-note("Khuôn giải", black, body)
#let bay(body) = box-note("Bẫy", black, body)
#let mau(title, body) = block(breakable: false, box-note("Bài mẫu — " + title, black, body))
#let mau-hinh(n, title, body) = box-note("Bài mẫu " + n + " — " + title, black, body)
#let o-viet(h) = []
#let bai(n, body, h: 4.2cm, fig: none, fw: 6.5cm) = block(width: 100%, above: 12pt, below: 6pt)[*Bài #n.* #body #if fig != none { align(center, fig) }]
#let tieude(body) = heading(level: 1, body)
#let cau(title, body) = block(width: 100%, above: 9pt, below: 7pt)[
  #set enum(numbering: "a)", indent: 0pt, body-indent: 0.8em, spacing: 0.8em)
  #heading(level: 2, title)
  #body
]
#let lam-bai = []
#let tiep(label) = []
#let d(s) = [#h(1fr)#text(9.5pt, weight: "bold", s)]
#let yi(n, diem, title) = block(sticky: true, above: 9pt, below: 5pt)[*Ý #n (#diem). #title*]
// Đáp án nối tiếp theo bài, không dùng lưới bảng.
#let answer-table(columns: none, ..args) = {
  let cells = args.pos()
  for i in range(2, cells.len(), step: 2) {
    block(width: 100%, above: 5pt, below: 3pt)[*Bài #cells.at(i).* #cells.at(i + 1)]
  }
}
#let flow-grid(columns: none, column-gutter: 0pt, align: none, ..args) = {
  for cell in args.pos() { block(width: 100%, above: 0pt, below: 2pt, cell) }
}
