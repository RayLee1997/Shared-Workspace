# Vim 使用指南 (CentOS 9 Terminal)

## 安装与准备

```bash
# CentOS 9 安装完整版 vim
sudo dnf install vim-enhanced

# 验证安装（检查 +clipboard 支持）
vim --version | grep clipboard

# 学习入门（强烈推荐，约 20 分钟）
vimtutor
```

---

## 模式概念

Vim 有四种主要模式，理解模式切换是掌握 Vim 的关键：

| 模式           | 进入方式             | 用途       |
| ------------ | ---------------- | -------- |
| Normal（正常）   | `Esc`            | 导航、执行命令  |
| Insert（插入）   | `i` `a` `o` 等    | 输入文本     |
| Visual（可视）   | `v` `V` `Ctrl-v` | 选择文本     |
| Command（命令行） | `:`              | 执行 Ex 命令 |
|              |                  |          |

> 记住：任何时候按 `Esc` 都会回到 Normal 模式

---

## 启动与退出

| 命令 | 说明 |
|------|------|
| `vim filename` | 打开文件 |
| `:w` | 保存 |
| `:q` | 退出 |
| `:wq` 或 `:x` | 保存并退出 |
| `:q!` | 强制退出（不保存） |
| `:w !sudo tee % >/dev/null` | 以 root 权限保存（忘记 sudo 打开时） |

---

## 进入插入模式

| 按键 | 说明 |
|------|------|
| `i` | 当前光标前插入 |
| `I` | 行首插入 |
| `a` | 当前光标后插入 |
| `A` | 行尾插入 |
| `o` | 下方新建一行并插入 |
| `O` | 上方新建一行并插入 |
| `s` | 删除当前字符并插入 |
| `S` | 删除当前行并插入 |

---

## 移动与跳转

### 基本移动

| 按键 | 说明 |
|------|------|
| `h` `j` `k` `l` | 左 下 上 右 |
| `w` | 下一个单词开头 |
| `e` | 当前/下一个单词结尾 |
| `b` | 上一个单词开头 |
| `0` | 行首 |
| `^` | 行首非空字符 |
| `$` | 行尾 |
| `gg` | 文件开头 |
| `G` | 文件末尾 |
| `:123` 或 `123G` | 跳转到第 123 行 |

### 跳转历史

| 按键 | 说明 |
|------|------|
| `Ctrl-o` | 跳回上一个位置 |
| `Ctrl-i` | 跳到下一个位置 |
| `m{a-z}` | 设置标记（如 `ma`） |
| `'{a-z}` | 跳转到标记（如 `'a`） |
| `''` | 跳回上次跳转前位置 |

### 屏幕滚动

| 按键 | 说明 |
|------|------|
| `Ctrl-f` | 向下翻页 |
| `Ctrl-b` | 向上翻页 |
| `Ctrl-d` | 向下半页 |
| `Ctrl-u` | 向上半页 |
| `zz` | 当前行居中 |
| `zt` | 当前行置顶 |
| `zb` | 当前行置底 |

---

## 搜索

| 命令 | 说明 |
|------|------|
| `/pattern` | 向下搜索 |
| `?pattern` | 向上搜索 |
| `n` | 下一个匹配 |
| `N` | 上一个匹配 |
| `*` | 搜索光标下的单词（向下） |
| `#` | 搜索光标下的单词（向上） |
| `:noh` | 清除搜索高亮 |

> 在 `.vimrc` 中加入 `set ignorecase smartcase` 可实现智能大小写搜索

---

## 编辑操作

### 删除

| 按键 | 说明 |
|------|------|
| `x` | 删除当前字符 |
| `X` | 删除前一个字符 |
| `dd` | 删除当前行 |
| `dw` | 删除到下一个单词 |
| `d$` 或 `D` | 删除到行尾 |
| `d0` | 删除到行首 |
| `dgg` | 删除到文件开头 |
| `dG` | 删除到文件末尾 |

### 修改

