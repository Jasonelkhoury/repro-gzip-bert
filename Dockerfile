FROM python:3.9-slim

# System dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    bash \
    build-essential \
    patchelf \
    sed \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /workspace

# Clone NPC-Gzip
RUN git clone \
    https://github.com/bazingagin/npc_gzip.git \
    /workspace/npc_gzip

# Install project dependencies
RUN pip install --no-cache-dir \
    -r /workspace/npc_gzip/original_codebase/requirements.txt \
    && pip install --no-cache-dir \
        "torchdata==0.5.1" \
        "portalocker>=2.0.0" \
        "pyarrow==14.0.1" \
        "fsspec==2023.6.0" \
        "zstandard==0.21.0" \
        "datasets==2.14.7" \
    && pip install --no-cache-dir --no-deps -e /workspace/npc_gzip \
    && find /usr/local/lib/python3.9/site-packages/torch/lib \
        -name "*.so*" \
        -exec patchelf --clear-execstack {} +


# Patch main_text.py to make the number of workers configurable
RUN python - <<'PY'
from pathlib import Path
import re

path = Path("/workspace/npc_gzip/original_codebase/main_text.py")
source = path.read_text()

# Find the Pool(6) line, regardless of indentation
pattern = r"(?m)^([ \t]*)with Pool\(\s*6\s*\) as p:"

def replace_pool(match):
    indent = match.group(1)
    return (
        f'{indent}num_workers = int(__import__("os").environ.get("NUM_WORKERS", 6))\n'
        f'{indent}print(f"Using {{num_workers}} worker processes")\n'
        f'{indent}with Pool(num_workers) as p:'
    )

patched_source, count = re.subn(pattern, replace_pool, source, count=1)

if count != 1:
    raise RuntimeError(
        "Could not find 'with Pool(6) as p:' in main_text.py. "
        "Please inspect the source code."
    )

path.write_text(patched_source)

print("Successfully patched main_text.py")
PY


# Prepare DBpedia dataset
COPY prepare_dbpedia.py /workspace/prepare_dbpedia.py

RUN python /workspace/prepare_dbpedia.py

# Copy reproduction script
COPY run_repro.sh /workspace/run_repro.sh

RUN sed -i 's/\r$//' /workspace/run_repro.sh \
    && chmod +x /workspace/run_repro.sh

# Default number of worker processes
ENV NUM_WORKERS=6

# Default execution
ENTRYPOINT ["/bin/bash", "/workspace/run_repro.sh"]
