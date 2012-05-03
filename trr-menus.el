;;; trr-menus - (C) 1996 Yamamoto Hirotaka <ymmt@is.s.u-tokyo.ac.jp>
;;; Last modified on Mon Jul  1 00:10:59 1996

;; This file is a part of TRR19, a type training package for Emacs19.
;; See the copyright notice in trr.el.base

(eval-when-compile
  ;; Shut Emacs' byte-compiler up
  (setq byte-compile-warnings '(redefine callargs)))


;; answer getting function
(defun TRR:get-answer (string1 string2 max)
  (let ((answer (string-to-int (read-from-minibuffer string1))))
    (while (or (<= answer 0) (> answer max))
      (message string2)
      (sleep-for 1.2)
      (setq answer (string-to-int (read-from-minibuffer string1))))
    answer))


;; menus definition
(defun TRR:select-text ()
  (delete-other-windows)
  (switch-to-buffer (get-buffer-create (TRR:trainer-menu-buffer)))
  (erase-buffer)
  (insert-file-contents TRR:select-text-file)
  (untabify (point-min) (point-max))
  (goto-char (point-min))
  (let ((kill-whole-line t))
    (while (not (eobp))
      (if (or (= (char-after (point)) 35) ; comment begins with #
	      (= (char-after (point)) 10))
	  (kill-line)
	(forward-line))))
  (goto-char (point-min))
  (let ((num 1) max-num)
    (while (not (eobp))
      (insert 
       (format "%4d. " num))
      (while (not (= (char-after (point)) 32)) (forward-char))
      (while      (= (char-after (point)) 32)  (forward-char))
      (while (not (= (char-after (point)) 32)) (forward-char))
      (while      (= (char-after (point)) 32)  (forward-char)) ; need comment
      (while (not (= (char-after (point)) 32)) (forward-char))
      (kill-line)
      (forward-line 1)
      (setq num (1+ num)))
    (setq max-num num)
    (goto-char (point-min))
    (if TRR:japanese
	(insert (TRR:current-trr)
		"$B8~$1%?%$%W%H%l!<%J!<!'(B\n\n$B%F%-%9%H$NA*Br!'(B\n")
      (insert "TRR for " (TRR:current-trr) ": \n\nChoose a text: \n"))
    (goto-char (point-max))
    (insert (if TRR:japanese
		(concat "\n\n  $B2?$+F~$l$FM_$7$$(B document $B$,$"$l$P(B\n "
			TRR:installator
			" $B$^$G$*Ld$$9g$o$;2<$5$$!#(B\n")
	      (concat "\n  If you have some document to use in TRR, consult with\n "
		      TRR:installator
		      "\n")))
    (insert (if TRR:japanese
		"\n$B3F<o$N@_Dj!'(B\n  97. TRR$B$N=*N;(B\n  98. $B@_DjCM$NJQ99(B\n"
	      "\nSet up: \n  97. Quit TRR\n  98. Change options.\n"))
    (if (not TRR:skip-session-flag)
	(insert (if TRR:japanese
		    "  99. $B%F%-%9%HA*Br8e%a%K%e!<2hLL$K0\9T(B\n"
		  "  99. move to menu after choose a text\n"))
      (insert (if TRR:japanese
		  "\n$B%F%-%9%HA*Br8e%a%K%e!<2hLL$K0\9T(B"
		"\nmove to menu after choose a text")))
    (setq num 
	  (if TRR:japanese
	      (TRR:get-answer "$B$I$l$K$9$k!)(B " "$B$O$C$-$j$7$J$5$$!*(B" 99)
	    (TRR:get-answer "Input an integer: " "Don't hesitate!" 99)))
    (if (and (or (< num 0) (> num max-num))
	     (/= num 97)
	     (/= num 98)
	     (or TRR:skip-session-flag
		 (/= num 99)))
	(setq num (if TRR:japanese
		      (TRR:get-answer "$B$b$&0lEYA*$s$G(B "
				      "$B%F%-%9%H$7$+A*$Y$J$$$o(B"
				      max-num)
		    (TRR:get-answer "Choose again: "
				    "Text is the only way left to you!"
				    max-num))))
    (cond
     ((= num 97) (setq TRR:quit-flag t))
     ((= num 98) (TRR:change-flag) (TRR:select-text))
     ((= num 99)
      (setq TRR:skip-session-flag t)
      (TRR:select-text))
     (t
      (TRR:decide-trr-text num)
      (TRR:initiate-files)
      (TRR:initiate-variables)
      (TRR:print-log)
      (TRR:print-data)
      (bury-buffer)
      (set-window-configuration TRR:win-conf)))))


(defun TRR:change-flag (&optional loop)
  (delete-other-windows)
  (switch-to-buffer (get-buffer-create (TRR:trainer-menu-buffer)))
  (erase-buffer)
  (let (num)
    (insert (if TRR:japanese
		(concat "\
$B<!$NCf$+$iA*$s$G2<$5$$!#(B\n\
\n\
1. $B=i5i<T8~$1$N%?%$%W%H%l!<%J(B\n\
   $BI>2A4X?t$O!JBGJ8;z?t!]!J8mBG?t!v#1#0!K!K!v#6#0!?!JIC?t!K(B\n\
   $B%F%-%9%H$O%9%F%C%WKh$KF1$8$b$N$rI=<((B\n\
\n\
2. $BCf5i<T8~$1$N%?%$%W%H%l!<%J!J%G%U%)!<%k%H$O$3$l$K@_Dj$5$l$k!K(B\n\
   $BI>2A4X?t$O!JBGJ8;z?t!]!J8mBG?t!v#1#0!K!K!v#6#0!?!JIC?t!K(B\n\
\n\
3. $B>e5i<T8~$1$N%?%$%W%H%l!<%J(B\n\
   $BI>2A4X?t$O!JBGJ8;z?t!]!J8mBG?t!v#5#0!K!K!v#6#0!?!JIC?t!K(B\n\
   $B#12s$N<B9T$GI,MW$J%?%$%WNL$,B?$$(B\n\
\n\
4. $BHkL)<g5A<T8~$1$N%?%$%W%H%l!<%J(B\n\
   $B=i5i<T8~$1$N%?%$%W%H%l!<%J$HF1$8$G$"$k$,!"(B\n\
   $B%O%$%9%3%"$NEPO?$r9T$J$o$J$$(B\n\
\n"
			(if TRR:return-is-space
			    "5. [toggle] $B9TKv$N%j%?!<%s$O%9%Z!<%9$GBeBX$G$-$k(B\n\n"
			  "5. [toggle] $B9TKv$N%j%?!<%s$O%j%?!<%s$r2!$5$J$1$l$P$J$i$J$$(B\n\n")
			"\
6. [toggle] $B%a%C%;!<%8$OF|K\8l$GI=<((B\n\n"
			(if TRR:ding-when-miss
			    "7. [toggle] $B4V0c$($?;~$K(B ding($B2;$rLD$i$9(B) $B$9$k(B\n\n"
			  "7. [toggle] $B4V0c$($?;~$K(B ding($B2;$rLD$i$9(B) $B$7$J$$(B\n\n")
			(if TRR:un-hyphenate
			    "8. [toggle] $B%O%$%U%M!<%H$5$l$?C18l$r85$KLa$9(B\n"
			  "8. [toggle] $B%O%$%U%M!<%7%g%s$r;D$7$?$^$^$K$9$k(B\n"))
	      (concat "Select a number (1 - 8)\n\n\
1. TRR for Novice.\n\
The function which evaluate your score is,\n\
(key - (wrong * 10)) * 60 / time\n\
where key is the number of your key stroke,\n\
wrong is the number of your miss type, and\n\
time is the seconds that is taken your finishing typing the text.\n\
In every STEP, TRR shows the same text.\n\
\n\
2. TRR for Trainee.\n\
The function which evaluate your score is the same as Novice.\n\
This is the default level.\n\
\n\
3. TRR for Typist.\n\
The function which evaluate your score is,\n\
(key - (wrong * 50)) * 60 / time\n\
In this level you have to type much more than Trainee or Novice.\n\
\n\
4. TRR in Secret mode.\n\
same as Novice, except that your score won't be recorded\n\
in Score-file.\n\n"
(if TRR:return-is-space
    "5. If select, TRR will require that you type RET for the return code\n\
at the end of a line.\n\n"
  "5. If select, TRR will allow you to type SPC for the return code\n\
at the end of a line.\n\n")
"6. [toggle] Display messages in English\n\n"
(if TRR:ding-when-miss
    "7. Make TRR shut when miss-type\n\n"
  "7. Make TRR ding when miss-type\n\n")
(if TRR:un-hyphenate
    "8. [toggle] deny hyphenation from text\n"
    "8. [toggle] leave hyphenated words untouched\n"))))
  (setq num (if TRR:japanese
                (TRR:get-answer "$B$I$l$K$9$k!)(B " "$B$$$C$?$$$I$l$K$9$k$N!)(B" 8)
                (TRR:get-answer "which do you want to change? "
                                "Don't waver!" 8)))
  (cond
   ((= num 1)
    (setq TRR:random-flag nil)
    (setq TRR:typist-flag nil)
    (setq TRR:secret-flag nil))
   ((= num 2)
    (setq TRR:random-flag t)
    (setq TRR:typist-flag nil)
    (setq TRR:secret-flag nil))
   ((= num 3)
    (setq TRR:random-flag t)
    (setq TRR:typist-flag t)
    (setq TRR:secret-flag nil))
   ((= num 4)
    (setq TRR:random-flag nil)
    (setq TRR:typist-flag nil)
    (setq TRR:secret-flag t))
   ((= num 5)
    (setq TRR:return-is-space (not TRR:return-is-space))
    (TRR:change-flag t))
   ((= num 6)
    (TRR:finish t)
    (setq TRR:japanese (not TRR:japanese))
    (TRR:prepare-buffers)
    (TRR:change-flag t))
   ((= num 7)
    (setq TRR:ding-when-miss (not TRR:ding-when-miss))
    (TRR:change-flag t))
   ((= num 8)
    (setq TRR:un-hyphenate (not TRR:un-hyphenate))
    (TRR:change-flag t)))
  (if (not loop)
      (progn
        (switch-to-buffer (get-buffer-create (TRR:trainer-menu-buffer)))
        (let* ((height (- (window-height) 5))
	       (text-buffer-height (1+ (- (/ height 2) (% (/ height 2) 3)))))
          (if TRR:typist-flag
	      (setq TRR:text-lines (/ (1- (window-height)) 3))
            (setq TRR:text-lines (/ (1- text-buffer-height) 3))))))))


(defun TRR:select-menu ()
  (set-buffer (get-buffer-create (TRR:trainer-menu-buffer)))
  (erase-buffer)
  (if TRR:japanese
      (insert "\
 1. $B=*N;(B               2. $B<B9T(B                3. $B%O%$%9%3%"(B\n\
 4. $BJ?6QB.EY%0%i%U(B     5. $BJ?6Q%_%9N(%0%i%U(B    6. $BJ?6QF@E@%0%i%U(B\n\
 7. $B<B9T;~4V%0%i%U(B     8. $B<B9T2s?t%0%i%U(B      9. $BFMGKE@?t%0%i%U(B\n\
10. $B2a5n$N@.@S(B        11. $B%F%-%9%H$NJQ99(B     12. $B@_Dj$NJQ99(B")
    (insert "\
 1. Quit	       2. Execute again	       3. High Scores\n\
 4. Typing Speed Graph 5. Freq. of Typo Graph  6. Score Graph\n\
 7. Time Graph	       8. Num. of Trial Graph  9. Breaking Score Graph\n\
10. Past results      11. Choose another text 12. Change options"))
  (let ((num (if TRR:japanese
		 (TRR:get-answer "$B$I$&$9$k$N!)(B " "$B$O$C$-$j$7$J$5$$!*(B" 12)
	       (TRR:get-answer "What do you want to do? "
			       "Commit yourself!" 12))))
    (cond
     ((= num 1) (setq TRR:quit-flag t) nil)
     ((= num 2) 
      (TRR:read-file) ;  Read next text
      t)
     ((= num 3)
      (set-window-configuration TRR:win-conf-display)
      (switch-to-buffer (get-buffer-create (TRR:display-buffer)))
      (TRR:show-ranking)
      (TRR:select-menu))
     ((= num 4)
      (set-window-configuration TRR:win-conf-display)
      (switch-to-buffer (get-buffer-create (TRR:display-buffer)))
      (TRR:get-graph-points)
      (TRR:write-graph TRR:list-of-speed TRR:skipped-step
		       (concat (if TRR:japanese
				   "$B%9%F%C%W!]J?6Q%9%T!<%I!JJ8;z!?J,!K%0%i%U(B"
				 "STEP <-> SPEED(type / minute) Graph")
			       "\t" TRR:text-name))
      (TRR:select-menu))
     ((= num 5)
      (set-window-configuration TRR:win-conf-display)
      (switch-to-buffer (get-buffer-create (TRR:display-buffer)))
      (TRR:get-graph-points)
      (TRR:write-graph TRR:list-of-miss TRR:skipped-step
		       (concat (if TRR:japanese
				   "$B%9%F%C%W!]J?6Q%_%9N(!J(B/1000$B!K%0%i%U(B"
				 "STEP <-> avg.Miss-ratio(/1000) Graph")
			       "\t" TRR:text-name))
      (TRR:select-menu))
     ((= num 6)
      (set-window-configuration TRR:win-conf-display)
      (switch-to-buffer (get-buffer-create (TRR:display-buffer)))
      (TRR:get-graph-points)
      (TRR:write-graph TRR:list-of-average TRR:skipped-step
		       (concat (if TRR:japanese
				   "$B%9%F%C%W!]J?6QF@E@%0%i%U(B"
				 "STEP <-> avg.SCORE Graph")
			       "\t" TRR:text-name))
      (TRR:select-menu))
     ((= num 7)
      (set-window-configuration TRR:win-conf-display)
      (switch-to-buffer (get-buffer-create (TRR:display-buffer)))
      (TRR:get-graph-points)
      (TRR:write-graph TRR:list-of-time TRR:skipped-step
		       (concat (if TRR:japanese
				   "$B%9%F%C%W!]<B9T;~4V!JJ,!K%0%i%U(B"
				 "STEP <-> TIME(min) Graph")
			       "\t" TRR:text-name))
      (TRR:select-menu))
     ((= num 8)
      (set-window-configuration TRR:win-conf-display)
      (switch-to-buffer (get-buffer-create (TRR:display-buffer)))
      (TRR:get-graph-points)
      (TRR:write-graph TRR:list-of-times TRR:skipped-step
		       (concat (if TRR:japanese
				   "$B%9%F%C%W!]<B9T2s?t%0%i%U(B"
				 "STEP <-> times (the number of execution of TRR) Graph")
			       "\t" TRR:text-name))
      (TRR:select-menu))
     ((= num 9)
      (set-window-configuration TRR:win-conf-display)
      (set-buffer (get-buffer-create (TRR:display-buffer)))
      (TRR:get-graph-points)
      (TRR:write-graph TRR:list-of-value TRR:skipped-step
		       (concat (if TRR:japanese
				   "$B%9%F%C%W!]FMGKE@?t%0%i%U(B"
				 "STEP <-> ACHIEVEMENT_SCORE Graph")
			       "\t" TRR:text-name))
      (TRR:select-menu))
     ((= num 10)
      (set-window-configuration TRR:win-conf-display)
      (set-buffer (get-buffer-create (TRR:display-buffer)))
      (TRR:print-log-for-display)
      (TRR:select-menu))
     ((= num 11)
      (TRR:save-file (TRR:record-buffer) TRR:record-file)
      (TRR:kill-file TRR:record-file)
      (TRR:kill-file TRR:score-file)
      (TRR:kill-file TRR:record-file)
      (or (zerop (length TRR:text-file-buffer))
	  (kill-buffer TRR:text-file-buffer))
      (TRR:select-text)
      (not TRR:quit-flag))
     ((= num 12)
      (TRR:save-file (TRR:record-buffer) TRR:record-file)
      (TRR:kill-file TRR:record-file)
      (TRR:kill-file TRR:score-file)
      (TRR:kill-file TRR:record-file)
      (or (zerop (length TRR:text-file-buffer))
	  (kill-buffer TRR:text-file-buffer))
      (TRR:change-flag)
      (TRR:select-text)
      (not TRR:quit-flag))
     )))


(provide 'trr-menus)
;;; trr-menus.el ends here