| 按键 | 说明 |
|------|------|
| `r{char}` | 替换当前字符 |
| `R` | 进入替换模式 |
| `cw` | 修改到单词结尾 |
| `cc` 或 `S` | 修改整行 |
| `c$` 或 `C` | 修改到行尾 |
| `ciw` | 修改整个单词 |
| `ci"` | 修改引号内内容 |

### 复制与粘贴

| 按键 | 说明 |
|------|------|
| `yy` | 复制当前行 |
| `yw` | 复制到单词结尾 |
| `y$` | 复制到行尾 |
| `p` | 粘贴到光标后 |
| `P` | 粘贴到光标前 |
| `"ayy` | 复制当前行到寄存器 a |
| `"ap` | 从寄存器 a 粘贴 |
| `"+y` | 复制到系统剪贴板 |
| `"+p` | 从系统剪贴板粘贴 |

### 撤销与重做

| 按键 | 说明 |
|------|------|
| `u` | 撤销 |
| `Ctrl-r` | 重做 |
| `U` | 撤销当前行所有修改 |

---

## 文本对象

文本对象与操作符（`d` `c` `y` `v`）组合使用，格式：`{操作符}{a/i}{对象}`

- `a` = around（包含边界）
- `i` = inner（不含边界）

| 对象 | 说明 | 示例 |
|------|------|------|
| `w` | 单词 | `daw` 删除整个单词含空格 |
| `W` | 大单词（空格分隔） | `ciW` 修改大单词 |
| `s` | 句子 | `das` 删除句子 |
| `p` | 段落 | `yap` 复制段落 |
| `"` `'` `` ` `` | 引号 | `ci"` 修改双引号内容 |
| `(` `)` | 圆括号 | `di)` 删除括号内内容 |
| `[` `]` | 方括号 | `ci]` 修改方括号内容 |
| `{` `}` | 花括号 | `da{` 删除花括号及内容 |
| `<` `>` | 尖括号 | `cit` 修改 tag 内容 |
| `t` | HTML/XML tag | `dat` 删除整个 tag |

---

## 可视模式

| 按键 | 说明 |
|------|------|
| `v` | 字符选择 |
| `V` | 行选择 |
| `Ctrl-v` | 块选择（列编辑） |
| `gv` | 重新选择上次选区 |

选中后可执行：
- `d` 删除
- `y` 复制
- `c` 修改
- `>` / `<` 缩进
- `u` / `U` 转小写/大写
- `~` 切换大小写
- `:` 对选区执行命令

### 块选择技巧（列编辑）

1. `Ctrl-v` 进入块选择
2. 移动选择列
3. `I` 在块前插入，`A` 在块后插入
4. 输入内容，按 `Esc` 应用到所有行

---

## 搜索与替换

```vim
# 基本替换
:s/old/new/           " 替换当前行第一个
:s/old/new/g          " 替换当前行所有

# 全文替换
:%s/old/new/g         " 替换全文所有
:%s/old/new/gc        " 替换全文，每次确认

# 范围替换
:10,20s/old/new/g     " 第 10-20 行
:'<,'>s/old/new/g     " 可视选区内

# 常用标志
# g - 全局（一行内多次）
# c - 确认
# i - 忽略大小写
# I - 区分大小写
```

---

## 窗口管理

### 分屏

| 命令 | 说明 |
|------|------|
| `:split` 或 `:sp` | 水平分屏 |
| `:vsplit` 或 `:vs` | 垂直分屏 |
| `:split file` | 水平分屏打开文件 |
| `Ctrl-w s` | 水平分屏当前文件 |
| `Ctrl-w v` | 垂直分屏当前文件 |

### 窗口切换

| 按键 | 说明 |
|------|------|
| `Ctrl-w h/j/k/l` | 切换到左/下/上/右窗口 |
| `Ctrl-w w` | 循环切换窗口 |
| `Ctrl-w q` | 关闭当前窗口 |
| `Ctrl-w o` | 只保留当前窗口 |

### 窗口大小

| 按键 | 说明 |
|------|------|
| `Ctrl-w =` | 所有窗口等大 |
| `Ctrl-w +/-` | 增加/减少高度 |
| `Ctrl-w >/<` | 增加/减少宽度 |
| `:resize 20` | 设置高度为 20 行 |

