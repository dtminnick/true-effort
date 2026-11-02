data {
  int<lower=1> N;
  int<lower=1> J;
  int<lower=1> I;

  array[N] int<lower=1, upper=I> associate;
  array[N] int<lower=1, upper=J> work_type;

  vector<lower=0>[N] observed_effort;

  array[I] int<lower=0, upper=1> known_good;
}

parameters {
  vector[J] log_mu;

  vector[I] logit_capture_bad;

  real<lower=0> sigma;
}

transformed parameters {
  vector[I] capture_rate;

  for (i in 1:I) {

    if (known_good[i] == 1) {
      capture_rate[i] = 1.0;
    } else {
      capture_rate[i] = inv_logit(logit_capture_bad[i]);
    }

  }
}

model {

  // Prior for true effort by work type
  log_mu ~ normal(log(20), 0.8);

  // Prior for capture rates of poorly measured associates
  logit_capture_bad ~ normal(logit(0.15), 1.0);

  // Prior for measurement noise
  sigma ~ exponential(1);

  // Measurement model
  for (n in 1:N) {

    log(observed_effort[n]) ~ normal(
      log_mu[work_type[n]]
      + log(capture_rate[associate[n]]),
      sigma
    );

  }
}