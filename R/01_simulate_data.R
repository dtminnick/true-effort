
set.seed(1234)

true_effort <- c(A = 10, B = 25, C = 45)

true_capture <- c(Associate_1 = 1.00,
                  Associate_2 = 1.00,
                  Associate_3 = 0.08,
                  Associate_4 = 0.05, 
                  Associate_5 = 0.15,
                  Associate_6 = 0.10)

dat <- expand.grid(associate = names(true_capture),
                   work_type = names(true_effort))

dat$true_effort <- true_effort[dat$work_type]

dat$capture_rate <- true_capture[dat$associate]

dat$expected_observed <- (dat$true_effort * dat$capture_rate)

dat$observed_effort <- exp(log(dat$expected_observed) + rnorm(nrow(dat), mean = 0, sd = 0.10))

dat$observed_effort <- round(dat$observed_effort, 2)

annual_volume <- c(A = 50000, B = 30000, C = 20000)

true_annual_hours <- sum(annual_volume * true_effort) / 60

true_annual_hours

model_dat <- dat[, c("associate", "work_type", "observed_effort")]

model_dat

known_good <- c(
    Associate_1 = 1,
    Associate_2 = 1,
    Associate_3 = 0,
    Associate_4 = 0,
    Associate_5 = 0,
    Associate_6 = 0
)

model_dat$associate_id <- as.integer(
    factor(
        model_dat$associate,
        levels = names(true_capture)
    )
)

model_dat$work_type_id <- as.integer(
    factor(
        model_dat$work_type,
        levels = names(true_effort)
    )
)

model_dat

aggregate(
    observed_effort ~ associate,
    data = model_dat,
    FUN = mean
)

aggregate(
    observed_effort ~ work_type,
    data = model_dat,
    FUN = mean
)
