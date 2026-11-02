# ============================================================
# TrueEffort
# 02 - Prepare data for Stan
# ============================================================

# This script assumes 01_simulate_data.R has already been run.
source("./R/01_simulate_data.R")

# ------------------------------------------------------------
# Number of observations, work types, and associates
# ------------------------------------------------------------

N <- nrow(model_dat)

J <- length(true_effort)

I <- length(true_capture)

# ------------------------------------------------------------
# Create the data list Stan will receive
# ------------------------------------------------------------

stan_data <- list(
    N = N,
    J = J,
    I = I,
    
    associate = model_dat$associate_id,
    
    work_type = model_dat$work_type_id,
    
    observed_effort = model_dat$observed_effort,
    
    known_good = unname(known_good)
)

stan_data