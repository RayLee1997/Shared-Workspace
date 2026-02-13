# NetNewsWire x ChatGPT 一键 AI 翻译工作流

这是一个让你的 RSS 阅读体验飞跃的配置教程。通过 macOS 快捷指令 (Shortcuts)，实现**一键将 NetNewsWire 的文章发送给 ChatGPT 进行翻译和总结**。

告别繁琐的复制粘贴，让 AI 成为你的私人阅读助手！👇

## 🛠️ 准备工作

* **macOS 系统**
* **[NetNewsWire](https://netnewswire.com/)** (RSS 阅读器)
* **ChatGPT Desktop App** (Mac 桌面版应用)

---

## 📝 配置步骤

### 第一步：创建快捷指令

1. 打开 Mac 上的 **「快捷指令」(Shortcuts)** 应用。
2. 点击右上角 <kbd>+</kbd> 号，新建一个快捷指令。
3. 将其重命名为 **「🧠 ChatGPT 深度阅读」** (或者你喜欢的名字)。

### 第二步：设置接收参数

点击快捷指令窗口右侧的 **详情图标 (ⓘ)**，在「详细信息」页签中勾选：

* ✅ **在共享表单中显示** (Show in Share Sheet)
* ✅ **作为快速操作使用** (Use as Quick Action)
* **接收内容**：点击 "无" -> 确保勾选 **URL** 和 **文本** (Safari 网页等)。

### 第三步：编排自动化流程

在左侧搜索并拖入以下动作，按顺序排列：

#### 1. 📥 获取文本

* 添加动作：**「文本」**
* 在文本框内填入不需要修改的神级提示词 (Prompt)：

> [!TIP] 推荐提示词
>
> ```text
> 请阅读以下 URL 内容，先提供一个简洁的中文摘要（3个要点），然后全文翻译成流畅的中文。
> 要求：
> 1. 保留原文中的专业术语（不要强行翻译）。
> 2. 附上原文链接。
> 3. 使用 Markdown 格式输出。
> 
> 内容：
> ```

* *关键点*：在提示词的最后，右键点击 -> 插入变量 -> 选择 **「快捷指令输入」** (Shortcut Input)。

#### 2. 📋 拷贝到剪贴板

* 添加动作：**「拷贝到剪贴板」**
* 确保它自动连接了上一步的文本内容。

#### 3. 🤖 唤醒 ChatGPT

* 添加动作：**「打开 App」**
* 选择 **ChatGPT**。

#### 4. ⏳ 稍作等待

* 添加动作：**「等待」**
* 时间设置为 **1 秒**。
* *原因*：给 ChatGPT 一点启动和响应的时间，避免粘贴失败。

#### 5. ⌨️ 自动粘贴 (注入灵魂的一步)

这是最关键的一步，利用 AppleScript 模拟键盘按下 `Cmd + V`。

* 添加动作：**「运行 AppleScript (Run AppleScript)」**
* 将默认代码替换为以下代码：

```applescript
on run {input, parameters}
 tell application "System Events"
  -- 模拟按下 Command + V
  keystroke "v" using command down
 end tell
 return input
end run
```

---

## ⚙️ 首次运行与权限

当你第一次运行这个快捷指令时，macOS 会弹窗请求权限：
> "System Events 想控制您的电脑..."

请务必点击 **「允许」** (或者在系统设置 -> 隐私与安全性 -> 辅助功能 中授权给快捷指令)，否则无法实现自动粘贴。

---

## 💡 如何使用？

1. 在 NetNewsWire 中看到感兴趣的英文文章。
2. 点击工具栏的 **分享按钮**。
3. 选择 **「🧠 ChatGPT 深度阅读」**。
4. 看着 ChatGPT 自动弹出并开始为你工作！☕️

---

## 🧩 进阶玩法

* **换成 Claude/Gemini**：只需要将第三步的「打开 ChatGPT」换成「打开 Claude」即可（前提是它们支持 cmd+v 直接输入）。
* **自定义 Prompt**：你可以修改第一步的文本，让它只做总结，或者提取金句，或者生成 Twitter thread。

## 推荐的订阅配置

```xml

<?xml version="1.0" encoding="UTF-8"?>
<opml version="2.0">
  <head>
    <title>RSS Subscriptions</title>
    <dateCreated>Wed, 04 Feb 2026 12:00:00 GMT</dateCreated>
    <dateModified>Wed, 04 Feb 2026 12:00:00 GMT</dateModified>
  </head>
  <body>
    <!-- 深度科技与极客文化 -->
    <outline text="深度科技与极客文化" title="深度科技与极客文化" _isOpen="true">
      <outline 
        type="rss" 
        text="Hacker News (精选)" 
        title="Hacker News (精选)" 
        xmlUrl="https://hnrss.org/frontpage" 
        htmlUrl="https://news.ycombinator.com/"
        description="HN 首页热门，技术与创业话题"/>
      
      <outline 
        type="rss" 
        text="The Verge" 
        title="The Verge" 
        xmlUrl="https://www.theverge.com/rss/index.xml" 
        htmlUrl="https://www.theverge.com/"
        description="科技与生活方式的交叉点，产品新闻与深度特稿"/>
      
      <outline 
        type="rss" 
        text="Ars Technica" 
        title="Ars Technica" 
        xmlUrl="https://arstechnica.com/feed/" 
        htmlUrl="https://arstechnica.com/"
        description="硬核技术深度分析、科学与游戏"/>
      
      <outline 
        type="rss" 
        text="WIRED" 
        title="WIRED" 
        xmlUrl="https://www.wired.com/feed/rss" 
        htmlUrl="https://www.wired.com/"
        description="科技对文化、政策和社会的影响"/>
      
      <outline 
        type="rss" 
        text="Daring Fireball" 
        title="Daring Fireball" 
        xmlUrl="https://daringfireball.net/feeds/main" 
        htmlUrl="https://daringfireball.net/"
        description="John Gruber 的独立博客，Apple 生态权威评论"/>
    </outline>

    <!-- 商业与战略洞察 -->
    <outline text="商业与战略洞察" title="商业与战略洞察" _isOpen="true">
      <outline 
        type="rss" 
        text="Stratechery" 
        title="Stratechery" 
        xmlUrl="https://stratechery.com/feed/" 
        htmlUrl="https://stratechery.com/"
        description="Ben Thompson 的科技商业战略分析"/>
      
      <outline 
        type="rss" 
        text="Benedict Evans" 
        title="Benedict Evans" 
        xmlUrl="https://www.ben-evans.com/rss" 
        htmlUrl="https://www.ben-evans.com/"
        description="前 a16z 合伙人，宏观科技趋势与市场分析"/>
      
      <outline 
        type="rss" 
        text="TechCrunch" 
        title="TechCrunch" 
        xmlUrl="https://techcrunch.com/feed/" 
        htmlUrl="https://techcrunch.com/"
        description="创业公司、融资、产品发布的第一手新闻"/>
    </outline>

    <!-- 开发者与工程实践 -->
    <outline text="开发者与工程实践" title="开发者与工程实践" _isOpen="true">
      <outline 
        type="rss" 
        text="Martin Fowler" 
        title="Martin Fowler" 
        xmlUrl="https://martinfowler.com/feed.atom" 
        htmlUrl="https://martinfowler.com/"
        description="软件架构设计大师，重构与企业应用模式"/>
      
      <outline 
        type="rss" 
        text="Netflix TechBlog" 
        title="Netflix TechBlog" 
        xmlUrl="https://netflixtechblog.com/feed" 
        htmlUrl="https://netflixtechblog.com/"
        description="流媒体巨头的高并发、微服务、数据工程实践"/>
      
      <outline 
        type="rss" 
        text="Uber Engineering" 
        title="Uber Engineering" 
        xmlUrl="https://eng.uber.com/feed/" 
        htmlUrl="https://eng.uber.com/"
        description="大规模分布式系统、机器学习工程案例"/>
      
      <outline 
        type="rss" 
        text="GitHub Blog" 
        title="GitHub Blog" 
        xmlUrl="https://github.blog/feed/" 
        htmlUrl="https://github.blog/"
        description="GitHub 官方产品更新、开源生态与开发者工具"/>
    </outline>

    <!-- 独立思考与杂谈 -->
    <outline text="独立思考与杂谈" title="独立思考与杂谈" _isOpen="true">
      <outline 
        type="rss" 
        text="Paul Graham Essays" 
        title="Paul Graham Essays" 
        xmlUrl="http://www.aaronsw.com/2002/feeds/pgessays.xml" 
        htmlUrl="http://www.paulgraham.com/articles.html"
        description="Y Combinator 创始人，创业与人生哲学"/>
      
      <outline 
        type="rss" 
        text="Naval Ravikant" 
        title="Naval Ravikant" 
        xmlUrl="https://nav.al/feed" 
        htmlUrl="https://nav.al/"
        description="硅谷天使投资人,财富与幸福的哲学"/>
      
      <outline 
        type="rss" 
        text="Wait But Why" 
        title="Wait But Why" 
        xmlUrl="https://waitbutwhy.com/feed" 
        htmlUrl="https://waitbutwhy.com/"
        description="Tim Urban 的长文博客，深度解读复杂话题 (AI, 人类未来)"/>
    </outline>
  </body>
</opml>

```
