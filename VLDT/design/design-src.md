# QUY CHUẨN SOẠN THẢO TÀI LIỆU ÔN TẬP VẬT LÝ ĐIỆN TỬ (VLĐT)

Tài liệu này quy định toàn bộ tiêu chuẩn định dạng, cấu trúc bài giảng, quy tắc viết tắt và cú pháp LaTeX áp dụng cho các đề cương, bài tập và lời giải môn Vật lý Điện tử (PH3330) tại HUST.

---

## 1. Định dạng tài liệu học thuật (Academic Style)

Dựa trên mẫu chuẩn học thuật của Bộ môn Vật lý:

1. **Khổ giấy & Căn lề:**
   ```latex
   \usepackage[a4paper, margin=2.5cm]{geometry}
   ```
2. **Font chữ & Giãn cách:**
   * Font serif học thuật: TeX Gyre Pagella (Palatino) cỡ `11pt`.
   * Giãn dòng: `\linespread{1.05}`.
   * Thụt đầu dòng: `\setlength{\parindent}{0pt}`.
   * Giãn đoạn: `\setlength{\parskip}{5pt plus 2pt minus 1pt}`.
3. **Tiêu đề đầu trang 1:**
   * Tiêu đề lớn căn giữa:
     ```latex
     \begin{center}
         {\Large\bfseries GIỮA KỲ VLĐT}
     \end{center}
     \vspace{0.2cm}
     ```
4. **Header & Footer:**
   * Không dùng running header trên đầu trang.
   * Đánh số trang căn giữa ở chân trang: `\pagestyle{plain}`.
   * **KHÔNG** để các dòng kẻ kết thúc dạng `--- Hết (X câu) ---` ở cuối tài liệu.
5. **Tránh khung viền màu mè:**
   * Không dùng các hộp màu nổi bật (`tcolorbox`), giữ nền trắng chữ đen trang nhã, nghiêm túc.

---

## 2. Dòng chảy trang & Khoảng cách (Flow & Pagination)

* **Chạy liền mạch (Continuous Flow):** Để các câu chảy liên tục tự nhiên qua từng trang, giúp tiết kiệm giấy in và tránh để lại các khoảng trống trắng lớn ở chân trang.
* **Khoảng cách phân tách giữa các câu:** Dùng `\vspace{0.5cm}` giữa các câu.

---

## 3. Cấu trúc một câu bài tập

Mỗi câu hỏi được tổ chức tối giản, mạch lạc theo thứ tự sau:

1. **Tiêu đề câu (`\section*`):**
   ```latex
   \section*{Câu X. [Tên chủ đề câu hỏi]}
   ```
   *Ví dụ:* `\section*{Câu 1. Tán xạ Compton}`.

2. **Nội dung câu hỏi (Đề bài):**
   * **BỎ cụm `\textbf{Đề bài.}`**: Đi thẳng vào câu hỏi ngay dưới tiêu đề mục, không lặp lại nhãn thừa.
   * Giữ nguyên nội dung gốc chuẩn mực, không dùng từ viết tắt.

3. **Bố cục 4 đáp án trắc nghiệm:**
   * Xem chi tiết ở Mục 4 bên dưới.

4. **Phần Giải:**
   * Tiêu đề: `\textbf{Giải.}`.
   * Dữ kiện đề bài (nếu cần): `\textbf{Dữ kiện:}` hoặc `\textbf{Tóm tắt dữ kiện:}`.
   * Trình bày logic theo các bước ngắn gọn: `\textbf{B1:}`, `\textbf{B2:}`, `\textbf{B3:}`.
   * **KHÔNG** thêm phần "Kiến thức trọng tâm" dạng hộp khối riêng nếu không yêu cầu.
   * **KHÔNG** làm mục kết luận đáp án chữ đỏ cồng kềnh; đáp án đúng đã được in đậm ở phần trắc nghiệm.

---

