;; -----------------------------------------------------------------------------------
;; Rules for converting PLIST facts into OmniGraffle model facts
;; -----------------------------------------------------------------------------------

(defmodule PLIST->GRAFFLE    
    (import GRAFFLE ?ALL)
    (import PLIST   ?ALL)
    (import MAIN deftemplate initial-fact))

(defrule PLIST->GRAFFLE::graffle-single-sheet
    (omnigraffle (root ?root)(path ?filename))
    (not (dict-entry (id ?root)(key Sheets)))
    =>
    ; root dictionary is the only sheet
    (assert (graffle (id ?root)(path ?filename)(sheets ?root)))
    (assert (make-sheet ?root ?root)))

(defrule PLIST->GRAFFLE::graffle-multiple-sheets
    (omnigraffle (root ?root)(path ?filename))
    (dict-entry (id ?root)(key Sheets)(value ?array))
    (array (id ?array)(values $?sheets))
    =>
    (assert (graffle (id ?root)(path ?filename)(sheets $?sheets)))
    (foreach ?sheet $?sheets
        (assert (make-sheet ?sheet ?root))))
    
(defrule PLIST->GRAFFLE::make-sheet
    (make-sheet ?id ?parent)
    (dict-entry (id ?id)(key SheetTitle)(value ?title))
    (dict-entry (id ?id)(key GraphicsList)(value ?array))
    (array (id ?array)(values $?graphics))
    =>
    (assert (sheet (parent ?parent)(id ?id)(title ?title)))
    (foreach ?top-graphic $?graphics
        (assert (make-graphic ?id ?top-graphic))
        (assert (graphic-parent (parent ?id)(graphic ?top-graphic)))))

(defrule PLIST->GRAFFLE::make-group
    (make-graphic ?sheet ?id)
    (dict-entry (id ?id)(key Class)(value "Group")) 
    (not (dict-entry (id ?id)(key isSubgraph)(value ?)))
    (dict-entry (id ?id)(key Graphics)(value ?array))
    (array (id ?array)(values $?graphics))
    =>
    (assert (group (id ?id)))
    (foreach ?graphic $?graphics
        (assert (make-graphic ?sheet ?graphic))
        (assert (graphic-parent (parent ?id)(graphic ?graphic)))))

(defrule PLIST->GRAFFLE::make-subgraph
    (make-graphic ?sheet ?id)
    (dict-entry (id ?id)(key Class)(value "Group")) 
    (dict-entry (id ?id)(key isSubgraph)(value ?))
    (dict-entry (id ?id)(key Graphics)(value ?array))
    (array (id ?array)(values $?graphics))
    =>
    (assert (subgraph (id ?id)(shape (nth$ (length$ $?graphics) $?graphics))))
    (foreach ?graphic $?graphics
        (assert (make-graphic ?sheet ?graphic))
        (assert (graphic-parent (parent ?id)(graphic ?graphic)))))

(defrule PLIST->GRAFFLE::link-to-sheet
    (make-graphic ?sheet ?id)
    (make-sheet ?sheet ?root)
    (graffle (id ?root)(sheets $?sheets))
    (dict-entry (id ?id)(key Link)(value ?link))
    (dict-entry (id ?link)(key documentJump)(value ?jump))
    (dict-entry (id ?jump)(key Type)(value 6))
    (dict-entry (id ?jump)(key Worksheet)(value ?sheet-index))
    =>
    (assert (link (from ?id)(sheet (nth$ (+ ?sheet-index 1) $?sheets)))))

(defrule PLIST->GRAFFLE::graphic-notes
    (make-graphic ?sheet ?id)
    (dict-entry (id ?id)(key Notes)(value ?notes))
    =>
    (assert (meta-notes (id ?id)(notes ?notes))))

(defrule PLIST->GRAFFLE::graphic-property
    (make-graphic ?sheet ?id)
    (dict-entry (id ?id)(key UserInfo)(value ?info))
    (dict-entry (id ?info)(key ?key)(value ?value))
    =>
    (assert (meta-prop (id ?id)(key ?key)(value ?value))))

(defrule PLIST->GRAFFLE::sheet-notes
    (dict-entry (id ?sheet)(key BackgroundGraphic)(value ?bgg))
    (dict-entry (id ?bgg)(key Notes)(value ?notes))
    =>
    (assert (meta-notes (id ?sheet)(notes ?notes))))

(defrule PLIST->GRAFFLE::sheet-property
    (dict-entry (id ?sheet)(key BackgroundGraphic)(value ?bgg))
    (dict-entry (id ?bgg)(key UserInfo)(value ?info))
    (dict-entry (id ?info)(key ?key)(value ?value))
    =>
    (assert (meta-prop (id ?sheet)(key ?key)(value ?value))))
    
