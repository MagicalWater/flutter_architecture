from typing import Optional


VALID_EXECUTION_MODES = frozenset(
    {
        "manual-local",
        "self-hosted",
        "github-hosted",
    }
)


def resolve_execution_mode(
    repository_value: Optional[str],
    override: Optional[str],
) -> str:
    candidate = (
        repository_value
        if override in (None, "repository-default")
        else override
    )
    candidate = candidate or ""
    if candidate not in VALID_EXECUTION_MODES:
        raise ValueError(f"Unsupported CI execution mode: {candidate!r}")
    return candidate
