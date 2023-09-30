# Bayesian mechanistic modelling of scRNAseq data using Stan 

### Requirements:
* Julia (recommended), including [JSON.jl](https://github.com/JuliaIO/JSON.jl), [ArgParse.jl](https://github.com/carlobaldassi/ArgParse.jl)
* Python (recommended) 
* [CmdStan](https://mc-stan.org/users/interfaces/cmdstan), or any other [Stan](https://mc-stan.org/) interface

## Description:

The folder `stan` contains the following models:
* `tg_zi_single`: Telegraph model, with zero inflation, single allele
* `tg_zi_vol_single`: Telegraph model, with zero inflation and cell volume, single allele
* `tg_zi_vol_pooled`: Telegraph model, with zero inflation and cell volume, two alleles (pooled)

These models can be run using [CmdStan](https://mc-stan.org/users/interfaces/cmdstan). 

## Input
The input to Stan is provided as a JSON file containing the following fields:
* `int ncells`: Number of cells
* `int ngenes`: Number of genes
* `int N`: Number of observations
* `int cells[N]`: Cell corresponding to each observation
* `int genes[N]`: Gene corresponding to each observation
* `int counts[N]`: Measured mRNA numbers for each observation

The script `convert_data.jl` can be used to convert a count matrix (stored as a CSV file) into this format, skipping missing values.

## Output
The sampler computes the posterior over the following quantities:
### Gene-specific:
* `mu`: Mean mRNA numbers
* `b`: Mean burst size
* `dur`: Mean burst duration
* `p0`: Amount of zero inflation
* `alpha`: Volume dependence (if present)

The following values are computed for convenience:
* `rho`: Transcription rate
* `sigma_on`: on switching rate
* `sigma_off`: on switching rate

### Cell-specific:
* `vol`: Volume scaling factor (if present)

**Note:** The outputs also contains the latent variables `raw_betas`, one per observation. This requires a lot of memory or disk space for large batches. These, and other internal variables, can be removed  using the script `postprocess_csv.py`.

# Example usage:

1. Convert mRNA count matrix to JSON:

```bash
julia scripts/convert_data.jl countmat.csv countmat.json
```

The input must be a CSV file containing mRNA counts. Each row represents a cell, and each column a gene (except for the first column, which is ignored). Missing values are allowed.

2. Run Stan:

```bash
stan/tg_zi_vol_single sample data file=countmat.json output file=raw_samples.csv
```

See the [CmdStan user guide](https://mc-stan.org/docs/cmdstan-guide/index.html) for more information

3. (Optional) Trim output files:

```bash
python scripts/postprocess_csv.py <raw_samples_1.csv >samples_1.csv
...
```
