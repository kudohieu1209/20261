"""Chỉ chuyển hình thức. Chạy ở thư mục này; nguồn gốc chỉ đọc."""
from pathlib import Path
import re, shutil, hashlib, json
from PIL import Image
OUT=Path(__file__).resolve().parent
SRC=OUT.parents[1]/'on-luyen-tablet'
SHARED=OUT.parent/'content'
COMMON={'accent','warn','soft','green','ok','ackc','box-note','khuon','bay','mau','mau-hinh','o-viet','bai','tieude','cau','lam-bai','tiep','d','yi'}
def remove_defs(s,names):
 for name in names:
  s=re.sub(r'^#let '+re.escape(name)+r'(?=[\s(=])[^\n]*(?:\n(?!#|//|\s*$)[^\n]*)*', '', s, flags=re.M)
 return s

def monochrome(s):
 # Các màu nhạt là nền trắng; mọi màu mực thành đen.
 def col(m):
  c=m.group(1); vals=[int(c[i:i+2],16) for i in (0,2,4)]
  return 'white' if min(vals)>170 else 'black'
 s=re.sub(r'rgb\("#([0-9a-fA-F]{6})"\)',col,s)
 s=re.sub(r'(?:accent|warn|green|ok|ackc|black|white|soft)\.(?:lighten|darken)\([^)]*\)',lambda m: 'white' if m.group().startswith(('soft','white')) else 'black',s)
 # Chữ luôn đen, nền nhẹ luôn trắng; không đảo chữ trắng trên nền đậm.
 s=re.sub(r'text\(white\b','text(black',s)
 s=re.sub(r'(text\([^\n)]*?fill: )white\b',r'\1black',s)
 s=re.sub(r'fill: luma\((?:1[7-9]\d|2\d\d)\)', 'fill: white',s)
 s=re.sub(r'fill: \w+\.lighten\([^)]*\)', 'fill: white',s)
 s=re.sub(r'\w+\.(?:lighten|darken)\([^)]*\)', 'black',s)
 s=re.sub(r'luma\(\d+\)', 'black',s)
 s=re.sub(r'\bgray\b', 'black',s)
 s=s.replace('fill: (x, y) => (if y == 0 { accent } else { green }).lighten(93%),','fill: white,')
 return s

