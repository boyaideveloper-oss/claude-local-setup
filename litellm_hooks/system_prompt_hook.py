import re
import json
from litellm.integrations.custom_logger import CustomLogger


TOOL_USE_SYSTEM_PROMPT = (
    "You have access to tools. "
    "ALWAYS use the appropriate tool when the user's request involves searching, "
    "fetching, or retrieving current/real-time information. "
    "Do NOT answer from memory when a tool is available to get accurate results. "
    "Call the tool immediately without explaining that you are going to call it."
)


def _ddgs_search(query: str, max_results: int = 5) -> str:
    try:
        from ddgs import DDGS
        results = list(DDGS().text(query, max_results=max_results))
        if not results:
            return f"No results found for: {query}"
        lines = [f'Web search results for query: "{query}"\n']
        for i, r in enumerate(results, 1):
            lines.append(f"{i}. [{r.get('title', '')}]({r.get('href', '')})")
            lines.append(f"   {r.get('body', '')[:300]}")
        lines.append("\nREMINDER: Include source links in your response.")
        return "\n".join(lines)
    except Exception as e:
        return f"Search failed: {e}"


def _extract_query(content) -> str:
    text = ""
    if isinstance(content, str):
        text = content
    elif isinstance(content, list):
        for block in content:
            if isinstance(block, dict) and block.get("type") == "text":
                text = block.get("text", "")
                break
    match = re.search(r'query[:\s]+["\']?(.+?)["\']?\s*$', text, re.IGNORECASE | re.DOTALL)
    return match.group(1).strip() if match else text.strip()


class SystemPromptInjector(CustomLogger):
    async def async_pre_call_hook(self, user_api_key_dict, cache, data, call_type):
        tools = data.get("tools") or []
        messages = data.get("messages") or []

        # Debug log
        with open("/tmp/litellm_debug.log", "a") as f:
            if tools:
                tool_names = [t.get("name") for t in tools if isinstance(t, dict)]
                f.write(f"[tools] {tool_names}\n")
            last = messages[-1] if messages else {}
            content = last.get("content", "")
            if isinstance(content, list):
                for block in content:
                    if isinstance(block, dict) and block.get("type") == "tool_result":
                        f.write(f"[tool_result FULL] {json.dumps(block)[:2000]}\n")

        # Intercept any request with only web_search tool — run real ddgs search
        if len(tools) == 1 and tools[0].get("name") == "web_search" and messages:
            # Find last user message content
            last_user_content = ""
            for msg in reversed(messages):
                if msg.get("role") == "user":
                    last_user_content = msg.get("content", "")
                    break
            query = _extract_query(last_user_content)
            with open("/tmp/litellm_debug.log", "a") as f:
                f.write(f"[DDGS search] query={query!r}\n")
            results = _ddgs_search(query)
            with open("/tmp/litellm_debug.log", "a") as f:
                f.write(f"[DDGS result] {results[:300]}\n")
            # Replace last message with search results, remove tools
            data["messages"][-1]["content"] = results
            data["messages"][-1]["role"] = "user"
            data.pop("tools", None)
            return data

        if not tools:
            return data

        # Inject system prompt for tool-enabled requests
        if call_type == "anthropic_messages":
            existing = data.get("system")
            if isinstance(existing, list):
                texts = [b.get("text", "") for b in existing if isinstance(b, dict)]
                if not any(TOOL_USE_SYSTEM_PROMPT in t for t in texts):
                    existing.insert(0, {"type": "text", "text": TOOL_USE_SYSTEM_PROMPT})
            else:
                existing = existing or ""
                if TOOL_USE_SYSTEM_PROMPT not in existing:
                    data["system"] = (TOOL_USE_SYSTEM_PROMPT + "\n\n" + existing).strip()
            return data

        messages = data.get("messages", [])
        if messages and messages[0].get("role") == "system":
            existing = messages[0].get("content", "")
            if TOOL_USE_SYSTEM_PROMPT not in existing:
                messages[0]["content"] = (TOOL_USE_SYSTEM_PROMPT + "\n\n" + existing).strip()
        else:
            messages.insert(0, {"role": "system", "content": TOOL_USE_SYSTEM_PROMPT})
        data["messages"] = messages
        return data


proxy_handler_instance = SystemPromptInjector()
