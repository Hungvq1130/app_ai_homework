// k_math_html.dart
const String kMathHtml = r'''<!doctype html>
<html lang="vi">
<head>
  <meta charset="utf-8" />
  <meta name="viewport" content="width=device-width,initial-scale=1" />
  <title>Lời giải Toán - Markdown + MathJax</title>

  <!-- MathJax -->
  <script>
    window.MathJax = {
      tex: {
        inlineMath: [['$', '$'], ['\\(', '\\)']],
        displayMath: [['$$', '$$'], ['\\[', '\\]']],
        processEscapes: true,
        tags: 'ams'
      },
      options: { renderActions: { addMenu: [] } }
    };
  </script>
  <script src="https://cdn.jsdelivr.net/npm/mathjax@3/es5/tex-mml-chtml.js"></script>

  <!-- Markdown -->
  <script src="https://cdn.jsdelivr.net/npm/marked/marked.min.js"></script>

  <style>
    :root {
      --bg:#fafafa; --card:#fff; --text:#1a1a1a; --muted:#2b2b2b;
      --border:#e6e6e6; --shadow:0 2px 6px rgba(0,0,0,.08);
      --c-problem:#0ea5e9;      /* Đề bài */
      --c-method:#8b5cf6;       /* Phương pháp */
      --c-solution:#22c55e;     /* Bài giải */
      --c-step:#f59e0b;         /* Bước */
    }
    * { box-sizing: border-box; }
    html, body {
  max-width:100%;
  overflow-x:hidden;
  overflow-y:auto;
  -webkit-overflow-scrolling:touch;
}
.content { overflow:visible; }

    body {
      font-family: system-ui, -apple-system, "Segoe UI", Roboto, Arial;
      line-height: 1.65; margin: 0; background: var(--bg); color: var(--text);
    }
    .wrap { max-width: 860px; margin: 0 auto; padding: 0; }      /* bỏ padding để không lặp khoảng trắng */
.content{
  background: transparent;   /* HỦY card giữa */
  border-radius: 0;
  box-shadow: none;
  padding: 0;                 /* để .sec tự canh lề bằng margin của nó */
  border: 0;
}

    h1,h2,h3 { margin: 1rem 0 .5rem; color: var(--muted); }
    p { margin: .5rem 0; }
    hr { border: none; border-top: 1px solid var(--border); margin: 1rem 0; }
    pre { background: #f4f4f4; padding: 12px; border-radius: 8px; overflow: auto; }
    code { background: #f4f4f4; border-radius: 6px; padding: .1rem .3rem; }
    img, svg, canvas { max-width: 100%; height: auto; display: block; margin: auto; }

    /* ---------- Bảng ---------- */
    .table-wrap{ overflow-x:auto; width:100%; -webkit-overflow-scrolling:touch; }
    table{
      border-collapse: collapse; width:100%; margin:10px 0; table-layout:fixed; display:table; max-width:100%;
      word-break: break-word;
    }
    th, td{
      border:1px solid var(--border); padding:6px; text-align:left;
      white-space:normal!important; overflow-wrap:anywhere; hyphens:auto; vertical-align:top;
    }

    /* ---------- MathJax + kéo ngang cho công thức dài ---------- */
    mjx-container{ max-width:none; overflow:visible; display:inline-block; word-break:normal; }
    mjx-container[display="true"]{ margin:.6rem 0; display:inline-block; }
    .math-scroll{ width:100%; overflow-x:auto; overflow-y:hidden; -webkit-overflow-scrolling:touch; padding-bottom:2px; }
    .math-scroll > mjx-container{ display:inline-block; }

    /* ---------- Card khu vực ---------- */
    .sec{
      --c:#999;
      border:1px solid var(--border);
      border-left:6px solid var(--c);
      background:linear-gradient(0deg, rgba(0,0,0,.015), rgba(0,0,0,.015)), var(--card);
      border-radius:12px; padding:12px 14px; margin:16px 0;
      box-shadow: var(--shadow);
    }
    .sec.problem{ --c: var(--c-problem); }
    .sec.method{ --c: var(--c-method); }
    .sec.solution{ --c: var(--c-solution); }
    .sec.step{ --c: var(--c-step); }

    .sec-title{
      display:flex; align-items:center; gap:10px; margin-bottom:8px;
      color: var(--muted); font-weight:700;
    }
    .sec-title h2, .sec-title h3{ margin:0; color:inherit; }
    .sec-body > :first-child{ margin-top:0; }
    .sec-body > :last-child{ margin-bottom:0; }

    /* Huy hiệu số bước */
    .badge-step{
      width:28px; height:28px; border-radius:999px; border:2px solid var(--c);
      display:inline-flex; align-items:center; justify-content:center; font-weight:800; font-size:.9rem;
      flex:0 0 28px;
    }
    .badge-step::after{ content: attr(data-step); }

    /* Mobile base nhỏ hơn chút */
    @media (max-width: 480px) {
      .wrap { padding: 10px; }
      .content { padding: 12px; }
      table { font-size: .60rem; }
      mjx-container { font-size: .95em; line-height: 1.15; }
      mjx-container[display="true"] { font-size: .95em; }
    }
    ul,ol,li { overflow: visible; }
  </style>
</head>
<body>
  <div class="wrap"><div id="output" class="content"></div></div>

  <script>
  // ---------- Helpers ----------
  function preprocessMarkdown(md) {
    if (!md) return '';
    return md.replace(/\r\n/g, '\n')
             .replace(/\\r\\n/g, '\n')
             .replace(/\\n/g, '\n')
             .replace(/\\u003E/g, '>')
             .replace(/&gt;/g, '>')
             .replace(/&lt;/g, '<')
             .replace(/&amp;/g, '&');
  }

  // Tách math khỏi markdown để tránh Markdown ăn ký tự
  function tokenizeMath(md) {
    const tokens = [];
    md = md.replace(/\$\$([\s\S]+?)\$\$/g, (m, inner) => {
      const tok = `@@MATH_${tokens.length}@@`;
      const fixed = inner.replace(/\\\\(?=[A-Za-z\[\]\(\)\{\}])/g, '\\');
      tokens.push({ tok, text: `\n$$\n${fixed}\n$$\n` });
      return tok;
    });
    md = md.replace(/\$([^\n\$]+?)\$/g, (m, inner) => {
      const tok = `@@MATH_${tokens.length}@@`;
      const fixed = inner.replace(/\\\\(?=[A-Za-z\[\]\(\)\{\}])/g, '\\');
      tokens.push({ tok, text: `\\(${fixed}\\)` });
      return tok;
    });
    return { md, tokens };
  }
  function detokenizeMath(html, tokens) {
    tokens.forEach(({ tok, text }) => { html = html.split(tok).join(text); });
    return html;
  }

  // ---------- Bọc bảng ----------
  function wrapTables(root) {
    root.querySelectorAll('table').forEach(t => {
      if (t.parentElement && t.parentElement.classList.contains('table-wrap')) return;
      const w = document.createElement('div');
      w.className = 'table-wrap';
      t.parentNode.insertBefore(w, t);
      w.appendChild(t);
    });
  }

  // ---------- Chia khu vực & tự tạo Bước ----------
  function structureSections(root){
    const text = el => (el.textContent || '').trim().toLowerCase();

    const typeFrom = t => {
      if (/^(đề bài|de bai)$/.test(t)) return 'problem';
      if (/^(phương pháp|phuong phap|phương pháp giải|phuong phap giai)$/.test(t)) return 'method';
      if (/^(bài giải|bai giai)$/.test(t)) return 'solution';
      if (/^(kết luận|ket luan)$/.test(t)) return 'solution';
      return '';
    };
    const isTop = (el) => {
      const t = text(el);
      const tp = typeFrom(t);
      return (el.tagName === 'H2' || el.tagName === 'H3') && tp;
    };
    const isStep = (el) => {
      const t = text(el);
      return (el.tagName === 'H2' || el.tagName === 'H3' || el.tagName === 'H4')
             && /^b(ư|u)ớc(\s*\d+)?/.test(t);
    };

    const children = Array.from(root.children);
    let i = 0, autoStep = 0;

    while (i < children.length){
      const el = children[i];
      if (!el || !el.tagName){ i++; continue; }

      // Khu vực lớn: Đề bài / Phương pháp / Bài giải
      if (isTop(el)){
        const cls = typeFrom(text(el));
        const sec = document.createElement('section');
        sec.className = 'sec ' + cls;
        const title = document.createElement('div');
        title.className = 'sec-title';
        title.appendChild(el.cloneNode(true));
        const body = document.createElement('div');
        body.className = 'sec-body';

        root.insertBefore(sec, el);
        root.removeChild(el);
        sec.appendChild(title);
        sec.appendChild(body);

        // chuyển các node kế tiếp vào body cho đến khi gặp heading top/step tiếp theo
        let j = i+1;
        while (j < children.length){
          const nx = children[j];
          if (!nx || !nx.tagName) { body.appendChild(nx); j++; continue; }
          if (isTop(nx) || isStep(nx)) break;
          body.appendChild(nx); j++;
        }
        i = j;  // tiếp tục duyệt từ phần còn lại
        continue;
      }

      // Bước n
      if (isStep(el)){
        autoStep++;
        const m = text(el).match(/b(ư|u)ớc\s*(\d+)/i);
        const stepNo = m ? parseInt(m[2],10) : autoStep;

        const sec = document.createElement('section');
        sec.className = 'sec step';
        const title = document.createElement('div');
        title.className = 'sec-title';

        const badge = document.createElement('span');
        badge.className = 'badge-step';
        badge.setAttribute('data-step', stepNo);

        title.appendChild(badge);
        title.appendChild(el.cloneNode(true));

        const body = document.createElement('div');
        body.className = 'sec-body';

        root.insertBefore(sec, el);
        root.removeChild(el);
        sec.appendChild(title);
        sec.appendChild(body);

        // gom nội dung của bước tới trước heading kế tiếp (top/step)
        let j = i+1;
        while (j < children.length){
          const nx = children[j];
          if (!nx || !nx.tagName) { body.appendChild(nx); j++; continue; }
          if (isTop(nx) || isStep(nx)) break;
          body.appendChild(nx); j++;
        }
        i = j;
        continue;
      }

      i++;
    }
  }

  // ---------- Kéo ngang cho công thức display ----------
  function wrapDisplayMathForScroll(root){
    root.querySelectorAll('mjx-container[display="true"]').forEach(mjx=>{
      const p = mjx.parentElement;
      if(!p) return;
      if(p.classList && p.classList.contains('math-scroll')) return;
      const w = document.createElement('div');
      w.className = 'math-scroll';
      p.insertBefore(w, mjx);
      w.appendChild(mjx);
    });
  }

  // ---------- Fit logic (giữ inline/bảng, KHÔNG thu nhỏ khối) ----------
  function fitMathAndTables(root) {
    root.querySelectorAll('mjx-container').forEach(el => {
      el.style.fontSize = ''; el.style.transform = ''; el.style.transformOrigin = ''; el.removeAttribute('data-fitted');
    });
    root.querySelectorAll('.table-wrap').forEach(w => { w.style.fontSize = ''; });

    const MIN_INLINE = 0.84, MIN_TABLE = 0.75;
    const SHRINK = 0.985, EPS = 4;

    // Inline math: nếu tràn ngang thì thu nhẹ
    root.querySelectorAll('mjx-container:not([display="true"])').forEach(el => {
      const parent = el.parentElement; if (!parent) return;
      const parentW = (parent.clientWidth || 0);
      const safeW = Math.max(0, parentW - EPS);
      const w = el.scrollWidth || 0;
      if (safeW && w > safeW) {
        const scale = Math.max(MIN_INLINE, (safeW / w) * SHRINK);
        el.style.fontSize = scale + 'em';
        el.setAttribute('data-fitted', '1');
      }
    });

    // Bảng: nếu vẫn tràn ngang, giảm nhẹ toàn bảng
    root.querySelectorAll('.table-wrap').forEach(wrap => {
      const parent = wrap.parentElement; if (!parent) return;
      const parentW = (parent.clientWidth || 0);
      const safeW = Math.max(0, parentW - EPS);
      const w = wrap.scrollWidth || 0;
      if (safeW && w > safeW) {
        const scale = Math.max(MIN_TABLE, (safeW / w) * SHRINK);
        wrap.style.fontSize = scale + 'em';
      }
    });
  }

  // ---------- Debounce ----------
  function debounce(fn, wait) { let t; return function(){ clearTimeout(t); t = setTimeout(() => fn(), wait); } }

  function renderMarkdown(md){
    const out = document.getElementById('output');
    const pre = preprocessMarkdown(md || '');

    const t = tokenizeMath(pre);
    let html = marked.parse(t.md);
    html = detokenizeMath(html, t.tokens);

    out.innerHTML = html;

    // Chia khu vực + bảng
    structureSections(out);
    wrapTables(out);

    if (window.MathJax && MathJax.typesetPromise){
      MathJax.typesetPromise().then(() => {
        wrapDisplayMathForScroll(out);
        requestAnimationFrame(() => { fitMathAndTables(out); });
      });
    } else {
      wrapDisplayMathForScroll(out);
      requestAnimationFrame(() => { fitMathAndTables(out); });
    }
  }

  window.renderMarkdown = renderMarkdown;

  // Refit khi đổi kích thước / xoay màn
  const refit = debounce(() => {
    const out = document.getElementById('output');
    if (out) fitMathAndTables(out);
  }, 120);
  window.addEventListener('resize', refit);

  // Fit khi nội dung thay đổi kích thước
  const ro = new ResizeObserver(refit);
  ro.observe(document.documentElement);

  // nếu bạn vẫn để __CONTENT__
  const content = `__CONTENT__`;
  if (content && content !== '__CONTENT__') renderMarkdown(content);
  </script>
</body>
</html>''';
