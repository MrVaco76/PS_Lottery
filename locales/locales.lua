translations = {}

if Config.locales == "en" then 
    --Notify
    translations.LotteryJoined = "You are now entered into the next lottery draw!"
    translations.DatabaseError = "There was an error in the database!"
    translations.LotteryJoinedAgain = "You have submitted another lottery ticket!"
    translations.MaxParticipationReached = "You have reached the maximum number of lottery participations!"
    translations.NoMoneyInPot = "There is no money in the pot!"
    translations.YouAreWinner = "Congratulations, you have won the lottery draw! Your prize: %d€"
    translations.YouAreNotWinner = "Unfortunately, you did not win the lottery draw."
    translations.LotteryPotUpdated = "The lottery pot has been updated to %s€."
    translations.LotteryPotDrawnAdmin = "You have successfully conducted the lottery draw!"
    translations.NoPermission = "You do not have permission for that."
    translations.lotteryDrawn = "The lottery draw is over, quickly check if you have won!"
    translations.NoEntriesInLottery = "No one took part in the lottery! Or you are not the winner of the last lottey!"
    translations.GetStats = "Lottery pot: %s€ Participant: %s"
    
    -- Admin menu
    translations.LotteryAdminMenueTitel = "Lottery Management"
    translations.LotteryParticipated = "Number of Participants"
    translations.LotteryPot = "Currently to be won:"
    translations.manualDrawing = "Should a winner be drawn now?"
    translations.LastWinner = "The last winner is:"
    translations.NoWinnerAdmin = "The last winner has already collected their prize!"
    translations.ConfirmChangePot = "Are you sure you want to change the prize to: %s€?"
    translations.LotteryDrawAdminCheck = "Are you sure you want to trigger the lottery draw?"
    
    -- Target
    translations.CheckWin = "Check your lottery win!"
    translations.CheckStatsLabel = "lottery stats!"

elseif Config.locales == "de" then 

    --Notify
    translations.LotteryJoined = "Sie sind jetzt für die nächste Lotterie angemeldet!"
    translations.DatabaseError = "Es gab einen Fehler in der Datenbank!"
    translations.LotteryJoinedAgain = "Sie haben ein weiteres Lotterieticket eingereicht!"
    translations.MaxParticipationReached = "Sie haben die maximale Anzahl an Lotterieteilnahmen erreicht!"
    translations.NoMoneyInPot = "Es ist kein Geld im Topf!"
    translations.YouAreWinner = "Herzlichen Glückwunsch, Sie haben die Lotterie gewonnen! Ihr Preis: %d€"
    translations.YouAreNotWinner = "Leider haben Sie die Lotterie nicht gewonnen."
    translations.LotteryPotUpdated = "Der Lotterietopf wurde auf %s€ aktualisiert."
    translations.LotteryPotDrawnAdmin = "Sie haben die Lotterie erfolgreich durchgeführt!"
    translations.NoPermission = "Sie haben keine Berechtigung dafür."
    translations.lotteryDrawn = "Die Lotterie ist beendet, überprüfen Sie schnell, ob Sie gewonnen haben!"
    translations.NoEntriesInLottery = "Niemand hat an der Lotterie teilgenommen! Oder Sie sind nicht der Gewinner der letzten Lotterie!"
    translations.GetStats = "Lotterietopf: %s€ Teilnehmer: %s"

    -- Admin menu
    translations.LotteryAdminMenueTitel = "Lotterieverwaltung"
    translations.LotteryParticipated = "Anzahl der Teilnehmer"
    translations.LotteryPot = "Aktuell zu gewinnen:"
    translations.manualDrawing = "Soll jetzt ein Gewinner gezogen werden?"
    translations.LastWinner = "Der letzte Gewinner ist:"
    translations.NoWinnerAdmin = "Der letzte Gewinner hat seinen Preis bereits abgeholt!"
    translations.ConfirmChangePot = "Sind Sie sicher, dass Sie den Preis auf %s€ ändern möchten?"
    translations.LotteryDrawAdminCheck = "Sind Sie sicher, dass Sie die Lotterieziehung auslösen möchten?"

    -- Target
    translations.CheckWin = "Überprüfen Sie Ihren Lotteriegewinn!"
    translations.CheckStatsLabel = "Lotteriestatistiken!"

    elseif Config.locales == "fr" then 
    --Notify
    translations.LotteryJoined = "Vous êtes maintenant inscrit au prochain tirage de la loterie !"
    translations.DatabaseError = "Il y a eu une erreur dans la base de données !"
    translations.LotteryJoinedAgain = "Vous avez soumis un autre billet de loterie !"
    translations.MaxParticipationReached = "Vous avez atteint le nombre maximum de participations à la loterie !"
    translations.NoMoneyInPot = "Il n'y a pas d'argent dans le pot !"
    translations.YouAreWinner = "Félicitations, vous avez gagné le tirage de la loterie ! Votre prix : %d€"
    translations.YouAreNotWinner = "Malheureusement, vous n'avez pas gagné le tirage de la loterie."
    translations.LotteryPotUpdated = "Le pot de la loterie a été mis à jour à %s€."
    translations.LotteryPotDrawnAdmin = "Vous avez effectué le tirage de la loterie avec succès !"
    translations.NoPermission = "Vous n'avez pas la permission de faire cela."
    translations.lotteryDrawn = "Le tirage de la loterie est terminé, vérifiez rapidement si vous avez gagné !"
    translations.NoEntriesInLottery = "Personne n'a participé à la loterie ! Ou vous n'êtes pas le gagnant de la dernière loterie !"
    translations.GetStats = "Pot de la loterie : %s€ Participant : %s"
    
    -- Admin menu
    translations.LotteryAdminMenueTitel = "Gestion de la loterie"
    translations.LotteryParticipated = "Nombre de participants"
    translations.LotteryPot = "Actuellement à gagner :"
    translations.manualDrawing = "Un gagnant doit-il être tiré maintenant ?"
    translations.LastWinner = "Le dernier gagnant est :"
    translations.NoWinnerAdmin = "Le dernier gagnant a déjà récupéré son prix !"
    translations.ConfirmChangePot = "Êtes-vous sûr de vouloir changer le prix à : %s€ ?"
    translations.LotteryDrawAdminCheck = "Êtes-vous sûr de vouloir déclencher le tirage de la loterie ?"
    
    -- Target
    translations.CheckWin = "Vérifiez votre gain à la loterie !"
    translations.CheckStatsLabel = "Statistiques de la loterie !"

end 