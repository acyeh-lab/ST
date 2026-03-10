## This file includes practical tips on how to install and use STAlign
Note that main page is here: https://github.com/JEFworks-Lab/STalign?tab=readme-ov-file


```
micromamba create -n stalign -c conda-forge python=3.11 pip -y
micromamba activate stalign
python -s -m pip install --upgrade pip
python -s -m pip install --upgrade "git+https://github.com/JEFworks-Lab/STalign.git"
python -s -m pip install --no-user --force-reinstall \
  tornado==6.2 \
  jupyter-client==8.6.3 \
  ipykernel==6.26.0 \
  Pygments==2.15.0
```

Then create the jupyter notebook environment name:
```
python -s -m ipykernel install \
  --user \
  --name stalign \
  --display-name "Python (stalign)"
```


Now make Jupyter kernel laucnh Python with "-s" by finding where the "kernel.json" file is.
```
jupyter kernelspec list
```

Choose the directory with stalign, cd into it, and edit the "kernel.json"

```
vi kernel.json
```

Change:
```
{
  "argv": [
    "/home/ayeh/micromamba/envs/stalign/bin/python",
    "-m",
    "ipykernel_launcher",
    "-f",
    "{connection_file}"
  ],
  "display_name": "Python (stalign)",
  "language": "python"
}
```

to 
```
{
  "argv": [
    "/home/ayeh/micromamba/envs/stalign/bin/python",
    "-s", 
    "-m",
    "ipykernel_launcher",
    "-f",
    "{connection_file}"
  ],
  "display_name": "Python (stalign)",
  "language": "python"
}
```
Now in the jupyter notebook, the following command should work:
```
from STalign import STalign 
```


# STalign + SpatialData Workflow

This pipeline avoids dependency conflicts by separating:

- **Spatial transcriptomics analysis** (`spatial-singular`)
- **Image registration** (`stalign-clean`)

Typical workflow:

```
SpatialData (.zarr)
        ↓
Export images / coordinates
        ↓
STalign registration
        ↓
Transform spatial coordinates
        ↓
Updated SpatialData object
```
