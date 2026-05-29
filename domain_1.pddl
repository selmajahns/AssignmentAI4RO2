;;; Agricultural Robotics - Pest Infection Spread

(define (domain pest_infestation)

(:requirements :strips :fluents :typing :negative-preconditions)

(:types 
    plot robot
)

(:predicates 
    ; states of plots
    (healthy ?p - plot)
    (suspected ?p - plot)
    (infested ?p - plot)
    (treated ?p - plot)

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
)

(:action move
    :parameters (?r - robot ?from ?to - plot)
    :precondition (and 
        (at ?r ?from)
        (adjacent ?from ?to)
    )
    :effect (and 
        (not (at ?r ?from))
        (at ?r ?to)
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

(:action treat
    :parameters (?r - robot ?p - plot)
    :precondition (and 
        (at ?r ?p)
        (detected-infested ?p)
        (not (treated ?p)) 
        (> (capacity ?r) 0)  
    )
    :effect (and 
        (treated ?p)
        (not(infested ?p))
        (decrease (capacity ?r) 1)
    )
)

(:action report-infested
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
)