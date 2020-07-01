function [AVGTeam1,AVGTie,AVGTeam2] =MOD_GreaterNumber(N_Games,kills,deaths,T1,T2)
k=0:100;
Total_Kills=sum(kills);
Total_Deaths=sum(deaths);
AF=kills/N_Games;
DF=deaths/N_Games;

SAF=sum(AF)/length(kills);
SDF=sum(DF)/length(deaths);

d1=(AF(T1)/SAF)*(DF(T2)/SDF)*SAF;
d2=(AF(T2)/SAF)*(DF(T1)/SDF)*SAF;

p1=poisspdf(k,d1);
p2=poisspdf(k,d2);

i=1;

while(i<max(k)+2)
    j=1;
    while (j<max(k)+2)
        R_kills(i,j)=p1(i)*p2(j);
        j=j+1;
    end
    i=i+1;
end
AVGTie=0;
AVGTeam1=0;
AVGTeam2=0;
%Tie
for i=1:max(k)+1
   AVGTie=AVGTie+R_kills(i,i);
    i=i+1;
end
%Team 2 greater num of kills
i=1;
while (i<max(k)+1)
   j=i+1;
   while(j<max(k)+1)
       AVGTeam2=AVGTeam2+R_kills(i,j);
       j=j+1;
   end
   i=i+1;
end   
%Team 1 greater num of kills
AVGTeam1=1-AVGTeam2-AVGTie;

end

