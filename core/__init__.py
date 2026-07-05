# Digital Garage@2026
# core/__init__.py
"""
This is the CHAT module  —


"""

# pyrefly: ignore [missing-import]
from src.llm_core import (
    llm_call,
    llm_call_async,
    stream_llm,
    list_model_ids,
    normalize_model_id,
    LLMConfig,
)

# pyrefly: ignore [missing-import]
from .auth import AuthManager

# pyrefly: ignore [missing-import]
from .constants import *

# pyrefly: ignore [missing-import]
from .middleware import SecurityHeadersMiddleware

# pyrefly: ignore [missing-import]
from .exceptions import (
    SessionNotFoundError,
    InvalidFileUploadError,
    LLMServiceError,
    WebSearchError,
)

# pyrefly: ignore [missing-import]
from .models import Session, ChatMessage
from .session_manager import SessionManager  # pyrefly: ignore [missing-import]

__all__ = [
    # LLM
    "llm_call",
    "llm_call_async",
    "stream_llm",
    "list_model_ids",
    "normalize_model_id",
    "LLMConfig",
    # Auth
    "AuthManager",
    # Middleware
    "SecurityHeadersMiddleware",
    # Exceptions
    "SessionNotFoundError",
    "InvalidFileUploadError",
    "LLMServiceError",
    "WebSearchError",
    # Models
    "Session",
    "ChatMessage",
    "SessionManager",
]
