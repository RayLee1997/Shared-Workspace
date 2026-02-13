
#AgenticWorkflow

1. 晚上开通了 Github Pro，官方无法订阅的几个模型终于绕开了地区服务管制，客观上说明 $msft 系还是相对友好的，不仅 OpenCode 完全可用，Obsidian 中的 OpenCode 插件也完全可用，这样 Thinking Engine + Coding Engine 的本地环境基本搭建完毕；
2.  OpenCode 是 Claude Code 的开源替代，设计思想可以说是有点直接 Copy Claude Agent 设计规范，只是上下游连接的模型厂和服务对象不同，目前看它在社区生态的发展势头非常好， 传闻说是 a16z 和油管创始成员陈士俊做的早期投资；
3. Thinking in Agent Design, 从模型侧的发展来看，CoT 技术的出现解决了模型自己给自己写提示词（即让模型显式展开中间推导）、延长思考时间等，具备了所谓的 Thinking 的能力，极大的拉升了模型能力的上限；模型上层的 Agent 设计模式也开始趋于稳定，走向了专业化分工的设计理念，即不同的 Agent 专注于不同的任务领域，通过配置不同的 System Prompt、Tools、Permisions、Skills 这些来实现 Agent 实例的创建，运行态主要是做好 Context 管理；
4. 经典的 MAS 模式，面向不同职责的 Agent 怎么协调工作，协调者 Agent 负责用户交互，识别用户意图创建执行计划和子任务，把子任务转交给子 Agent 进行工作；
5. 最后，Claude Code/OpenCode 这种超级动态代理系统绝不是只用来 Coding 的东西，它们的本质是本地 Agent 搭建平台和运行时环境，只是加载了一些默认配置看起来像是专门用来 Coding 的东西。如果你已经意识到 OpenCode 和 Claude Code 这类产品的 Agentic Workflow 的本质，那么你就可以解锁更多的高级姿势...

