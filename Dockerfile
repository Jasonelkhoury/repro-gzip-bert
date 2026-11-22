FROM python:3.9-slim

RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /workspace

RUN git clone https://github.com/bazingagin/npc_gzip.git /workspace/npc_gzip

RUN pip install --no-cache-dir -r /workspace/npc_gzip/original_codebase/requirements.txt \
    && pip install --no-cache-dir "pyarrow==14.0.1" "fsspec==2023.6.0" "zstandard==0.21.0" \
    && pip install --no-cache-dir --no-deps -e /workspace/npc_gzip

COPY compare_official_fix.py /workspace/compare_official_fix.py
COPY run_repro.sh /workspace/run_repro.sh
RUN chmod +x /workspace/run_repro.sh

ENTRYPOINT ["/workspace/run_repro.sh"]