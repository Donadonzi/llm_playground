# llm-playground

A small Python playground for trying out various LLMs from Jupyter notebooks. Cloud and local models go through [LiteLLM](https://docs.litellm.ai/); local runs assume [Ollama](https://ollama.com/) is installed.

## Setup

Install [uv](https://docs.astral.sh/uv/) if you do not have it, then from the repo root:

```bash
uv sync
cp .env.example .env
```

Fill in the keys in `.env` for any cloud providers you want to use. Ollama does not need a key; `OLLAMA_API_BASE` defaults to `http://localhost:11434`.

## Notebooks

```bash
uv run jupyter lab
```

Or `uv run jupyter notebook`. Open:

- [`notebooks/01_litellm_chat.ipynb`](notebooks/01_litellm_chat.ipynb) — cloud chat via LiteLLM (`gpt-4o-mini`, Anthropic, Gemini, …)
- [`notebooks/02_ollama_local.ipynb`](notebooks/02_ollama_local.ipynb) — local models via LiteLLM + Ollama

If Jupyter cannot import `llm_playground`, pick the kernel from this project's `.venv`.

## Ollama (optional)

Install Ollama, start it, and pull a model:

```bash
ollama pull llama3.2
```

Then run the Ollama notebook.