(defrule PLIST->GRAFFLE::make-graphic-shape
    (make-graphic ?sheet ?id)
    (dict-entry (id ?id)(key Class)(value "ShapedGraphic"))
    (dict-entry (id ?id)(key Shape)(value ?type))    
    (dict-entry (id ?id)(key Bounds)(value ?bounds))
    (array (id ?bounds)(values ?x ?y ?w ?h))
    =>
    (assert (shape (id ?id)(type ?type)))
    (assert (bounds (id ?id)(x ?x)(y ?y)(w ?w)(h ?h))))

(defrule PLIST->GRAFFLE::default-graphic-shape-type
    (dict-entry (id ?id)(key Class)(value "ShapedGraphic"))
    (not (dict-entry (id ?id)(key Shape)(value ?type)))
    =>
    (assert (dict-entry (id ?id)(key Shape)(value "Rectangle"))))
    
(defrule PLIST->GRAFFLE::make-graphic-text
    (make-graphic ?sheet ?id)
    (dict-entry (id ?id)(key Text)(value ?txt-id))    
    (dict-entry (id ?txt-id)(key Text)(value ?text))
    =>
    (assert (shape-text (id ?id)(text ?text))))

(defrule PLIST->GRAFFLE::shape-fill-color
    (make-graphic ?sheet ?id)
    (dict-entry (id ?id)(key Style)(value ?style))    
    (dict-entry (id ?style)(key fill)(value ?fill))
    (dict-entry (id ?fill)(key Color)(value ?color))
    (dict-entry (id ?color)(key r)(value ?red))
    (dict-entry (id ?color)(key g)(value ?green))
    (dict-entry (id ?color)(key b)(value ?blue))
    =>
    (assert (fill-color (id ?id) 
                        (r (string-to-field ?red))
                        (g (string-to-field ?green))
                        (b (string-to-field ?blue)))))

(defrule PLIST->GRAFFLE::stroke-color
    (make-graphic ?sheet ?id)
    (dict-entry (id ?id)(key Style)(value ?style))    
    (dict-entry (id ?style)(key stroke)(value ?stroke))
    (dict-entry (id ?stroke)(key Color)(value ?color))
    (dict-entry (id ?color)(key r)(value ?red))
    (dict-entry (id ?color)(key g)(value ?green))
    (dict-entry (id ?color)(key b)(value ?blue))
    =>
    (assert (stroke-color (id ?id)
                          (r (string-to-field ?red))
                          (g (string-to-field ?green))
                          (b (string-to-field ?blue)))))

(defrule PLIST->GRAFFLE::dashed-stroke
    (make-graphic ?sheet ?id)
    (dict-entry (id ?id)(key Style)(value ?style))    
    (dict-entry (id ?style)(key stroke)(value ?stroke))
    (dict-entry (id ?stroke)(key Pattern)(value ?pat&:(> ?pat 0)))
    =>
    (assert (dashed (id ?id))))

(defrule PLIST->GRAFFLE::line-label
    (shape (id ?id)(type ?))
    (make-graphic ?sheet ?id)
    (dict-entry (id ?id)(key Line)(value ?label))
    (dict-entry (id ?label)(key ID)(value ?line))
    (dict-entry (id ?label)(key Position)(value ?posn))
    (make-graphic ?sheet ?line-id)
    (dict-entry (id ?line-id)(key ID)(value ?line))
    =>
    (assert (line-label (line ?line-id)(shape ?id)(posn ?posn))))

(defrule PLIST->GRAFFLE::make-graphic-line
    (make-graphic ?sheet ?id)
    (dict-entry (id ?id)(key Class)(value "LineGraphic"))
    =>
    (assert (line (id ?id))))

(defrule PLIST->GRAFFLE::line-head-arrow
    (line (id ?id))
    (dict-entry (id ?id)(key Style)(value ?style))    
    (dict-entry (id ?style)(key stroke)(value ?stroke))
    (dict-entry (id ?stroke)(key HeadArrow)(value ?arrow))
    =>
    (assert (head-arrow (id ?id)(type ?arrow))))

(defrule PLIST->GRAFFLE::line-tail-arrow
    (line (id ?id))
    (dict-entry (id ?id)(key Style)(value ?style))    
    (dict-entry (id ?style)(key stroke)(value ?stroke))
    (dict-entry (id ?stroke)(key TailArrow)(value ?arrow))
    =>
    (assert (tail-arrow (id ?id)(type ?arrow))))