def make(p):
 s=p.read_text()
 # Giữ metadata và import; thay bộ luật trình bày đầu tập bằng style chung.
 start=s.index('#set page(')
 end=s.index('// Hộp ghi chú') if p.name.startswith('GK0_') else s.index('#let box-note')
 s=s[:start]+'#show: book\n\n'+s[end:]
 s=remove_defs(s,COMMON)
 s=s.replace('../mang-phong-thi/content/','content/')
 s='#import "style.typ": *\n'+s
 s=monochrome(s)
 s=re.sub(r'#set text\((?:11\.5|12\.5|13|12|11)pt\)', '#set text(11pt)',s)
 s=s.replace('#set par(leading: 0.68em, spacing: 0.95em)','')
 s=re.sub(r'#set par\(leading: (?:0\.9|0\.75)em[^)]*\)', '',s)
 s=s.replace('#v(1cm)','#v(3pt)').replace('#v(0.6cm)','#v(3pt)')
 s=s.replace('#text(22pt,','#text(16pt,').replace('#text(18pt,','#text(16pt,')
 # Bỏ ngắt trang phục vụ ô viết, vẫn tách từng đề và phần lời giải.
 s=s.replace('#pagebreak()','')
 s=s.replace('breakable: false','breakable: true')
 # Chỉ cập nhật chỉ dẫn thao tác vốn tham chiếu ô viết đã bỏ.
 s=s.replace(' — viết thẳng vào ô chấm','')
 s=s.replace('ngay vào ô chấm bên dưới mỗi bài','ra giấy riêng')
 s=s.replace('Viết thẳng vào ô lưới dưới mỗi câu.','Làm bài ra giấy riêng.')
 s=s.replace('Làm thẳng vào ô trống dưới mỗi câu.','Làm bài ra giấy riêng.')
 if p.name.startswith(('GK6_','CK5_')):
  s=re.sub(r'^(= (?:ĐỀ THI|Đề thi|ĐỀ SỐ|Đề số|Lời giải đề).*)$',r'#pagebreak(weak: true)\n\1',s,flags=re.M)
  s=s.replace('rows: (auto, 1.5cm),','rows: auto,')
 # Vòng tròn đánh số kết nối CK4: nền trắng, số đen và viền đen.
 s=s.replace('fill: c, stroke: none),','fill: white, stroke: 0.6pt + black),')
 # Làm gọn khung hỏi đáp và lý thuyết thành các đoạn.
 if p.name.startswith('GK5_'):
  s=remove_defs(s,{'the'})
  anchor='#let render-the'
  pos=s.index(anchor)
  s=s[:pos]+'''#let the(ma, hoi, dap) = block(width: 100%, above: 8pt, below: 6pt)[
  #block(sticky: true, below: 4pt)[*#ma. #hoi*]
  #dap
]
\n'''+s[pos:]
 if p.name.startswith('CK1_'):
  s=remove_defs(s,{'the'})
  pos=s.index('// =================')
  s=s[:pos]+'''#let the(hoi, dap) = block(width: 100%, above: 7pt, below: 6pt)[
  #block(sticky: true, below: 4pt)[*Hỏi: #hoi*]
  *Đáp:* #dap
]
\n'''+s[pos:]
 if p.name.startswith('GK0_'):
  s=s.replace('breakable: breakable','breakable: true')
  s=s.replace('#pad(left: 4pt, body)','#block(sticky: true)[*Giải.*]\n  #body')
  s=s.replace('VD 3"),\n  render-vd("VD 4"),','VD 3"),\n  render-vd("VD 4"),')
  s=re.sub(r'#grid\(columns: \(1fr, 1fr\), column-gutter: 10pt,\s*render-vd\("VD 3"\),\s*render-vd\("VD 4"\),\s*\)', '#render-vd("VD 3")\n\n#render-vd("VD 4")',s)

 # Nhãn và hình chuyển sang dọc để không bị chồng trong cột hẹp.
 if p.name.startswith('CK1_'):
  s=s.replace('#grid(', '#flow-grid(')
  s=s.replace('block(spacing: 6pt)', 'block(spacing: 3pt)').replace('inset: 4pt, radius: 2pt, image', 'inset: 2pt, radius: 0pt, image')
  s=s.replace('Ô tô vàng = nút được chốt ở bước đó.', 'Chữ đậm = nút được chốt ở bước đó.').replace('kê bảng, vẽ cây ra giấy riêng','kê bảng, vẽ cây')
 if p.name.startswith('CK5_'):
  s=s.replace('13cm)', '11cm)').replace('12.5cm)', '11cm)').replace('6.5cm)', '5.5cm)').replace('8.5cm)', '6.5cm)')
  s=s.replace('rows: (auto, 1.6cm),','rows: auto,').replace('inset: 9pt,','inset: 4pt,')
 if p.name.startswith('CK3_'):
  s=s.replace('dải xanh = khung, mũi tên xanh lá = ACK/NAK','dải viền đen = khung, mũi tên ngược = ACK/NAK')
 if p.name.startswith('CK4_'):
  # ACK có bit tắc dùng nét đứt; ACK còn lại nét liền.
  s=s.replace('let arrow(x1, y1, x2, y2, c, w) = {','let arrow(x1, y1, x2, y2, c, w, tac: false) = {')
  s=s.replace('stroke: w + c))','stroke: (paint: black, thickness: w, dash: if tac { "dashed" } else { "solid" })))')
  s=s.replace('arrow(xd, y(ts + 5.8), xs, y(ts + 10.8), c, 0.85pt)','arrow(xd, y(ts + 5.8), xs, y(ts + 10.8), c, 0.85pt, tac: k in tac)')
  s=s.replace('— đỏ: ACK có bit tắc','– – nét đứt: ACK có bit tắc').replace('— xanh: không tắc','— nét liền: không tắc')
  # Chiều cao giản đồ thời gian giữ nguyên, giảm phần bề rộng lời dẫn.
 if p.name.startswith('GK1_'):
  s=s.replace('columns: (1.25fr, 1fr, 2.5fr, 0.8fr, 1fr),','columns: (1.25fr, 1fr, 2.5fr, 0.8fr, 1fr), inset: (x: 3pt, y: 2pt),')
 # Bỏ các nhãn chỉ dành cho ô viết tay.
 s=s.replace('Ghi thêm:', '')
 s=s.replace('#text(9.5pt, fill: black)[]', '')
 s=s.replace('#text(9.5pt, fill: black)[Bài 1 (tiếp)]','')
 s=s.replace('ngay vào ô chấm','ra giấy riêng').replace('vào ô chấm','ra giấy riêng')
 s=s.replace(' — kê bảng, vẽ cây ngay ra giấy riêng',' — kê bảng, vẽ cây')
 s=s.replace('viết thẳng vào ô chấm','làm bài ra giấy riêng')
 if p.name.startswith('GK0_'):
  # Đề và lời giải là các đoạn liền mạch, giữ heading có bookmark.
  s=s.replace('inset: (x: 7pt, y: 6pt), radius: 3pt, stroke: 0.9pt + accent, fill: soft,','inset: 0pt,')
  s=s.replace('radius: 3pt, stroke: 1.2pt + accent,','')
  s=s.replace('breakable: true, above: 10pt, below: 4pt','breakable: id == "VD 12", above: 10pt, below: 4pt')

 # Tăng vùng chữ trong giới hạn lề 2 cm ở các tập nhiều đồ thị.
 if p.name.startswith(('CK1_','CK4_','CK5_')):
  s=s.replace('#show: book','#show: book\n#set page(margin: (x: 2cm, top: 2cm, bottom: 2cm))')
 if p.name.startswith('CK5_'):
  s=s.replace('11cm)', '10cm)').replace('6.5cm)', '5cm)')
  # Bảng tự chấm gọn ở phần hướng dẫn, tránh một trang chỉ có bảng trống.
  mark=s.index('= Bảng tự chấm')
  score=s[mark:]
  s=s[:mark]
  intro=s.index('#pagebreak(weak: true)')
  s=s[:intro]+score+'\n\n'+s[intro:]
 if p.name.startswith(('CK1_','CK4_')):
  s=s.replace('#set page(margin: (x: 2cm, top: 2cm, bottom: 2cm))','#set page(margin: (x: 2cm, top: 2cm, bottom: 2cm))\n#set par(leading: 0.35em, spacing: 0.5em)')
 # Bảng đáp án hai cột trở thành đoạn lời giải theo số bài.
 if '= Đáp án' in s:
  pos=s.index('= Đáp án')
  front,back=s[:pos],s[pos:]
  back=back.replace('#table(\n  columns: (auto, 1fr),','#answer-table(\n  columns: (auto, 1fr),')
  s=front+back
 # Mỗi ví dụ mẫu ngắn được giữ liền với lời giải.
 (OUT/p.name).write_text(s)
 return s

