function ComparePlayers(p)
%P_selfish = 1;
%P_selfless= 0;
%P_collab  = 0;
p = p/sum(p);
N_Types = 6;
typeNames = ["Selfish  ","Selfless ","Collab   ","Hybrid   ","Secretive","KeepOne  "];
epsilon = 1e-8; %fudge-factor for division

N = 1000;
IDs = 1:N;
N_days = 100;
n_type = zeros(1,N_Types);
players = cell(1,N);
N_friends = 30;
 
% Create players
for n = IDs
    r = rand;
    for type = 1:N_Types
        if r<=sum(p(1:type))
            n_type(type) = n_type(type)+1;
            switch type
                case 1
                    players{n} = SelfishPlayer(n);
                case 2
                    players{n} = SelflessPlayer(n);
                case 3
                    players{n} = CollabPlayer(n);
                case 4
                    players{n} = HybridPlayer(n);
                case 5
                    players{n} = SecretivePlayer(n);
                case 6
                    players{n} = KeepOnePlayer(n);
            end
            break
        end
    end
end
% Assign friendships
%{
for n = IDs
    halfN = min(15,fix((N-1)/2));
    otherIDs = mod(n+(1:halfN)-1,N)+1;
    %each player is friends with the 15 preceding and succeeding players.
    for m = otherIDs
        %fprintf('%d adds %d\n',n,m);
        players{n} = players{n}.addFriend(m);
        players{m} = players{m}.addFriend(n);
    end
end
%}
for n = IDs
    invalidFriends = [n, players{n}.friendList];
    otherIDs = setdiff(IDs,invalidFriends);
    otherIDs = otherIDs(randperm(N-length(invalidFriends))); 
    for m = otherIDs
        if length(players{m}.friendList) < N_friends &&...
           length(players{n}.friendList) < N_friends 
            players{n} = players{n}.addFriend(m);
            players{m} = players{m}.addFriend(n);
        end
    end
end
%{
friendcounts = zeros(1,N);
for n = IDs
    friendcounts(n) = length(players{n}.friendList);
end
disp(friendcounts)
pause;
%}
totCredit       = zeros(1,N_Types);
totParties      = zeros(1,N_Types);
totVisitCredit  = zeros(1,N_Types);
DaysPerSegment  = 25;
for day = 1:N_days
    for n = IDs
        players{n} = players{n}.newDay();
    end
    %we assume 3 clues per day for all players
    for iter = 1:3
        for n = IDs
            %fprintf('----DBG: ')
            [players, players{n}] = players{n}.findClue(randi(7),players);
            %fprintf('\n')
        end
    end
    for n = IDs
        totVisitCredit(players{n}.playertype)= ...
            totVisitCredit(players{n}.playertype) + players{n}.partyCreditsToday;
    end
    fprintf('End of day %3d (%2.0f%%):\n',day,100*day/N_days)
    if(mod(day,DaysPerSegment)==0)   
        for n = IDs
            totCredit(players{n}.playertype) = ...
                totCredit(players{n}.playertype) + players{n}.credits;
            totParties(players{n}.playertype)= ...
                totParties(players{n}.playertype)+ players{n}.partiesThrown;
        end
        meanCredit = totCredit./(n_type+epsilon);
        meanParties = totParties./(n_type+epsilon);
        meanVisitCredit = totVisitCredit./(n_type+epsilon)/DaysPerSegment;

        for type = 1:N_Types
            fprintf('%s avg : %9.1f credits, %5.1f parties, %5.1f visit credit\n',...
            typeNames(type),meanCredit(type),meanParties(type),meanVisitCredit(type))
        end
        disp('¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯')
        totCredit       = zeros(1,N_Types);
        totParties      = zeros(1,N_Types);
        totVisitCredit  = zeros(1,N_Types);
    end
end

%clearvars players
end