---

## 标签页

| 命令 | 说明 |
|------|------|
| `:tabnew` | 新建标签页 |
| `:tabnew file` | 在新标签页打开文件 |
| `:tabn` 或 `gt` | 下一个标签页 |
| `:tabp` 或 `gT` | 上一个标签页 |
| `:tabclose` | 关闭当前标签页 |
| `:tabonly` | 只保留当前标签页 |
| `{n}gt` | 跳转到第 n 个标签页 |

---

## 缓冲区

| 命令 | 说明 |
|------|------|
| `:ls` 或 `:buffers` | 列出所有缓冲区 |
| `:b {n}` | 切换到缓冲区 n |
| `:bn` | 下一个缓冲区 |
| `:bp` | 上一个缓冲区 |
| `:bd` | 关闭当前缓冲区 |
| `:b name` | 按名称切换（支持 Tab 补全） |

---

## 宏录制

| 按键 | 说明 |
|------|------|
| `q{a-z}` | 开始录制宏到寄存器（如 `qa`） |
| `q` | 停止录制 |
| `@{a-z}` | 执行宏（如 `@a`） |
| `@@` | 重复上次执行的宏 |
| `10@a` | 执行宏 10 次 |

示例：批量给行添加注释
1. `qa` 开始录制
2. `I// <Esc>j` 在行首添加注释并下移
3. `q` 停止录制
4. `10@a` 对接下来 10 行执行

---

## 折叠

| 按键 | 说明 |
|------|------|
| `za` | 切换当前折叠 |
| `zo` | 打开折叠 |
| `zc` | 关闭折叠 |
| `zR` | 打开所有折叠 |
| `zM` | 关闭所有折叠 |
| `zj` / `zk` | 移动到下/上一个折叠 |

```vim
" 折叠方式设置
:set foldmethod=indent   " 按缩进折叠
:set foldmethod=syntax   " 按语法折叠
:set foldmethod=marker   " 按标记折叠
```

---

## 代码相关

### ctags 跳转

```bash
# 生成 tags 文件
ctags -R .
```

| 按键 | 说明 |
|------|------|
| `Ctrl-]` | 跳转到定义 |
| `Ctrl-t` | 返回跳转前位置 |
| `:tag name` | 跳转到指定 tag |
| `:ts` | 列出匹配的 tag |

### Quickfix

| 命令 | 说明 |
|------|------|
| `:make` | 执行编译 |
| `:copen` | 打开 quickfix 窗口 |
| `:cclose` | 关闭 quickfix 窗口 |
| `:cn` | 下一个错误 |
| `:cp` | 上一个错误 |
| `:grep pattern **/*.py` | 搜索并填充 quickfix |

### 缩进

| 按键 | 说明 |
|------|------|
| `>>` | 当前行右缩进 |
| `<<` | 当前行左缩进 |
| `==` | 自动缩进当前行 |
| `gg=G` | 自动缩进全文 |
| `=ap` | 自动缩进段落 |

---

## 推荐 .vimrc 配置

