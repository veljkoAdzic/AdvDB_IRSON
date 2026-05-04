-- team roster kje ima dueli * 2 * 2.2 (avg team capacity)
-- scores kje ima dueli * (~17) pati
-- refereing duel kje ima kolku duel
-- coaching team kje ima teams * 2
-- contracti kje ima teams * (~44) pati
-- 8,732,478 persons se dovolni sega generira 16m ama so ssn distinct sega se 13m
-- 15m dueli vo 5 sezoni - 3m po sezona lesno promenlivo za povekje
--      samo generate series vo sezona kje se zgolemi
-- okolu 1m prijatelski dueli pomegju reprezentacii

INSERT INTO COUNTRY (name, abreviation) VALUES
('Afghanistan', 'AFG'), ('Albania', 'ALB'), ('Algeria', 'ALG'),
('Andorra', 'AND'), ('Angola', 'ANG'), ('Argentina', 'ARG'),
('Armenia', 'ARM'), ('Australia', 'AUS'), ('Austria', 'AUT'),
('Azerbaijan', 'AZE'), ('Bahamas', 'BAH'), ('Bahrain', 'BRN'),
('Bangladesh', 'BAN'), ('Belarus', 'BLR'), ('Belgium', 'BEL'),
('Belize', 'BLZ'), ('Benin', 'BEN'), ('Bhutan', 'BHU'),
('Bolivia', 'BOL'), ('Bosnia', 'BIH'), ('Botswana', 'BOT'),
('Brazil', 'BRA'), ('Brunei', 'BRU'), ('Bulgaria', 'BUL'),
('Burkina Faso', 'BUR'), ('Burundi', 'BDI'), ('Cambodia', 'CAM'),
('Cameroon', 'CMR'), ('Canada', 'CAN'), ('Cape Verde', 'CPV'),
('Chad', 'CHA'), ('Chile', 'CHI'), ('China', 'CHN'),
('Colombia', 'COL'), ('Comoros', 'COM'), ('Congo', 'CGO'),
('Costa Rica', 'CRC'), ('Croatia', 'CRO'), ('Cuba', 'CUB'),
('Cyprus', 'CYP'), ('Czech Republic', 'CZE'), ('Denmark', 'DEN'),
('Djibouti', 'DJI'), ('Dominican Republic', 'DOM'), ('Ecuador', 'ECU'),
('Egypt', 'EGY'), ('El Salvador', 'ESA'), ('Estonia', 'EST'),
('Ethiopia', 'ETH'), ('Fiji', 'FIJ'), ('Finland', 'FIN'),
('France', 'FRA'), ('Gabon', 'GAB'), ('Gambia', 'GAM'),
('Georgia', 'GEO'), ('Germany', 'GER'), ('Ghana', 'GHA'),
('Greece', 'GRE'), ('Guatemala', 'GUA'), ('Guinea', 'GUI'),
('Haiti', 'HAI'), ('Honduras', 'HON'), ('Hungary', 'HUN'),
('Iceland', 'ISL'), ('India', 'IND'), ('Indonesia', 'INA'),
('Iran', 'IRI'), ('Iraq', 'IRQ'), ('Ireland', 'IRL'),
('Israel', 'ISR'), ('Italy', 'ITA'), ('Jamaica', 'JAM'),
('Japan', 'JPN'), ('Jordan', 'JOR'), ('Kazakhstan', 'KAZ'),
('Kenya', 'KEN'), ('Kosovo', 'KOS'), ('Kuwait', 'KUW'),
('Kyrgyzstan', 'KGZ'), ('Laos', 'LAO'), ('Latvia', 'LAT'),
('Lebanon', 'LIB'), ('Lesotho', 'LES'), ('Liberia', 'LBR'),
('Libya', 'LBA'), ('Lithuania', 'LTU'), ('Luxembourg', 'LUX'),
('Madagascar', 'MAD'), ('Malawi', 'MAW'), ('Malaysia', 'MAS'),
('Maldives', 'MDV'), ('Mali', 'MLI'), ('Malta', 'MLT'),
('Mauritania', 'MTN'), ('Mauritius', 'MRI'), ('Mexico', 'MEX'),
('Moldova', 'MDA'), ('Monaco', 'MON'), ('Mongolia', 'MGL'),
('Montenegro', 'MNE'), ('Morocco', 'MAR'), ('Mozambique', 'MOZ'),
('Myanmar', 'MYA'), ('Namibia', 'NAM'), ('Nepal', 'NEP'),
('Netherlands', 'NED'), ('New Zealand', 'NZL'), ('Nicaragua', 'NCA'),
('Niger', 'NIG'), ('Nigeria', 'NGR'), ('North Korea', 'PRK'),
('North Macedonia', 'MKD'), ('Norway', 'NOR'), ('Oman', 'OMA'),
('Pakistan', 'PAK'), ('Palestine', 'PLE'), ('Panama', 'PAN'),
('Paraguay', 'PAR'), ('Peru', 'PER'), ('Philippines', 'PHI'),
('Poland', 'POL'), ('Portugal', 'POR'), ('Qatar', 'QAT'),
('Romania', 'ROU'), ('Russia', 'RUS'), ('Rwanda', 'RWA'),
('Saudi Arabia', 'KSA'), ('Senegal', 'SEN'), ('Serbia', 'SRB'),
('Sierra Leone', 'SLE'), ('Singapore', 'SGP'), ('Slovakia', 'SVK'),
('Slovenia', 'SLO'), ('Somalia', 'SOM'), ('South Africa', 'RSA'),
('South Korea', 'KOR'), ('South Sudan', 'SSD'), ('Spain', 'ESP'),
('Sri Lanka', 'SRI'), ('Sudan', 'SUD'), ('Suriname', 'SUR'),
('Sweden', 'SWE'), ('Switzerland', 'SUI'), ('Syria', 'SYR'),
('Taiwan', 'TPE'), ('Tajikistan', 'TJK'), ('Tanzania', 'TAN'),
('Thailand', 'THA'), ('Togo', 'TOG'), ('Trinidad', 'TTO'),
('Tunisia', 'TUN'), ('Turkey', 'TUR'), ('Turkmenistan', 'TKM'),
('Uganda', 'UGA'), ('Ukraine', 'UKR'), ('UAE', 'UAE'),
('United Kingdom', 'GBR'), ('Uruguay', 'URU'), ('USA', 'USA'),
('Uzbekistan', 'UZB'), ('Venezuela', 'VEN'), ('Vietnam', 'VIE'),
('Yemen', 'YEM'), ('Zambia', 'ZAM'), ('Zimbabwe', 'ZIM');

INSERT INTO SPORT (name) VALUES
('Football'),
('Basketball'),
('Handball'),
('Volleyball'),
('Tennis'),
('Athletics'),
('Boxing'),
('Rugby'),
('Hockey'),
('Baseball'),
('Softball'),
('Cricket'),
('Golf'),
('Cycling'),
('Weightlifting'),
('Wrestling'),
('Judo'),
('Karate'),
('Taekwondo'),
('Fencing'),
('Archery'),
('Rowing'),
('Sailing'),
('Skiing'),
('Ice Hockey'),
('Triathlon'),
('Badminton'),
('Table Tennis'),
('Squash'),
('Water Polo'),
('Gymnastics'),
('Equestrian'),
('Canoeing'),
('Curling'),
('Biathlon'),
('Polo'),
('Lacrosse'),
('Futsal'),
('Beach Volleyball'),
('Kickboxing');

INSERT INTO SPORT_CATEGORY
  (name, sport_id, gender, duration_minutes, specification,
   team_capacity, points_per_win, points_per_draw, points_per_losing)
