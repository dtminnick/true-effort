# True Effort

*Estimating how much work really goes into a case when the recorded time is incomplete.*

## Why this project exists

Teams that build business cases for agentic AI need to estimate **capacity savings**, and that depends on how much effort the work takes. Work effort is often poorly measured. An associate might spend 20 minutes on a case but record under a minute, because most of the work happens outside the workflow system and the case is only updated when it is finished.

When a bottom-up estimate built from recorded effort falls short of the operating budget, a common shortcut is to work backward from the budget to "implied hours." Those hours are no longer an observation of the work. They are a value chosen to make the numbers match, and the metric (the savings figure) quietly becomes the target.

This project takes the opposite approach: **treat the gap as a question to investigate, not a gap to close.** The gap could mean effort is under-recorded, some activities are missing from the data, or the budget reflects more than the effort of the work itself.

## Target, evidence, and metric

| | |
|---|---|
| **Target** | The true amount of work effort that agentic AI can address |
| **Evidence** | Recorded effort, case volumes, system-activity hours, a small time sample, and other information about how the work is done |
| **Metric** | The capacity savings presented in the business case |

The goal is a savings estimate grounded in the work as actually performed, with a measure of uncertainty that helps decision-makers judge how much confidence to place in it.

## A hypothetical example

A company processes 100,000 account-maintenance cases a year. Its workflow system records two minutes per case on average, which suggests about 3,333 hours of work. The budget funds 12 full-time employees, roughly 25,000 hours. The gap is large because associates do research and document review outside the system and record only a brief update at the end.

Working backward from the budget would overstate the savings. The budget funds the whole operation, not only the activities AI would take on, and even within scope, AI may assist with part of a case instead of eliminating the labor.

## Approach

The model is a **hierarchical Bayesian measurement-error model** (also called a latent-variable model), fit to several sources of evidence at once. Real effort is hidden. The model describes how each source of evidence is produced from it, then lets the data show which effort values fit best. The result is a **range** of plausible effort for each work type, carried through to a range of hours saved. The budget is compared at the end, outside the model.

### The parts

1. **Real effort (hidden).** Each case has a true time. Cases of the same work type share an average and a spread. Case touches shift individual cases up or down.
2. **Recording.** Recorded time is real time multiplied by a recording share. Each associate has a typical share, and the share varies from case to case. A separate chance that nothing is recorded handles zeros. A small reference group of well-recorded associates sets the scale, but they are not assumed to record exactly 100%.
3. **Time sample.** A small sample where real time is observed directly, paired with recorded time on the same cases. It shows how recording varies and checks the other evidence.
4. **Weekly hours.** Utilized hours per associate (time in production systems, from PegaWFI) are compared with the cases they completed. Weekly hours equal a baseline of other production work, plus time per case times cases of each type, plus error. This gives a second route to real effort that does not rely on recorded times.
5. **Results layer.** Effort estimates feed forward into volume, in-scope share, AI-addressable share, and cost. Scope and AI share come from expert ranges, not data. The output is a range of hours and cost saved, plus which unknown moves the answer most.

Each source of evidence has its own allowance for error. When sources disagree, the model reports a gap to investigate instead of forcing agreement.

### Work types and NIGO

Cases that are not in good order (NIGO) create child cases that carry their own effort. NIGO children are treated as separate work types, for example `termination`, `termination-nigo`, `inservice`, and `inservice-nigo`. Parent cases are tagged as having NIGO. Parents that never reach completed status go to "no process" status. NIGO work types can share information with each other so that types with few cases are not wildly uncertain.

## Data needed

One year of history.

**1. Case records (one row per case)**

| field | notes |
|---|---|
| case_id | |
| work_type | includes NIGO types |
| parent_case_id | for NIGO child cases |
| has_nigo | flag on parent cases |
| status | completed or no process |
| finishing_associate | the associate who completed the case |
| opened, closed | dates |
| recorded_minutes | keep zeros and very small values |
| touches | total case touches |
| associates_touched | number of associates who touched the case |

Touches and associates touched are summarized from step data. Steps themselves are not modeled.

**2. Time sample (one row per sampled case):** `case_id`, `associate`, `real_minutes`. Must pair with recorded time on the same cases and include at least one under-recorder.

**3. Utilized hours (one row per associate per day):** `associate`, `date`, `utilized_hours`. Aggregated to weeks for the main comparison.

**4. Work type details (one row per work type):** annual volume, in-scope range, AI-addressable range, and expert estimates (minimum, typical, maximum minutes).

**5. Costs:** cost per hour, and the budget for the final comparison.

## Assumptions and scope

- **Normal operations only.** Mass plan migrations and similar events are not modeled. Savings apply to normal day-to-day work.
- **Cases are credited to the finishing associate.** Hand-offs are assumed to average out, and this is checked in the data.
- **Cases handled by other teams** (related cases that need supporting work) are out of scope. They affect cycle time, not associate effort.
- **Cycle time is never used as a stand-in for effort.**
- **Weekly is the main comparison unit** for hours versus cases, because most cases finish in one to two days but some run longer than a week.
- **Seasonality** is handled with a month adjustment if the data shows one, not with time series forecasting.
- **Utilized hours are measurements with error**, not truth. They can include time that is not case work and can miss case work done outside tracked systems.

## Known risks

- The answer is only as good as the structure of the recording story. A wrong structure gives a wrong answer, which the time sample helps catch.
- Too small a time sample leaves effort and recording only partly separable. The model will show this as wide ranges.
- Case touches come from the same system with the recording problem, so they may understate complexity for associates who work offline.
- With a single year of data, a seasonal pattern cannot be told apart from a one-off event.
- Many hidden parts can make fitting slow or unstable, and a year of cases may need to be summarized by associate, work type, and week.

## Validation plan

There is no time study with fully known effort, so the model is built and tested on **simulated data with a known ground truth**. At each stage the recovered values are compared with the truth, and the intervals are checked to see whether they contain it.

Scenarios to simulate:

- A reference group that records 80%, 90%, or 100%
- Recording that varies by case, not a fixed share
- Seasonal swings in volume and recording habits
- Mostly 1-2 day cases with a tail of longer ones
- NIGO work types, including thin ones
- Error in the utilized hours
- Hand-offs between associates

The simulation also answers a practical question: **how many sampled cases per under-recorder are needed**, which becomes the sampling plan for the real time sample.

## Build stages

1. Recorded times plus the reference group (extends the current starter)
2. Add the time sample
3. Add weekly hours
4. Add the results layer and the budget comparison

## Future enhancements

- Monthly comparison alongside weekly, as a check on week-boundary effects
- Mass migrations and other events
- NIGO rate as a scenario input, since AI may reduce NIGO and not only speed up handling
- Work done by other teams
- Step-level modeling and hand-off-aware recording

## Open questions

- What share of cases stay open more than five working days?
- What share of cases are touched by more than one associate?
- How well do PegaWFI production-system hours reflect case work?
- Do touch counts predict real time for under-recorders as well as for the reference group?

## Repository

| path | contents |
|---|---|
| `R/01_simulate_data.R` | Starter simulation: 6 associates, 3 work types, 2 reference associates |
| `R/02_prepare_stan_data.R` | Prepares data for Stan |
| `R/03_fit_model.R` | Fits the model and summarizes effort by work type |
| `stan/effort_measurement.stan` | Starter measurement model |

The current code is a starter. It will be extended through the stages above.
