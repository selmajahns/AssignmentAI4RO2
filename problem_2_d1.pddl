(define (problem multiple_plots_threatened) (:domain pest_infestation_Q1)
(:objects 
    r - robot 
    p1 p2 p3 p4 p5 - plot
)

; p1 - p2 - p3 - p4
;           |
;           p5

(:init
    (adjacent p1 p2)
    (adjacent p2 p1)

    (adjacent p2 p3)
    (adjacent p3 p2)

    (adjacent p3 p4)
    (adjacent p4 p3)

    (adjacent p3 p5)
    (adjacent p5 p3)
    
    (at r p1)
    (= (capacity r) 1)

    ; partial knowlegde
    (suspected p2)
    (suspected p3)

    ; ground truth
    (healthy p1)
    (infested p2)
    (infested p3)
    (healthy p4)
    (healthy p5)
)

(:goal (and
    (treated p3) 
    (not (infested p5))
    (reported p3)
))

(:metric minimize (total-time))
)
