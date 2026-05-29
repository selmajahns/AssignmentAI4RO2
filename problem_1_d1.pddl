(define (problem localized_problem) (:domain pest_infestation)
(:objects 
    r - robot
    p1 p2 p3 - plot
)

(:init
    (adjacent p1 p2)
    (adjacent p2 p1)
    (adjacent p2 p3)
    (adjacent p3 p2)

    ; only capacity for treating one plot
    (at r p1)
    (= (capacity r) 1)

    ; partial knowlegde
    (suspected p1)
    (suspected p2)
    (suspected p3)

    ; ground truth, only one plot is infested
    (infested p3)
    (healthy p1)
    (healthy p2)
)

(:goal (and
    (treated p3)
    (reported p3)
))

(:metric minimize (total-time))
)