## 4. Bố cục đáp án trắc nghiệm (Multiple Choice)

Để trang in đẹp và gọn gàng, cách sắp xếp 4 phương án $A, B, C, D$ tuân thủ:

### A. Quy tắc xếp dòng
* **Phương án ngắn (số liệu, công thức toán, đơn vị ngắn):** Bắt buộc xếp trên **1 dòng** (`\begin{multicols}{4}`).
* **Phương án dài (câu văn mô tả, điều kiện dài):** Xếp dạng **2x2** (`\begin{multicols}{2}`).

### B. Quy chuẩn in đậm đáp án đúng
* **Văn bản thông thường:** Sử dụng `\textbf{...}`.
* **Toán học / Công thức / Ký hiệu / Mũ / Đơn vị trong Math mode:** Bắt buộc sử dụng `\boldsymbol{...}` (từ gói `amsmath`):
  ```latex
  % Đúng chuẩn (cả số, ký hiệu và đơn vị đều đậm nét):
  \item $\boldsymbol{2{,}68 \times 10^{-12}\text{ \textbf{m}}}$
  \item $\boldsymbol{2\hbar\hat{L}_z}$
  \item $\boldsymbol{\sqrt{\dfrac{15}{16L^5}}}$

  % Tránh (chỉ in đậm được text, số và toán vẫn mảnh):
  \item \textbf{$2,68 \times 10^{-12}$ m}
  ```

---

## 5. Quy tắc viết tắt (Abbreviations)

Áp dụng nhất quán các từ viết tắt sau nhằm tối ưu diện tích trang và tăng tính súc tích của lời giải:

| Từ gốc | Viết tắt quy ước | Ví dụ sử dụng |
| :--- | :---: | :--- |
| **Công thức** | `CT` | `AD CT Compton`, `CT tính chu kỳ` |
| **Điều kiện** | `ĐK` | `ĐK chuẩn hóa`, `ĐK hội tụ` |
| **Phương trình** | `PT` | `PT Schrödinger`, `nghiệm của PT` |
| **Áp dụng** | `AD` | `AD hệ thức Heisenberg`, `AD CT hệ hai thấu kính` |
| **Lời giải / Lời giải chi tiết** | `Giải` | `\textbf{Giải.}` |
| **Bước 1, Bước 2, ...** | `B1, B2, ...` | `\textbf{B1:}`, `\textbf{B2:}` |
| **Bậc nhất / Bậc hai** | `Bậc 1 / Bậc 2` | `đạo hàm bậc 1`, `phương trình bậc 2` |

> [!IMPORTANT]
> **Quy tắc bất biến:** Quy tắc viết tắt **tuyệt đối KHÔNG áp dụng cho phần Đề bài**. Phần câu hỏi / đề bài phải luôn giữ nguyên văn bản đầy đủ, chuẩn ngữ pháp, thuật ngữ rõ ràng để người đọc nắm trọn vẹn yêu cầu đề thi.

---

## 6. Mẫu khung LaTeX chuẩn cho một câu hỏi (Template)

```latex
%=====================================================================
% CÂU X
%=====================================================================
\section*{Câu X. [Tên chủ đề]}

[Nội dung câu hỏi đề bài đầy đủ, chuẩn ngữ pháp, không viết tắt]

\begin{multicols}{4} % dùng {2} nếu đáp án là câu chữ dài
\begin{enumerate}[label=\Alph*., itemsep=1pt, topsep=1pt, parsep=0pt, leftmargin=1.8em]
    \item Phương án A
    \item $\boldsymbol{Phương\ án\ B\ đúng}$
    \item Phương án C
    \item Phương án D
\end{enumerate}
\end{multicols}

\textbf{Giải.}

\textbf{Dữ kiện:} ...

\textbf{B1:} AD CT ...
\begin{equation*}
    ...
\end{equation*}

\textbf{B2:} ...

\vspace{0.5cm}
```