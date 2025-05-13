use master
go

IF EXISTS (SELECT name FROM master.dbo.sysdatabases WHERE name = 'Automacia')
	DROP DATABASE Automacia;

CREATE DATABASE Automacia;
go

use Automacia;
go
Set dateformat DMY;

go

--Farmácia/Hospital/Clínica
Create Table Contratante (
	CNPJ INT Not null,
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
	CNPJ INT Not null,
	Senha_Funcionario Varchar(12) Not null,
	Nome_Funcionario Varchar(50) Not null,
	Primary Key (ID_Funcionario),
	Foreign Key (ID_Tipo_Funcionario) References Tipo_Funcionario(ID_Tipo_Funcionario),
	Foreign Key (CNPJ) References Contratante(CNPJ)
);

--Paciente
Create Table Paciente (
	CPF INT Not null,
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
	CPF INT Not null,
	Medicamento Varchar(100) Not null,
	Baixar INT,
	Primary Key (ID_Receita),
	Foreign Key (ID_Funcionario) References Funcionario(ID_Funcionario),
	Foreign Key (CPF) References Paciente(CPF)
);

--Historico Medico
Create Table Historico_Medico (
	ID_Historico INT Identity Not null,
	CPF INT Not null,
	Registro_Medico VarBinary(max) Not null,
	Primary Key (ID_Historico),
	Foreign Key (CPF) References Paciente(CPF)
);

--Chat
Create Table Chat (
	ID_Chat INT Identity Not null,
	Primary Key (ID_Chat)
);

--Mensagem
Create Table Mensagem (
	Identificador INT Not null,
	ID_Chat INT Not null
);

/*
Como Monitorar o identificador o tornando algo que pode ser CPF e ID_Funcionario?
*/