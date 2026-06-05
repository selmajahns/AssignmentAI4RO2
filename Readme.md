# Agricultural Robotics – Pest Infestation Spread

See plans.md fro results.

## Basic PDDL model : Domain 1

States of plot:
- healthy
- suspected
- infested
- treated

Actions:
- move
- inspect-and-finds-infested
- inspect-and-finds-healthy
- treat
- report-treated
- report-healthy

### Design choices made:
- The effect of the inspect action needs to be either healthy or infested. Therefore modelled as inspect-and-finds-healthy and inspect-and-finds-infested.
- Chose to model partial knowledge: each inspect action results in detected-healthy or detected-infested. The robot needs to know a plot is infested before treating it, therefore detected-infested is a precondition for the treat action. This means the planner must inspect a plot before it can treat it.
- Same goes for the report action. report-healthy and report-infested both result in reported. Report-healthy will only be used if the goal specifies that a healthy plot needs to be reported.
- Spread is approximated through the initial state with two plots starting as infested, representing spread that occurred before the robot arrived. This is a static approximation since classical PDDL has no autonomous processes. The threat to neighboring plots is implicit through adjacency and the capacity constraint. A spread action could have been modelled, but the planner would have to be forced to use it — it would not actually model dynamic spread, and would be equivalent to just setting plots as infested in the initial state. This is a known limitation of classical PDDL modelling.

---

## Problem 1:
Modelling localized infestation. One infested plot and simple treat.
p3 starts infested and robot starts at p1.


p1 (robot) — p2 — p3 (infested)


Design choices:
- All plots are suspected (partial knowledge). Note: the planner never actually considers inspect-and-finds-healthy because it knows p3 is infested from the initial state, a known limitation of modelling partial observability in classical PDDL. The planner knows everything even though the robot does not. Could force the planner to use inspect-and-finds-healthy by requiring all plots to be reported in the goal.
- Capacity set to 1. Exactly enough for the single treatment needed. This ensures the capacity constraint is tested without slack.

---

## Problem 2:
Modelling multiple plots threatened. Two plots infested at start: p2 and p3.


p1 — p2 — p3 — p4
          |
          p5


This makes all adjacent plots threatened: p1, p4, and p5. The robot is given capacity to treat only one plot, forcing it to prioritize. Setting (not (infested p5)) in the goal models p5 as a critical plot. The optimal choice given the capacity constraint is to treat p3, since p3 is the bottleneck adjacent to both p4 and p5.

Design choices:
- Suspected is used to model partial knowledge by only marking plots that are actually infested as suspected. Unlike Problem 1 where all plots were marked suspected, here the robot has prior knowledge that only infested plots need inspection.
- If the robot treats p2 instead of p3, capacity is exhausted and p3 remains infested. Since p3 is adjacent to p5, the goal (not (infested p5)) becomes unreachable. Wrong prioritization directly causes plan failure, satisfying the requirement that delaying or incorrect treatment causes failure.
- p2 remains infested at the end of the plan. In reality this would continue spreading, but classical PDDL cannot model this. This is a limitation worth noting — the model only optimizes for the goal, not complete field remediation.

---

## PDDL+ : Domain 2

Processes:
- spread-pressure
- treating
- moving

Actions:
- start-move
- inspect-and-finds-infested
- inspect-and-finds-healthy
- start-treat
- report-treated
- report-healthy

Events:
- get-infested
- get-treated
- get-moved

Same plot states as Q1 but with being-treated added, set by the start-treat action. Movement is also modelled as a process rather than an instantaneous action.

### Design choices made:
- Spread pressure increases continuously at 0.2 per elapsed time unit. When pressure reaches 1, the get-infested event fires and the plot becomes infested. This models autonomous spread without requiring the planner to choose it.
- Treatment is modelled as a process rather than an instantaneous action, for realism. The full flow is:
    1. start-treat sets being-treated on the plot
    2. treating process decreases pressure at 0.5 per time unit
    3. get-treated event fires when pressure reaches 0, setting treated and restoring healthy
- Treatment rate (0.5) is higher than spread rate (0.2) so the robot can overcome infestation if it acts in time. If the robot delays, new plots are in danger of becoming infested.
- Robot is forced to stay at a plot during treatment by setting (not (being-treated ?from)) as a precondition for start-move. This means the robot must commit to treating a plot fully before moving to the next threat.
- Movement is modelled as a process using start-move, a moving process, and a get-moved event. This means travel time is real — spread runs autonomously while the robot is in transit, creating genuine timing tension.
- get-healthy event was removed and merged into get-treated. Having both caused an overlap — get-healthy would fire at pressure < 1 and clear infested before get-treated could fire at pressure = 0, making treated never reachable.

---

## Problem 1:
Early intervention success. Robot must reach and treat p3 before spread reaches critical plot p5.


p1(robot) — p2 — p3(infested) — p4 — p5(critical)


