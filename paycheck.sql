CREATE TABLE IF NOT EXISTS paychecks (
  citizenid varchar(50) NOT NULL,
  amount varchar(50) DEFAULT NULL,
  PRIMARY KEY (citizenid)
);