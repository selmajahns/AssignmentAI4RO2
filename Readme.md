## Basic PDDL model

in spec:
    - states of plot: healthy, suspected, infested, treated
    - actions: inspect, treat, move, report

Design choices made:
    - Inspect -> effect needs to be either healthy or infested. Therefore modelled as inspect-and-finds-healthy and inspect-and-finds-infested.
    - Chose to model partial knowlegde: each inspect action results to detected-healthy or detected-infested.
    Detected-infested is then a precondition for treating a plot. -> robot needs to know it is infested before treating.
    - Report -> also needs two: report-healthy and report-infested, both result in reported. Report-healthy will only be used if the goal spesify that that plot needs to be reported. 

Problem files: 
    - Problem 1: localized infection. One infested plot and simple treat. 
    Design choices: 
        - Chosen to only have three plots to illustrate the localized infection. 
        p1 - p2 - p3
        - p3 is infested and all plots are suspected (partial knowlegde). robot starts in p1.
        note: planner never actually consider inspect-and-finds-healthy because it knows p3 is infested (limitation of partial knowlegde).
    - Problem 2: multiple plots threathed. Now chose to set iinfested and suspected at start or have timed-initial infested -> which means plot gets infested at a spesific time, if not treated.