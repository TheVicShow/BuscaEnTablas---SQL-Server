CREATE PROCEDURE Buscaentablas
(
  @Buscar NVARCHAR(100)
) 
AS 
BEGIN 
SET NOCOUNT ON 

  CREATE TABLE #Resultados 
  ( 
     nomcolumna NVARCHAR(400), 
     valcolumna NVARCHAR(4000) 
  ) 

  DECLARE @Tabla      NVARCHAR(256), 
          @NomColumna NVARCHAR(128), 
          @Buscar2    NVARCHAR(128)

  SET @Tabla = '' 
  SET @Buscar2 = Quotename('%' + @Buscar + '%', '''') 

  WHILE @Tabla IS NOT NULL
    BEGIN 
        SET @NomColumna = '' 

        SET @Tabla = (SELECT Min(Quotename(table_schema) + '.' + Quotename(table_name)) 
                      FROM   information_schema.tables 
                      WHERE  table_type = 'BASE TABLE' 
                      AND Quotename(table_schema) + '.' + Quotename(table_name) > @Tabla 
                      AND Objectproperty(Object_id(Quotename(table_schema)+'.'+ Quotename(table_name)) , 'IsMSShipped') = 0) 

        WHILE ( @Tabla IS NOT NULL ) AND ( @NomColumna IS NOT NULL ) 
          BEGIN 
              SET @NomColumna = (SELECT Min(Quotename(column_name)) 
                                 FROM   information_schema.columns 
                                 WHERE  table_schema = Parsename(@Tabla, 2) 
                                        AND table_name = Parsename(@Tabla, 1) 
                                        AND data_type IN ( 'char', 'varchar', 'nchar', 'nvarchar') 
                                        AND Quotename(column_name) > @NomColumna) 

              IF @NomColumna IS NOT NULL 
                BEGIN 
                    INSERT INTO #Resultados 
                    EXEC ( 'SELECT ''' + @Tabla + '.' + @NomColumna + ''', LEFT('+ @NomColumna +', 3630)  
                            FROM ' + @Tabla + ' (NOLOCK) ' + 
                            ' WHERE ' + @NomColumna + ' LIKE ' + @Buscar2) 
                END 
          END 
    END 

    SELECT nomcolumna, 
           valcolumna 
    FROM   #Resultados 
END 