VALUES
('Men''s Football – 11-a-side',         1,'M',90,'Standard 11-a-side outdoor',          11,3,1,0),
('Women''s Football – 11-a-side',       1,'F',90,'Standard 11-a-side outdoor',          11,3,1,0),
('Men''s Football – Futsal',            1,'M',40,'5-a-side indoor variant',               5,3,1,0),
('Women''s Football – Futsal',          1,'F',40,'5-a-side indoor variant',               5,3,1,0),
('Men''s Football – Beach Soccer',      1,'M',36,'3×12-min periods, sand pitch',          5,3,1,0),
('Women''s Football – Beach Soccer',    1,'F',36,'3×12-min periods, sand pitch',          5,3,1,0),
('Men''s Football – Under-21',          1,'M',90,'Youth Olympic / U21 tournament',       11,3,1,0),
('Women''s Football – Under-20',        1,'F',90,'FIFA Women''s World Youth',            11,3,1,0),
('Men''s Basketball – 5-on-5',         2,'M',40,'FIBA regulation 4×10 min quarters',    5,3,0,1),
('Women''s Basketball – 5-on-5',       2,'F',40,'FIBA regulation 4×10 min quarters',    5,3,0,1),
('Men''s Basketball – 3×3',            2,'M',10,'FIBA 3×3, half-court',                  3,3,0,1),
('Women''s Basketball – 3×3',          2,'F',10,'FIBA 3×3, half-court',                  3,3,0,1),
('Men''s Basketball – Wheelchair',     2,'M',40,'Paralympic classification',              5,3,0,1),
('Women''s Basketball – Wheelchair',   2,'F',40,'Paralympic classification',              5,3,0,1),
('Men''s Handball – Indoor',           3,'M',60,'2×30-min halves, 7-a-side',             7,3,1,0),
('Women''s Handball – Indoor',         3,'F',60,'2×30-min halves, 7-a-side',             7,3,1,0),
('Men''s Beach Handball',              3,'M',20,'2×10-min periods, 4-a-side',             4,3,0,1),
('Women''s Beach Handball',            3,'F',20,'2×10-min periods, 4-a-side',             4,3,0,1),
('Men''s Volleyball – Indoor',         4,'M',90,'Best-of-5 sets, 6-a-side',              6,3,0,1),
('Women''s Volleyball – Indoor',       4,'F',90,'Best-of-5 sets, 6-a-side',              6,3,0,1),
('Men''s Beach Volleyball',            4,'M',45,'Best-of-3 sets, 2-a-side',              2,3,0,1),
('Women''s Beach Volleyball',          4,'F',45,'Best-of-3 sets, 2-a-side',              2,3,0,1),
('Men''s Snow Volleyball',             4,'M',40,'3-a-side on snow court',                 3,3,0,1),
('Women''s Snow Volleyball',           4,'F',40,'3-a-side on snow court',                 3,3,0,1),
('Men''s Tennis – Singles',            5,'M',180,'Best-of-5 sets (Grand Slams)',          1,3,0,1),
('Women''s Tennis – Singles',          5,'F',120,'Best-of-3 sets',                        1,3,0,1),
('Men''s Tennis – Doubles',            5,'M',120,'Best-of-3 sets',                        2,3,0,1),
('Women''s Tennis – Doubles',          5,'F',120,'Best-of-3 sets',                        2,3,0,1),
('Mixed Tennis – Doubles',             5,'M',120,'Mixed-gender doubles',                  2,3,0,1),
('Men''s Athletics – Track Sprint',    6,'M',1,'100m/200m/400m events',                  1,3,0,1),
('Women''s Athletics – Track Sprint',  6,'F',1,'100m/200m/400m events',                  1,3,0,1),
('Men''s Athletics – Middle Distance', 6,'M',4,'800m/1500m events',                       1,3,0,1),
('Women''s Athletics – Middle Distance',6,'F',4,'800m/1500m events',                      1,3,0,1),
('Men''s Athletics – Long Distance',   6,'M',30,'5000m/10000m events',                    1,3,0,1),
('Women''s Athletics – Long Distance', 6,'F',30,'5000m/10000m events',                    1,3,0,1),
('Men''s Athletics – Marathon',        6,'M',130,'Road race, 42.195 km',                  1,3,0,1),
('Women''s Athletics – Marathon',      6,'F',145,'Road race, 42.195 km',                  1,3,0,1),
('Men''s Athletics – Hurdles',         6,'M',2,'110m/400m hurdles',                       1,3,0,1),
('Women''s Athletics – Hurdles',       6,'F',2,'100m/400m hurdles',                       1,3,0,1),
('Men''s Athletics – Steeplechase',    6,'M',8,'3000m steeplechase',                      1,3,0,1),
('Women''s Athletics – Steeplechase',  6,'F',10,'3000m steeplechase',                     1,3,0,1),
('Men''s Athletics – Relay',           6,'M',1,'4×100m and 4×400m relay',                4,3,0,1),
('Women''s Athletics – Relay',         6,'F',1,'4×100m and 4×400m relay',                4,3,0,1),
('Men''s Athletics – High Jump',       6,'M',60,'Field jump event',                        1,3,0,1),
('Women''s Athletics – High Jump',     6,'F',60,'Field jump event',                        1,3,0,1),
('Men''s Athletics – Long Jump',       6,'M',60,'Field jump event',                        1,3,0,1),
('Women''s Athletics – Long Jump',     6,'F',60,'Field jump event',                        1,3,0,1),
('Men''s Athletics – Triple Jump',     6,'M',60,'Field jump event',                        1,3,0,1),
('Women''s Athletics – Triple Jump',   6,'F',60,'Field jump event',                        1,3,0,1),
('Men''s Athletics – Pole Vault',      6,'M',90,'Field vault event',                       1,3,0,1),
('Women''s Athletics – Pole Vault',    6,'F',90,'Field vault event',                       1,3,0,1),
('Men''s Athletics – Shot Put',        6,'M',60,'Throwing event',                          1,3,0,1),
('Women''s Athletics – Shot Put',      6,'F',60,'Throwing event',                          1,3,0,1),
('Men''s Athletics – Discus',          6,'M',60,'Throwing event',                          1,3,0,1),
('Women''s Athletics – Discus',        6,'F',60,'Throwing event',                          1,3,0,1),
('Men''s Athletics – Hammer',          6,'M',60,'Throwing event',                          1,3,0,1),
('Women''s Athletics – Hammer',        6,'F',60,'Throwing event',                          1,3,0,1),
('Men''s Athletics – Javelin',         6,'M',60,'Throwing event',                          1,3,0,1),
('Women''s Athletics – Javelin',       6,'F',60,'Throwing event',                          1,3,0,1),
('Men''s Athletics – Decathlon',       6,'M',600,'10 events over 2 days',                  1,3,0,1),
('Women''s Athletics – Heptathlon',    6,'F',480,'7 events over 2 days',                   1,3,0,1),
('Men''s Athletics – Race Walk 20km',  6,'M',90,'Road race walk',                          1,3,0,1),
('Women''s Athletics – Race Walk 20km',6,'F',100,'Road race walk',                         1,3,0,1),
('Men''s Boxing – Light Flyweight',    7,'M',9,'Up to 49 kg, 3×3-min rounds',             1,3,0,1),
('Men''s Boxing – Flyweight',          7,'M',9,'Up to 52 kg, 3×3-min rounds',             1,3,0,1),
('Men''s Boxing – Bantamweight',       7,'M',9,'Up to 56 kg',                              1,3,0,1),
('Men''s Boxing – Featherweight',      7,'M',9,'Up to 60 kg',                              1,3,0,1),
('Men''s Boxing – Lightweight',        7,'M',9,'Up to 64 kg',                              1,3,0,1),
('Men''s Boxing – Welterweight',       7,'M',9,'Up to 69 kg',                              1,3,0,1),
('Men''s Boxing – Middleweight',       7,'M',9,'Up to 75 kg',                              1,3,0,1),
('Men''s Boxing – Light Heavyweight',  7,'M',9,'Up to 81 kg',                              1,3,0,1),
('Men''s Boxing – Heavyweight',        7,'M',9,'Up to 91 kg',                              1,3,0,1),
('Men''s Boxing – Super Heavyweight',  7,'M',9,'Over 91 kg',                               1,3,0,1),
('Women''s Boxing – Flyweight',        7,'F',9,'Up to 50 kg, 3×3-min rounds',             1,3,0,1),
('Women''s Boxing – Lightweight',      7,'F',9,'Up to 60 kg',                              1,3,0,1),
('Women''s Boxing – Welterweight',     7,'F',9,'Up to 66 kg',                              1,3,0,1),
('Women''s Boxing – Middleweight',     7,'F',9,'Up to 75 kg',                              1,3,0,1),
('Women''s Boxing – Heavyweight',      7,'F',9,'Up to 81 kg',                              1,3,0,1),
('Men''s Rugby Union – 15s',           8,'M',80,'2×40-min halves, 15-a-side',            15,4,2,0),
('Women''s Rugby Union – 15s',         8,'F',80,'2×40-min halves, 15-a-side',            15,4,2,0),
('Men''s Rugby Sevens',                8,'M',14,'2×7-min halves, 7-a-side',               7,4,2,0),
('Women''s Rugby Sevens',              8,'F',14,'2×7-min halves, 7-a-side',               7,4,2,0),
('Men''s Rugby League',               8,'M',80,'2×40-min halves, 13-a-side',            13,2,1,0),
('Women''s Rugby League',             8,'F',80,'2×40-min halves, 13-a-side',            13,2,1,0),
('Men''s Field Hockey',                9,'M',60,'4×15-min quarters, 11-a-side',          11,3,1,0),
('Women''s Field Hockey',              9,'F',60,'4×15-min quarters, 11-a-side',          11,3,1,0),
('Men''s Baseball',                   10,'M',180,'9 innings, standard rules',              9,2,0,1),
('Women''s Baseball',                 10,'F',150,'9 innings, women''s rules',              9,2,0,1),
('Men''s Softball – Slow Pitch',      11,'M',60,'7 innings slow pitch',                   9,2,0,1),
('Women''s Softball – Fast Pitch',    11,'F',60,'7 innings fast pitch',                   9,2,0,1),
('Mixed Softball – Slow Pitch',       11,'M',60,'Co-ed, mixed gender roster',             9,2,0,1),
('Men''s Cricket – Test Match',       12,'M',450,'5-day match, 11-a-side',               11,1,1,0),
('Women''s Cricket – Test Match',     12,'F',450,'5-day women''s test',                  11,1,1,0),
('Men''s Cricket – ODI',              12,'M',480,'50-over one-day international',         11,2,1,0),
('Women''s Cricket – ODI',            12,'F',480,'50-over one-day international',         11,2,1,0),
('Men''s Cricket – T20',              12,'M',80,'20-over format',                         11,2,0,1),
('Women''s Cricket – T20',            12,'F',80,'20-over format',                         11,2,0,1),
('Men''s Golf – Stroke Play',         13,'M',240,'72-hole stroke play tournament',         1,3,0,1),
('Women''s Golf – Stroke Play',       13,'F',240,'72-hole stroke play tournament',         1,3,0,1),
('Men''s Golf – Match Play',          13,'M',240,'Hole-by-hole competition',               1,3,0,1),
('Women''s Golf – Match Play',        13,'F',240,'Hole-by-hole competition',               1,3,0,1),
('Men''s Golf – Team Ryder Cup',      13,'M',240,'Foursomes/fourballs, 12-man teams',     12,2,1,0),
('Women''s Golf – Solheim Cup',       13,'F',240,'Foursomes/fourballs, 12-woman teams',   12,2,1,0),
('Men''s Cycling – Road Race',        14,'M',300,'Mass-start road race',                   1,3,0,1),
('Women''s Cycling – Road Race',      14,'F',240,'Mass-start road race',                   1,3,0,1),
('Men''s Cycling – Time Trial',       14,'M',60,'Individual time trial',                   1,3,0,1),
('Women''s Cycling – Time Trial',     14,'F',45,'Individual time trial',                   1,3,0,1),
('Men''s Cycling – Track Sprint',     14,'M',4,'Track sprint / keirin',                    1,3,0,1),
('Women''s Cycling – Track Sprint',   14,'F',4,'Track sprint / keirin',                    1,3,0,1),
('Men''s Cycling – Track Endurance',  14,'M',50,'Points race / omnium',                    1,3,0,1),
('Women''s Cycling – Track Endurance',14,'F',50,'Points race / omnium',                    1,3,0,1),
('Men''s Cycling – Mountain Bike XC', 14,'M',90,'Cross-country off-road',                  1,3,0,1),
('Women''s Cycling – Mountain Bike XC',14,'F',75,'Cross-country off-road',                 1,3,0,1),
('Men''s Cycling – BMX Racing',       14,'M',1,'Sprint elimination format',                1,3,0,1),
('Women''s Cycling – BMX Racing',     14,'F',1,'Sprint elimination format',                1,3,0,1),
('Men''s Cycling – Team Pursuit',     14,'M',4,'4-km team pursuit, track',                 4,3,0,1),
('Women''s Cycling – Team Pursuit',   14,'F',4,'4-km team pursuit, track',                 4,3,0,1),
('Men''s Weightlifting – 61 kg',      15,'M',30,'Snatch + clean & jerk combined',          1,3,0,1),
('Men''s Weightlifting – 73 kg',      15,'M',30,'Snatch + clean & jerk combined',          1,3,0,1),
('Men''s Weightlifting – 89 kg',      15,'M',30,'Snatch + clean & jerk combined',          1,3,0,1),
('Men''s Weightlifting – 102 kg',     15,'M',30,'Snatch + clean & jerk combined',          1,3,0,1),
('Men''s Weightlifting – 109 kg',     15,'M',30,'Snatch + clean & jerk combined',          1,3,0,1),
('Men''s Weightlifting – 109+ kg',    15,'M',30,'Unlimited class',                          1,3,0,1),
('Women''s Weightlifting – 49 kg',    15,'F',30,'Snatch + clean & jerk combined',          1,3,0,1),
('Women''s Weightlifting – 59 kg',    15,'F',30,'Snatch + clean & jerk combined',          1,3,0,1),
('Women''s Weightlifting – 71 kg',    15,'F',30,'Snatch + clean & jerk combined',          1,3,0,1),
('Women''s Weightlifting – 87 kg',    15,'F',30,'Snatch + clean & jerk combined',          1,3,0,1),
('Women''s Weightlifting – 87+ kg',   15,'F',30,'Unlimited class',                          1,3,0,1),
('Men''s Wrestling – Freestyle 57 kg',16,'M',6,'3+3 minutes, two periods',                1,3,0,1),
('Men''s Wrestling – Freestyle 65 kg',16,'M',6,'Freestyle rules',                          1,3,0,1),
('Men''s Wrestling – Freestyle 74 kg',16,'M',6,'Freestyle rules',                          1,3,0,1),
('Men''s Wrestling – Freestyle 86 kg',16,'M',6,'Freestyle rules',                          1,3,0,1),
('Men''s Wrestling – Freestyle 97 kg',16,'M',6,'Freestyle rules',                          1,3,0,1),
('Men''s Wrestling – Freestyle 125 kg',16,'M',6,'Freestyle rules',                         1,3,0,1),
('Men''s Wrestling – Greco-Roman 60 kg',16,'M',6,'Greco-Roman rules',                      1,3,0,1),
('Men''s Wrestling – Greco-Roman 77 kg',16,'M',6,'Greco-Roman rules',                      1,3,0,1),
('Men''s Wrestling – Greco-Roman 130 kg',16,'M',6,'Greco-Roman rules',                     1,3,0,1),
('Women''s Wrestling – Freestyle 50 kg',16,'F',6,'Freestyle rules',                        1,3,0,1),
('Women''s Wrestling – Freestyle 57 kg',16,'F',6,'Freestyle rules',                        1,3,0,1),
('Women''s Wrestling – Freestyle 68 kg',16,'F',6,'Freestyle rules',                        1,3,0,1),
('Women''s Wrestling – Freestyle 76 kg',16,'F',6,'Freestyle rules',                        1,3,0,1),
('Men''s Judo – Extra Lightweight',   17,'M',4,'Up to 60 kg, Olympic mat',                1,3,0,1),
('Men''s Judo – Half Lightweight',    17,'M',4,'Up to 66 kg',                              1,3,0,1),
('Men''s Judo – Lightweight',         17,'M',4,'Up to 73 kg',                              1,3,0,1),
('Men''s Judo – Half Middleweight',   17,'M',4,'Up to 81 kg',                              1,3,0,1),
('Men''s Judo – Middleweight',        17,'M',4,'Up to 90 kg',                              1,3,0,1),
('Men''s Judo – Half Heavyweight',    17,'M',4,'Up to 100 kg',                             1,3,0,1),
('Men''s Judo – Heavyweight',         17,'M',4,'Over 100 kg',                              1,3,0,1),
('Women''s Judo – Extra Lightweight', 17,'F',4,'Up to 48 kg',                              1,3,0,1),
('Women''s Judo – Half Lightweight',  17,'F',4,'Up to 52 kg',                              1,3,0,1),
('Women''s Judo – Lightweight',       17,'F',4,'Up to 57 kg',                              1,3,0,1),
('Women''s Judo – Half Middleweight', 17,'F',4,'Up to 63 kg',                              1,3,0,1),
('Women''s Judo – Middleweight',      17,'F',4,'Up to 70 kg',                              1,3,0,1),
('Women''s Judo – Half Heavyweight',  17,'F',4,'Up to 78 kg',                              1,3,0,1),
('Women''s Judo – Heavyweight',       17,'F',4,'Over 78 kg',                               1,3,0,1),
('Mixed Judo – Team Event',           17,'M',4,'3M+3F per team, alternating bouts',        6,3,0,1),
('Men''s Karate – Kata Individual',   18,'M',5,'Solo performance judged',                  1,3,0,1),
('Women''s Karate – Kata Individual', 18,'F',5,'Solo performance judged',                  1,3,0,1),
('Men''s Karate – Kata Team',         18,'M',5,'Team synchronised kata',                   3,3,0,1),
('Women''s Karate – Kata Team',       18,'F',5,'Team synchronised kata',                   3,3,0,1),
('Men''s Karate – Kumite 60 kg',      18,'M',3,'Sparring under 60 kg',                     1,3,0,1),
('Men''s Karate – Kumite 75 kg',      18,'M',3,'Sparring under 75 kg',                     1,3,0,1),
('Men''s Karate – Kumite 75+ kg',     18,'M',3,'Sparring over 75 kg',                      1,3,0,1),
('Women''s Karate – Kumite 55 kg',    18,'F',3,'Sparring under 55 kg',                     1,3,0,1),
('Women''s Karate – Kumite 61 kg',    18,'F',3,'Sparring under 61 kg',                     1,3,0,1),
('Women''s Karate – Kumite 61+ kg',   18,'F',3,'Sparring over 61 kg',                      1,3,0,1),
('Men''s Taekwondo – 58 kg',          19,'M',9,'3×3-min rounds',                           1,3,0,1),
('Men''s Taekwondo – 68 kg',          19,'M',9,'3×3-min rounds',                           1,3,0,1),
('Men''s Taekwondo – 80 kg',          19,'M',9,'3×3-min rounds',                           1,3,0,1),
('Men''s Taekwondo – 80+ kg',         19,'M',9,'Heavyweight division',                      1,3,0,1),
('Women''s Taekwondo – 49 kg',        19,'F',9,'3×3-min rounds',                           1,3,0,1),
('Women''s Taekwondo – 57 kg',        19,'F',9,'3×3-min rounds',                           1,3,0,1),
('Women''s Taekwondo – 67 kg',        19,'F',9,'3×3-min rounds',                           1,3,0,1),
('Women''s Taekwondo – 67+ kg',       19,'F',9,'Heavyweight division',                      1,3,0,1),
('Men''s Fencing – Foil Individual',  20,'M',9,'3×3-min periods',                          1,3,0,1),
('Women''s Fencing – Foil Individual',20,'F',9,'3×3-min periods',                          1,3,0,1),
('Men''s Fencing – Épée Individual',  20,'M',9,'3×3-min periods',                          1,3,0,1),
('Women''s Fencing – Épée Individual',20,'F',9,'3×3-min periods',                          1,3,0,1),
('Men''s Fencing – Sabre Individual', 20,'M',9,'3×3-min periods',                          1,3,0,1),
('Women''s Fencing – Sabre Individual',20,'F',9,'3×3-min periods',                         1,3,0,1),
('Men''s Fencing – Foil Team',        20,'M',27,'3-fencer relay, 9 bouts',                 3,3,0,1),
('Women''s Fencing – Foil Team',      20,'F',27,'3-fencer relay, 9 bouts',                 3,3,0,1),
('Men''s Fencing – Épée Team',        20,'M',27,'3-fencer relay',                           3,3,0,1),
('Women''s Fencing – Épée Team',      20,'F',27,'3-fencer relay',                           3,3,0,1),
('Men''s Fencing – Sabre Team',       20,'M',27,'3-fencer relay',                           3,3,0,1),
('Women''s Fencing – Sabre Team',     20,'F',27,'3-fencer relay',                           3,3,0,1),
('Men''s Archery – Recurve Individual',21,'M',90,'70 m elimination + final',               1,3,0,1),
('Women''s Archery – Recurve Individual',21,'F',90,'70 m elimination + final',             1,3,0,1),
('Men''s Archery – Recurve Team',     21,'M',60,'3-archer team, 18 ends',                  3,3,0,1),
('Women''s Archery – Recurve Team',   21,'F',60,'3-archer team, 18 ends',                  3,3,0,1),
('Mixed Archery – Recurve Team',      21,'M',60,'1M+1F mixed team',                        2,3,0,1),
('Men''s Archery – Compound Individual',21,'M',60,'50 m, compound bow',                    1,3,0,1),
('Women''s Archery – Compound Individual',21,'F',60,'50 m, compound bow',                  1,3,0,1),
('Men''s Rowing – Single Sculls',     22,'M',8,'2000 m course',                            1,3,0,1),
('Women''s Rowing – Single Sculls',   22,'F',8,'2000 m course',                            1,3,0,1),
('Men''s Rowing – Double Sculls',     22,'M',7,'2000 m course',                            2,3,0,1),
('Women''s Rowing – Double Sculls',   22,'F',7,'2000 m course',                            2,3,0,1),
('Men''s Rowing – Quadruple Sculls',  22,'M',6,'2000 m course',                            4,3,0,1),
('Women''s Rowing – Quadruple Sculls',22,'F',6,'2000 m course',                            4,3,0,1),
('Men''s Rowing – Coxless Pair',      22,'M',7,'2000 m course',                            2,3,0,1),
('Women''s Rowing – Coxless Pair',    22,'F',7,'2000 m course',                            2,3,0,1),
('Men''s Rowing – Coxless Four',      22,'M',6,'2000 m course',                            4,3,0,1),
('Women''s Rowing – Coxless Four',    22,'F',6,'2000 m course',                            4,3,0,1),
('Men''s Rowing – Eight with Cox',    22,'M',5,'2000 m course, coxswain included',         9,3,0,1),
('Women''s Rowing – Eight with Cox',  22,'F',6,'2000 m course, coxswain included',         9,3,0,1),
('Mixed Rowing – Adaptive Single',    22,'M',8,'Paralympic AS category',                   1,3,0,1),
('Men''s Sailing – Laser/ILCA 7',     23,'M',90,'Dinghy single-handed',                    1,3,0,1),
('Women''s Sailing – Laser/ILCA 6',   23,'F',80,'Dinghy single-handed',                    1,3,0,1),
('Men''s Sailing – Finn',             23,'M',90,'Heavy-weather single-handed dinghy',       1,3,0,1),
('Mixed Sailing – 470',               23,'M',90,'Two-person dinghy',                        2,3,0,1),
('Mixed Sailing – Nacra 17 Foiling',  23,'M',60,'Mixed catamaran foiler',                   2,3,0,1),
('Men''s Sailing – 49er Skiff',       23,'M',60,'Double-handed high-performance',           2,3,0,1),
('Women''s Sailing – 49erFX Skiff',   23,'F',60,'Double-handed high-performance',           2,3,0,1),
('Mixed Sailing – RS:X Windsurfer',   23,'M',60,'Windsurfer class',                         1,3,0,1),
('Men''s Alpine Skiing – Downhill',   24,'M',2,'Speed event, single run',                  1,3,0,1),
('Women''s Alpine Skiing – Downhill', 24,'F',2,'Speed event, single run',                  1,3,0,1),
('Men''s Alpine Skiing – Slalom',     24,'M',3,'Technical event, 2 runs combined',          1,3,0,1),
('Women''s Alpine Skiing – Slalom',   24,'F',3,'Technical event, 2 runs combined',          1,3,0,1),
('Men''s Alpine Skiing – Giant Slalom',24,'M',4,'Technical event, 2 runs',                  1,3,0,1),
('Women''s Alpine Skiing – Giant Slalom',24,'F',4,'Technical event, 2 runs',                1,3,0,1),
('Men''s Alpine Skiing – Super-G',    24,'M',2,'Speed + technique combined',                1,3,0,1),
('Women''s Alpine Skiing – Super-G',  24,'F',2,'Speed + technique combined',                1,3,0,1),
('Men''s Alpine Skiing – Combined',   24,'M',5,'Downhill + slalom combined',                1,3,0,1),
('Women''s Alpine Skiing – Combined', 24,'F',5,'Downhill + slalom combined',                1,3,0,1),
('Men''s Freestyle Skiing – Moguls',  24,'M',2,'Mogul field scoring',                       1,3,0,1),
('Women''s Freestyle Skiing – Moguls',24,'F',2,'Mogul field scoring',                       1,3,0,1),
('Men''s Freestyle Skiing – Aerials', 24,'M',2,'Jump scoring',                              1,3,0,1),
('Women''s Freestyle Skiing – Aerials',24,'F',2,'Jump scoring',                             1,3,0,1),
('Men''s Ski Cross',                  24,'M',1,'Head-to-head course elimination',            1,3,0,1),
('Women''s Ski Cross',                24,'F',1,'Head-to-head course elimination',            1,3,0,1),
('Men''s Cross-Country Skiing – 50km',24,'M',120,'Classical/freestyle mass start',           1,3,0,1),
('Women''s Cross-Country – 30km',     24,'F',90,'Classical/freestyle mass start',            1,3,0,1),
('Men''s Ski Jumping – Large Hill',   24,'M',60,'Points for distance + style',              1,3,0,1),
('Women''s Ski Jumping – Normal Hill',24,'F',60,'Points for distance + style',              1,3,0,1),
('Men''s Ice Hockey',                 25,'M',60,'3×20-min periods, 6-a-side',              6,3,0,1),
('Women''s Ice Hockey',               25,'F',60,'3×20-min periods, 6-a-side',              6,3,0,1),
('Men''s Triathlon – Standard',       26,'M',120,'1.5km swim / 40km bike / 10km run',      1,3,0,1),
('Women''s Triathlon – Standard',     26,'F',130,'1.5km swim / 40km bike / 10km run',      1,3,0,1),
('Men''s Triathlon – Sprint',         26,'M',55,'750m / 20km / 5km',                       1,3,0,1),
('Women''s Triathlon – Sprint',       26,'F',60,'750m / 20km / 5km',                       1,3,0,1),
('Mixed Triathlon – Relay',           26,'M',80,'2M+2F, each leg sprint distance',          4,3,0,1),
('Men''s Badminton – Singles',        27,'M',60,'Best-of-3 games to 21',                   1,3,0,1),
('Women''s Badminton – Singles',      27,'F',60,'Best-of-3 games to 21',                   1,3,0,1),
('Men''s Badminton – Doubles',        27,'M',60,'Pairs, best-of-3',                         2,3,0,1),
('Women''s Badminton – Doubles',      27,'F',60,'Pairs, best-of-3',                         2,3,0,1),
('Mixed Badminton – Doubles',         27,'M',60,'One of each gender per pair',              2,3,0,1),
('Men''s Table Tennis – Singles',     28,'M',60,'Best-of-7 games to 11',                   1,3,0,1),
('Women''s Table Tennis – Singles',   28,'F',60,'Best-of-7 games to 11',                   1,3,0,1),
('Men''s Table Tennis – Doubles',     28,'M',60,'Pairs, best-of-5',                         2,3,0,1),
('Women''s Table Tennis – Doubles',   28,'F',60,'Pairs, best-of-5',                         2,3,0,1),
('Mixed Table Tennis – Doubles',      28,'M',60,'Mixed-gender pairs',                       2,3,0,1),
('Men''s Table Tennis – Team',        28,'M',90,'3-player team, 5 singles matches',         3,3,0,1),
('Women''s Table Tennis – Team',      28,'F',90,'3-player team, 5 singles matches',         3,3,0,1),
('Men''s Squash – Singles',           29,'M',60,'Best-of-5 games, PSA rules',               1,3,0,1),
('Women''s Squash – Singles',         29,'F',60,'Best-of-5 games, PSA rules',               1,3,0,1),
('Men''s Squash – Doubles',           29,'M',60,'Pairs, hardball or softball',               2,3,0,1),
('Women''s Squash – Doubles',         29,'F',60,'Pairs',                                     2,3,0,1),
('Mixed Squash – Doubles',            29,'M',60,'Mixed-gender pairs',                        2,3,0,1),
('Men''s Water Polo',                 30,'M',32,'4×8-min periods, 7-a-side',                7,3,0,1),
('Women''s Water Polo',               30,'F',32,'4×8-min periods, 7-a-side',                7,3,0,1),
('Men''s Artistic – All-Around',      31,'M',120,'6 apparatus individual',                  1,3,0,1),
('Women''s Artistic – All-Around',    31,'F',90,'4 apparatus individual',                   1,3,0,1),
('Men''s Artistic – Team',            31,'M',180,'Team combined score, 6 apparatus',        5,3,0,1),
('Women''s Artistic – Team',          31,'F',120,'Team combined score, 4 apparatus',        5,3,0,1),
('Men''s Artistic – Floor Exercise',  31,'M',30,'Floor apparatus final',                    1,3,0,1),
('Men''s Artistic – Pommel Horse',    31,'M',30,'Pommel horse apparatus final',              1,3,0,1),
('Men''s Artistic – Rings',           31,'M',30,'Rings apparatus final',                    1,3,0,1),
('Men''s Artistic – Vault',           31,'M',30,'Vault apparatus final',                    1,3,0,1),
('Men''s Artistic – Parallel Bars',   31,'M',30,'Parallel bars apparatus final',            1,3,0,1),
('Men''s Artistic – High Bar',        31,'M',30,'High bar apparatus final',                 1,3,0,1),
('Women''s Artistic – Vault',         31,'F',30,'Vault apparatus final',                    1,3,0,1),
('Women''s Artistic – Uneven Bars',   31,'F',30,'Uneven bars apparatus final',              1,3,0,1),
('Women''s Artistic – Balance Beam',  31,'F',30,'Balance beam apparatus final',             1,3,0,1),
('Women''s Artistic – Floor Exercise',31,'F',30,'Floor exercise apparatus final',           1,3,0,1),
('Men''s Rhythmic – Group',           31,'M',90,'5-person group, hoops/clubs/ribbons',      5,3,0,1),
('Women''s Rhythmic – Individual',    31,'F',60,'Individual routine, scored',               1,3,0,1),
('Women''s Rhythmic – Group',         31,'F',90,'5-person group',                           5,3,0,1),
('Men''s Trampoline – Individual',    31,'M',10,'10 skill routine',                          1,3,0,1),
('Women''s Trampoline – Individual',  31,'F',10,'10 skill routine',                          1,3,0,1),
('Men''s Acrobatic – Team',           31,'M',25,'Partnership/group acrobatics',              3,3,0,1),
('Women''s Acrobatic – Team',         31,'F',25,'Partnership/group acrobatics',              3,3,0,1),
('Men''s Equestrian – Dressage Ind.',  32,'M',30,'Grand Prix Freestyle',                    1,3,0,1),
('Women''s Equestrian – Dressage Ind.',32,'F',30,'Grand Prix Freestyle',                    1,3,0,1),
('Mixed Equestrian – Dressage Team',  32,'M',120,'3-pair team combined',                   3,3,0,1),
('Men''s Equestrian – Jumping Ind.',  32,'M',90,'Show jumping clear round',                 1,3,0,1),
('Women''s Equestrian – Jumping Ind.',32,'F',90,'Show jumping clear round',                 1,3,0,1),
('Mixed Equestrian – Jumping Team',   32,'M',120,'3-pair team',                             3,3,0,1),
('Men''s Equestrian – Eventing Ind.', 32,'M',540,'Dressage + cross-country + jumping',      1,3,0,1),
('Women''s Equestrian – Eventing Ind.',32,'F',540,'Dressage + cross-country + jumping',     1,3,0,1),
('Mixed Equestrian – Eventing Team',  32,'M',540,'3-pair team eventing',                    3,3,0,1),
('Men''s Canoe Sprint – K1 1000m',    33,'M',4,'Kayak single, 1000 m',                     1,3,0,1),
('Women''s Canoe Sprint – K1 500m',   33,'F',2,'Kayak single, 500 m',                      1,3,0,1),
('Men''s Canoe Sprint – K2 1000m',    33,'M',4,'Kayak double, 1000 m',                     2,3,0,1),
('Women''s Canoe Sprint – K2 500m',   33,'F',2,'Kayak double, 500 m',                      2,3,0,1),
('Men''s Canoe Sprint – K4 500m',     33,'M',2,'Kayak four, 500 m',                        4,3,0,1),
('Women''s Canoe Sprint – K4 500m',   33,'F',2,'Kayak four, 500 m',                        4,3,0,1),
('Men''s Canoe Sprint – C1 1000m',    33,'M',5,'Canoe single, 1000 m',                     1,3,0,1),
('Women''s Canoe Sprint – C1 200m',   33,'F',1,'Canoe single, 200 m',                      1,3,0,1),
('Men''s Canoe Slalom – K1',          33,'M',3,'Whitewater kayak slalom',                   1,3,0,1),
('Women''s Canoe Slalom – K1',        33,'F',3,'Whitewater kayak slalom',                   1,3,0,1),
('Men''s Canoe Slalom – C1',          33,'M',3,'Whitewater canoe slalom',                   1,3,0,1),
('Women''s Canoe Slalom – C1',        33,'F',3,'Whitewater canoe slalom',                   1,3,0,1),
('Mixed Canoe Slalom – C2',           33,'M',3,'Mixed-gender tandem canoe',                 2,3,0,1),
('Men''s Curling',                    34,'M',150,'10 ends, 4-person team',                  4,2,1,0),
('Women''s Curling',                  34,'F',150,'10 ends, 4-person team',                  4,2,1,0),
('Mixed Doubles Curling',             34,'M',75,'5 ends, 1M+1F per team',                   2,2,1,0),
('Men''s Biathlon – Sprint 10km',     35,'M',30,'Ski + 2 shooting stages',                  1,3,0,1),
('Women''s Biathlon – Sprint 7.5km',  35,'F',25,'Ski + 2 shooting stages',                  1,3,0,1),
('Men''s Biathlon – Pursuit 12.5km',  35,'M',36,'Ski + 4 shooting stages',                  1,3,0,1),
('Women''s Biathlon – Pursuit 10km',  35,'F',30,'Ski + 4 shooting stages',                  1,3,0,1),
('Men''s Biathlon – Individual 20km', 35,'M',60,'Classic individual, 4 shooting stages',     1,3,0,1),
('Women''s Biathlon – Individual 15km',35,'F',50,'Classic individual, 4 shooting stages',    1,3,0,1),
('Men''s Biathlon – Mass Start 15km', 35,'M',40,'Mass start, 4 shooting stages',             1,3,0,1),
('Women''s Biathlon – Mass Start 12.5km',35,'F',36,'Mass start, 4 shooting stages',          1,3,0,1),
('Mixed Biathlon – Relay 4×6km',      35,'M',80,'2M+2F relay teams',                        4,3,0,1),
('Men''s Polo – Outdoor',             36,'M',105,'7 chukkers × 7+2 min',                    4,3,1,0),
('Men''s Polo – Arena Polo',          36,'M',42,'6 chukkers × 7 min, indoor',               3,3,1,0),
('Women''s Polo – Outdoor',           36,'F',105,'7 chukkers, women''s tournament',          4,3,1,0),
('Men''s Lacrosse – Field',           37,'M',60,'4×15-min quarters, 10-a-side',            10,3,1,0),
('Women''s Lacrosse – Field',         37,'F',60,'4×15-min quarters, 12-a-side',            12,3,1,0),
('Men''s Lacrosse – Box',             37,'M',45,'3×15-min periods, 6-a-side',               6,3,0,1),
('Women''s Lacrosse – Box',           37,'F',45,'3×15-min periods, 6-a-side',               6,3,0,1),
('Men''s Futsal',                     38,'M',40,'2×20-min halves, 5-a-side',                5,3,1,0),
('Women''s Futsal',                   38,'F',40,'2×20-min halves, 5-a-side',                5,3,1,0),
('Men''s Beach Volleyball',           39,'M',45,'Best-of-3 sets, pairs',                    2,3,0,1),
('Women''s Beach Volleyball',         39,'F',45,'Best-of-3 sets, pairs',                    2,3,0,1),
('Mixed Beach Volleyball',            39,'M',45,'1M+1F per team',                           2,3,0,1),
('Men''s Kickboxing – Point Fighting',40,'M',9,'3×3-min rounds',                            1,3,0,1),
('Women''s Kickboxing – Point Fighting',40,'F',9,'3×3-min rounds',                          1,3,0,1),
('Men''s Kickboxing – Light Contact', 40,'M',9,'3×3-min rounds, controlled contact',        1,3,0,1),
('Women''s Kickboxing – Light Contact',40,'F',9,'3×3-min rounds, controlled contact',       1,3,0,1),
('Men''s Kickboxing – Full Contact',  40,'M',9,'3×3-min rounds, unlimited contact',         1,3,0,1),
('Women''s Kickboxing – Full Contact',40,'F',9,'3×3-min rounds, unlimited contact',         1,3,0,1),
('Men''s Kickboxing – Low Kick',      40,'M',9,'Full contact + low kicks',                   1,3,0,1),
('Women''s Kickboxing – Low Kick',    40,'F',9,'Full contact + low kicks',                   1,3,0,1),
('Men''s Kickboxing – K1 Rules',      40,'M',9,'Knees + kicks + punches, 3×3 min',          1,3,0,1),
('Women''s Kickboxing – K1 Rules',    40,'F',9,'Knees + kicks + punches, 3×3 min',          1,3,0,1);

