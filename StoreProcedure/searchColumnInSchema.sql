CREATE PROCEDURE `searchColumnInSchema`(IN old_id INT, IN new_id INT, IN updateRecords TINYINT)
BEGIN
    DECLARE finished INTEGER DEFAULT 0;
	DECLARE tName    VARCHAR(255);
	DECLARE errState TINYINT;

	DECLARE zoneCur CURSOR FOR
		SELECT
			TABLE_NAME AS 'TableName'
		FROM
			INFORMATION_SCHEMA.COLUMNS
		WHERE
			COLUMN_NAME = "SPECIFIC_COLUMN_NAME" AND TABLE_SCHEMA = "SCHEMA_NAME_TO_SEARCH";
	
    DECLARE CONTINUE HANDLER FOR SQLEXCEPTION    
		BEGIN
			SET errState = TRUE;
			SELECT "Something went wrong. Please check error logs.";
		END;

    OPEN zoneCur;
        returnRows: LOOP
			FETCH zoneCur INTO tName;

			IF finished = 1 THEN 
				LEAVE returnRows;
			END IF;
            
            SET     @s1 = CONCAT('SELECT \'', tName, '\' AS TABLE_NAME, ', tName ,'.* FROM ', tName, ' WHERE ', tName, '.SPECIFIC_COLUMN_NAME_TO_UPDATE = ', old_id); 
            PREPARE q1 FROM @s1;
            EXECUTE q1;
            
			DEALLOCATE PREPARE q1;
            
            IF updateRecords = TRUE AND errState = FALSE THEN 
				SET     @s2 = CONCAT('UPDATE ', tName, ' SET SPECIFIC_COLUMN_NAME_TO_UPDATE = ', new_id, ' WHERE SPECIFIC_COLUMN_NAME_TO_UPDATE = ', old_id); 
				PREPARE q2 FROM @s2;
				EXECUTE q2;
                
				DEALLOCATE PREPARE q2;
			END IF;
            SET errState = FALSE;
		END LOOP returnRows;
	CLOSE zoneCur;
END
