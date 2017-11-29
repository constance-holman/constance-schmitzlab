%% Script containing sql create queries
% struct field names correspond to table names
% will not crate tables if they already exist

db.Project = 'CREATE TABLE IF NOT EXISTS `Project` ( `project_id` INT UNSIGNED NOT NULL AUTO_INCREMENT,  `name` VARCHAR(256) NULL,   PRIMARY KEY (`project_id`)) ENGINE = InnoDB;';
db.Animal = 'CREATE TABLE IF NOT EXISTS `Animal` ( `animal_id` INT(11) NOT NULL, `project_id` INT UNSIGNED NOT NULL, `genotype` VARCHAR(45) NULL,   `birthdate` DATETIME NULL,   `sex` ENUM(''m'', ''f'') NULL,   `name` VARCHAR(45) NULL,   `pyrat_id` VARCHAR(45) NULL,   PRIMARY KEY (`animal_id`),   INDEX `fk_Animal_1_idx` (`project_id` ASC),   CONSTRAINT `fk_Animal_1`     FOREIGN KEY (`project_id`)     REFERENCES `Project` (`project_id`)     ON DELETE CASCADE     ON UPDATE CASCADE) ENGINE = InnoDB;';
db.Experiment = 'CREATE TABLE IF NOT EXISTS `Experiment` (   `experiment_id` INT NOT NULL,   `project_id` INT UNSIGNED NOT NULL,   `experimenter` VARCHAR(45) NULL,   `description` VARCHAR(256) NULL,   PRIMARY KEY (`experiment_id`),   INDEX `fk_Experiment_1_idx` (`project_id` ASC),   CONSTRAINT `fk_Experiment_1`     FOREIGN KEY (`project_id`)     REFERENCES `Project` (`project_id`)     ON DELETE CASCADE     ON UPDATE CASCADE) ENGINE = InnoDB;';