INSERT INTO FEDERATION (sport_id, name)
SELECT
    s.id as sport_id,
    s.name || ' Federation of ' || c.name as name
FROM SPORT s
    cross join COUNTRY c
WHERE length(s.name || ' Federation of ' || c.name) <=80
ON CONFLICT (name) DO NOTHING;
INSERT INTO FEDERATION (sport_id, name)
SELECT id as sport_id,
       'International ' || name || ' Federation' AS name
FROM SPORT
where length('International ' || name || ' Federation') <= 80
ON CONFLICT Do NOTHING;
INSERT INTO INTERNATIONAL_FEDERATION (id)
SELECT id
FROM FEDERATION
WHERE name LIKE 'International%';
INSERT INTO NATIONAL_FEDERATION (id, country_id, international_federation_id)
SELECT f.id,
       c.id,
       inf.id
FROM FEDERATION f
    join SPORT s on s.id = f.sport_id
    join COUNTRY c on f.name = s.name || ' Federation of ' || c.name
    join FEDERATION ifF on ifF.name = 'International ' || s.name || ' Federation'
    join INTERNATIONAL_FEDERATION inf on inf.id = ifF.id
ON CONFLICT DO NOTHING;

INSERT INTO SPORT_CLUB (name, is_national_representation, country_id)
select
       ('National Representation Club of ' || c.abreviation) as name,
       TRUE as is_national_representation,
       c.id as country_id