(defrule PLIST->GRAFFLE::head-connection
    (make-graphic ?sheet ?id)
    (dict-entry (id ?id)(key Head)(value ?head))    
    (dict-entry (id ?head)(key ID)(value ?target))    
    (dict-entry (id ?target-id)(key ID)(value ?target))
    (make-graphic ?sheet ?target-id)  ; graphic is same sheet as line
    =>
    (assert (connection (end head)(from ?id)(to ?target-id))))

(defrule PLIST->GRAFFLE::tail-connection
    (make-graphic ?sheet ?id)
    (dict-entry (id ?id)(key Tail)(value ?tail))    
    (dict-entry (id ?tail)(key ID)(value ?target))    
    (dict-entry (id ?target-id)(key ID)(value ?target))
    (make-graphic ?sheet ?target-id)  ; graphic is same sheet as line
    =>
    (assert (connection (end tail)(from ?id)(to ?target-id))))


;; -----------------------------------------------------------------------------------
;; Constructs and Eval
;; - text of shapes with "construct" note are passed to the build function
;; - text of shapes with "eval" note are passed to the eval function
;; -----------------------------------------------------------------------------------

(defrule PLIST->GRAFFLE::shape-construct
    (meta-notes (id ?id)(notes "construct"))
    (shape-text (id ?id)(text ?text))
    => 
    (build ?text))

(defrule PLIST->GRAFFLE::shape-eval
    (meta-notes (id ?id)(notes "eval"))
    (shape-text (id ?id)(text ?text))
    => 
    (eval ?text))

;; -----------------------------------------------------------------------------------
;; Tables
;; -----------------------------------------------------------------------------------

(defrule PLIST->GRAFFLE::make-table
    (make-graphic ?sheet ?id)
    (dict-entry (id ?id)(key Class)(value "TableGroup")) 
    (dict-entry (id ?id)(key Graphics)(value ?array))
    (array (id ?array)(values $?graphics))
    =>
    (assert (table (id ?id)))
    (foreach ?graphic $?graphics
        (assert (make-graphic ?sheet ?graphic))
        (assert (graphic-parent (parent ?id)(graphic ?graphic)))))

(defrule PLIST->GRAFFLE::make-table-rows
    (make-graphic ?sheet ?table)
    (dict-entry (id ?table)(key GridH)(value ?grid))
    (array (id ?grid)(values $?rows))
    =>
    (bind ?row-ids (create$))
    (foreach ?row (subseq$ $?rows 1 (- (length$ $?rows) 1)) ; last array is empty/bogus 
        (if (symbolp ?row) then
            (bind ?row-ids (create$ ?row-ids ?row)) ; append
            (assert (make-cells ?sheet ?row))
          else 
            ; row is a single integer graphic id - make it an array
            (bind ?new-id (gensym))
            (bind ?row-ids (create$ ?row-ids ?new-id)) ; append            
            (assert (array (id ?new-id)(values ?row)))
            (assert (make-cells ?sheet ?new-id))))
    (assert (rows (id ?table)(cells ?row-ids))))

(defrule PLIST->GRAFFLE::make-table-cols
    (make-graphic ?sheet ?table)
    (dict-entry (id ?table)(key GridV)(value ?grid))
    (array (id ?grid)(values $?cols))
    =>
    (bind ?col-ids (create$))
    (foreach ?col (subseq$ $?cols 1 (- (length$ $?cols) 1)) ; last array is empty/bogus 
        (if (symbolp ?col) then
            (bind ?col-ids (create$ ?col-ids ?col)) ; append
            (assert (make-cells ?sheet ?col))
          else 
            ; col is a single integer graphic id - make it an array
            (bind ?new-id (gensym))
            (bind ?col-ids (create$ ?col-ids ?new-id)) ; append            
            (assert (array (id ?new-id)(values ?col)))
            (assert (make-cells ?sheet ?new-id))))
    (assert (cols (id ?table)(cells ?col-ids))))

(defrule PLIST->GRAFFLE::make-cells
    (make-cells ?sheet ?array-id)
    (array (id ?array-id)(values $?gids))
    =>
    (bind ?graphics (create$))
    (foreach ?gid $?gids
        (do-for-fact 
            ((?mg make-graphic)(?de dict-entry))
            (and (eq (nth$ 1 ?mg:implied) ?sheet)
                 (eq (nth$ 2 ?mg:implied) (nth$ 1 ?de:implied))
                 (eq (nth$ 2 ?de:implied) ID)
                 (eq (nth$ 3 ?de:implied) ?gid))
            (bind ?graphics (create$ ?graphics (nth$ 2 ?mg:implied))))) ; append     
    (assert (cells (id ?array-id)(shapes ?graphics))))

