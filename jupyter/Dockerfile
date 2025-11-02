FROM blnkoff/spark-jupyter:latest

USER root

COPY requirements.txt /tmp/requirements.txt
RUN pip install --upgrade pip && \
    pip install --upgrade --no-cache-dir -r /tmp/requirements.txt && \
    rm -f /tmp/requirements.txt

USER jovyan