if __name__=='__main__':
 (OUT/'img').mkdir(exist_ok=True)
 for p in (SRC/'img').glob('*.png'):
  Image.open(p).convert('L').save(OUT/'img'/p.name)
 (OUT/'content').mkdir(exist_ok=True)
 for p in SHARED.glob('gk-exam-*.typ'):
  shared=monochrome(p.read_text())
  if p.name=='gk-exam-examples.typ':
   shared=shared.replace('$ (p_0,p_1,p_2,p_3)=(8/15,4/15,2/15,1/15). $', '$ (p_0,p_1,p_2,p_3)=(8/15,4/15,2/15,1/15). $\n      $ p_0 approx bold(0","533), quad p_1 approx bold(0","267), quad p_2 approx bold(0","133), quad p_3 approx bold(0","067). $')
   shared=shared.replace('$ C=(1","6^4)/(4! times 0","6)p_0 approx 0","0907. $','$ C=(1","6^4)/(4! times 0","6)p_0 approx 0","0907. $\n        (Trên bảng lớp ghi 0,10602 — nên hỏi lại; bấm theo (3.79) ra 0,0907.)')
   shared=shared.replace('Kết quả: *T ≈ 0,083 µs; N ≈ 1,66 tác vụ*.','Kết quả: *T ≈ 0,083 µs; N ≈ 1,66 tác vụ* (bảng lớp ghi 1,67).')
   shared=shared.replace('$ P_B=p_14=(a^4)/(4!)rho^10 p_0 approx 5","71 times 10^(-6). $','$ P_B=p_14=(a^4)/(4!)rho^10 p_0 approx 5","71 times 10^(-6). $\n        (Bảng lớp ghi ≈ 8,8·10⁻⁷ — nên hỏi lại; cả hai đều rất nhỏ.)')
  (OUT/'content'/p.name).write_text(shared)
 for p in SRC.glob('*.typ'):
  make(p)
 manifest={str(p.relative_to(SRC)):hashlib.sha256(p.read_bytes()).hexdigest() for p in SRC.rglob('*') if p.is_file()}
 (OUT/'qa/source-sha256.json').write_text(json.dumps(manifest,indent=2))