;; -----------------------------------------------------------------------------------
;; Overlapping and containment
;; -----------------------------------------------------------------------------------

(deffunction PLIST->GRAFFLE::between (?v ?a ?b)
    (and (>= ?v ?a)
         (<= ?v ?b)))

(deffunction PLIST->GRAFFLE::overlaps (?x1 ?y1 ?w1 ?h1 ?x2 ?y2 ?w2 ?h2)
    (bind ?r1 (+ ?x1 ?w1))
    (bind ?r2 (+ ?x2 ?w2))
    (bind ?b1 (+ ?y1 ?h1))
    (bind ?b2 (+ ?y2 ?h2))
    (and (or (between ?x1 ?x2 ?r2)
             (between ?r1 ?x2 ?r2))
         (or (between ?y1 ?y2 ?b2)
             (between ?b1 ?y2 ?b2))))

(defrule PLIST->GRAFFLE::shapes-overlap
    (not (no-containment))
    (sheet (parent ?)(id ?sheet)(title ?))
    (graphic-parent (parent ?sheet)(graphic ?id1))
    (graphic-parent (parent ?sheet)(graphic ?id2&:(neq ?id2 ?id1)))
    (bounds (id ?id1)(x ?x1)(y ?y1)(w ?w1)(h ?h1))
    (bounds (id ?id2)(x ?x2)(y ?y2)(w ?w2)(h ?h2))
    (not (overlaps (id1 ?id2)(id2 ?id1)))  ;; ensure one direction
    (test (overlaps ?x1 ?y1 ?w1 ?h1 ?x2 ?y2 ?w2 ?h2))
    =>
    (assert (overlaps (id1 ?id1)(id2 ?id2))))

(deffunction PLIST->GRAFFLE::contains (?x1 ?y1 ?w1 ?h1 ?x2 ?y2 ?w2 ?h2)
    (bind ?r1 (+ ?x1 ?w1))
    (bind ?r2 (+ ?x2 ?w2))
    (bind ?b1 (+ ?y1 ?h1))
    (bind ?b2 (+ ?y2 ?h2))
    (and (or (and (>= ?x2 ?x1)
                  (< ?r2 ?r1))
             (and (> ?x2 ?x1)
                  (<= ?r2 ?r1)))
         (or (and (>= ?y2 ?y1)
                  (< ?b2 ?b1))
             (and (> ?y2 ?y1)
                  (<= ?b2 ?b1)))))    

(defrule PLIST->GRAFFLE::shape-containment
    (not (no-containment))
    (sheet (parent ?)(id ?sheet)(title ?))
    (graphic-parent (parent ?sheet)(graphic ?id1))
    (graphic-parent (parent ?sheet)(graphic ?id2&:(neq ?id2 ?id1)))
    (bounds (id ?id1)(x ?x1)(y ?y1)(w ?w1)(h ?h1))
    (bounds (id ?id2)(x ?x2)(y ?y2)(w ?w2)(h ?h2))
    (test (contains ?x1 ?y1 ?w1 ?h1 ?x2 ?y2 ?w2 ?h2))
    =>
    (assert (contains (outer ?id1)(inner ?id2))))

(defrule PLIST->GRAFFLE::nested-containment "detect unwanted nested containment"
    (not (verbose-containment))
    (contains (outer ?p1)(inner ?p2))
    (contains (outer ?p2)(inner ?k))
    ?r <- (contains (outer ?p1)(inner ?k))
    =>
    (assert (nested-contains ?r)))

(defrule PLIST->GRAFFLE::prune-nested-contains
    (declare (salience -1000))
    ?nc <- (nested-contains ?r)
    =>
    (retract ?r)
    (retract ?nc))

(defrule PLIST->GRAFFLE::prune-overlap-when-contains
    (declare (salience -1000))
    (or (contains (outer ?p1)(inner ?p2))
        (contains (outer ?p2)(inner ?p1)))
    ?overlaps <- (overlaps (id1 ?p1)(id2 ?p2))
    =>
    (retract ?overlaps))

;; -----------------------------------------------------------------------------------
;; Clean up
;; -----------------------------------------------------------------------------------
(defrule PLIST->GRAFFLE::cleanup-plist
    (declare (salience -1000))
    (not (leave-plist))
    => 
    (do-for-all-facts 
        ((?f omnigraffle dict-entry array)) 
        TRUE 
        (retract ?f)))

(defrule PLIST->GRAFFLE::cleanup-graffle 
    (declare (salience -1000)) 
    => 
    (do-for-all-facts 
        ((?f make-graphic make-sheet make-cells)) 
        TRUE 
        (retract ?f)))
