JPBRIDGE ; generic bridge
 NEW ref SET ref=$ZCMD
 NEW d SET d=$DATA(@ref) WRITE "JP:D:",d,!
 NEW v SET v=$GET(@ref) WRITE "JP:V:",v,!
 QUIT