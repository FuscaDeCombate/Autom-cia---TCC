Use master
Go

IF EXISTS (SELECT name FROM master.dbo.sysdatabases WHERE name = 'Automacia')
	DROP DATABASE Automacia;

CREATE DATABASE Automacia;
Go

Use Automacia;

Go

Set dateformat DMY;

Go

--Farmácia/Hospital/Clínica
Create Table Contratante (
	CNPJ Varchar Not null,
	Documentacao VarBinary(max) Not null,
	Nome_Contratante Varchar(50) Not null,
	Senha_Contratante Varchar(12) Not null,
	Primary Key (CNPJ)
);

--Tipo de Funcionário
Create Table Tipo_Funcionario (
	ID_Tipo_Funcionario INT,
	--Tipo_Funcionario Varchar(15),
	Primary Key (ID_Tipo_Funcionario)
);

--Funcionário de Farmácia/Hospital/Clínica
Create Table Funcionario (
	ID_Funcionario INT Not null,
	ID_Tipo_Funcionario INT Not null,
	CNPJ Varchar Not null,
	Senha_Funcionario Varchar(12) Not null,
	Nome_Funcionario Varchar(50) Not null,
	Primary Key (ID_Funcionario),
	Foreign Key (ID_Tipo_Funcionario) References Tipo_Funcionario(ID_Tipo_Funcionario),
	Foreign Key (CNPJ) References Contratante(CNPJ)
);

--Paciente
Create Table Paciente (
	CPF Varchar Not null,
	Senha_Paciente Varchar(12) Not null,
	Email Varchar(45),
	Nome_Paciente Varchar(50) Not null,
	Nome_Social Varchar(50) Not null,
	Primary Key (CPF)
);

--Receita
Create Table Receita (
	ID_Receita INT Identity Not null,
	Data_Receita Date Not null,
	Data_Validade Date Not null,
	ID_Funcionario INT Not null,
	CPF Varchar Not null,
	Medicamento Varchar(100) Not null,
	Baixas INT,
	Primary Key (ID_Receita),
	Foreign Key (ID_Funcionario) References Funcionario(ID_Funcionario),
	Foreign Key (CPF) References Paciente(CPF)
);

--Historico Medico
Create Table Historico_Medico (
	ID_Historico INT Identity Not null,
	CPF Varchar Not null,
	Registro_Medico VarBinary(max) Not null,
	Primary Key (ID_Historico),
	Foreign Key (CPF) References Paciente(CPF)
);

--Mensagem
Create Table Mensagem (
	ID_Chat INT Not null,
	CPF Varchar,
	ID_Funcionario INT,
	Primary Key (ID_Chat),
	Foreign Key (CPF) References Paciente(CPF),
	Foreign Key (ID_Funcionario) References Funcionario(ID_Funcionario)
);

/*
Como Monitorar o identificador o tornando algo que pode ser CPF e ID_Funcionario?
*/

Go

Create Index IDX_CNPJ On Contratante(CNPJ);
Create Index IDX_CPF On Paciente(CPF);
Create Index IDX_ID_Funcionario On Funcionario(ID_Funcionario);
Create Index IDX_ID_Receita On Receita(ID_Receita);
Create Index IDX_ID_Historico On Historico_Medico(ID_Historico);
Create Index IDX_ID_Chat On Mensagem(ID_Chat);

Go

/* Valida CPF
Crédito: Cristiano Martins Alves

CREATE FUNCTION CPF_VALIDO(@CPF VARCHAR(11)) RETURNS CHAR(1)
AS
BEGIN
  DECLARE @INDICE INT,
          @SOMA INT,
          @DIG1 INT,
          @DIG2 INT,
          @CPF_TEMP VARCHAR(11),
          @DIGITOS_IGUAIS CHAR(1),
          @RESULTADO CHAR(1)
          
  SET @RESULTADO = 'N'

  /*
      Verificando se os digitos são iguais
      A Principio CPF com todos o números iguais são Inválidos
      apesar de validar o Calculo do digito verificado
      EX: O CPF 00000000000 é inválido, mas pelo calculo
      Validaria
  */

  SET @CPF_TEMP = SUBSTRING(@CPF,1,1)

  SET @INDICE = 1
  SET @DIGITOS_IGUAIS = 'S'

  WHILE (@INDICE <= 11)
  BEGIN
    IF SUBSTRING(@CPF,@INDICE,1) <> @CPF_TEMP
      SET @DIGITOS_IGUAIS = 'N'
    SET @INDICE = @INDICE + 1
  END;

  --Caso os digitos não sejão todos iguais Começo o calculo do digitos
  IF @DIGITOS_IGUAIS = 'N'
  BEGIN
    --Cálculo do 1º dígito
    SET @SOMA = 0
    SET @INDICE = 1
    WHILE (@INDICE <= 9)
    BEGIN
      SET @Soma = @Soma + CONVERT(INT,SUBSTRING(@CPF,@INDICE,1)) * (11 - @INDICE);
      SET @INDICE = @INDICE + 1
    END

    SET @DIG1 = 11 - (@SOMA % 11)

    IF @DIG1 > 9
      SET @DIG1 = 0;

    -- Cálculo do 2º dígito }
    SET @SOMA = 0
    SET @INDICE = 1
    WHILE (@INDICE <= 10)
    BEGIN
      SET @Soma = @Soma + CONVERT(INT,SUBSTRING(@CPF,@INDICE,1)) * (12 - @INDICE);
      SET @INDICE = @INDICE + 1
    END

    SET @DIG2 = 11 - (@SOMA % 11)

    IF @DIG2 > 9
      SET @DIG2 = 0;

    -- Validando
    IF (@DIG1 = SUBSTRING(@CPF,LEN(@CPF)-1,1)) AND (@DIG2 = SUBSTRING(@CPF,LEN(@CPF),1))
      SET @RESULTADO = 'S'
    ELSE
      SET @RESULTADO = 'N'
  END
  RETURN @RESULTADO
END
*/