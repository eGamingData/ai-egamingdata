format short
clear
%---------------------------------
%CONFIGURATION
%---------------------------------
%Data
selection=[1];
FIRST_DRAKE=1;
FIRST_TOWER=2;
FIRST_BLOOD=3;
NUMBER_KILLS=4;
NUMBER_DEATHS=5;
%Configuration
opts = configureJDBCDataSource("Vendor","MySQL");
opts = setConnectionOptions(opts,"DataSourceName","MySQL","Server","146.148.2.232","PortNumber",3306,"JDBCDriverLocation","C:\Users\usuario\Desktop\mysql-connector-java-8.0.20\mysql-connector-java-8.0.20.jar");
username= "root";
password= "Qwertyuiop7*";
datasource = "MySQL";
status= testConnection(opts,username,password);
saveAsJDBCDataSource(opts)
conn = database(datasource, username, password);
%---------------------------------
%OBTINING EVENTS DATA
%---------------------------------
query=("SELECT league, team_one, team_two FROM egamingdata.lol_events");
events=table2array(fetch(conn,query));
a=length(events);
for k=1:a
    %Conection at data base
    league=events(k,1);
    queryteams= strcat("SELECT acronym FROM"," egamingdata.lol_teams WHERE league= "+"'"+league+"'");
    acronyms=table2array(fetch(conn,queryteams));
    queryteams= strcat("SELECT team FROM"," egamingdata."+league);
    teams=table2array(fetch(conn,queryteams));
    %---------------------------------
    %OBTINING DATA FROM DATA BASE
    %---------------------------------
    %First Drake
    lg=("SELECT firstdragon FROM egamingdata.raw_data WHERE firstdragon=1 AND league="+"'"+league+"'");
    query= strcat(lg," AND team = ?");
    pstmt= databasePreparedStatement (conn, query);
    for i = 1:10
        pstmt = bindParamValues(pstmt,selection,teams(i));
        result= fetch(conn,pstmt);
        useful_data(i,FIRST_DRAKE)= height(result);
        i=i+1;
    end
    %First Tower
    lg=("SELECT firsttower FROM egamingdata.raw_data WHERE firsttower=1 AND league="+"'"+league+"'");
    query= strcat(lg," AND team = ?");
    pstmt= databasePreparedStatement (conn, query);
    for i = 1:10
        pstmt = bindParamValues(pstmt,selection,teams(i));
        result= fetch(conn,pstmt);
        useful_data(i,FIRST_TOWER)= height(result);
        i=i+1;
    end
    %First Blood
    lg=("SELECT firstbloodkill FROM egamingdata.raw_data WHERE firstbloodkill=1 AND league="+"'"+league+"'");
    query= strcat(lg," AND team = ?");
    pstmt= databasePreparedStatement (conn, query);
    for i = 1:10
        pstmt = bindParamValues(pstmt,selection,teams(i));
        result= fetch(conn,pstmt);
        useful_data(i,FIRST_BLOOD)= height(result);
        i=i+1;
    end
    %Number of kills
    lg=("SELECT teamkills FROM egamingdata.raw_data WHERE league="+"'"+league+"'");
    query= strcat(lg," AND team = ? AND player is NULL ");
    pstmt= databasePreparedStatement (conn, query);
    for i = 1:10
        pstmt = bindParamValues(pstmt,selection,teams(i));
        result=  table2array(fetch(conn,pstmt));    
        useful_data(i,NUMBER_KILLS)= sum(result);
        Kills(i)=sum(result);
        i=i+1;
    end
    %Number of Deaths
    lg=("SELECT teamdeaths FROM egamingdata.raw_data WHERE league="+"'"+league+"'");
    query= strcat(lg," AND team = ? AND player is NULL ");
    pstmt= databasePreparedStatement (conn, query);
    for i = 1:10
        pstmt = bindParamValues(pstmt,selection,teams(i));
        result=  table2array(fetch(conn,pstmt));    
        useful_data(i,NUMBER_DEATHS)= sum(result);
        Deaths(i)=sum(result);
        i=i+1;
    end
    %---------------------------------
    %OBTINING ESTADISTICS
    %---------------------------------
    %Selecting team
    team1=find(acronyms==string(events(k,2)));
    team2=find(acronyms==string(events(k,3)));
    %Number of games
    Num_Games=sum(useful_data)/(length(useful_data)/2);
    Num_Games=Num_Games(1,1);
    %Estadistics of first drake
    AVG_t1_fd=useful_data(team1,FIRST_DRAKE)./Num_Games;
    AVG_t2_fd=useful_data(team2,FIRST_DRAKE)./Num_Games;
    [RESULT_fd(1),RESULT_fd(2)]=MOD_FirstIn(AVG_t1_fd,AVG_t2_fd);
    %Estadistics of first tower
    AVG_t1_ft=useful_data(team1,FIRST_TOWER)./Num_Games;
    AVG_t2_ft=useful_data(team2,FIRST_TOWER)./Num_Games;
    [RESULT_ft(1),RESULT_ft(2)]=MOD_FirstIn(AVG_t1_ft,AVG_t2_ft);
    %Estadistics of first Blood
    AVG_t1_fb=useful_data(team1,FIRST_BLOOD)./Num_Games;
    AVG_t2_fb=useful_data(team2,FIRST_BLOOD)./Num_Games;
    [RESULT_fb(1),RESULT_fb(2)]=MOD_FirstIn(AVG_t1_fb,AVG_t2_fb);
    %Estadistics Greater Num. of kills
    [RESULT_GTN_Kills(1),RESULT_GTN_Kills(2),RESULT_GTN_Kills(3)]=MOD_GreaterNumber(Num_Games,Kills,Deaths,team1,team2);

    %---------------------------------
    %GRAFIC REPRESENTATION
    %---------------------------------
