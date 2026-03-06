## This file includes practical tips on how to install STAlign
Note that main page is here: https://github.com/JEFworks-Lab/STalign?tab=readme-ov-file


```
micromamba create -n stalign -c conda-forge python=3.11 pip -y
micromamba activate stalign
python -s -m pip install --upgrade pip
python -s -m pip install --upgrade "git+https://github.com/JEFworks-Lab/STalign.git"
python -s -m pip install --no-user --force-reinstall \
  tornado==6.2 \
  jupyter-client==8.6.3 \
  ipykernel==6.26.0
```

Now make Jupyter kernel laucnh Python with "-s"
```
jupyter kernelspec list
```
Change:
```
{
  "argv": [
    "/home/ayeh/micromamba/envs/stalign-clean/bin/python",
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
    "/home/ayeh/micromamba/envs/stalign-clean/bin/python",
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
