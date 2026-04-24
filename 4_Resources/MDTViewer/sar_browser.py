"""
sar_browser.py  —  Reusable SAR archive file-browser widget (Treeview version).
"""

import tkinter as tk
from tkinter import ttk
from typing import Optional, Callable

_C = {
    'bg0':    '#1e1e2e',
    'bg1':    '#181825',
    'bg2':    '#313244',
    'panel':  '#181825',
    'surf':   '#313244',
    'fg':     '#cdd6f4',
    'dim':    '#6c7086',
    'blue':   '#89b4fa',
    'green':  '#a6e3a1',
    'yell':   '#f9e2af',
    'sel_bg': '#1a3a4a',
    'idx':    '#585870',
    'hdr':    '#6c7086',
}

_EXT_COLORS = {
    '.SAR': '#f38ba8',
    '.MDT': '#89dceb',
    '.GRP': '#a6e3a1',
    '.MSD': '#f9e2af',
    '.BIN': '#cba6f7',
}

def _ext_color(name):
    ext = ('.' + name.rsplit('.', 1)[-1].upper()) if '.' in name else ''
    return _EXT_COLORS.get(ext, _C['dim'])


class SarBrowser(tk.Frame):
    FILTERS = [('All',''),('MDT','MDT'),('GRP','GRP'),('MSD','MSD'),('BIN','BIN')]

    def __init__(self, parent, on_select: Optional[Callable] = None,
                 colors: Optional[dict] = None, **kwargs):
        super().__init__(parent, bg=_C['bg0'], **kwargs)
        self._sar          = None
        self._all_entries  = []
        self._entries      = []
        self._entry_hints  = {}
        self._sort_col     = '#'
        self._sort_asc     = True
        self.on_select     = on_select
        self._colors       = colors or _C
        self._check_vars   = {}
        self._build()

    def _build(self):
        C = self._colors

        self.name_lbl = tk.Label(
            self, text='  Open SAR to browse files',
            bg=C.get('bg0', _C['bg0']), fg=C.get('dim', _C['dim']),
            font=('Consolas', 8), anchor='w', padx=4, pady=2)
        self.name_lbl.pack(fill='x')

        flt = tk.Frame(self, bg=C.get('bg0', _C['bg0']))
        flt.pack(fill='x', padx=4, pady=2)
        self._all_var = tk.BooleanVar(value=True)
        tk.Checkbutton(flt, text='All', variable=self._all_var,
                       command=self._on_all_click,
                       bg=C.get('bg0',_C['bg0']), fg=C.get('fg',_C['fg']),
                       selectcolor=C.get('bg0',_C['bg0']),
                       activebackground=C.get('bg0',_C['bg0']),
                       font=('Consolas', 8), bd=0).pack(side='left', padx=2)

        ext_colors = {'MDT':'#89dceb','GRP':'#a6e3a1','MSD':'#f9e2af','BIN':'#cba6f7'}
        for _, ext in self.FILTERS[1:]:
            v = tk.BooleanVar(value=False)
            tk.Checkbutton(flt, text=ext, variable=v,
                           command=self._on_filter_change,
                           bg=C.get('bg0',_C['bg0']),
                           fg=ext_colors.get(ext, C.get('fg',_C['fg'])),
                           selectcolor=C.get('bg0',_C['bg0']),
                           activebackground=C.get('bg0',_C['bg0']),
                           font=('Consolas', 8), bd=0).pack(side='left', padx=2)
            self._check_vars[ext] = v

        tv_frame = tk.Frame(self, bg=C.get('bg0', _C['bg0']))
        tv_frame.pack(fill='both', expand=True, padx=2, pady=2)

        style = ttk.Style()
        style.theme_use('clam')
        style.configure('SAR.Treeview',
                         background=_C['panel'], foreground=_C['fg'],
                         fieldbackground=_C['panel'], rowheight=17,
                         font=('Consolas', 8))
        style.configure('SAR.Treeview.Heading',
                         background=_C['surf'], foreground=_C['hdr'],
                         relief='flat', font=('Consolas', 8, 'bold'))
        style.map('SAR.Treeview',
                  background=[('selected', _C['sel_bg'])],
                  foreground=[('selected', '#ffffff')])

        cols = ('#', 'Name', 'Size', 'Source', 'Place')
        self._tv = ttk.Treeview(tv_frame, columns=cols, show='headings',
                                 style='SAR.Treeview', selectmode='browse')
        col_w = {'#':36,'Name':120,'Size':48,'Source':68,'Place':120}
        col_a = {'#':'e','Name':'w','Size':'e','Source':'w','Place':'w'}
        for c in cols:
            self._tv.column(c, width=col_w[c], anchor=col_a[c], stretch=(c=='Place'))
            self._tv.heading(c, text=c, command=lambda _c=c: self._sort_by(_c))

        for ext, color in _EXT_COLORS.items():
            self._tv.tag_configure(ext.lstrip('.'), foreground=color)
        self._tv.tag_configure('dim', foreground=_C['dim'])

        vsb = ttk.Scrollbar(tv_frame, orient='vertical',   command=self._tv.yview)
        hsb = ttk.Scrollbar(tv_frame, orient='horizontal', command=self._tv.xview)
        self._tv.configure(yscrollcommand=vsb.set, xscrollcommand=hsb.set)
        vsb.pack(side='right', fill='y')
        hsb.pack(side='bottom', fill='x')
        self._tv.pack(fill='both', expand=True)

        self._tv.bind('<Double-Button-1>', self._on_dclick)
        self._tv.bind('<Return>',          self._on_dclick)
        self._tv.bind('<Control-a>',       self._select_all)
        self._tv.bind('<Control-A>',       self._select_all)
        self._tv.bind('<Control-c>',       self._copy_sel)
        self._tv.bind('<Control-C>',       self._copy_sel)

        self.status_lbl = tk.Label(
            self, text='', bg=C.get('bg0', _C['bg0']),
            fg=C.get('dim', _C['dim']),
            font=('Consolas', 7), anchor='w', padx=6, pady=2, wraplength=200)
        self.status_lbl.pack(fill='x', side='bottom')

    # ── Public ────────────────────────────────────────────────────────────
    def load(self, sar):
        self._sar = sar
        self._all_entries = list(sar.entries) if sar else []
        name = getattr(sar, 'name', '') if sar else ''
        self.name_lbl.config(text=f'  {name}' if name else '  Open SAR to browse files')
        self._refresh()

    def set_entry_hint(self, name: str, hint: str):
        self._entry_hints[name.upper()] = hint.replace(chr(92), chr(39))

    def get_selected(self) -> Optional[str]:
        sel = self._tv.selection()
        if not sel:
            return None
        return self._tv.set(sel[0], 'Name').strip() or None

    def set_status(self, msg: str, color: str = ''):
        self.status_lbl.config(text=msg, fg=color or _C['dim'])

    def _get_source(self, entry_name: str) -> str:
        if self._sar is None:
            return ''
        idx = getattr(self._sar, '_index', {})
        sar = idx.get(entry_name.upper())
        if sar is None:
            return ''
        base = getattr(sar, 'name', '')
        return base.rsplit('.', 1)[0] if '.' in base else base

    # ── Filter ────────────────────────────────────────────────────────────
    def _on_all_click(self):
        self._all_var.set(True)
        for v in self._check_vars.values():
            v.set(False)
        self._refresh()

    def _on_filter_change(self):
        any_on = any(v.get() for v in self._check_vars.values())
        self._all_var.set(not any_on)
        self._refresh()

    def _active_exts(self):
        return {ext for ext, v in self._check_vars.items() if v.get()}

    # ── Render ────────────────────────────────────────────────────────────
    def _refresh(self):
        exts = self._active_exts()
        entries = [e for e in self._all_entries
                   if not exts or
                   any(e.name.upper().endswith('.' + x) for x in exts)]
        self._entries = entries
        self._apply_sort(entries)

        self._tv.delete(*self._tv.get_children())
        for i, entry in enumerate(entries, 1):
            name = entry.name.strip()
            sz = entry.size
            if sz < 1024:       sz_str = f'{sz}B'
            elif sz < 1048576:  sz_str = f'{sz/1024:.1f}K'
            else:               sz_str = f'{sz/1048576:.1f}M'
            source = self._get_source(name)
            hint   = self._entry_hints.get(name.upper(), '')
            ext    = ('.' + name.rsplit('.', 1)[-1].upper()) if '.' in name else ''
            tag    = ext.lstrip('.') if ext in _EXT_COLORS else 'dim'
            self._tv.insert('', 'end', values=(i, name, sz_str, source, hint), tags=(tag,))

        self.status_lbl.config(text=f'{len(entries)} files', fg=_C['dim'])

    def _apply_sort(self, entries):
        col = self._sort_col
        rev = not self._sort_asc
        def key(e):
            n = e.name.strip()
            if col == '#':      return self._all_entries.index(e) if e in self._all_entries else 0
            elif col == 'Name': return n.upper()
            elif col == 'Size': return e.size
            elif col == 'Source': return self._get_source(n)
            elif col == 'Place': return self._entry_hints.get(n.upper(), '')
            return n
        entries.sort(key=key, reverse=rev)

    def _sort_by(self, col):
        if self._sort_col == col:
            self._sort_asc = not self._sort_asc
        else:
            self._sort_col = col
            self._sort_asc = True
        self._refresh()
        for c in ('#', 'Name', 'Size', 'Source', 'Place'):
            arrow = (' ▲' if self._sort_asc else ' ▼') if c == self._sort_col else ''
            self._tv.heading(c, text=c + arrow)

    # ── Events ────────────────────────────────────────────────────────────
    def _on_dclick(self, event=None):
        name = self.get_selected()
        if name and self.on_select:
            for e in self._entries:
                if e.name.strip() == name:
                    self.on_select(e.name, e)
                    return

    def _select_all(self, event=None):
        ch = self._tv.get_children()
        if ch:
            self._tv.selection_set(ch)
        return 'break'

    def _copy_sel(self, event=None):
        sel = self._tv.selection() or self._tv.get_children()
        lines = ['\t'.join(str(v) for v in self._tv.item(i, 'values')) for i in sel]
        self.clipboard_clear()
        self.clipboard_append('\n'.join(lines))
        return 'break'
