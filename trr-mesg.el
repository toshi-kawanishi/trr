;;; trr-message.el - (C) 1996 Yamamoto Hirotaka <ymmt@is.s.u-tokyo.ac.jp>
;;; Last modified on Sun Jun 30 03:11:31 1996

;; This file is a part of TRR19, a type training package for Emacs19.
;; See the copyright notice in trr.el.base

(eval-when-compile
  ;; Shut Emacs' byte-compiler up
  (setq byte-compile-warnings '(redefine callargs)))

;; $B%a%C%;!<%8$O0J2<$NJQ?t$NCM$K$h$C$F7h$a$i$l$k!#(B
;; $B2K$J?M$,8=$l$F$b$C$HE,@Z$J%a%C%;!<%8BN7O$r9=C[$7$F$/$l$k$3$H$rK>$`!#(B
;; TRR decide its messages according to the following variables.
;; I hope you build more proper messaging system.

;; TRR:beginner-flag         $B=i$a$F(B TRR $B$r$7$?$+$I$&$+(B
;;			     whether this is the first play or not
;; TRR:random-flag           $B%F%-%9%H$,%i%s%@%`$+$I$&$+(B
;;			     whether random selecting is enabled or not
;; TRR:update-flag           $B5-O?99?7$7$?$+$I$&$+(B
;;			     whether there's necessity of updating high scores
;; TRR:pass-flag             $B%9%F%C%W$r%Q%9$7$?$+$I$&$+(B
;;			     whether the player achieved the mark point
;; TRR:secret-flag           $BHkL)<g5A<T$+$I$&$+(B
;;			     whether TRR won't record the player's score or not
;; TRR:cheat-flag            $B2?$i$+$N5?$o$7$-9T0Y$r$7$?$+$I$&$+(B
;;			     whether there's something doubtful or not
;; TRR:typist-flag           $B%?%$%T%9%H$rL\;X$9$+$I$&$+(B
;;			     whether TRR runs in typist mode or not
;; TRR:steps                 $B8=:_$N%9%F%C%W(B
;;			     the player's current step
;; TRR:eval                  $B:#2s=P$7$?E@?t(B
;;			     the player's current mark
;; TRR:whole-char-count      $B%F%-%9%H$NJ8;z?t(B
;;			     the number of characters in the text
;; TRR:high-score-old        $BA02s$^$G$N:G9bF@E@(B
;;			     the previous high score record
;; TRR:high-score            $B:#2s$^$G$N:G9bF@E@(B
;;			     high score record
;; TRR:miss-type-ratio       $B%_%9N((B ($B@iJ,N((B)
;;			     miss type ratio
;; TRR:type-speed            $B%?%$%T%s%0B.EY!JJ8;z?t!?J,!K(B
;;			     the number of characters typed per minute
;; TRR:total-times           $B:#$^$G$NN_@Q<B9T2s?t(B
;;			     the total number of TRR trials
;; TRR:total-time            $B:#$^$G$NN_@Q<B9T;~4V(B
;;			     the total time spends in TRR trials
;; TRR:times-for-message     $B$3$N%9%F%C%W$G$NN_@Q<B9T2s?t(B
;;			     the total number of TRR trials in the current step


(defun TRR:print-first-message-as-result ()
  (insert  (if TRR:japanese
	       " $B$h$&$3$=(BTRR$B$N@$3&$X!*(B\n\
 $BCk5Y$_$d;E;v$N8e$K!"(B\n\
 $B0?$$$O;E;v$N:GCf$K$b(B\n\
 $B4hD%$C$F(BTRR$B$KNe$b$&!*(B"
	     " Welcome to TRR world! \n\
 Let's play TRR\n\
 After lunch, class,\n\
 Even during works!")))


(defun TRR:print-message ()
  (let ((fill-column (- (window-width) 3)))
    (delete-region (point-min) (point-max))
    (insert "  ")
    (TRR:print-message-main)
    (fill-region (point-min) (point-max))
    (goto-char (point-min))))


(defun TRR:print-message-main ()
  (let ((diff (- (* (1+ TRR:steps) 10) TRR:eval)))
    (cond
     (TRR:cheat-flag
      (TRR:message-for-cheater))
     (TRR:secret-flag
      (TRR:message-for-secret-player))
     (TRR:typist-flag
      (TRR:message-for-typist))
     (TRR:beginner-flag
      (TRR:message-for-beginner))
     ((and TRR:update-flag TRR:pass-flag)
      (insert
       (format (if TRR:japanese
		   "$B%9%F%C%W(B%d$BFMGK$=$7$F5-O?99?7$*$a$G$H$&!#(B"
		 "Great. You've cleared the step %d with the new record!")
	       TRR:steps))
      (if (< (% TRR:high-score 100) (% TRR:high-score-old 100))
	  (progn
	    (TRR:message-specially-for-record-breaker))
	(TRR:message-for-record-breaker))
      (setq TRR:high-score-old TRR:high-score))
     (TRR:update-flag
      (insert (if TRR:japanese
		  "$B5-O?99?7$*$a$G$H$&!*(B"
		"Congratulations! You've marked the new record!"))
      (TRR:message-for-record-breaker)
      (setq TRR:high-score-old TRR:high-score))
     (TRR:pass-flag
      (insert
       (format (if TRR:japanese
		   "$B%9%F%C%W(B%d$BFMGK$*$a$G$H$&!#(B"
		 "Nice! You've cleared the step %d.")
	       TRR:steps))
      (TRR:message-for-success))
     ((= TRR:eval 0)
      (insert (if TRR:japanese
		  "$B#0E@$J$s$FCQ$:$+$7$$$o!#$b$C$HEXNO$7$J$5$$!#(B"
		"Arn't you ashmed of having marked such an amazing score 0!")))
     ((< diff  60)
      (TRR:message-for-failed-one-1 diff))
     ((or (< diff 100) (> TRR:miss-type-ratio 30))
      (TRR:message-for-failed-one-2 diff))
     (t
      (TRR:message-for-failed-one-3 diff)))))


(defun TRR:message-for-cheater ()
  (cond 
   ((> TRR:eval 750)
    (insert (if TRR:japanese
		"$B$=$s$J$3$H$G$$$$$N!)CQ$rCN$j$J$5$$!#(B"
	      "Aren't you ashamed of having done such a thing?")))
   ((< TRR:whole-char-count 270)
    (insert (if TRR:japanese
		"$BH\61$h!#%F%-%9%H$,>/$J2a$.$k$o!#$=$l$G$&$l$7$$!)(B"
	      "That's not fair! Too few letters in the text!")))
   ((and (< TRR:whole-char-count 520) TRR:typist-flag)
    (insert (if TRR:japanese
		"$BH\61$h!#%F%-%9%H$,>/$J2a$.$k$o!#$=$l$G$&$l$7$$!)(B"
	      "That's not fair! Too few letters in the text!")))))


(defun TRR:message-for-secret-player ()
  (cond
   (TRR:pass-flag
    (setq TRR:secret-flag nil)
    (setq TRR:update-flag nil)
    (setq TRR:beginner-flag nil)
    (TRR:print-message-main)
    (setq TRR:secret-flag t))
   ((> TRR:eval 300)
    (insert (if TRR:japanese
		"$B$3$s$J9b$$F@E@$r=P$9J}$,$I$&$7$FHkL)$K$7$F$*$/$N!)(B"
	      "What a good typist you are! You'd unveil your score.")))
   ((> TRR:eval 200)
    (insert (if TRR:japanese
		"$B6H3&I8=`$r1[$($F$k$o!#HkL)$K$9$kI,MW$OA4$/$J$$$o$h!#(B"
	      "Your score now reaches to the World standard. Go out public TRR world!")))
   ((> TRR:eval 120)
    (insert (if TRR:japanese
		"$BCQ$:$+$7$/$J$$E@$@$o!#HkL)$K$9$k$N$O$b$&$d$a$^$7$g$&!#(B"
	      "Good score! Put an end to play in this secret world.")))
   (t
    (insert (if TRR:japanese
		"$B8x3+$9$k$H$A$g$C$HCQ$:$+$7$$E@$@$o!#$7$P$i$/HkL)$GB3$1$^$7$g$&!#(B"
	      "Keep your score secret for a while.")))))


(defun TRR:message-for-beginner ()
  (cond
   ((= TRR:eval 0)
    (insert (if TRR:japanese
		"$B#0E@$H$$$&$N$OLdBj$@$o!#$3$l$+$i$+$J$j$NEXNO$,I,MW$h!#F;$N$j$OD9$$$1$I4hD%$j$^$7$g$&!#(B"
	      "0point... hopeless it is! You have to do much effort to step your level up.")))
   ((< TRR:eval 40)
    (insert (if TRR:japanese
		"$B>/$J$/$H$b1QJ8;z$0$i$$$O@dBP3P$($k$3$H!#6H3&I,?\$N(B100$BE@$K8~$1$F$3$l$+$i4hD%$j$^$7$g$&!#(B"
	      "You need to learn at least the position of the alphabet keys. Set your sights on 100pt: the World indispensable point.")))
   ((< TRR:eval 80)
    (insert (if TRR:japanese
		"$B%-!<G[CV$bBgJ,3P$($?$h$&$@$1$I$^$@$^$@$@$o!#6H3&I,?\$N(B100$BE@$K8~$1$F$3$l$+$i4hD%$j$^$7$g$&!#(B"
	      "Yes, you've learned the positions of keys; but still more! Set your sights on 100pt: the World indispensable point.")))
   ((< TRR:eval 130)
    (insert (if TRR:japanese
		"$B4pACE*$J5;=Q$O?H$KIU$1$F$$$k$h$&$@$1$I$^$@$^$@$@$o!#6H3&I8=`$N(B200$BE@$K8~$1$F$3$l$+$i4hD%$j$^$7$g$&!#(B"
	      "You've learned some basic techniques; but still more! Go forward to 200pt: the World standard point.")))
   ((< TRR:eval 180)
    (insert (if TRR:japanese
		"$B$J$+$J$+$N<BNO$M!#$G$b%9%T!<%I$H@53N$5$,>/$7B-$j$J$$$o!#6H3&I8=`$N(B200$BE@$K8~$1$F$b$&>/$74hD%$j$^$7$g$&!#(B"
	      "Your typing skill is rather high. More speedy & exactly! Go forward to 200pt: the World standard point.")))
   ((< TRR:eval 280)
    (insert (if TRR:japanese
		"$B$J$+$J$+$d$k$o$M!#$b$&>/$74hD%$l$P6H3&L\I8$N(B300$BE@$r$-$C$HFMGK$G$-$k$o!#(B"
	      "Nice. With some effort, you will surely reach 300pt: the World highly standard.")))
   ((< TRR:eval 380)
    (insert (if TRR:japanese
		"$B$9$4$$$o$M!#=i$a$F$G$3$l$0$i$$=P$;$l$P==J,$@$o!#$G$b6H3&0lN.$N(B400$BE@$K8~$1$F$b$&>/$74hD%$j$^$7$g$&!#(B"
	      "Great. You have had sufficient skill. But push yourself to 400pt: the World firstclass.")))
   ((< TRR:eval 480)
    (insert (if TRR:japanese
		"$B$9$C$4$$!*$3$s$JE@$r=P$9?M$OLGB?$K$$$J$$$o$h!#$R$g$C$H$7$F%W%m$G$O$J$$$+$7$i!)(B"
	      "Wonderful score! You may be a proffesional typist?")))
   (t
    (insert (if TRR:japanese
		"$B$"$^$j$K$bD6?ME*$@$o!#$-$C$H%.%M%9%V%C%/$K:\$k$o$h!#(B"
	      "Too high score. You are sure to get a entry of the Guiness Book.")))))


(defun TRR:message-for-success ()
  (cond
   ((>= (- TRR:eval (* 10 (1+ TRR:steps))) 100)
    (insert (if TRR:japanese
		"$B$"$J$?$K$O4JC12a$.$?$h$&$M!#(B"
	      "This step must have been quite easy for you.")))
   ((<= TRR:times-for-message 2)
    (insert (if TRR:japanese
		"$B7Z$/FMGK$7$?$o$M!#(B"
	      "You made it effortlessly.")))
   ((<= TRR:times-for-message 4)
    (insert (if TRR:japanese
		"$B$o$j$H4JC1$KFMGK$7$?$o$M!#(B"
	      "You made it!")))
   ((<= TRR:times-for-message 8)
    (insert (if TRR:japanese
		"$B$A$g$C$H$F$3$:$C$?$h$&$M!#(B"
	      "You carried out with a little trouble.")))
   ((<= TRR:times-for-message 16)
    (insert (if TRR:japanese
		"$B$@$$$V$F$3$:$C$?$h$&$M!#(B"
	      "With much trouble, you accomplished this step's mark!")))
   ((<= TRR:times-for-message 32)
    (insert (if TRR:japanese
		"$B$h$/4hD%$C$?$o$M!#(B"
	      "You've sweat it out. Nice record.")))
   ((<= TRR:times-for-message 64)
    (insert (if TRR:japanese
		"$B?oJ,6lO+$7$?$h$&$M!#(B"
	      "You've had a very hard time.")))
   ((<= TRR:times-for-message 128)
    (insert (if TRR:japanese
		"$B6l$7$_$L$$$?$o$M!#(B"
	      "You've gone through all sorts of hardships. ")))
   (t
    (insert 
     (format (if TRR:japanese
		 "%d$B2s$bD)@o$9$k$J$s$F$9$4$$$o!#<9G0$G$d$j$H$2$?$o$M!#(B"
	       "You've challenged this step %d times. Great efforts! ")
	     TRR:times-for-message)))))


(defun TRR:message-for-failed-one-1 (diff)
  (cond 
   ((< diff 10)
    (insert (if TRR:japanese
		"$B$"$H$[$s$N>/$7$@$C$?$N$K(B....$BK\Ev$K@K$7$+$C$?$o$M!#(B"
	      "Your score is slightly lower than the mark... How maddening!")))
   ((< diff 20)
    (insert (if TRR:japanese
		"$B@K$7$+$C$?$o$M!#(B"
	      "Disappointing!")))
   ((< diff 30)
    (insert (if TRR:japanese
		"$B$=$ND4;R$h!#(B"
	      "That's it!")))
   ((< diff 40)
    (insert (if TRR:japanese
		"$B$b$&0lB)$@$o!#$G$bB)H4$-$O$@$a$h!#(B"
	      "Just one more effort. Don't goof off!")))
   ((< diff 50)
    (insert (if TRR:japanese
		"$B4hD%$l$P$-$C$H$G$-$k$o!#(B"
	      "With much effort, and you will make it.")))
   (t
    (insert (if TRR:japanese
		"$BEXNO$"$k$N$_$h!#(B"
	      "What you have to do is nothing but making all possible effort.")))))


(defun TRR:message-for-failed-one-2 (diff)
  (cond 
   ((> TRR:miss-type-ratio 60)
    (insert (if TRR:japanese
		"$B%_%9$,$"$^$j$K$bB?2a$.$k$+$i%@%a$J$N$h!#$H$K$+$/@53N$KBG$DN}=,$KNe$_$J$5$$!#$b$&$=$l$7$+J}K!$O$J$$$o!#(B"
	      "Your hopeless point is based on your enormous misses! Practice the typing paying attention to correctness of typing keys.")))
   ((> TRR:miss-type-ratio 40)
    (insert (if TRR:japanese
		"$B%_%9$,B?2a$.$k$o!#=i?4$K5"$C$F0l$D0l$D?5=E$KBG$DN}=,$r$7$J$5$$!#(B"
	      "Too many wrong types! Remember your original purpose.")))
   ((> TRR:miss-type-ratio 24)
    (insert (if TRR:japanese
		"$B%_%9$,B?$$$o!#@53N$KBG$DN}=,$r$7$J$5$$!#(B"
	      "You failed frequently. Type accurate!")))
   ((> TRR:miss-type-ratio  8)
    (insert (if TRR:japanese
		"$BN}=,$KN}=,$r=E$M$J$5$$!#(B"
	      "Keep in practice.")))
   (t
    (insert (if TRR:japanese
		"$B@53N$KBG$C$F$k$h$&$@$1$I%9%T!<%I$,CY$9$.$k$o!#B.$/BG$DN}=,$KNe$_$J$5$$!#(B"
	      "You typed accurately, but too slow! Type more quickly.")))))


(defun TRR:message-for-failed-one-3 (diff)
  (cond 
   ((< diff 110)
    (insert (if TRR:japanese
		"$B!V(BTRR$B$NF;$O0lF|$K$7$F$J$i$:!W(B"
	      "\"TRR was not built in a day.\"")))
   ((< diff 120)
    (insert (if TRR:japanese
		"$B!V(BTRR$B$K2&F;$J$7!W(B"
	      "\"There is no royal road to TRRing.\"")))
   ((< diff 130)
    (insert
     (format (if TRR:japanese
		 "$B$"$i$^$!!#(B%d$BE@$r=P$7$??M$,$?$C$?$N(B%d$BE@$J$s$F$$$C$?$$$I$&$7$?$N$h!#(B"
	       "Oh, no! Your best is %d, however marked %d point this time! What on earth be with you?")
	     TRR:high-score TRR:eval)))
   ((< diff 140)
    (insert
     (format (if TRR:japanese
		 "%d$BE@$O$^$0$l$@$C$?$N!)(B"
	       "Is the fact once you marked %d point an illusion?")
	     TRR:high-score)))
   (t
    (insert (if TRR:japanese
		"$B$"$J$?$N<BNO$C$F$3$NDxEY$@$C$?$N$M!#(B"
	      "Your real ability is no more than this point. isn't it?")))))


(defun TRR:message-specially-for-record-breaker ()
  (cond 
   ((< TRR:high-score-old 100)
    (insert (if TRR:japanese
		"$B$D$$$K6H3&I,?\$N(B100$BE@FMGK$M!*$3$l$+$i$O6H3&I8=`$N(B200$BE@$rL\;X$7$F4hD%$j$^$7$g$&!#(B"
	      "Congratulations! You reaches 100pt: the World indispensable. Next your target is 200pt: the World standard.")))
   ((< TRR:high-score-old 200)
    (insert (if TRR:japanese
		"$B$D$$$K6H3&I8=`$N(B200$BE@FMGK$M!*$3$l$+$i$O6H3&L\I8$N(B300$BE@$rL\;X$7$F4hD%$j$^$7$g$&!#(B"
	      "Congratulations! You reaches 200pt: the World standard. Next your target is 300pt: the World highly standard.")))
   ((< TRR:high-score-old 300)
    (insert (if TRR:japanese
		"$B$D$$$K6H3&L\I8$N(B300$BE@FMGK$M!*$3$l$+$i$O6H3&0lN.$N(B400$BE@$rL\;X$7$F4hD%$j$^$7$g$&!#(B"
	      "Congratulations! You reaches 300pt: the World highly standard. Next your target is 400pt: the World firstclass.")))
   ((< TRR:high-score-old 400)
    (insert (if TRR:japanese
		"$B$D$$$K6H3&0lN.$N(B400$BE@FMGK$M!*$3$l$+$i$O6H3&D60lN.$N(B500$BE@$rL\;X$7$F4hD%$j$^$7$g$&!#(B"
	      "Congratulations! You reaches 400pt: the World firstclass. Next your target is 500pt: the world superclass.")))
   ((< TRR:high-score-old 500)
    (insert (if TRR:japanese
		"$B$D$$$K6H3&D60lN.$N(B500$BE@FMGK$M!*$3$l$+$i$O6H3&D:E@$N(B600$BE@$rL\;X$7$F4hD%$j$^$7$g$&!#(B"
	      "Congratulations! You reaches 500pt: the world superclass. Next your target is 600pt: the World supreme.")))
   (t
    (insert (if TRR:japanese
		"$B$"$J$?$N$h$&$J$9$4$$?M$O=i$a$F$h!#%W%m$K$J$l$k$o!#(B"
	      "You are the most marvelous typist I've ever met. The title \"TRRer\" suits you well!")))))


(defun TRR:message-for-record-breaker ()
  (cond
   ((< TRR:high-score  67)
    (insert (if TRR:japanese
		"$B6H3&I,?\$N(B100$BE@;X$7$F4hD%$C$F!#(B"
	      "Keep aiming at 100pt: the World indispensable.")))
   ((< TRR:high-score 100)
    (insert (if TRR:japanese
		"$B6H3&I,?\$N(B100$BE@$^$G$b$&$9$0$h!#(B"
	      "You are close to 100pt: the World indispensable.")))
   ((< TRR:high-score 167)
    (insert (if TRR:japanese
		"$B6H3&I8=`$N(B200$BE@L\;X$7$F4hD%$C$F!#(B"
	      "Keep aiming at 200pt: the World standard.")))
   ((< TRR:high-score 200)
    (insert (if TRR:japanese
		"$B6H3&I8=`$N(B200$BE@$^$G$b$&$9$0$h!#(B"
	      "You are close to 200pt: the World standard.")))
   ((< TRR:high-score 267)
    (insert (if TRR:japanese
		"$B6H3&L\I8$N(B300$BE@L\;X$7$F4hD%$C$F!#(B"
	      "Keep aiming at 300pt: the World highly standard.")))
   ((< TRR:high-score 300)
    (insert (if TRR:japanese
		"$B6H3&L\I8$N(B300$BE@$^$G$b$&$9$0$h!#(B"
	      "You are close to 300pt: the World highly standard.")))
   ((< TRR:high-score 367)
    (insert (if TRR:japanese
		"$B6H3&0lN.$N(B400$BE@L\;X$7$F4hD%$C$F!#(B"
	      "Keep aiming at 400pt: the World firstclass.")))
   ((< TRR:high-score 400)
    (insert (if TRR:japanese
		"$B6H3&0lN.$N(B400$BE@$^$G$b$&$9$0$h!#(B"
	      "You are close to 400pt: the World firstclass.")))
   ((< TRR:high-score 467)
    (insert (if TRR:japanese
		"$B6H3&D60lN.$N(B500$BE@L\;X$7$F4hD%$C$F!#(B"
	      "Keep aiming at 500pt: the world superclass.")))
   ((< TRR:high-score 500)
    (insert (if TRR:japanese
		"$B6H3&D60lN.$N(B500$BE@$^$G$b$&$9$0$h!#(B"
	      "You are close to 500pt: the world superclass.")))
   ((< TRR:high-score 567)
    (insert (if TRR:japanese
		"$B6H3&D:E@$N(B600$BE@$^$GL\;X$7$F4hD%$C$F!#(B"
	      "Keep aiming at 600pt: the World supreme.")))
   ((< TRR:high-score 600)
    (insert (if TRR:japanese
		"$B6H3&D:E@$N(B600$BE@$^$G$b$&$9$0$h!#(B"
	      "You are close to 600pt: the World supreme.")))
   (t
    (insert (if TRR:japanese
		"$B$h$/$3$3$^$G$d$k$o$M!#$"$J$?$NL\I8$O0lBN2?$J$N!)(B"
	      "What is interesting to you? What you are aiming at?")))))


(defun TRR:message-for-typist ()
  (cond
   (TRR:beginner-flag
    (insert (if TRR:japanese
		"$B%?%$%T%9%H$X$NF;$O81$7$$$o$h!#>/$J$/$H$b(B300$BE@$r%3%s%9%?%s%H$K=P$9$h$&$K4hD%$C$F!#(B"
	      "The way to the typist is severe. Keep makeing 300pt every time."))
    (setq TRR:beginner-flag nil))
   ((and TRR:pass-flag (not TRR:update-flag))
    (setq TRR:typist-flag nil)
    (TRR:print-message-main)
    (setq TRR:typist-flag t))
   ((and TRR:update-flag TRR:pass-flag)
    (insert (if TRR:japanese
		"$B5-O?99?7$=$7$F(B"
	      "You've marked a new record. And "))
    (setq TRR:typist-flag nil)
    (setq TRR:update-flag nil)
    (TRR:print-message-main)
    (setq TRR:typist-flag t))
   (TRR:update-flag (insert (if TRR:japanese
				"$B5-O?99?7$*$a$G$H$&!*(B"
			      "Nice! You've marked a new record.")))
   ((> TRR:miss-type-ratio 30)
    (insert (if TRR:japanese
		"$B$"$J$?$K$OL5M}$h!#%?%$%T%9%H$K$J$m$&$J$s$FEvJ,9M$($J$$$3$H$M!#(B"
	      "You are not up to Typist mode. Leave here for a while.")))
   ((> TRR:miss-type-ratio 20)
    (insert (if TRR:japanese
		"$B#0E@$J$s$FCQ$:$+$7$$$o$M!#$3$N6~?+$r6;$K?<$/9o$_9~$_$J$5$$!#(B"
	      "0pt! Aren't you ashamed?  Engrave this humiliation deeply engraved on my mind.")))
   ((> TRR:miss-type-ratio 15)
    (insert (if TRR:japanese
		"$B%_%9$,$"$^$j$K$bB?2a$.$k$o!#@P66$rC!$$$FEO$k$h$&$K%?%$%W$7$J$5$$!#(B"
	      "Excessively many miss types! Make assurance double sure.")))
   ((> TRR:miss-type-ratio 10)
    (insert (if TRR:japanese
		"$B%_%9$,B?2a$.$k$o!#$b$C$H?5=E$K%?%$%W$7$J$5$$!#(B"
	      "Too many typos. Type more carefully.")))
   ((> TRR:miss-type-ratio 6)
    (insert (if TRR:japanese
		"$B%_%9$,B?$$$o!#$b$C$H?5=E$K%?%$%W$7$?J}$,$$$$$o$h!#(B"
	      "Many typos. Take more care of typing.")))
   (t
    (setq TRR:typist-flag nil)
    (TRR:print-message-main)
    (setq TRR:typist-flag t))))


(provide 'trr-mesg)
;;; trr-mesg.el ends here
