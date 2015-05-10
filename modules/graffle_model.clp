;; -----------------------------------------------------------------------------------
;; Graffle Model Fact Templates
;; -----------------------------------------------------------------------------------

(defmodule GRAFFLE    
    (export deftemplate ?ALL))

(deftemplate GRAFFLE::graffle "root of a graffle document"
    (slot id   (type SYMBOL)(default ?NONE))
    (slot path (type STRING))
    (multislot sheets (type SYMBOL)(cardinality 1 ?VARIABLE)))

(deftemplate GRAFFLE::sheet "page of a graffle document"
    (slot parent (type SYMBOL)(default ?NONE))
    (slot id     (type SYMBOL)(default ?NONE))    
    (slot title  (type STRING)(default ?NONE)))

(deftemplate GRAFFLE::graphic-parent "link between graphic and its parent"
    (slot parent  (type SYMBOL)(default ?NONE))
    (slot graphic (type SYMBOL)(default ?NONE)))

(deftemplate GRAFFLE::group "a group graphic"
    (slot id (type SYMBOL)(default ?NONE)))

(deftemplate GRAFFLE::subgraph "a subgraph group graphic"
    (slot id    (type SYMBOL)(default ?NONE))
    (slot shape (type SYMBOL)(default ?NONE))) ; the background shape

(deftemplate GRAFFLE::shape "a shape graphic"
    (slot id   (type SYMBOL)(default ?NONE))
    (slot type (type LEXEME)(default ?NONE)))

(deftemplate GRAFFLE::line "a line graphic"
    (slot id (type SYMBOL)(default ?NONE)))

(deftemplate GRAFFLE::table "a table group graphic"
    (slot id (type SYMBOL)(default ?NONE)))

(deftemplate GRAFFLE::rows "the rows of a table"
    (slot id (type SYMBOL)(default ?NONE)) ; table id
    (multislot cells (type SYMBOL)(cardinality 1 ?VARIABLE))) ; the cells of each row

(deftemplate GRAFFLE::cols "the columns of a table"
    (slot id (type SYMBOL)(default ?NONE)) ; table id
    (multislot cells (type SYMBOL)(cardinality 1 ?VARIABLE))) ; the cells of each column

(deftemplate GRAFFLE::cells "the cells of a row or column"
    (slot id (type SYMBOL)(default ?NONE)) 
    (multislot shapes (type SYMBOL)(cardinality 1 ?VARIABLE))) ; the shape ids

(deftemplate GRAFFLE::bounds "the bounds of a shape"
    (slot id (type SYMBOL)(default ?NONE)) ; shape id
    (slot x  (type NUMBER))
    (slot y  (type NUMBER))
    (slot w  (type NUMBER))
    (slot h  (type NUMBER)))

(deftemplate GRAFFLE::shape-text "the text of a shape"
    (slot id   (type SYMBOL)(default ?NONE)) ; shape id
    (slot text (type STRING)))

(deftemplate GRAFFLE::fill-color "the color of a shape"
    (slot id (type SYMBOL)(default ?NONE)) ; shape id
    (slot r  (type NUMBER))
    (slot g  (type NUMBER))
    (slot b  (type NUMBER)))

(deftemplate GRAFFLE::stroke-color "the stroke color of a shape or line"
    (slot id (type SYMBOL)(default ?NONE)) ; shape/line id
    (slot r  (type NUMBER))
    (slot g  (type NUMBER))
    (slot b  (type NUMBER)))

(deftemplate GRAFFLE::dashed "indicates that a shape or line has a dashed stroke"
    (slot id (type SYMBOL)(default ?NONE))) ; shape/line id

(deftemplate GRAFFLE::line-label "indicates a shape used as a line label"
    (slot line  (type SYMBOL)(default ?NONE)) ; line id
    (slot shape (type SYMBOL)(default ?NONE)) ; shape id
    (slot posn  (type NUMBER))) ; position of label (0 =< posn <= 1)
    
(deftemplate GRAFFLE::head-arrow "arrow type for line"
    (slot id   (type SYMBOL)(default ?NONE)) ; line id
    (slot type (type LEXEME)(default ?NONE)))

(deftemplate GRAFFLE::tail-arrow "arrow type for line"
    (slot id   (type SYMBOL)(default ?NONE)) ; line id
    (slot type (type LEXEME)(default ?NONE)))

(deftemplate GRAFFLE::meta-notes "notes metadata for a graphic or sheet"
    (slot id    (type SYMBOL)(default ?NONE)) ; graphic or sheet id
    (slot notes (type STRING)(default ?NONE)))

(deftemplate GRAFFLE::meta-prop "property metadata for a graphic or sheet"
    (slot id    (type SYMBOL)(default ?NONE)) ; graphic or sheet id
    (slot key   (type LEXEME)(default ?NONE))
    (slot value))

(deftemplate GRAFFLE::connection "connection from a shape or line to another graphic"
    (slot from (type SYMBOL)(default ?NONE)) ; shape or line id
    (slot to   (type SYMBOL)(default ?NONE)) ; target graphic id
    (slot end  (allowed-symbols head tail))) ; which end of the shape/line is connected

(deftemplate GRAFFLE::link "hyperlink from a graphic to a sheet"
    (slot from  (type SYMBOL)(default ?NONE))  ; origin id
    (slot sheet (type SYMBOL)(default ?NONE))) ; target sheet id

(deftemplate GRAFFLE::overlaps "indicates that a top-level shape overlaps another"
    (slot id1 (type SYMBOL)(default ?NONE)) 
    (slot id2 (type SYMBOL)(default ?NONE)))

(deftemplate GRAFFLE::contains "indicates that a top-level shape contains another"
    (slot outer (type SYMBOL)(default ?NONE)) 
    (slot inner (type SYMBOL)(default ?NONE)))

(deftemplate GRAFFLE::leave-plist "requests that PLIST facts should not be cleaned up")

(deftemplate GRAFFLE::no-containment "requests that overlaps/contains facts not be determined")

(deftemplate GRAFFLE::verbose-containment 
    "requests that contains facts between all ancestors/descendants remain - otherwise
     they are cleaned up, leaving only parent/child relationships")