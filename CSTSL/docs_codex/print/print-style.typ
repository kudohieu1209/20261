// Kiểu bài tập VLDT: serif 11pt, lề 2.5cm, nội dung liên tục, không khung hộp.
#let print-style(title: "Ôn giữa kỳ", appendix: false, body) = {
  set document(title: title)
  set page(
    paper: "a4", margin: 2.5cm,
    header: none,
    footer: context align(center, text(size: 10pt, fill: black)[
      #if appendix [P]#counter(page).display()
    ]),
  )
  set text(font: "Palatino Linotype", size: 11pt, fill: black, lang: "vi")
  show math.equation: set text(font: "New Computer Modern Math", fill: black)
  show math.equation.where(block: true): set text(size: 11.5pt)
  show math.equation.where(block: true): set block(above: 5pt, below: 5pt, breakable: false)
  set par(justify: true, first-line-indent: 0pt, leading: 0.62em, spacing: 6pt)
  set list(indent: 8pt, body-indent: 6pt, spacing: 4pt)
  set enum(indent: 8pt, body-indent: 6pt, spacing: 4pt)
  set table(stroke: (left: none, right: none, top: 0.35pt + black, bottom: 0.35pt + black),
    inset: (x: 5pt, y: 5pt))
  show table: it => block(breakable: false, it)
  show heading.where(level: 1): it => block(width: 100%, above: 16pt, below: 11pt, sticky: true,
    text(13pt, weight: "bold", it.body))
  show heading.where(level: 2): it => block(above: 13pt, below: 9pt, sticky: true,
    text(11.5pt, weight: "bold", it.body))
  show heading.where(level: 3): it => block(above: 8pt, below: 5pt, sticky: true,
    text(11pt, weight: "bold", it.body))
  body
}

#let note(title, body) = block(width: 100%, breakable: false, above: 11pt, below: 10pt)[
  #set par(justify: false)
  #block(sticky: true, below: 8pt, text(weight: "bold", title))
  #body
]

#let example(ex) = block(width: 100%, breakable: ex.id == "VD 12", above: 15pt, below: 14pt)[
  #metadata((kind: "example", id: ex.id, title: ex.short)) <print-index>
  #block(width: 100%, breakable: false, sticky: true)[
    #block(sticky: true, below: 7pt)[
      *#if ex.id.slice(0, 3) == "VD " { "Ví dụ " + ex.id.slice(3) } else { "Bài tập " + ex.id.slice(3) }. #ex.title.*
    ]
    #ex.prompt
  ]
  #block(above: 9pt)[
    #set par(justify: false)
    #block(sticky: true, below: 7pt)[_Giải._]
    #ex.answer
  ]
  #metadata((kind: "example-end", id: ex.id)) <print-index>
]

#let question(q, answer: none, title: none) = block(width: 100%, breakable: false,
  above: 12pt, below: 10pt)[
  #metadata((kind: "question", id: q.id)) <print-index>
  #block(sticky: true, below: 6pt)[*#if title == none { q.question } else { title }*]
  #if q.id.slice(0, 1) == "C" {
    if answer == none { q.answer } else { answer }
  } else {
    [#show strong: it => it.body
    #if answer == none { q.answer } else { answer }]
  }
]

// Sơ đồ mục lục dùng cho bản in: tên chủ đề và số trang.
#let topic-pages(kind, ids) = context {
  let items = query(<print-index>).filter(it => it.value.id in ids and
    (it.value.kind == kind or (kind == "span" and it.value.kind in ("formula", "question", "example", "example-end"))))
  let first = calc.min(..items.map(it => it.location().page()))
  let last = calc.max(..items.map(it => it.location().page()))
  if kind == "example" {
    let ends = query(<print-index>).filter(it => it.value.kind == kind + "-end" and it.value.id in ids)
    last = calc.max(last, ..ends.map(it => it.location().page()))
  }
  [tr. #first#if last != first [–#last]]
}

#let topic-map(groups) = layout(size => {
  let row = 20pt
  let header = 23pt
  let gap = 12pt
  let group-x = 92pt
  let leaf-x = 111pt
  let spine = 76pt
  let ys = ()
  let y = 0pt
  for group in groups {
    ys.push(y)
    y += header + row * group.items.len() + gap
  }
  let total = y - gap
  let first-anchor = 7pt
  let last-anchor = ys.last() + 7pt
  let middle = (first-anchor + last-anchor)/2
  box(width: size.width, height: total)[
    #place(line(start: (62pt, middle), end: (spine, middle), stroke: 0.6pt))
    #place(line(start: (spine, first-anchor), end: (spine, last-anchor), stroke: 0.6pt))
    #place(dx: 0pt, dy: middle - 16pt,
      box(width: 60pt, align(center)[*GIỮA KỲ* \ *CSTSL*]))
    #for (i, group) in groups.enumerate() {
      let base = ys.at(i)
      place(line(start: (spine, base+7pt), end: (group-x - 5pt, base+7pt), stroke: 0.6pt))
      place(dx: group-x, dy: base,
        box(width: size.width - group-x, text(11.5pt, weight:"bold", group.title)))
      let last-leaf = base + header + row*(group.items.len()-1) + 6pt
      place(line(start: (group-x+6pt, base+18pt), end: (group-x+6pt, last-leaf), stroke: 0.4pt))
      for (j, item) in group.items.enumerate() {
        let leaf-y = base + header + row*j
        place(line(start: (group-x+6pt, leaf-y+6pt), end: (leaf-x - 4pt, leaf-y+6pt), stroke: 0.4pt))
        place(dx: leaf-x, dy: leaf-y,
          box(width: size.width - leaf-x, grid(columns:(1fr,auto), column-gutter:8pt,
            item.title,
            if "pages" in item { item.pages } else { topic-pages(item.kind, item.ids) },
          )))
      }
    }
  ]
})

#let formula(card) = {
  [#metadata((kind: "formula", id: card.id, title: card.title)) <print-index>]
  note(card.title, card.body)
}
