(define (problem problem_2) (:domain pest_infestation_Q2)
(:objects 
    r - robot 
    p1 p2 p3 p4 p5 - plot
)

; p1 — p2 — p3 — p4 — p5
(:init
    (adjacent p1 p2)
    (adjacent p2 p1)

    (adjacent p2 p3)
    (adjacent p3 p2)

    (adjacent p3 p4)
    (adjacent p4 p3)

    (adjacent p5 p4)
    (adjacent p4 p5)

    (at r p1)
    (= (capacity r) 2)

    ; partial knowlegde
    (suspected p3)

    ; ground truth
    (healthy p1)
    (infested p3)
    (healthy p4)
    (healthy p2)
    (healthy p5)

    (= (pressure p2) 0)
    (= (pressure p1) 0)
    (= (pressure p3) 1)
    (= (pressure p4) 0.4)
    (= (pressure p5) 0)

    (= (move-progress r) 0)
)

(:goal (and
    (not(infested p5))
    (treated p3)
    (reported p3)
    (treated p4)
    (reported p4)
))


(:metric minimize (total-time))
)
