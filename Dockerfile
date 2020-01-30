FROM jupyter/base-notebook:213760e5674e
MAINTAINER ome-devel@lists.openmicroscopy.org.uk

USER root
RUN apt-get update -y && \
    apt-get install -y \
        build-essential \
        curl \
        git

USER jovyan
# Default workdir: /home/jovyan

# Autoupdate notebooks https://github.com/data-8/nbgitpuller
# nbval for testing reproducibility
RUN pip install git+https://github.com/data-8/gitautosync && \
    jupyter serverextension enable --py nbgitpuller && \
    conda install -y -q nbval

# create a python2 environment (for OMERO-PY compatibility)
RUN mkdir .setup
ADD binder/environment.yml .setup/
RUN conda env create -n python2 -f .setup/environment.yml && \
    # Jupyterlab component for ipywidgets (must match jupyterlab version) \
    jupyter labextension install @jupyter-widgets/jupyterlab-manager@1.0

COPY --chown=1000:100 python2-kernel.json .local/share/jupyter/kernels/python2/kernel.json

# Clone the source git repo into notebooks (keep this at the end of the file)
COPY --chown=1000:100 . .

# Autodetects jupyterhub and standalone modes
CMD ["start-notebook.sh"]