```vim
" ===== 基础设置 =====
set nocompatible              " 禁用 vi 兼容模式
filetype plugin indent on     " 文件类型检测
syntax on                     " 语法高亮

" ===== 界面 =====
set number                    " 显示行号
set relativenumber            " 相对行号
set cursorline                " 高亮当前行
set showcmd                   " 显示命令
set showmode                  " 显示模式
set ruler                     " 显示光标位置
set laststatus=2              " 总是显示状态栏
set wildmenu                  " 命令行补全菜单
set scrolloff=5               " 光标距边缘 5 行

" ===== 编辑 =====
set tabstop=4                 " Tab 宽度
set shiftwidth=4              " 缩进宽度
set expandtab                 " Tab 转空格
set smartindent               " 智能缩进
set autoindent                " 自动缩进
set backspace=indent,eol,start  " 退格键行为

" ===== 搜索 =====
set hlsearch                  " 高亮搜索结果
set incsearch                 " 增量搜索
set ignorecase                " 忽略大小写
set smartcase                 " 智能大小写

" ===== 编码 =====
set encoding=utf-8
set fileencodings=utf-8,gbk,gb2312

" ===== 性能 =====
set lazyredraw                " 宏执行时不重绘
set ttyfast                   " 快速终端连接

" ===== 文件 =====
set autoread                  " 自动重载外部修改
set nobackup                  " 不创建备份文件
set noswapfile                " 不创建交换文件
set undofile                  " 持久化撤销历史
set undodir=~/.vim/undo       " 撤销文件目录

" ===== 鼠标 =====
set mouse=a                   " 启用鼠标

" ===== 剪贴板 =====
set clipboard=unnamedplus     " 使用系统剪贴板

" ===== 真彩色（终端支持时启用）=====
if has('termguicolors')
  set termguicolors
endif

" ===== 快捷键映射 =====
" 快速保存
nnoremap <C-s> :w<CR>
inoremap <C-s> <Esc>:w<CR>a

" 清除搜索高亮
nnoremap <Esc><Esc> :noh<CR>

" 窗口切换
nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l

" 缓冲区切换
nnoremap <Tab> :bn<CR>
nnoremap <S-Tab> :bp<CR>

" 创建 undo 目录
if !isdirectory($HOME . '/.vim/undo')
  call mkdir($HOME . '/.vim/undo', 'p', 0700)
endif
```

---

## CentOS 9 终端特有技巧

### 系统剪贴板支持

```bash
# X11 环境
sudo dnf install xclip

# Wayland 环境
sudo dnf install wl-clipboard
```

使用 `"+y` 复制到系统剪贴板，`"+p` 从系统剪贴板粘贴。

### 粘贴模式

从外部粘贴代码时避免缩进混乱：

```vim
:set paste      " 开启粘贴模式
" 粘贴内容
:set nopaste    " 关闭粘贴模式
```

或在 `.vimrc` 中设置快捷键：`set pastetoggle=<F2>`

### 终端颜色问题

```bash
# 检查终端类型
echo $TERM

# 确保 TERM 设置正确（通常为 xterm-256color）
export TERM=xterm-256color
```

### 推荐安装工具

```bash
# 代码搜索与 tag 生成
sudo dnf install ripgrep ctags the_silver_searcher
```

---

## 插件管理（vim-plug）

### 安装 vim-plug

```bash
curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
```

### 配置示例

在 `.vimrc` 中添加：

```vim
call plug#begin('~/.vim/plugged')

" 文件树
Plug 'preservim/nerdtree'

" 模糊搜索
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'

" 状态栏
Plug 'vim-airline/vim-airline'

" Git 集成
Plug 'tpope/vim-fugitive'

" 快速注释
Plug 'tpope/vim-commentary'

" 括号配对
Plug 'jiangmiao/auto-pairs'

" 主题
Plug 'morhetz/gruvbox'

call plug#end()

" 主题设置
colorscheme gruvbox
set background=dark
```

### 插件命令

| 命令 | 说明 |
|------|------|
| `:PlugInstall` | 安装插件 |
| `:PlugUpdate` | 更新插件 |
| `:PlugClean` | 删除未使用插件 |
| `:PlugStatus` | 查看插件状态 |

---

## 常见问题排查

| 问题 | 解决方案 |
|------|----------|
| 无语法高亮 | 确认 `syntax on`，检查 `$TERM` 变量 |
| 剪贴板不工作 | 安装 xclip/wl-clipboard，确认 vim 有 `+clipboard` |
| 粘贴缩进混乱 | 使用 `:set paste` 或 `Ctrl-Shift-v` 直接粘贴 |
| 中文乱码 | 设置 `encoding=utf-8` 和 `fileencodings` |
| 退格键无效 | 设置 `backspace=indent,eol,start` |
| 大文件卡顿 | 使用 `:set lazyredraw`，禁用语法高亮 `:syntax off` |

---

## 快速参考卡片

```
移动: h j k l w b e 0 $ gg G
编辑: i a o dd yy p u Ctrl-r
搜索: /pattern n N :noh
保存: :w :q :wq :q!
分屏: :sp :vs Ctrl-w hjkl
替换: :%s/old/new/g
```
