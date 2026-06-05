(define (domain pest_infestation_Q2)

(:requirements :strips :fluents :typing :negative-preconditions :time)

(:types 
    plot robot
)

(:predicates 
    ; states of plots
    (healthy ?p - plot)
    (suspected ?p - plot)
    (infested ?p - plot)
    (treated ?p - plot)

    (being-treated ?p - plot)
    (moving ?r - robot ?from ?to - plot)

    (at ?r - robot ?p - plot)
    (adjacent ?p1 ?p2 - plot)
    (inspected ?p - plot)
    (reported ?p - plot)

    ; partial knowlegde
    (detected-infested ?p - plot)
    (detected-healthy ?p - plot)

)

(:functions
    (capacity ?r - robot)
    (pressure ?p - plot)
    (move-progress ?r - robot)
)

(:process spread-pressure
    :parameters (?p ?from - plot)
    :precondition (and
        (infested ?from)
        (adjacent ?from ?p)
        (not (infested ?p)))
    :effect (increase (pressure ?p) (* #t 0.2))
)

(:process treating
    :parameters (?p - plot)
    :precondition (being-treated ?p)
    :effect (decrease (pressure ?p) (* #t 0.5))
)

(:process moving
    :parameters (?r - robot ?from ?to - plot)
    :precondition (moving ?r ?from ?to)
    :effect (increase (move-progress ?r) (* #t 1))
)

(:action start-treat
    :parameters (?r - robot ?p - plot)
    :precondition (and
        (at ?r ?p)
        (detected-infested ?p)
        (not (treated ?p))
        (> (capacity ?r) 0)
    )
    :effect (and
        (decrease (capacity ?r) 1)
        (being-treated ?p)
    )
)

(:action start-move
    :parameters (?r - robot ?from ?to - plot)
    :precondition (and
        (at ?r ?from)
        (adjacent ?from ?to)
        (not (being-treated ?from))
        (not (moving ?r ?from ?to))
    )
    :effect (and
        (moving ?r ?from ?to)
        (not (at ?r ?from))
        (assign (move-progress ?r) 0)
        ) 
)

(:action inspect-and-finds-healthy
    :parameters (?r - robot ?p - plot)
    :precondition (and 
        (at ?r ?p)
        (not(inspected ?p))
        (suspected ?p)
        (healthy ?p)
    )
    :effect (and 
        (inspected ?p)
        (not(suspected ?p))
        (detected-healthy ?p)
    )
)

(:action inspect-and-finds-infested
    :parameters (?r - robot ?p - plot)
    :precondition (and 
        (at ?r ?p)
        (not(inspected ?p))
        (suspected ?p)
        (infested ?p)
    )
    :effect (and 
        (inspected ?p)
        (not(suspected ?p))
        (detected-infested ?p)
    )
)

(:action report-treated
    :parameters (?r - robot ?p - plot)
    :precondition (and 
        (at ?r ?p)
        (detected-infested ?p)
        (treated ?p))
    :effect (reported ?p)
)

(:action report-healthy
    :parameters (?r - robot ?p - plot)
    :precondition (and 
        (at ?r ?p)
        (detected-healthy ?p)
    )
    :effect (reported ?p)
)

(:event get-infested
    :parameters (?p - plot)
    :precondition (and
        (healthy ?p)
        (>= (pressure ?p) 1)
        )
    :effect (and
        (infested ?p)
        (not(healthy ?p))
        (suspected ?p)
    )
)

(:event get-treated
    :parameters (?p - plot)
    :precondition (and
        (<= (pressure ?p) 0)
        (being-treated ?p)
    )
    :effect (and
        (treated ?p)
        (not(being-treated ?p))
        (not (infested ?p))
        (healthy ?p)
        )
)

(:event get-moved
    :parameters (?r - robot ?from ?to - plot)
    :precondition (and
        (moving ?r ?from ?to)
        (>= (move-progress ?r) 1))
    :effect (and
        (at ?r ?to)
        (not (moving ?r ?from ?to))
        (assign (move-progress ?r) 0)
        )
)

)

