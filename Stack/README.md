Spatial stacks vary depending on the software used.

For example, STAlign has their own stack: https://github.com/JEFworks-Lab/STalign/blob/main/pipenv-requirements.txt

For Singular:
```
micromamba activate spatial-singular
cd /fh/fast/hill_g/Albert/Collaboration-Spatial_Seq_Biopsy_Samples
git clone https://github.com/scverse/spatialdata-io.git
cd spatialdata-io
git fetch origin pull/281/head:pr-281
git checkout pr-281
python -m pip install --no-cache-dir -e .
```