%     tiledlayout(2,2);
%     nexttile; 
%     pie3(RESULT_fd);
%     title('First Drake');
%     labels=[teams(team1), teams(team2)];
%     legend(labels,'Location','southoutside','Orientation','horizontal');
%     nexttile; 
%     pie3(RESULT_ft);
%     title('First Tower');
%     labels=[teams(team1), teams(team2)];
%     legend(labels,'Location','southoutside','Orientation','horizontal');
%     nexttile; 
%     pie3(RESULT_fb);
%     title('First Blood');
%     labels=[teams(team1), teams(team2)];
%     legend(labels,'Location','southoutside','Orientation','horizontal');
%     nexttile; 
%     pie3(RESULT_GTN_Kills);
%     title('Greater Number of kills');
%     labels=[teams(team1),'Tie', teams(team2)];
%     legend(labels,'Location','southoutside','Orientation','horizontal');

    %---------------------------------
    %EXPORT DATA
    %---------------------------------
    %Insert First Drake Results
    colnames={'league','mo_type','team_one','result_team_one','team_two','result_team_two'};
    insertdata={league,'mo_fd',teams(team1),round(RESULT_fd(1),2),teams(team2),round(RESULT_fd(2),2)};
    fastinsert(conn,'egamingdata.lol_models',colnames,insertdata);
    %Insert First Tower
    colnames={'league','mo_type','team_one','result_team_one','team_two','result_team_two'};
    insertdata={league,'mo_ft',teams(team1),round(RESULT_ft(1),2),teams(team2),round(RESULT_ft(2),2)};
    fastinsert(conn,'egamingdata.lol_models',colnames,insertdata);
    %Insert First Blood
    colnames={'league','mo_type','team_one','result_team_one','team_two','result_team_two'};
    insertdata={league,'mo_fb',teams(team1),round(RESULT_fb(1),2),teams(team2),round(RESULT_fb(2),2)};
    fastinsert(conn,'egamingdata.lol_models',colnames,insertdata);
    %Insert First Blood
    colnames={'league','mo_type','team_one','result_team_one','result_tie','team_two','result_team_two'};
    insertdata={league,'mo_gnk',teams(team1),round(RESULT_GTN_Kills(1),2),round(RESULT_GTN_Kills(2),2),teams(team2),round(RESULT_GTN_Kills(3),2)};
    fastinsert(conn,'egamingdata.lol_models',colnames,insertdata);
    
    k=k+1;
end