FROM COUNTRY c
CROSS JOIN sport_category sc
WHERE length('National Representation Club of' || c.abreviation) <= 150
ON CONFLICT DO NOTHING;
INSERT INTO sport_team(club_id, name, sport_category_id)
SELECT
       sc.id as club_id,
       'NT_' || c.abreviation || ' ' || scat.name as name,
       scat.id as sport_category_id
FROM sport_club sc
JOIN country c
    ON c.id = sc.country_id
CROSS JOIN sport_category scat
WHERE sc.is_national_representation = TRUE
    AND length('NT_' || c.abreviation || ' ' || scat.name) <= 150;

INSERT INTO SPORT_CLUB (name, is_national_representation, country_id)
SELECT name, is_national_representation, country_id
FROM (
    SELECT
        tcn.name as name,
        FALSE as is_national_representation,
        c.id as country_id
    FROM (
        SELECT name, row_number() OVER (ORDER BY random()) as rn
        FROM temp_clubs_names
        WHERE length(name) <= 150
    ) as tcn
    CROSS JOIN LATERAL (
        SELECT
            c.id
        FROM COUNTRY c
        ORDER BY random() * tcn.rn
        LIMIT 1
    ) as c
) as data
ON CONFLICT (name, country_id) DO NOTHING;
INSERT INTO sport_team(club_id, name, sport_category_id)
SELECT
    sc.id AS club_id,
    sc.name || ' ' || scat.name AS name,
    scat.id AS sport_category_id
FROM sport_club sc
JOIN country c ON c.id = sc.country_id
CROSS JOIN LATERAL (
    SELECT scat.id, scat.name
    FROM sport_category scat
    ORDER BY md5(sc.id::text || scat.id::text || random()::text)
    LIMIT 10
) AS scat
WHERE sc.is_national_representation = FALSE
    AND length(sc.name || ' ' || scat.name) <= 150;

INSERT INTO club_federation(federation_id, club_id, start_date, end_date)
SELECT nf.id, sc.id, ((now() - interval '40 years') - (random() * interval '10 years'))::date as d, null
FROM sport_club sc
CROSS JOIN SPORT s
JOIN national_federation nf
    ON nf.country_id = sc.country_id
WHERE sc.is_national_representation = TRUE
ON CONFLICT DO NOTHING;
INSERT INTO club_federation(federation_id, club_id, start_date, end_date)
SELECT nf.id, sc.id,
       ((now() - interval '30 years') - (random() * interval '5 years'))::date AS start_date,
       NULL::date as end_date
