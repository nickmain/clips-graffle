;; -----------------------------------------------------------------------------------
;; Fact templates for PLists
;; -----------------------------------------------------------------------------------
(defmodule PLIST
    (export deftemplate ?ALL))

(deftemplate PLIST::file-error "An error when loading a file"
    (slot path (type STRING)(default ?NONE))
    (slot msg  (type STRING)(default ?NONE)))

(deftemplate PLIST::plist-error "An error when parsing a PList"
    (slot path (type STRING)(default ?NONE))
    (slot msg  (type STRING)(default ?NONE)))

(deftemplate PLIST::omnigraffle "An Omnigraffle PList"
    (slot root (type SYMBOL)(default ?NONE))  ; id of root dictionary
    (slot path (type STRING)(default ?NONE)))

(deftemplate PLIST::dict-entry "An entry in a PList dictionary"
    (slot id    (type SYMBOL)(default ?NONE)) 
    (slot key   (type LEXEME)(default ?NONE))
    (slot value (default ?NONE)))

(deftemplate PLIST::array "A PList array"
    (slot id (type SYMBOL)(default ?NONE)) 
    (multislot values))