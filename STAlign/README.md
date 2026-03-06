## This file includes practical tips on how to install and use STAlign
Note that main page is here: https://github.com/JEFworks-Lab/STalign?tab=readme-ov-file


```
micromamba create -n stbalign -c conda-forge python=3.11 pip -y
micromamba activate stbalign
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
  --name stbalign \
  --display-name "Python (stbalign)"
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

# STalign + SpatialData Workflow

This workflow separates **spatial analysis** and **image registration** into two micromamba environments to avoid dependency conflicts.

| Task | Environment |
|-----|-------------|
| Spatial transcriptomics analysis (Scanpy / SpatialData / Squidpy) | `spatial-singular` |
| Image registration with STalign | `stalign-clean` |

---

# Step 1 — Load Spatial Data

Activate the spatial analysis environment.

```bash
micromamba activate spatial-singular
```

Load the `.zarr` dataset using SpatialData:

```python
from spatialdata import read_zarr

sdata = read_zarr("sample.zarr")
print(sdata)
```

---

# Step 2 — Export Images / Coordinates

Extract the images and coordinates that will be used for alignment.

Example:

```python
image = sdata.images["h_and_e"]
points = sdata.points["cells"]
```

Export arrays if needed:

```python
import numpy as np

np.save("image.npy", image)
np.save("coords.npy", points)
```

---

# Step 3 — Run STalign

Activate the STalign environment.

```bash
micromamba activate stalign-clean
```

Run STalign to compute the transformation between images.

```python
from STalign import STalign

# example placeholder
aligner = STalign()

transform = aligner.align(image1, image2)
```

Save the transformation parameters:

```python
import json

with open("transform.json", "w") as f:
    json.dump(transform, f)
```

---

# Step 4 — Apply Transform Back to SpatialData

Return to the spatial analysis environment.

```bash
micromamba activate spatial-singular
```

Load the transform and apply it to the dataset.

```python
import json

with open("transform.json") as f:
    transform = json.load(f)

# apply transform to spatial coordinates
# (implementation depends on STalign output format)
```

---

# Summary

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