FROM sport_club sc
JOIN sport_team st
    ON st.club_id = sc.id
JOIN sport_category scat
    ON scat.id = st.sport_category_id
JOIN SPORT s
    ON s.id = scat.sport_id
JOIN federation f
    ON f.sport_id = s.id
JOIN national_federation nf
    ON nf.country_id = sc.country_id
    AND f.id = nf.id
WHERE sc.is_national_representation = FALSE
ON CONFLICT DO NOTHING;

INSERT INTO REGION (name, part_of_country)
VALUES
  ('Nordic', FALSE), ('Balkans', FALSE), ('Maghreb', FALSE),
  ('Benelux', FALSE), ('Cono_sur', FALSE), ('Gcc', FALSE),
  ('Asean', FALSE), ('Visegrad', FALSE), ('Baltic', FALSE),
  ('Andean', FALSE), ('Ecowas', FALSE), ('Eac', FALSE),
  ('Levant', FALSE), ('Steppe', FALSE), ('Alpine', FALSE),
  ('Caribbean', FALSE), ('Anzac', FALSE), ('Saarc', FALSE),
  ('Melanesia', FALSE), ('Caucasus', FALSE), ('Central_america', FALSE),
  ('Iberia', FALSE), ('Nile_valley', FALSE),
  ('Cascadia', TRUE), ('Great_lakes', TRUE);
INSERT INTO REGION (name, part_of_country)
    SELECT c.name || '_North', TRUE FROM COUNTRY c
    UNION ALL
    SELECT c.name || '_South', TRUE FROM COUNTRY c
    UNION ALL
    SELECT c.name || '_East',  TRUE FROM COUNTRY c
    UNION ALL
    SELECT c.name || '_West',  TRUE FROM COUNTRY c;

INSERT INTO COUNTRY_REGION (country_id, region_id)
SELECT c.id, r.id
FROM COUNTRY c
JOIN REGION r ON r.name IN (
  c.name || '_North',
  c.name || '_South',
  c.name || '_East',
  c.name || '_West'
);
INSERT INTO COUNTRY_REGION (country_id, region_id)
SELECT c.id, r.id FROM COUNTRY c, REGION r
WHERE r.name = 'Nordic'
  AND c.name IN ('Norway','Sweden','Finland','Denmark','Iceland');
INSERT INTO COUNTRY_REGION (country_id, region_id)
SELECT c.id, r.id FROM COUNTRY c, REGION r
WHERE r.name = 'Balkans'
  AND c.name IN ('Serbia','Croatia','Bosnia','Slovenia','Montenegro',
                 'Kosovo','Albania','North Macedonia','Bulgaria','Romania','Greece');
INSERT INTO COUNTRY_REGION (country_id, region_id)
SELECT c.id, r.id FROM COUNTRY c, REGION r
WHERE r.name = 'Maghreb'
  AND c.name IN ('Morocco','Algeria','Tunisia','Libya','Mauritania');
INSERT INTO COUNTRY_REGION (country_id, region_id)
SELECT c.id, r.id FROM COUNTRY c, REGION r
WHERE r.name = 'Benelux'
  AND c.name IN ('Belgium','Netherlands','Luxembourg');
INSERT INTO COUNTRY_REGION (country_id, region_id)
SELECT c.id, r.id FROM COUNTRY c, REGION r
WHERE r.name = 'Cono_sur'
  AND c.name IN ('Argentina','Chile','Uruguay','Paraguay','Brazil');
INSERT INTO COUNTRY_REGION (country_id, region_id)
SELECT c.id, r.id FROM COUNTRY c, REGION r
WHERE r.name = 'Gcc'
  AND c.name IN ('Saudi Arabia','UAE','Kuwait','Qatar','Bahrain','Oman');
INSERT INTO COUNTRY_REGION (country_id, region_id)
SELECT c.id, r.id FROM COUNTRY c, REGION r
WHERE r.name = 'Asean'
  AND c.name IN ('Thailand','Vietnam','Indonesia','Malaysia','Philippines',
                 'Singapore','Myanmar','Cambodia','Laos','Brunei');
INSERT INTO COUNTRY_REGION (country_id, region_id)
SELECT c.id, r.id FROM COUNTRY c, REGION r
WHERE r.name = 'Visegrad'
  AND c.name IN ('Poland','Czech Republic','Slovakia','Hungary');
INSERT INTO COUNTRY_REGION (country_id, region_id)
SELECT c.id, r.id FROM COUNTRY c, REGION r
WHERE r.name = 'Baltic'
  AND c.name IN ('Estonia','Latvia','Lithuania');
INSERT INTO COUNTRY_REGION (country_id, region_id)
SELECT c.id, r.id FROM COUNTRY c, REGION r
WHERE r.name = 'Andean'
  AND c.name IN ('Colombia','Venezuela','Ecuador','Peru','Bolivia');
INSERT INTO COUNTRY_REGION (country_id, region_id)
SELECT c.id, r.id FROM COUNTRY c, REGION r
WHERE r.name = 'Ecowas'
  AND c.name IN ('Nigeria','Ghana','Senegal','Mali','Burkina Faso','Guinea',
                 'Benin','Niger','Togo','Sierra Leone','Liberia','Gambia',
                 'Cape Verde','Mauritania');
INSERT INTO COUNTRY_REGION (country_id, region_id)
SELECT c.id, r.id FROM COUNTRY c, REGION r
WHERE r.name = 'Eac'
  AND c.name IN ('Kenya','Tanzania','Uganda','Rwanda','Burundi','South Sudan');
INSERT INTO COUNTRY_REGION (country_id, region_id)
SELECT c.id, r.id FROM COUNTRY c, REGION r
WHERE r.name = 'Levant'
  AND c.name IN ('Lebanon','Syria','Jordan','Israel','Palestine','Iraq');
INSERT INTO COUNTRY_REGION (country_id, region_id)
SELECT c.id, r.id FROM COUNTRY c, REGION r
WHERE r.name = 'Steppe'
  AND c.name IN ('Kazakhstan','Kyrgyzstan','Tajikistan','Turkmenistan',
                 'Uzbekistan','Mongolia');
INSERT INTO COUNTRY_REGION (country_id, region_id)
SELECT c.id, r.id FROM COUNTRY c, REGION r
WHERE r.name = 'Alpine'
  AND c.name IN ('Switzerland','Austria','Slovenia');
INSERT INTO COUNTRY_REGION (country_id, region_id)
SELECT c.id, r.id FROM COUNTRY c, REGION r
WHERE r.name = 'Caribbean'
  AND c.name IN ('Cuba','Jamaica','Haiti','Dominican Republic','Trinidad','Bahamas');
INSERT INTO COUNTRY_REGION (country_id, region_id)
SELECT c.id, r.id FROM COUNTRY c, REGION r
WHERE r.name = 'Anzac'
  AND c.name IN ('Australia','New Zealand');
INSERT INTO COUNTRY_REGION (country_id, region_id)
SELECT c.id, r.id FROM COUNTRY c, REGION r
WHERE r.name = 'Saarc'
  AND c.name IN ('India','Pakistan','Bangladesh','Nepal','Sri Lanka',
                 'Bhutan','Maldives','Afghanistan');
INSERT INTO COUNTRY_REGION (country_id, region_id)
SELECT c.id, r.id FROM COUNTRY c, REGION r
WHERE r.name = 'Melanesia'
  AND c.name IN ('Fiji');
INSERT INTO COUNTRY_REGION (country_id, region_id)
SELECT c.id, r.id FROM COUNTRY c, REGION r
WHERE r.name = 'Caucasus'
  AND c.name IN ('Georgia','Armenia','Azerbaijan');
INSERT INTO COUNTRY_REGION (country_id, region_id)
SELECT c.id, r.id FROM COUNTRY c, REGION r
WHERE r.name = 'Central_america'
  AND c.name IN ('Guatemala','Belize','El Salvador','Honduras',
                 'Nicaragua','Costa Rica','Panama');
INSERT INTO COUNTRY_REGION (country_id, region_id)
SELECT c.id, r.id FROM COUNTRY c, REGION r
WHERE r.name = 'Iberia'
  AND c.name IN ('Spain','Portugal','Andorra');
INSERT INTO COUNTRY_REGION (country_id, region_id)
SELECT c.id, r.id FROM COUNTRY c, REGION r
WHERE r.name = 'Nile_valley'
  AND c.name IN ('Egypt','Sudan','South Sudan','Ethiopia','Uganda');

INSERT INTO COMPETITION_TYPE (type_label) VALUES
-- League formats
('National League 1'),
('National League 2'),
('National League 3'),
('National League 4'),
-- Cup formats
('National Cup'),
('Regional Cup'),
-- International formats
('World Championship'),
('Continental Championship'),
('European Championship'),
('Olympic Qualification Tournament'),
('Friendly International'),
('International Friendly Tournament'),
--Other
('Exhibition Match'),
('All Star Game'),
('Playoff Series'),
('Promotion Playoff'),
('Relegation Playoff');

WITH name_cte AS (
    SELECT
        p1 || p2 || ' ' || s AS name
    FROM (
        VALUES
            ('National'),('Olympic'),('Central'),('City'),('Victory'),('Heritage'),('Liberty'),
        ('Riverside'),('Colonial'),('Greenfield'),('Mountain'),('Lakeside'),('Sunset'),
        ('Eastside'),('West End'),('North Park'),('South Gate'),('Golden'),('Springfield'),
        ('Lakewood'),('Hillside'),('Meadow'),('Valley'),('Horizon'),('Westbrook'),
        ('Northgate'),('Southfield'),('Eastgate'),('Clearwater')
    ) AS sufix(p1)
    CROSS JOIN (
        VALUES
            (' Hall'),(' Grounds'),(' Stripe'),(''),(' Pirate'),(' Comb'),(' Bay'),
        (' Ridge'),(' Heights'),(' Point'),(' View'),(' Gate'),(' Square'),
        (' Crest'),(' Field'),(' Way'),(' Place'),(' Vale'),(' Glen'),(' Moor'),
        (' Cross'),(' End'),(' Side'),(' Bank'),(' Bend'),(' Reach'),(' Run'),
        (' Walk'),(' Arch'),(' Park')
    ) AS midfix(p2)
    CROSS JOIN (
        VALUES
            ('Stadium'),('Arena'),('Complex'),('Center'),('Dome'),('Field'),
        ('Track'),('Ring'),('Court'),('Grounds'),('Park'),('Pitch'),
        ('Plaza')
    ) AS suffixes(s)
    ORDER BY random()
),
address_cte AS (
    SELECT p1 || ' ' || p2 || ' No.' || random(1, 5)::int4 as name
    FROM (
        VALUES
        ('Main'),('High'),('Church'),('Park'),('Victoria'),('King'),('Queen'),
        ('Market'),('Bridge'),('Station'),('School'),('Green'),('North'),('South'),
        ('East'),('West'),('Central'),('Union'),('Spring'),('Lake'),('Hill'),
        ('River'),('Forest'),('Maple'),('Oak'),('Cedar')
    )  first_name(p1)
    CROSS JOIN (
        VALUES
        ('Street'),('Road'),('Avenue'),('Boulevard'),('Lane'),('Drive'),
        ('Way'),('Place'),('Court'),('Terrace'),('Crescent'),('Close'),
        ('Alley'),('Row'),('Walk'),('Path'),('Parade'),('Promenade')
    ) second_name(p2)
    ORDER BY random()
)
INSERT INTO location (country_id, name, capacity, address)
    SELECT c.id as country_id,
           loc_data.name as name,
           random(2, 500)::int4 * 100 as capacity,
           loc_data.adr as address
    FROM (
        SELECT
            id,
            floor(random(300, 1060)) as loc_count
        FROM country
     ) as c
    CROSS JOIN LATERAL (
        SELECT
            name_cte.name as name,
            address_t.name as adr
        FROM name_cte
        CROSS JOIN
            (SELECT * FROM address_cte ORDER BY random() LIMIT c.loc_count*3) as address_t
        ORDER BY random()
        LIMIT c.loc_count
    ) as loc_data
ON CONFLICT (country_id, name) DO NOTHING;

INSERT INTO SPONSORSHIP (sport_team_id, sponsor_id, start_date, end_date, amount)
SELECT st.id as sport_team_id,
       s.id as sponsor_id,
       ((now() - interval '5 years' * random()) - interval '5 years')::date as start_date,
       ((now() + interval '8 year' * random()) + interval '2 years')::date end_date,
       (1000000 + floor(random()*6000000))::int as amount