Design choices:
- Robot starts at p1, two moves from the infestation — travel time lets spread build pressure during movement.
- p3 starts with pressure 1.0 (already infested), all other plots at pressure 0.
- Capacity 1 — exactly enough for one treatment.
- Goal: (not (infested p5)) models p5 as critical, (treated p3) forces the robot to address the outbreak.
- By t=4 both p2 and p4 reach pressure 0.8 — just under the threshold of 1.0. Robot barely succeeds.
- Shows that correct timing leads to success. Any additional delay would cause cascade failure, motivating Problem 2.

---

## Problem 2:
Delayed intervention causes additional work. Same layout as Problem 1 but p4 starts with pressure 0.4, representing pre-existing spread pressure building before the robot arrives.


p1(robot) — p2 — p3(infested) — p4 — p5(critical)


Design choices:
- p4 starts with pressure 0.4 — this causes p4 to tip to infested during the robot's travel, creating a second outbreak that requires treatment.
- Capacity increased to 2 to reflect the additional work required — the robot must now treat both p3 and p4.
- Problem 1 requires 1 treatment and completes at t=4. Problem 2 requires 2 treatments and completes at t=9, demonstrating that delayed intervention creates significant additional work.
- The planner treats p4 before p3 despite p3 being the original outbreak. This is because p4 is adjacent to the critical plot p5 — treating p3 first would allow p4 to keep spreading toward p5, potentially causing goal failure. This demonstrates that intervention order directly affects safety outcomes.
- Together Problems 1 and 2 satisfy the requirement that different intervention timing and order lead to different feasibility and safety outcomes.



## Discussion

### Modelling propagation processes over graphs
Infestation spread is modelled through explicit adjacency declarations, only plots that are directly connected can spread infestation to each other. This means graph topology directly determines which plots are important. Plot like p3 in Q1 Problem 2 is adjacent to multiple plots simultaneously, making it a bottleneck that protect several neighbors at once. Plots like p1 and p4 only threaten one neighbor, making them lower priority. In Q1, spread cannot be modelled dynamically. A spread action could be added to the domain, but the planner would never choose it since spreading infestation contradicts the goal. Forcing the planner to apply it would be equivalent to simply setting plots as infested in the initial state. Spread is therefore approximated through the initial state, representing infestation that occurred before the robot arrived. Q2 models spread more intuitively through a continuous process that increases pressure on all adjacent plots at 0.2 per time unit. When pressure reaches 1, the get-infested event fires and that plot's neighbors immediately begin accumulating pressure too, creating a cascade. For this to be meaningful, time must genuinely pass during the plan which is why movement and treatment are modelled as processes with events rather than instantaneous actions. Without this, all actions would execute at t=0 and spread would never be a real threat. Durative actions could have achieved similar timing effects, but ENHSP does not support mixing durative actions with processes and events.

### Trade-offs between local treatment and global containment
Local treatment means addressing the nearest or most immediately infested plot. Global containment means prioritizing plots that protect the largest area of the field. These two are not always aligned, and limited capacity forces the robot to choose between them. In Q1 Problem 1, local and global treatment coincide there is only one infested plot, so treating it is both the local and global optimal choice. In Q1 Problem 2, the robot skips p2 which is the closest infested plot and treats p3 instead, because p3 is the bottleneck adjacent to the critical plot p5. This is global containment over local treatment. However, the planner does not reason globally in any general sense. It chooses p3 because the goal explicitly requires (not (infested p5)), and treating p3 is the only way to satisfy that constraint given capacity 1. Goal structure encodes global priorities, and the planner satisfies them. Capacity is central to this trade-off. With capacity 1, the robot must make a meaningful choice. With capacity 2, it would treat both p2 and p3, eliminating the prioritization decision entirely. Resource constraints are therefore what make containment strategy interesting and necessary. In Q2 Problem 2, the same tension appears. The planner treats p4 before p3 despite p3 being the original outbreak, because p4 is adjacent to the critical plot p5. Intervention order matters as much as intervention choice.

### Limitations of representing biological spread with deterministic processes
Real pest infestation spread is influenced by many factors, for example wind, soil conditions, pest species, temperature, and crop density. None of which are captured in this model. Several specific limitations are worth noting.
First, spread rate is uniform across all plots and all time steps. In reality, spread from a heavily infested plot would be faster than from a lightly infested one, and environmental conditions would cause variation between neighboring plots.
Second, the fixed infestation threshold of 1.0 means all plots behave identically. A more realistic model would allow different plots to have different thresholds meaning some crops are more resistant than others. Similarly, treatment time is fixed regardless of how infested a plot is. A severely infested plot realistically takes longer to treat than a lightly pressured one.
Third, the model is entirely deterministic. Given the same initial state, the outcome is always identical. Real biological spread is probabilistic. A plot adjacent to an infested neighbor may or may not become infested depending on conditions that are difficult to predict. A more faithful model would require probabilistic planning or stochastic processes, which are beyond the scope of PDDL+.
Finally, the model assumes the robot's knowledge of the field is complete once inspection has occurred. In reality, infestation can develop in previously healthy plots between inspections, requiring repeated surveying. Which is a dynamic feature that is only partially captured in Q2 through the suspected predicate being reset after recovery.