%% Script containing sql create queries
% struct field names correspond to table names
% will not crate tables if they already exist

db.Project = 'CREATE TABLE IF NOT EXISTS `Project` ( `project_id` INT UNSIGNED NOT NULL AUTO_INCREMENT,  `name` VARCHAR(256) NULL,   PRIMARY KEY (`project_id`)) ENGINE = InnoDB;';
db.Animal = 'CREATE TABLE IF NOT EXISTS `Animal` ( `animal_id` INT(11) NOT NULL AUTO_INCREMENT, `project_id` INT UNSIGNED NOT NULL, `genotype` VARCHAR(45) NULL,   `birthdate` DATETIME NULL, `sex` ENUM(''m'', ''f'') NULL, `name` VARCHAR(45) NULL,   `pyrat_id` VARCHAR(45) NULL,   PRIMARY KEY (`animal_id`),   INDEX `fk_Animal_1_idx` (`project_id` ASC),   CONSTRAINT `fk_Animal_1`     FOREIGN KEY (`project_id`)     REFERENCES `Project` (`project_id`)     ON DELETE CASCADE     ON UPDATE CASCADE) ENGINE = InnoDB;';
db.Experiment = 'CREATE TABLE IF NOT EXISTS `Experiment` (   `experiment_id` INT NOT NULL AUTO_INCREMENT,   `project_id` INT UNSIGNED NOT NULL,   `experimenter` VARCHAR(45) NULL, `description` VARCHAR(256) NULL,  PRIMARY KEY (`experiment_id`),   INDEX `fk_Experiment_1_idx` (`project_id` ASC),   CONSTRAINT `fk_Experiment_1`     FOREIGN KEY (`project_id`)     REFERENCES `Project` (`project_id`)     ON DELETE CASCADE     ON UPDATE CASCADE) ENGINE = InnoDB;';
db.Session = 'CREATE TABLE IF NOT EXISTS `Session` (`session_id` INT NOT NULL AUTO_INCREMENT, `animal_id` INT(11) NOT NULL, `experiment_id` INT NOT NULL,`start_date` VARCHAR(10) NOT NULL, `note` VARCHAR(256) NULL, `session_type` ENUM(''behav'', ''rec'', ''both'') NULL, PRIMARY KEY (`session_id`), INDEX `fk_Session_1_idx` (`animal_id` ASC), INDEX `fk_Session_2_idx` (`experiment_id` ASC), CONSTRAINT `fk_Session_1` FOREIGN KEY (`animal_id`) REFERENCES `Animal` (`animal_id`) ON DELETE CASCADE ON UPDATE CASCADE, CONSTRAINT `fk_Session_2` FOREIGN KEY (`experiment_id`) REFERENCES `Experiment` (`experiment_id`) ON DELETE CASCADE ON UPDATE CASCADE) ENGINE = InnoDB;';
db.ProbeType  = 'CREATE TABLE IF NOT EXISTS `ProbeType` (`probe_type_id` INT NOT NULL AUTO_INCREMENT,`type` VARCHAR(45) NOT NULL, PRIMARY KEY (`probe_type_id`))ENGINE = InnoDB;';
db.Amplifier = 'CREATE TABLE IF NOT EXISTS `Amplifier` (`amplifier_id` INT NOT NULL AUTO_INCREMENT, `name` VARCHAR(45) NOT NULL, PRIMARY KEY (`amplifier_id`)) ENGINE = InnoDB;';
db.Remapping = 'CREATE TABLE IF NOT EXISTS `Remapping` (`probe_type_id` INT NOT NULL,`amplifier_id` INT NOT NULL,`probe_channel` INT NULL,`connector_channel` INT NULL,`headstage_channel` INT NULL, INDEX `fk_Remapping_1_idx` (`probe_type_id` ASC),INDEX `fk_Remapping_2_idx` (`amplifier_id` ASC), CONSTRAINT `fk_Remapping_1`FOREIGN KEY (`probe_type_id`) REFERENCES `ProbeType` (`probe_type_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,CONSTRAINT `fk_Remapping_2`FOREIGN KEY (`amplifier_id`) REFERENCES `Amplifier` (`amplifier_id`)ON DELETE NO ACTION ON UPDATE NO ACTION)ENGINE = InnoDB;';
db.Probe = 'CREATE TABLE IF NOT EXISTS `Probe` (`probe_id` INT NOT NULL AUTO_INCREMENT, `probe_type_id` INT NOT NULL, `serialnum` VARCHAR(45) NOT NULL, PRIMARY KEY (`probe_id`), INDEX `fk_Probe_1_idx` (`probe_type_id` ASC), CONSTRAINT `fk_Probe_1` FOREIGN KEY (`probe_type_id`) REFERENCES `ProbeType` (`probe_type_id`) ON DELETE NO ACTION ON UPDATE NO ACTION) ENGINE = InnoDB;'; 
db.Recording  = 'CREATE TABLE IF NOT EXISTS `Recording` ( `rec_id` INT NOT NULL AUTO_INCREMENT, `session_id` INT NOT NULL, `probe_id` INT NOT NULL, `amplifier_id` INT NOT NULL, `depth` DOUBLE NOT NULL, `note` VARCHAR(256) NULL, PRIMARY KEY (`rec_id`), INDEX `fk_Recording_1_idx` (`session_id` ASC),   INDEX `fk_Recording_3_idx` (`amplifier_id` ASC),   INDEX `fk_Recording_2_idx` (`probe_id` ASC),   CONSTRAINT `fk_Recording_1` FOREIGN KEY (`session_id`) REFERENCES `Session` (`session_id`) ON DELETE CASCADE ON UPDATE CASCADE, CONSTRAINT `fk_Recording_2` FOREIGN KEY (`probe_id`) REFERENCES `Probe` (`probe_id`) ON DELETE NO ACTION ON UPDATE NO ACTION, CONSTRAINT `fk_Recording_3` FOREIGN KEY (`amplifier_id`) REFERENCES `Amplifier` (`amplifier_id`) ON DELETE NO ACTION  ON UPDATE NO ACTION) ENGINE = InnoDB;';
db.Histology = 'CREATE TABLE IF NOT EXISTS `Histology` (   `histology_id` INT NOT NULL AUTO_INCREMENT,   `rec_id` INT NOT NULL,   `dye` VARCHAR(45) NOT NULL,   `staining` VARCHAR(45) NOT NULL,   `note` VARCHAR(256) NULL,   INDEX `fk_Histology_1_idx` (`rec_id` ASC),   PRIMARY KEY (`histology_id`),   CONSTRAINT `fk_Histology_1`     FOREIGN KEY (`rec_id`)     REFERENCES `Recording` (`rec_id`)     ON DELETE CASCADE     ON UPDATE CASCADE) ENGINE = InnoDB;';
db.Behavior = 'CREATE TABLE IF NOT EXISTS `Behavior` (   `session_id` INT NOT NULL,   `real_x` DOUBLE NOT NULL,   `real_y` DOUBLE NOT NULL,   `virt_x` DOUBLE NOT NULL,   `virt_y` DOUBLE NOT NULL,   `time` DOUBLE NOT NULL,   `virt_end` BINARY(1) NULL DEFAULT 0,   INDEX `fk_Behavior_1_idx` (`session_id` ASC),   CONSTRAINT `fk_Behavior_1`     FOREIGN KEY (`session_id`)     REFERENCES `Session` (`session_id`)     ON DELETE CASCADE     ON UPDATE CASCADE) ENGINE = InnoDB;';
db.Anatomy = 'CREATE TABLE IF NOT EXISTS `Anatomy` (   `histology_id` INT NOT NULL,   `score` DOUBLE NULL,   `location` VARCHAR(45) NOT NULL,   `channel` INT(3) NOT NULL,   INDEX `fk_Anatomy_1_idx` (`histology_id` ASC),   CONSTRAINT `fk_Anatomy_1`     FOREIGN KEY (`histology_id`)     REFERENCES `Histology` (`histology_id`)     ON DELETE CASCADE     ON UPDATE CASCADE) ENGINE = InnoDB;';
db.LFP = 'CREATE TABLE IF NOT EXISTS `LFP` (   `rec_id` INT NOT NULL,   `channel` INT(3) NOT NULL,   `time` DOUBLE NOT NULL,   `aplitude` DOUBLE NOT NULL,   INDEX `fk_LFP_1_idx` (`rec_id` ASC),   CONSTRAINT `fk_LFP_1`     FOREIGN KEY (`rec_id`)     REFERENCES `Recording` (`rec_id`)     ON DELETE NO ACTION     ON UPDATE NO ACTION) ENGINE = InnoDB;';
db.Juxta = 'CREATE TABLE IF NOT EXISTS `Juxta` (   `rec_id` INT NOT NULL,   `channel` ENUM(''rec'', ''drive'') NOT NULL,   `time` DOUBLE NOT NULL,   `amplitude` DOUBLE NOT NULL,   CONSTRAINT `fk_Juxta_1`     FOREIGN KEY (`rec_id`)     REFERENCES `Recording` (`rec_id`)     ON DELETE NO ACTION     ON UPDATE NO ACTION) ENGINE = InnoDB;';
db.Patch= 'CREATE TABLE IF NOT EXISTS `Patch` (   `rec_id` INT NOT NULL,   `channel` ENUM(''rec'', ''drive'') NOT NULL,   `time` DOUBLE NOT NULL,   `amplitude` DOUBLE NOT NULL,   INDEX `fk_Patch_1_idx` (`rec_id` ASC),   CONSTRAINT `fk_Patch_1`     FOREIGN KEY (`rec_id`)     REFERENCES `Recording` (`rec_id`)     ON DELETE NO ACTION     ON UPDATE NO ACTION) ENGINE = InnoDB; '; 
db.Shank = 'CREATE TABLE IF NOT EXISTS `Shank` (   `shank_id` INT NOT NULL AUTO_INCREMENT,   `probe_id` INT NOT NULL,   `num_sites` INT NULL,   PRIMARY KEY (`shank_id`),   INDEX `fk_Shank_1_idx` (`probe_id` ASC),   CONSTRAINT `fk_Shank_1`     FOREIGN KEY (`probe_id`)     REFERENCES `Probe` (`probe_id`)     ON DELETE NO ACTION     ON UPDATE NO ACTION) ENGINE = InnoDB; '; 
db.OptoStim = 'CREATE TABLE IF NOT EXISTS `OptoStim` (   `rec_id` INT NOT NULL,   `time` DOUBLE NOT NULL,   `wavelength` DOUBLE NOT NULL,   `shank_id` INT NULL,   INDEX `fk_OptoStim_1_idx` (`rec_id` ASC),   INDEX `fk_OptoStim_2_idx` (`shank_id` ASC),   CONSTRAINT `fk_OptoStim_1`     FOREIGN KEY (`rec_id`)     REFERENCES `Recording` (`rec_id`)     ON DELETE CASCADE     ON UPDATE CASCADE,   CONSTRAINT `fk_OptoStim_2`     FOREIGN KEY (`shank_id`)     REFERENCES `Shank` (`shank_id`)     ON DELETE NO ACTION     ON UPDATE NO ACTION) ENGINE = InnoDB;'; 
db.ElectroStim = 'CREATE TABLE IF NOT EXISTS `ElectroStim` (   `rec_id` INT NOT NULL,   `time` DOUBLE NOT NULL,   `voltage` DOUBLE NOT NULL,   INDEX `fk_ElectroStim_1_idx` (`rec_id` ASC),   CONSTRAINT `fk_ElectroStim_1`     FOREIGN KEY (`rec_id`)     REFERENCES `Recording` (`rec_id`)     ON DELETE CASCADE     ON UPDATE CASCADE) ENGINE = InnoDB; '; 
db.RewardType = 'CREATE TABLE IF NOT EXISTS `RewardType` (   `reward_type_id` INT NOT NULL AUTO_INCREMENT,   `name` VARCHAR(45) NOT NULL UNIQUE, `reward_type` ENUM(''positive'', ''negative'', ''neutral'') NOT NULL,   `note` VARCHAR(256) NULL,   PRIMARY KEY (`reward_type_id`)) ENGINE = InnoDB; '; 
db.Reward = 'CREATE TABLE IF NOT EXISTS `Reward` (   `session_id` INT NOT NULL,   `reward_type_id` INT NOT NULL,   `time` DOUBLE NOT NULL,   INDEX `fk_Reward_1_idx` (`session_id` ASC),   INDEX `fk_Reward_2_idx` (`reward_type_id` ASC),   CONSTRAINT `fk_Reward_1`     FOREIGN KEY (`session_id`)     REFERENCES `Session` (`session_id`)     ON DELETE CASCADE     ON UPDATE CASCADE,   CONSTRAINT `fk_Reward_2`     FOREIGN KEY (`reward_type_id`)     REFERENCES `RewardType` (`reward_type_id`)     ON DELETE NO ACTION     ON UPDATE NO ACTION) ENGINE = InnoDB; ';
db.StereotacticInjection = 'CREATE TABLE IF NOT EXISTS `StereotacticInjection` (   `animal_id` INT NOT NULL,   `virus_name` VARCHAR(256) NULL,   `x_coord` DOUBLE NULL,   `y_coord` DOUBLE NULL,   `date` DATETIME NULL,   `volume` DOUBLE NULL,   `target` VARCHAR(45) NULL,   INDEX `fk_StereotacticInjection_1_idx` (`animal_id` ASC),   CONSTRAINT `fk_StereotacticInjection_1`     FOREIGN KEY (`animal_id`)     REFERENCES `Animal` (`animal_id`)     ON DELETE CASCADE     ON UPDATE CASCADE) ENGINE = InnoDB; '; 
db.DrugInjection = 'CREATE TABLE IF NOT EXISTS `DrugInjection` (   `rec_id` INT NOT NULL,   `drug` VARCHAR(256) NOT NULL,   `time` DOUBLE NOT NULL,   `volume` DOUBLE NULL,   `type` ENUM(''IP'', ''IC'', ''SC'', ''IM'') NULL,   INDEX `fk_DrugInjection_1_idx` (`rec_id` ASC),   CONSTRAINT `fk_DrugInjection_1`     FOREIGN KEY (`rec_id`)     REFERENCES `Recording` (`rec_id`)     ON DELETE CASCADE     ON UPDATE CASCADE) ENGINE = InnoDB; '; 
db.SitePosition = 'CREATE TABLE IF NOT EXISTS `SitePosition` (   `shank_id` INT NOT NULL,   `x_pos` INT UNSIGNED NOT NULL,   `y_pos` INT UNSIGNED NOT NULL,   `site_num` INT NOT NULL,   INDEX `fk_SitePosition_1_idx` (`shank_id` ASC),   CONSTRAINT `fk_SitePosition_1`     FOREIGN KEY (`shank_id`)     REFERENCES `Shank` (`shank_id`)     ON DELETE NO ACTION     ON UPDATE NO ACTION) ENGINE = InnoDB; '; 
