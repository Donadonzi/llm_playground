from pathlib import Path

from dotenv import load_dotenv

REPO_ROOT = Path(__file__).resolve().parents[2]


def load_env() -> bool:
    """Load `.env` from the repository root into the process environment."""
    return load_dotenv(REPO_ROOT / ".env")
