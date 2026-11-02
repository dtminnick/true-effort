# ============================================================
# TrueEffort
# 03 - Fit Bayesian measurement model
# ============================================================

library(rstan)

# ------------------------------------------------------------
# Prepare the data
# ------------------------------------------------------------

source("R/02_prepare_stan_data.R")

# ------------------------------------------------------------
# Fit the Stan model
# ------------------------------------------------------------

fit <- stan(
    file = "stan/effort_measurement.stan",
    data = stan_data,
    chains = 4,
    iter = 2000,
    warmup = 1000,
    seed = 1234
)

# ------------------------------------------------------------
# View the fitted model
# ------------------------------------------------------------

print(fit)

# Extract posterior draws
posterior <- rstan::extract(fit)

# True effort by work type
true_effort_summary <- data.frame(
    work_type = c("A", "B", "C"),
    mean_minutes = exp(colMeans(posterior$log_mu)),
    median_minutes = apply(
        exp(posterior$log_mu),
        2,
        median
    ),
    lower_95 = apply(
        exp(posterior$log_mu),
        2,
        quantile,
        probs = 0.025
    ),
    upper_95 = apply(
        exp(posterior$log_mu),
        2,
        quantile,
        probs = 0.975
    )
)

true_effort_summary