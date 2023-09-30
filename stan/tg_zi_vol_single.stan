data {
    int<lower=0> ncells;
    int<lower=0> ngenes;
    int<lower=0> N;
    array[N] int<lower=0> cells;
    array[N] int<lower=0> genes;
    array[N] int<lower=0> counts;
}

parameters {
    vector<lower=0>[ngenes] mu;
    vector<lower=0>[ngenes] raw_b;
    vector<lower=0>[ngenes] dur;

    vector<lower=0,upper=1>[N] raw_betas;

    vector<lower=0,upper=1>[ngenes] p0;

    vector<lower=0,upper=1>[ngenes] alpha;
    simplex[ncells] raw_vol;
}

transformed parameters {
    vector<lower=0>[ngenes] b = raw_b + mu .* dur;

    vector<lower=0>[ngenes] rho = b ./ dur;
    vector<lower=0>[ngenes] sigma_on = mu ./ (b - mu .* dur);
    vector<lower=0>[ngenes] sigma_off = 1 ./ dur;

    vector<lower=0>[ncells] vol = ncells * raw_vol;
}

model {
    mu ~ exponential(0.05);
    raw_b ~ exponential(0.05);
    dur ~ exponential(1);

    p0 ~ uniform(0, 1);

    alpha ~ uniform(0, 1);
    raw_vol ~ dirichlet(rep_vector(1,ncells));

    raw_betas ~ beta(sigma_on[genes], sigma_off[genes]);

    for (n in 1:N) {
        int c = cells[n];
        int g = genes[n];

        real rho_eff = rho[g] * ((1 - alpha[g]) + vol[c] * alpha[g]);

        if (counts[n] == 0) {
            target += log_sum_exp(bernoulli_lpmf(1 | p0[g]), bernoulli_lpmf(0 | p0[g]) + poisson_lpmf(counts[n] | rho_eff * raw_betas[n]));
        } else {
            target += bernoulli_lpmf(0 | p0[g]) + poisson_lpmf(counts[n] | rho_eff * raw_betas[n]);
        }
    }
}

