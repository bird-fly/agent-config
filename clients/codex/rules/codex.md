# Codex 专属规则

- 本节只放 Codex 专属规则；共享规则继续维护在 `shared/rules/`。
- 如 Codex 与共享规则冲突，以本文件中的 Codex 专属规则为准。
- 最终答复末尾附两行：`会话 ID: <thread.id>`、`turn_id: <turn_id>`；`turn_id` 从本地 Codex 会话 JSONL 中匹配当前用户消息，并读取 `payload.internal_chat_message_metadata_passthrough.turn_id`；不要用 `read_thread` 或 `read_mcp_resource` 获取当前 turn。
- 读取 turn_id 时单轮仅允许执行一次查询脚本，获取到值后必须立即输出最终答复正文，严禁重复读取或递归调用工具。