from (
    select id, row_number() over (order by random()) as rn, gs as offf
    from SPORT_TEAM
    cross join generate_series(1, 7) as gs
     ) as st join
    (
    select id, row_number() over (order by random()) as rn
    from SPONSOR
    ) as s on s.rn = ((st.rn*st.offf-1) % (Select count(*) from SPONSOR) + 1)
on conflict do nothing;

INSERT INTO NATIONAL_LEAGUE (federation_id, name, date_started, date_disbanded, region_id, sport_category_id)
SELECT
    nf.id,
    scat.name || ' National 1 ' || cc.name,
    (CURRENT_DATE - INTERVAL '1 years' * random() - INTERVAL '5 years')::date,
    NULL::date,
    NULL::int4,
    scat.id as sport_category_id
FROM SPORT_CATEGORY scat
JOIN FEDERATION f ON f.sport_id = scat.sport_id
JOIN NATIONAL_FEDERATION nf ON nf.id = f.id
JOIN COUNTRY cc ON cc.id = nf.country_id;

INSERT INTO SEASON (national_league_id, start_date, end_date)
SELECT
    nl.id,
    (CURRENT_DATE - INTERVAL '30 days' * random() - interval '1 year' * gs)::date AS start_date,

         (CURRENT_DATE - INTERVAL '30 days' * random() - interval '1 year' * (gs - 1))::date
     AS end_date
FROM NATIONAL_LEAGUE nl
CROSS JOIN generate_series(0, 4) AS gs;

INSERT INTO competition(type, organizer_federation_id, season_id, name, start_date, end_date)
SELECT
    ct.id,
    nl.federation_id,
    s.id,
    nl.name,
    s.start_date,
    s.end_date
FROM season s
JOIN national_league nl ON s.national_league_id = nl.id
JOIN competition_type ct ON ct.id = (
    CASE
        WHEN nl.name LIKE '% National 1 %' THEN 1
        WHEN nl.name LIKE '% National 2 %' THEN 2
        WHEN nl.name LIKE '% National 3 %' THEN 3
        WHEN nl.name LIKE '% National 4 %' THEN 4
    END
)
ON CONFLICT DO NOTHING;

CREATE INDEX IF NOT EXISTS idx_sport_team_club_id ON sport_team(club_id);
CREATE INDEX IF NOT EXISTS idx_sport_team_sport_cat_id ON sport_team(sport_category_id);
CREATE INDEX IF NOT EXISTS idx_sport_club_country_id ON sport_club(country_id);
CREATE INDEX IF NOT EXISTS idx_cf_lookup
    ON club_federation(federation_id, club_id, start_date, end_date);
CREATE INDEX IF NOT EXISTS idx_season_nat_league
    ON season(national_league_id);
CREATE INDEX IF NOT EXISTS idx_nl_federation
    ON national_league(federation_id, sport_category_id);
INSERT INTO season_sport_team (season_id, sport_team_id)
SELECT s.id AS season_id, st.id AS sport_team_id
FROM season s
JOIN national_league nl
    ON s.national_league_id = nl.id
CROSS JOIN LATERAL (
    SELECT DISTINCT on (st.id)
        st.id,
        row_number() over (partition by s.id order by random()) i
    FROM sport_team st
    JOIN sport_club sc
        ON st.club_id = sc.id
    JOIN sport_category scat
        ON st.sport_category_id = scat.id
    JOIN national_federation nf
        ON nf.id = nl.federation_id
    JOIN federation f
        ON f.id = nl.federation_id
    JOIN club_federation cf
        ON cf.club_id = sc.id
        AND cf.federation_id = nl.federation_id
        AND cf.start_date < s.start_date
        AND (cf.end_date IS NULL OR cf.end_date > s.start_date)
    WHERE
        sc.country_id = nf.country_id
        AND scat.sport_id = f.sport_id
        AND NOT sc.is_national_representation
        AND st.sport_category_id = nl.sport_category_id
) AS st
WHERE st.i <= 20;
DROP INDEX
    idx_sport_team_club_id,
    idx_sport_team_sport_cat_id,
    idx_sport_club_country_id,
    idx_cf_lookup,
    idx_season_nat_league,
    idx_nl_federation;

WITH score_logic (sport_id, multiplier, offset_val) AS (
    VALUES
        (1, 5, 0), (9, 11, 0), (11, 11, 0), (16, 11, 0), (17, 11, 0),
        (19, 11, 0), (20, 11, 0), (25, 11, 0), (34, 11, 0), (40, 11, 0),
        (2, 71, 50),
        (3, 21, 15),
        (4, 4, 0), (5, 4, 0), (27, 4, 0), (28, 4, 0), (29, 4, 0), (39, 4, 0),
        (6, 2, 0), (14, 2, 0), (15, 2, 0), (22, 2, 0), (23, 2, 0), (26, 2, 0), (31, 2, 0), (32, 2, 0), (33, 2, 0),
        (7, 13, 0),
        (8, 61, 0),
        (10, 15, 1),
        (12, 401, 100),
        (13, 21, 60),
        (18, 9, 0),
        (21, 151, 0),
        (24, 141, 60),
        (30, 16, 5),
        (35, 21, 0),
        (36, 16, 0),
        (37, 21, 5),
        (38, 16, 0)
)
INSERT INTO duel (
    home_team_id, away_team_id, location_id, competition_id,
    start_time, sport_category_id, home_team_score, away_team_score
)
SELECT
    st1.id,
    st2.id,
    (
        SELECT l.id
        FROM location l
        WHERE l.country_id = sc1.country_id
        ORDER BY random()
        LIMIT 1
    ) AS location_id,
    NULL,
    generated_times.start_time,
    st1.sport_category_id,
    CASE
        WHEN now() < generated_times.start_time THEN NULL
        ELSE floor(random() * COALESCE(sl.multiplier, 2) + COALESCE(sl.offset_val, 0))::int
    END AS home_team_score,
    CASE
        WHEN now() < generated_times.start_time THEN NULL
        ELSE floor(random() * COALESCE(sl.multiplier, 2) + COALESCE(sl.offset_val, 0))::int
    END AS away_team_score
FROM sport_team st1
JOIN sport_club sc1
    ON sc1.id = st1.club_id
    AND sc1.is_national_representation = TRUE
JOIN LATERAL (
    SELECT st2.id
    FROM sport_team st2
    JOIN sport_club sc2 ON sc2.id = st2.club_id
    WHERE sc2.is_national_representation = TRUE
      AND st1.sport_category_id = st2.sport_category_id
      AND st1.id < st2.id
    LIMIT 10 -- mozhe da se pokachi no fokusot ne e na ovie dueli
) st2 ON TRUE
CROSS JOIN LATERAL (
    SELECT CASE
        WHEN random() > 0.5 THEN now() - (interval '5 year' * random())
        ELSE now() + (interval '5 year' * random())
    END AS start_time
    WHERE st1.id IS NOT NULL AND st2.id IS NOT NULL -- da raboti random
) AS generated_times
JOIN sport_category scat ON scat.id = st1.sport_category_id
LEFT JOIN score_logic sl ON sl.sport_id = scat.sport_id
offset 100;

-- duel no rep
CREATE UNLOGGED TABLE tmp_season_teams_rr AS
SELECT
    s.id AS season_id,
    s.start_date,
    nl.sport_category_id,
    CASE WHEN COUNT(*) % 2 = 1
         THEN array_agg(sst.sport_team_id ORDER BY sst.sport_team_id) || ARRAY[-1]
         ELSE array_agg(sst.sport_team_id ORDER BY sst.sport_team_id)
    END AS teams,
    CASE WHEN COUNT(*) % 2 = 1
         THEN COUNT(*) + 1
         ELSE COUNT(*)
    END AS n
FROM season s
JOIN national_league nl ON nl.id = s.national_league_id
JOIN season_sport_team sst ON sst.season_id = s.id
GROUP BY s.id, s.start_date, nl.sport_category_id
HAVING COUNT(*) >= 2;

CREATE INDEX ON tmp_season_teams_rr(season_id);

CREATE UNLOGGED TABLE tmp_rr_club_location AS
SELECT DISTINCT ON (sc.id)
    sc.id AS club_id,
    l.id  AS location_id
FROM sport_club sc
JOIN location l ON l.country_id = sc.country_id
ORDER BY sc.id, random();

CREATE INDEX ON tmp_rr_club_location(club_id);

CREATE UNLOGGED TABLE tmp_rr_competition AS
SELECT DISTINCT ON (season_id)
    season_id,
    id AS competition_id
FROM competition
WHERE type = 1
ORDER BY season_id;

CREATE INDEX ON tmp_rr_competition(season_id);

WITH score_logic (sport_id, multiplier, offset_val) AS (
    VALUES
        (1,5,0),(9,11,0),(11,11,0),(16,11,0),(17,11,0),
        (19,5,0),(20,11,0),(25,11,0),(34,11,0),(40,11,0),
        (2,71,50),(3,21,15),
        (4,4,0),(5,4,0),(27,4,0),(28,4,0),(29,4,0),(39,4,0),
        (6,2,0),(14,2,0),(15,2,0),(22,2,0),(23,2,0),(26,2,0),
        (31,2,0),(32,2,0),(33,2,0),
        (7,13,0),(8,61,0),(10,15,1),(12,401,100),(13,21,60),
        (18,9,0),(21,151,0),(24,141,60),(30,16,5),(35,21,0),
        (36,16,0),(37,21,5),(38,16,0)
),
rounds AS (
    SELECT
        sm.season_id,
        sm.start_date,
        sm.sport_category_id,
        sm.teams,
        sm.n,
        r.round_num,
        CASE WHEN r.round_num <= sm.n - 1 THEN 1 ELSE 2 END AS leg,
        (r.round_num - 1) % (sm.n - 1) AS r_idx
    FROM tmp_season_teams_rr sm
    CROSS JOIN generate_series(1, (sm.n - 1) * 2) AS r(round_num)
),
pairings AS (
    SELECT
        rnd.season_id,
        rnd.start_date,
        rnd.sport_category_id,
        rnd.round_num,
        rnd.leg,
        rnd.n,
        rnd.teams,
        rnd.r_idx,
        slot.i,
        CASE WHEN slot.i = 0 THEN rnd.n - 1
             ELSE rnd.n - 1 - slot.i
        END AS partner_slot
    FROM rounds rnd
    CROSS JOIN generate_series(0, rnd.n / 2 - 1) AS slot(i)
),
resolved AS (
    SELECT
        p.season_id,
        p.start_date,
        p.sport_category_id,
        p.round_num,
        p.leg,
        p.n,
        CASE WHEN p.i = 0 THEN p.teams[1]
             ELSE p.teams[((p.i - 1 + p.r_idx) % (p.n - 1)) + 2]
        END AS team_a,
        CASE WHEN p.partner_slot = 0 THEN p.teams[1]
             ELSE p.teams[((p.partner_slot - 1 + p.r_idx) % (p.n - 1)) + 2]
        END AS team_b,
        ROW_NUMBER() OVER (
            PARTITION BY p.season_id, p.round_num
            ORDER BY p.i
        ) AS match_num
    FROM pairings p
),
final_matches AS (
    SELECT
        r.season_id,
        r.sport_category_id,
        r.round_num,
        r.match_num,
        r.start_date,
        CASE WHEN r.leg = 1 THEN r.team_a ELSE r.team_b END AS home_team_id,
        CASE WHEN r.leg = 1 THEN r.team_b ELSE r.team_a END AS away_team_id
    FROM resolved r
    WHERE r.team_a != -1
      AND r.team_b != -1
      AND r.team_a IS NOT NULL
      AND r.team_b IS NOT NULL
      AND r.team_a != r.team_b
)
INSERT INTO duel (
    home_team_id, away_team_id, location_id, competition_id,
    start_time, sport_category_id, home_team_score, away_team_score
)
SELECT
    fm.home_team_id,
    fm.away_team_id,
    cl.location_id,
    rc.competition_id,
    fm.start_date
        + ((fm.round_num - 1) * INTERVAL '7 days')
        + ((fm.match_num - 1) * INTERVAL '1 day')
        + CASE WHEN fm.match_num % 2 = 0
               THEN INTERVAL '18 hours'
               ELSE INTERVAL '12 hours' END
        AS start_time,
    fm.sport_category_id,
    CASE
        WHEN fm.start_date + ((fm.round_num - 1) * INTERVAL '7 days') > NOW() THEN NULL
        ELSE FLOOR(RANDOM() * COALESCE(sl.multiplier, 2) + COALESCE(sl.offset_val, 0))::INT
    END AS home_team_score,
    CASE
        WHEN fm.start_date + ((fm.round_num - 1) * INTERVAL '7 days') > NOW() THEN NULL
        ELSE FLOOR(RANDOM() * COALESCE(sl.multiplier, 2) + COALESCE(sl.offset_val, 0))::INT
    END AS away_team_score
