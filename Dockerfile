FROM python:3.9-slim

# System dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    bash \
    build-essential \
    patchelf \
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

# Prepare DBpedia dataset
COPY prepare_dbpedia.py /workspace/prepare_dbpedia.py

RUN python /workspace/prepare_dbpedia.py

# Copy reproduction script
COPY run_repro.sh /workspace/run_repro.sh

RUN sed -i 's/\r$//' /workspace/run_repro.sh \
    && chmod +x /workspace/run_repro.sh

# Default execution
ENTRYPOINT ["/bin/bash", "/workspace/run_repro.sh"]
