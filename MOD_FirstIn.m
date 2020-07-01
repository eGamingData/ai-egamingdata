function [AVGTeam1,AVGTeam2] = MOD_FirstIn(PROBTeam1,PROBTeam2)
%AVGTeam1 and AVGTeam2 are the average of the first dragons for every team
%PROBTeam1 and PROBTEAM" are the probability of every team of doing
%the first something.  
    AVGTeam1=PROBTeam1/(PROBTeam1+PROBTeam2);
    AVGTeam2=1-AVGTeam1;
end

