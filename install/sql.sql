CREATE TABLE lottery_participants (
    identifier VARCHAR(75) PRIMARY KEY,
    lottery_citizenid VARCHAR(75),
    playername VARCHAR(255) NOT NULL,
    participations INT NOT NULL,
    discord VARCHAR(255) NOT NULL
);

CREATE TABLE lottery_pot(
    lottery_pot VARCHAR(75) PRIMARY KEY
);

CREATE TABLE lottery_winner (
    lottery_winnerid VARCHAR(75) PRIMARY KEY,
    lottery_winnercitizenid VARCHAR(75),
    lottery_winningamount VARCHAR(75),
    UNIQUE (lottery_winnerid, lottery_winnercitizenid, lottery_winningamount)
);