FROM final_matches fm
JOIN sport_team st_home ON st_home.id = fm.home_team_id
JOIN sport_club sc_home ON sc_home.id = st_home.club_id
JOIN tmp_rr_club_location cl ON cl.club_id = sc_home.id
JOIN tmp_rr_competition rc ON rc.season_id = fm.season_id
JOIN sport_category scat ON scat.id = fm.sport_category_id
LEFT JOIN score_logic sl ON sl.sport_id = scat.sport_id;

DROP TABLE tmp_season_teams_rr;
DROP TABLE tmp_rr_club_location;
DROP TABLE tmp_rr_competition;

WITH male_names AS (
    SELECT name, row_number() OVER (ORDER BY random()) AS rn
    FROM temp_male_names
),
surnames AS (
    SELECT surname, row_number() OVER (ORDER BY random()) AS rn
    FROM temp_surnames
)
INSERT INTO PERSON (ssn, first_name, last_name, date_of_birth, gender, country_id)
SELECT
    to_char(data.date_of_birth, 'DDMM')||
    to_char(extract(year from data.date_of_birth)::integer % 1000, 'FM009')||
    '4'||
    to_char((1 + floor(random()*8))::int, 'FM9') ||
    '0'||
    to_char(floor(random()*100)::int, 'FM09') as ssn,
    data.first_name,
    data.last_name,
    data.date_of_birth,
    data.gender,
    data.country_id
FROM (
    SELECT
        mn.name as first_name,
        s.surname as last_name,
        ((now() - interval '15 years') - (random() * interval '70 years'))::date as date_of_birth,
        'M'as gender,
        (floor(random() * 165) + 1)::int as country_id
    FROM male_names mn
        CROSS JOIN surnames s
    LIMIT 8000000
) as data
ON CONFLICT (ssn) DO NOTHING;
WITH female_names AS (
    SELECT name, row_number() OVER (ORDER BY random()) AS rn
    FROM temp_female_names
),
surnames AS (
    SELECT surname, row_number() OVER (ORDER BY random()) AS rn
    FROM temp_surnames
)
INSERT INTO PERSON (ssn, first_name, last_name, date_of_birth, gender, country_id)
SELECT
    to_char(data.date_of_birth, 'DDMM')||
    to_char(extract(year from data.date_of_birth)::integer % 1000, 'FM009')||
    '4'||
    to_char((1 + floor(random()*8))::int, 'FM9') ||
    '5'||
    to_char(floor(random()*100)::int, 'FM09') as ssn,
    data.first_name,
    data.last_name,
    data.date_of_birth,
    data.gender,
    data.country_id
FROM (
    SELECT
        mn.name as first_name,
        s.surname as last_name,
        ((now() - interval '15 years') - (random() * interval '70 years'))::date as date_of_birth,
        'F'as gender,
        (floor(random() * 165) + 1)::int as country_id
    FROM female_names mn
        CROSS JOIN surnames s
    LIMIT 8000000
) as data
ON CONFLICT (ssn) DO NOTHING;

CREATE TEMP TABLE tmp_people AS
SELECT ssn,
       ROW_NUMBER() OVER (ORDER BY random()) AS person_rn
FROM   PERSON;
CREATE INDEX ON tmp_people (person_rn);
WITH available_people AS (
    SELECT ssn, person_rn
    FROM tmp_people
),
total_persons AS (
    SELECT COUNT(*) AS cnt FROM tmp_people
),
federations AS (
    SELECT f.id AS federation_id,
           scat.id AS sport_category_id,
           ROW_NUMBER() OVER (ORDER BY random()) AS combo_rn
    FROM federation f
    JOIN sport_category scat ON scat.sport_id = f.sport_id
)
INSERT INTO referee (ssn, federation_id, sport_category_id)
SELECT ap.ssn,
       fed.federation_id,
       fed.sport_category_id
FROM federations fed
CROSS JOIN generate_series(1, 100) AS gs(slot)
JOIN available_people ap ON 1=1
CROSS JOIN total_persons tp
WHERE ap.person_rn = ((fed.combo_rn - 1) * 100 + gs.slot - 1) % tp.cnt + 1
ON CONFLICT (ssn) DO NOTHING;

CREATE TABLE tmp_people_no_referee AS
SELECT ssn,
       ROW_NUMBER() OVER (ORDER BY random()) AS person_rn
FROM   PERSON
WHERE  ssn NOT IN (SELECT ssn FROM REFEREE);
CREATE INDEX ON tmp_people_no_referee(person_rn);
WITH total AS (
    SELECT COUNT(*) AS cnt FROM tmp_people_no_referee
),
team_fed AS (
    SELECT
        st.id AS team_id,
        st.sport_category_id,
        f.id AS federation_id,
        ROW_NUMBER() OVER (PARTITION BY st.id ORDER BY random()) AS fed_rn
    FROM sport_team st
    JOIN sport_category scat ON scat.id = st.sport_category_id
    JOIN federation f ON f.sport_id = scat.sport_id
),
team_fed_one AS (
    SELECT team_id, sport_category_id, federation_id
    FROM team_fed
    WHERE fed_rn = 1
),
slots AS (
    SELECT
        tf.team_id,
        tf.sport_category_id,
        tf.federation_id,
        gs.n,
        ROW_NUMBER() OVER (ORDER BY tf.team_id, gs.n) AS global_slot
    FROM team_fed_one tf
    CROSS JOIN generate_series(1, 2) AS gs(n)
),
assigned AS (
    SELECT
        s.team_id,
        s.sport_category_id,
        s.federation_id,
        p.ssn
    FROM slots s
    JOIN total t ON true
    JOIN tmp_people_no_referee p ON p.person_rn = (s.global_slot - 1) % t.cnt + 1
)
INSERT INTO COACH (ssn, sport_category_id, federation_id)
SELECT DISTINCT ssn, sport_category_id, federation_id
FROM assigned
ON CONFLICT (ssn) DO NOTHING;

CREATE TABLE tmp_sportspersons_pool AS
SELECT ssn,
       ROW_NUMBER() OVER (ORDER BY random()) AS rn
FROM PERSON
WHERE ssn NOT IN (SELECT ssn FROM REFEREE)
  AND ssn NOT IN (SELECT ssn FROM COACH);
CREATE INDEX ON tmp_sportspersons_pool(rn);
WITH total AS (
    SELECT COUNT(*) AS cnt FROM tmp_sportspersons_pool
),
slots AS (
    SELECT
        st.id AS team_id,
        st.sport_category_id,
        gs.n,
        ROW_NUMBER() OVER (ORDER BY st.id, gs.n) AS global_slot
    FROM sport_team st
    JOIN sport_category scat ON scat.id = st.sport_category_id
    CROSS JOIN generate_series(1, scat.team_capacity + 2) AS gs(n)
),
assigned AS (
    SELECT
        s.team_id,
        s.sport_category_id,
        p.ssn
    FROM slots s
    JOIN total t ON true
    JOIN tmp_sportspersons_pool p ON p.rn = (s.global_slot - 1) % t.cnt + 1
)
INSERT INTO SPORTSPERSON (ssn, sport_category_id)
SELECT DISTINCT ssn, sport_category_id
FROM assigned
ON CONFLICT (ssn) DO NOTHING;

WITH team_slots AS (
    SELECT
        st.id AS team_id,
        st.sport_category_id,
        ROW_NUMBER() OVER (
            PARTITION BY st.id
            ORDER BY gs.gs
        ) AS slot_rn,
        DENSE_RANK() OVER (
            PARTITION BY st.sport_category_id
            ORDER BY st.id
        ) AS team_rank
    FROM sport_team st
    CROSS JOIN generate_series(1,2) AS gs(gs)
),
shuffled_coaches AS (
    SELECT
        ssn,
        sport_category_id,
        ROW_NUMBER() OVER (
            PARTITION BY sport_category_id
            ORDER BY random()
        ) AS coach_rn
    FROM coach
)
INSERT INTO coaching_team (team_id, coach_ssn, start_date, end_date)
SELECT
    ts.team_id,
    sc.ssn,
    (CURRENT_DATE - (INTERVAL '1 years' * random() + INTERVAL '6 years'))::date,
    NULL
FROM team_slots ts
JOIN shuffled_coaches sc
    ON sc.sport_category_id = ts.sport_category_id
    AND sc.coach_rn = ((ts.team_rank - 1) * 2 + ts.slot_rn);

INSERT INTO sportsperson_contract (player_ssn, club_id, start_date, end_date, payout)
SELECT
    sp.ssn,
    es.club_id,
    (CURRENT_DATE - (INTERVAL '1 year' * random() + INTERVAL '6 years'))::date,
    NULL,
    (50000 + random() * 200000)::int
FROM (
    SELECT
        st.id AS team_id,
        st.sport_category_id,
        sc.id AS club_id,
        ROW_NUMBER() OVER (
            PARTITION BY st.sport_category_id
            ORDER BY st.id, slot_num
        ) AS global_slot
    FROM sport_team st
    JOIN sport_club sc ON sc.id = st.club_id
    JOIN sport_category scat ON scat.id = st.sport_category_id
    CROSS JOIN LATERAL generate_series(1, scat.team_capacity + 2) AS slot_num
    WHERE sc.is_national_representation = FALSE
) es
JOIN (
    SELECT
        ssn,
        sport_category_id,
        ROW_NUMBER() OVER (
            PARTITION BY sport_category_id
            ORDER BY random()
        ) AS sp_rn
    FROM sportsperson
) sp ON sp.sport_category_id = es.sport_category_id
    AND sp.sp_rn = es.global_slot;

--reprezentaciski contracti
INSERT INTO sportsperson_contract (player_ssn, club_id, start_date, end_date, payout)
SELECT
    sp.ssn,
    es.club_id,
    (CURRENT_DATE - (INTERVAL '1 year' * random() + INTERVAL '6 years'))::date,
    NULL,
    (50000 + random() * 200000)::int
FROM (
    SELECT
        st.id AS team_id,
        st.sport_category_id,
        sc.id AS club_id,
        sc.country_id,
        ROW_NUMBER() OVER (
            PARTITION BY st.sport_category_id, sc.country_id
            ORDER BY st.id, slot_num
        ) AS global_slot
    FROM sport_team st
    JOIN sport_club sc ON sc.id = st.club_id
    JOIN sport_category scat ON scat.id = st.sport_category_id
    CROSS JOIN LATERAL generate_series(1, scat.team_capacity + 2) AS slot_num
    WHERE sc.is_national_representation = TRUE
) es
JOIN (
    SELECT
        sp.ssn,
        sp.sport_category_id,
        p.country_id,
        ROW_NUMBER() OVER (
            PARTITION BY sp.sport_category_id, p.country_id
            ORDER BY random()
        ) AS sp_rn
    FROM sportsperson sp
    JOIN person p ON p.ssn = sp.ssn
) sp ON sp.sport_category_id = es.sport_category_id
       AND sp.country_id = es.country_id
       AND sp.sp_rn = es.global_slot
ON CONFLICT DO NOTHING;

-- istoriski insert za kontrakti
INSERT INTO sportsperson_contract (player_ssn, club_id, start_date, end_date, payout)
SELECT
    sp.ssn,
    es.club_id,
    (CURRENT_DATE - (INTERVAL '1 year' * random() + INTERVAL '13 years'))::date,
    (CURRENT_DATE - (INTERVAL '1 year' * random() + INTERVAL '11 years'))::date,
    (5000 + random() * 2000)::int
FROM (
    SELECT
        st.id AS team_id,
        st.sport_category_id,
        sc.id AS club_id,
        ROW_NUMBER() OVER (
            PARTITION BY st.sport_category_id
            ORDER BY st.id, slot_num
        ) AS global_slot
    FROM sport_team st
    JOIN sport_club sc ON sc.id = st.club_id
    JOIN sport_category scat ON scat.id = st.sport_category_id
    CROSS JOIN LATERAL generate_series(1, scat.team_capacity + 2) AS slot_num
    WHERE sc.is_national_representation = FALSE
) es
JOIN (
    SELECT
        ssn,
        sport_category_id,
        ROW_NUMBER() OVER (
            PARTITION BY sport_category_id
            ORDER BY random()
        ) AS sp_rn
    FROM sportsperson
) sp ON sp.sport_category_id = es.sport_category_id
    AND sp.sp_rn = es.global_slot;

CREATE UNLOGGED TABLE tmp_contract_pool AS
SELECT DISTINCT
    spc.player_ssn,
    spc.club_id,
    sp.sport_category_id,
    spc.start_date,
    spc.end_date
