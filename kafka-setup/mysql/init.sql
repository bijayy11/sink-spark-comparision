-- CREATE TABLE IF NOT EXISTS sensor_data (
--   id INT PRIMARY KEY,
--   latitude DOUBLE,
--   longitude DOUBLE,
--   temperature DOUBLE
-- );

CREATE TABLE IF NOT EXISTS sensor_data (
  id INT PRIMARY KEY,
  latitude DOUBLE,
  longitude DOUBLE,
  temperature DOUBLE,
  ts_produced DATETIME,
  ts_ingested TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS `test-topic` (
  id INT PRIMARY KEY,
  latitude DOUBLE,
  longitude DOUBLE,
  temperature DOUBLE,
  ts_produced DATETIME,
  ts_ingested TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);


CREATE TABLE sensor_data_changes (
  change_id INT AUTO_INCREMENT PRIMARY KEY,
  operation_type ENUM('INSERT', 'UPDATE', 'DELETE'),
  id INT,
  latitude DOUBLE,
  longitude DOUBLE,
  temperature DOUBLE,
  ts_produced DATETIME,
  ts_ingested TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS `test-topic-changes` (
    
  change_id INT AUTO_INCREMENT PRIMARY KEY,
  operation_type ENUM('INSERT', 'UPDATE', 'DELETE'),
  id INT,
  latitude DOUBLE,
  longitude DOUBLE,
  temperature DOUBLE,
  ts_produced DATETIME,
  ts_ingested TIMESTAMP DEFAULT CURRENT_TIMESTAMP
  
);

DELIMITER //

CREATE TRIGGER trg_sensor_data_insert AFTER INSERT ON sensor_data
FOR EACH ROW BEGIN
  INSERT INTO sensor_data_changes(operation_type, id, latitude, longitude, temperature, ts_produced)
  VALUES ('INSERT', NEW.id, NEW.latitude, NEW.longitude, NEW.temperature, NEW.ts_produced);
END //

CREATE TRIGGER trg_sensor_data_update AFTER UPDATE ON sensor_data
FOR EACH ROW BEGIN
  INSERT INTO sensor_data_changes(operation_type, id, latitude, longitude, temperature, ts_produced)
  VALUES ('UPDATE', NEW.id, NEW.latitude, NEW.longitude, NEW.temperature, NEW.ts_produced);
END //

CREATE TRIGGER trg_sensor_data_delete AFTER DELETE ON sensor_data
FOR EACH ROW BEGIN
  INSERT INTO sensor_data_changes(operation_type, id, latitude, longitude, temperature, ts_produced)
  VALUES ('DELETE', OLD.id, OLD.latitude, OLD.longitude, OLD.temperature, OLD.ts_produced);
END //

DELIMITER ;

DELIMITER //

CREATE TRIGGER trg_test_data_insert AFTER INSERT ON `test-topic`
FOR EACH ROW BEGIN
  INSERT INTO `test-topic-changes`(operation_type, id, latitude, longitude, temperature, ts_produced)
  VALUES ('INSERT', NEW.id, NEW.latitude, NEW.longitude, NEW.temperature, NEW.ts_produced);
END //

CREATE TRIGGER trg_test_data_update AFTER UPDATE ON `test-topic`
FOR EACH ROW BEGIN
  INSERT INTO `test-topic-changes`(operation_type, id, latitude, longitude, temperature, ts_produced)
  VALUES ('UPDATE', NEW.id, NEW.latitude, NEW.longitude, NEW.temperature, NEW.ts_produced);
END //

CREATE TRIGGER trg_test_data_delete AFTER DELETE ON `test-topic`
FOR EACH ROW BEGIN
  INSERT INTO `test-topic-changes`(operation_type, id, latitude, longitude, temperature, ts_produced)
  VALUES ('DELETE', OLD.id, OLD.latitude, OLD.longitude, OLD.temperature, OLD.ts_produced);
END //


DELIMITER ;

CREATE USER 'debezium'@'%' IDENTIFIED BY 'dbz';
GRANT SELECT, RELOAD, SHOW DATABASES, REPLICATION SLAVE, REPLICATION CLIENT ON *.* TO 'debezium'@'%';
FLUSH PRIVILEGES;
