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

--Administador (quem insere Farmácias e Hospitais/Clínicas)
Create Table Administrador (
	ID_Adm INT IDENTITY Not null,
	Nome_Adm Varchar(50) Not null,
	Senha_Adm Varchar(12) Not null,
	PRIMARY KEY(ID_Adm)
);

-- Farmácia
Create Table Farmacia (
	CNPJ_Farma INT Not null,
	Autorizacao_de_Funcionamento VarBinary(max) Not null,
	Senha_Farma Varchar(15) Not null,
	Nome_Farma Varchar(30) Not null,
	PRIMARY KEY (CNPJ_Farma)
);

--Hospital ou Clínica
Create Table HospitalClinica (
	CNPJ_Hos INT Not null,
	Alvara VarBinary(max) Not null,
	Senha_HospCli Varchar(15) Not null,
	Nome_HosCli Varchar(30) Not null,
	PRIMARY KEY (CNPJ_Hos)
);

--Profissional da saúde (trabalha em hospital ou clínica)
Create Table Profissional_Da_Saude(
	CRM INT Not null,
	Administrador BIT Not null,
	Senha_Prof Varchar(15) Not null,
	Nome_Prof Varchar(45) Not null,
	CNPJ INT Not null,
	Primary Key (CRM),
	Foreign Key (CNPJ) References HospitalClinica(CNPJ_Hos)
);
--Farmaceutico (trabalha na farmácia)
Create Table Farmaceutico (
	ID_Farmaceutico INT Identity Not null,
	Administrador BIT Not null,
	Senha_Farmaceutico Varchar(15) Not null,
	Nome_Farmaceutico Varchar(45) Not null,
	CNPJ_Farma INT Not null,
	Primary Key (ID_Farmaceutico),
	Foreign Key (CNPJ_Farma) References Farmacia(CNPJ_Farma)
);

--Usuário/Paciente
Create Table Usuario (
	CPF INT Not null,
	Nome_Usuario Varchar(45) Not null,
	Nome_Social Varchar(45),
	Senha_Usu Varchar(15) Not null,
	Email Varchar(45),
	Telefone INT,
	Primary Key (CPF)
);

--Receita
Create Table Receita (
	ID_Receita INT Identity Not null,
	Data_Receita Date Not null,
	Data_Validade Date,
	CRM INT Not null,
	CPF INT Not null,
	Medicamento Varchar(25) Not null,
	Baixas INT,
	Primary Key (ID_Receita),
	Foreign Key (CRM) References Profissional_Da_Saude(CRM),
	Foreign Key (CPF) References Usuario(CPF)
);

--Histórico do usuário
Create Table Historico_Medico (
	ID_Historico INT Identity Not null,
	Historico VarBinary(max),
	CPF INT Not null,
	Primary Key (ID_Historico),
	Foreign Key (CPF) References Usuario(CPF)
);

--Chat
Create Table Chat (
	ID_Chat INT Identity Not null,
	Primary Key (ID_Chat)
);

--Texto do Chat
Create Table Mensagem (
	CPF INT,
	CRM INT,
	ID_Chat INT,
	Texto Varchar(200),
	Foreign Key (CPF) References Usuario(CPF),
	Foreign Key (CRM) References Profissional_Da_Saude(CRM),
	Foreign Key (ID_Chat) References Chat(ID_Chat)
);

/*
	
		*/