FROM sportsperson_contract spc
JOIN sportsperson sp ON sp.ssn = spc.player_ssn
WHERE EXISTS (
    SELECT 1 FROM sport_team st
    WHERE st.club_id = spc.club_id
      AND st.sport_category_id = sp.sport_category_id
);

CREATE INDEX ON tmp_contract_pool(club_id, sport_category_id, start_date);
CREATE INDEX ON tmp_contract_pool(end_date);

CREATE UNLOGGED TABLE tmp_duel_info AS
SELECT
    d.id, d.home_team_id, d.away_team_id, d.sport_category_id,
    d.start_time::date AS duel_date, scat.team_capacity,
    scat.duration_minutes, sc_home.id AS home_club_id,
    sc_away.id AS away_club_id
FROM duel d
JOIN sport_category scat
    ON scat.id = d.sport_category_id
JOIN sport_team st_home
    ON st_home.id = d.home_team_id
JOIN sport_club sc_home
    ON sc_home.id = st_home.club_id
JOIN sport_team st_away
    ON st_away.id = d.away_team_id
JOIN sport_club sc_away
    ON sc_away.id = st_away.club_id
WHERE d.start_time < NOW();

CREATE INDEX ON tmp_duel_info(id);
CREATE INDEX ON tmp_duel_info(home_club_id, sport_category_id);
CREATE INDEX ON tmp_duel_info(away_club_id, sport_category_id);

SELECT di.id, di.home_club_id, di.sport_category_id, cp.player_ssn
FROM tmp_duel_info di
JOIN LATERAL (
    SELECT player_ssn
    FROM tmp_contract_pool cp
    WHERE cp.club_id = di.home_club_id
      AND cp.sport_category_id = di.sport_category_id
      AND cp.start_date <= di.duel_date
      AND (cp.end_date IS NULL OR cp.end_date >= di.duel_date)
    ORDER BY cp.player_ssn
    LIMIT di.team_capacity
) cp ON true
WHERE di.id BETWEEN (SELECT MIN(id) FROM tmp_duel_info)
                AND (SELECT MIN(id) FROM tmp_duel_info) + 10
LIMIT 50;

-- zema od aktiven contract so toj klub igrach so taa sportska kategorija
-- 0.05% prob za koga kapacitetot e > 3 nekoj igraah da dobie crven karton ili iskluchuvanje
CREATE OR REPLACE FUNCTION insert_team_roster_batched_fixed()
RETURNS void LANGUAGE plpgsql AS $$
DECLARE
    batch_size  INT := 10000;
    current_id  INT;
    max_id      INT;
    batch_end   INT;
BEGIN
    SELECT MIN(id), MAX(id) INTO current_id, max_id FROM tmp_duel_info;

    WHILE current_id <= max_id LOOP
        batch_end := current_id + batch_size - 1;

        INSERT INTO team_roster (player_ssn, team_id, duel_id, start_time, end_time)
        SELECT
            cp.player_ssn,
            di.home_team_id,
            di.id,
            '00:00:00'::time,
            CASE
                WHEN random() < 0.05 AND di.team_capacity > 3 THEN
                    (INTERVAL '1 second' + random() * ((di.duration_minutes - 0.016) * INTERVAL '1 minute'))::time
                ELSE
                    (di.duration_minutes * INTERVAL '1 minute')::time
            END
        FROM tmp_duel_info di
        JOIN LATERAL (
            SELECT player_ssn
            FROM tmp_contract_pool cp
            WHERE cp.club_id = di.home_club_id
              AND cp.sport_category_id = di.sport_category_id
              AND cp.start_date <= di.duel_date
              AND (cp.end_date IS NULL OR cp.end_date >= di.duel_date)
            ORDER BY cp.player_ssn
            LIMIT di.team_capacity
        ) cp ON true
        WHERE di.id BETWEEN current_id AND batch_end
        ON CONFLICT DO NOTHING;

        INSERT INTO team_roster (player_ssn, team_id, duel_id, start_time, end_time)
        SELECT
            cp.player_ssn,
            di.away_team_id,
            di.id,
            '00:00:00'::time,
            CASE
                WHEN random() < 0.05 AND di.team_capacity > 3 THEN
                    (INTERVAL '1 second' + random() * ((di.duration_minutes - 0.016) * INTERVAL '1 minute'))::time
                ELSE
                    (di.duration_minutes * INTERVAL '1 minute')::time
            END
        FROM tmp_duel_info di
        JOIN LATERAL (
            SELECT player_ssn
            FROM tmp_contract_pool cp
            WHERE cp.club_id = di.away_club_id
              AND cp.sport_category_id = di.sport_category_id
              AND cp.start_date <= di.duel_date
              AND (cp.end_date IS NULL OR cp.end_date >= di.duel_date)
            ORDER BY cp.player_ssn
            LIMIT di.team_capacity
        ) cp ON true
        WHERE di.id BETWEEN current_id AND batch_end
        ON CONFLICT DO NOTHING;

        RAISE NOTICE 'Done duels % – %, roster count: %',
            current_id, batch_end,
            (SELECT COUNT(*) FROM team_roster);

        current_id := current_id + batch_size;
    END LOOP;
END;
$$;
select insert_team_roster_batched_fixed();

-- score pushta generate series od duel za scorot i soodvetno stava na igrachi shto se na terenot
CREATE UNLOGGED TABLE tmp_score_data AS
SELECT
    d.id AS duel_id,
    d.home_team_id,
    d.away_team_id,
    d.home_team_score,
    d.away_team_score,
    scat.duration_minutes
FROM duel d
JOIN sport_category scat ON scat.id = d.sport_category_id
WHERE d.start_time < NOW()
  AND (d.home_team_score > 0 OR d.away_team_score > 0);

CREATE INDEX ON tmp_score_data(duel_id);

CREATE UNLOGGED TABLE tmp_roster_data AS
SELECT
    tr.duel_id,
    tr.team_id,
    tr.player_ssn,
    tr.start_time,
    tr.end_time
FROM team_roster tr
WHERE EXISTS (
    SELECT 1 FROM tmp_score_data sd WHERE sd.duel_id = tr.duel_id
);

CREATE INDEX ON tmp_roster_data(duel_id, team_id, start_time, end_time);

INSERT INTO score (duel_id, player_ssn, time_score)
SELECT
    sd.duel_id,
    roster.player_ssn,
    roster.time_score
FROM tmp_score_data sd
CROSS JOIN generate_series(1, sd.home_team_score) AS gs(goal_num)
JOIN LATERAL (
    SELECT
        tr.player_ssn,
        scored_at.t AS time_score
    FROM (
        SELECT (random() * sd.duration_minutes * INTERVAL '1 minute')::time AS t
    ) scored_at
    JOIN tmp_roster_data tr
        ON tr.duel_id = sd.duel_id
       AND tr.team_id = sd.home_team_id
       AND tr.start_time <= scored_at.t
       AND tr.end_time >= scored_at.t
    ORDER BY random()
    LIMIT 1
) roster ON true
ON CONFLICT DO NOTHING;

INSERT INTO score (duel_id, player_ssn, time_score)
SELECT
    sd.duel_id,
    roster.player_ssn,
    roster.time_score
FROM tmp_score_data sd
CROSS JOIN generate_series(1, sd.away_team_score) AS gs(goal_num)
JOIN LATERAL (
    SELECT
        tr.player_ssn,
        scored_at.t AS time_score
    FROM (
        SELECT (random() * sd.duration_minutes * INTERVAL '1 minute')::time AS t
    ) scored_at
    JOIN tmp_roster_data tr
        ON tr.duel_id = sd.duel_id
       AND tr.team_id = sd.away_team_id
       AND tr.start_time <= scored_at.t
       AND tr.end_time >= scored_at.t
    ORDER BY random()
    LIMIT 1
) roster ON true
ON CONFLICT DO NOTHING;

DROP TABLE tmp_score_data;
DROP TABLE tmp_roster_data;

-- refeering duel zema random federacija ako nema competition
-- ako e nacionalna liga zema ref shto chlenuva vo taa federacija shto organizira ligata
CREATE UNLOGGED TABLE tmp_duel_federation AS
SELECT
    d.id AS duel_id,
    d.sport_category_id,
    COALESCE(
        c.organizer_federation_id,
        (
            SELECT f.id
            FROM federation f
            JOIN sport_category scat ON scat.sport_id = f.sport_id
            WHERE scat.id = d.sport_category_id
            ORDER BY random()
            LIMIT 1
        )
    ) AS federation_id
FROM duel d
LEFT JOIN competition c ON c.id = d.competition_id;

CREATE INDEX ON tmp_duel_federation(duel_id);
CREATE INDEX ON tmp_duel_federation(sport_category_id, federation_id);

CREATE UNLOGGED TABLE tmp_ref_assignment AS
WITH ranked_duels AS (
    SELECT
        df.duel_id,
        df.sport_category_id,
        df.federation_id,
        ROW_NUMBER() OVER (
            PARTITION BY df.sport_category_id, df.federation_id
            ORDER BY d.start_time
        ) AS duel_rn
    FROM tmp_duel_federation df
    JOIN duel d ON d.id = df.duel_id
),
ranked_refs AS (
    SELECT
        r.ssn,
        r.sport_category_id,
        r.federation_id,
        ROW_NUMBER() OVER (
            PARTITION BY r.sport_category_id, r.federation_id
            ORDER BY random()
        ) AS ref_rn
    FROM referee r
)
SELECT
    rd.duel_id,
    rr.ssn AS referee_ssn
FROM ranked_duels rd
JOIN ranked_refs rr
    ON rr.sport_category_id = rd.sport_category_id
    AND rr.federation_id = rd.federation_id
    AND rr.ref_rn = ((rd.duel_rn - 1) % 100) + 1;

CREATE INDEX ON tmp_ref_assignment(duel_id);

INSERT INTO refereeing_duel (referee_ssn, duel_id)
SELECT referee_ssn, duel_id
FROM tmp_ref_assignment
ON CONFLICT DO NOTHING;

DROP TABLE tmp_duel_federation;
DROP TABLE tmp_ref_assignment;

-- global counts
SELECT 'club_federation' AS tablename, COUNT(*) FROM club_federation UNION ALL
SELECT 'coach', COUNT(*) FROM coach UNION ALL
SELECT 'coaching_team', COUNT(*) FROM coaching_team UNION ALL
SELECT 'competition', COUNT(*) FROM competition UNION ALL
SELECT 'competition_type', COUNT(*) FROM competition_type UNION ALL
SELECT 'country', COUNT(*) FROM country UNION ALL
SELECT 'country_region', COUNT(*) FROM country_region UNION ALL
SELECT 'duel', COUNT(*) FROM duel UNION ALL
SELECT 'federation', COUNT(*) FROM federation UNION ALL
SELECT 'international_federation', COUNT(*) FROM international_federation UNION ALL
SELECT 'national_federation', COUNT(*) FROM national_federation UNION ALL
SELECT 'national_league', COUNT(*) FROM national_league UNION ALL
SELECT 'location', COUNT(*) FROM location UNION ALL
SELECT 'person', COUNT(*) FROM person UNION ALL
SELECT 'referee', COUNT(*) FROM referee UNION ALL
SELECT 'refereeing_duel', COUNT(*) FROM refereeing_duel UNION ALL
SELECT 'region', COUNT(*) FROM region UNION ALL
SELECT 'score', COUNT(*) FROM score UNION ALL
SELECT 'season', COUNT(*) FROM season UNION ALL
SELECT 'season_sport_team', COUNT(*) FROM season_sport_team UNION ALL
SELECT 'sponsor', COUNT(*) FROM sponsor UNION ALL
SELECT 'sponsorship', COUNT(*) FROM sponsorship UNION ALL
SELECT 'sport', COUNT(*) FROM sport UNION ALL
SELECT 'sport_category', COUNT(*) FROM sport_category UNION ALL
SELECT 'sport_club', COUNT(*) FROM sport_club UNION ALL
SELECT 'sport_team', COUNT(*) FROM sport_team UNION ALL
SELECT 'sportsperson', COUNT(*) FROM sportsperson UNION ALL
SELECT 'sportsperson_contract', COUNT(*) FROM sportsperson_contract UNION ALL
SELECT 'team_roster', COUNT(*) FROM team_roster
ORDER BY tablename;

-- dozvolen overlap za reprezentaciski club contract i nerepreznetaciski
SELECT sc.player_ssn, count(*)
FROM sportsperson_contract sc
WHERE sc.end_date IS NULL
GROUP BY sc.player_ssn
HAVING count(*) > 1;